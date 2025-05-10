---
layout: post
title: "LSP client in Clojure in 200 lines of code"
description: "I wrote a small LSP client, it was kinda neat so I'm sharing it"
---
Awhile ago I was prototyping integrating LLMs with [LSP](https://microsoft.github.io/language-server-protocol/) to enable a language model to answer questions about code while having access to code navigation tools provided by language servers. I wasn't that successful with this prototype, but I found it cool that I could write a minimal LSP client in around 200 lines of code. Of course, it was very helpful that I previously wrote a much more featureful [LSP client for the Defold editor](https://github.com/defold/defold/blob/dev/editor/src/clj/editor/lsp.clj)... So let me share with you a minimal LSP client, written in Clojure, in under 200 lines. Also, at the end of the post, I'll share my thoughts on the LSP.

Who is the target audience of this blog post? I don't even know... Clojure developers writing code editors? There are, like, 3 of us! Okay, let's try to change the scope of this exercise a bit: let's build a command line linter that uses a language server to do the work. Surely that wouldn't be a problem...

# The what

Some terminology and scope first. LSP stands for Language Server Protocol, a standard that defines how some text editor (a language client) should talk to some language-specific tool (a language server) that knows the semantics of a programming language and may provide contextual information like code navigation, refactoring, linting etc.

The main benefit of LSP is that the so called MxN problem of IDEs and languages becomes M+N with LSP. [Here is a good explanation](https://langserver.org/). In short, as a language author, previously you had to write integration for every code editor. Or, as an IDE author, you had to write a separate integration for every language. Now there is a common interface — LSP — and both language authors and IDE authors only need to support this interface.

In 200 LoC, we will implement essential blocks of the [LSP Specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/) that supports programmatic read-only querying of language servers. We will implement:
1. base communication layer between language client and server processes. It is similar to HTTP protocol: client and server talk to each other using byte streams with messages formatted as headers + JSON message bodies. The base layer establishes a way to exchange JSON blobs.
2. [JSON-RPC](https://www.jsonrpc.org/) — a layer on top of the base layer that adds meaning to JSON blobs, turning them into either requests/responses, or notifications.
3. A wrapper around JSON-RPC connection that is a leaving breathing language server we can talk to.

We will use Java 24 with [virtual threads](https://openjdk.org/jeps/425): writing blocking code that performs and scales well is nice, sweet, and performant. Now, here are few things we will not implement:
- JSON parser. I mean come on. We will just use a dependency. I picked [jsonista](https://github.com/metosin/jsonista/) because it's fast and has a cool name.
- Document syncing. When the user opens a file in a text editor and makes some changes to it without saving, the editor notifies running language servers about the new text of the open files. We are not building a text editor here, just a small PoC, so we'll skip this.

Now, Let's go!

# The how

If you just want to look at the code, [here it is](https://github.com/vlaaad/lsp-clj-client/blob/main/src/io/github/vlaaad/lsp.clj). Now I'll walk you through it.

## Base layer

First, we start with a base communication layer. Language server runs in another process, so the communication happens over InputStream + OutputStream pair. We will run the language server as a process and we will communicate via stdin/stdout, so java Process will provide us the pair. Both client and server send and receive HTTP-like requests with JSON blobs. Each individual message looks like this:
```
Content-Length: 14\r\n
\r\n
{"json": true}
```
First, there are 1 or more headers with a required `Content-Length` header, separated with `\r\n`. Then, an empty line. Then comes a JSON string. The headers are serialized using ASCII encoding (so 1 byte is always 1 char), the JSON blob uses UTF-8.

We start with [a function that reads a line of ascii text from InputStream](https://github.com/vlaaad/lsp-clj-client/blob/main/src/io/github/vlaaad/lsp.clj#L12-L23):
```clj
(defn- read-ascii-line [^InputStream in]
  (let [sb (StringBuilder.)]
    (loop [carriage-return false]
      (let [ch (.read in)]
        (if (= -1 ch)
          (if (zero? (.length sb)) nil (.toString sb))
          (let [ch (char ch)]
            (.append sb ch)
            (cond
              (= ch \return) (recur true)
              (and carriage-return (= ch \newline)) (.substring sb 0 (- (.length sb) 2))
              :else (recur false))))))))
```
So, we read characters byte by byte into a string until we get to `\r\n`. If we reached end of stream, we return `nil`. We can't use BufferedReader's `readLine` here for a few reasons:
- it buffers, meaning it might read more than we want.
- it uses both `\n` and `\r\n` as line separators, while we only want `\r\n`.
- it uses a single encoding, while the communication channel uses a mix of ASCII and UTF-8.

The next step is a single function that implements the whole [base communication layer](https://github.com/vlaaad/lsp-clj-client/blob/main/src/io/github/vlaaad/lsp.clj#L25-L56):
```clj
(defn- lsp-base [^InputStream in ^BlockingQueue server-in ^OutputStream out ^BlockingQueue server-out]
  (-> (Thread/ofVirtual)
      (.name "lsp-base-in")
      (.start
        #(loop []
           (when-some [headers (loop [acc {}]
                                 (when-let [line (read-ascii-line in)]
                                   (if (= "" line)
                                     acc
                                     (if-let [[_ field value] (re-matches #"^([^:]+):\s*(.+?)\s*$" line)]
                                       (recur (assoc acc (string/lower-case field) value))
                                       (throw (IllegalStateException. (str "Can't parse header: " line)))))))]
             (let [^String content-length (or (get headers "content-length")
                                              (throw (IllegalStateException. "Required header missing: Content-Length")))
                   len (Integer/valueOf content-length)
                   bytes (.readNBytes in len)]
               (if (= (alength bytes) len)
                 (do (.put server-in (json/read-value (String. bytes StandardCharsets/UTF_8) json/keyword-keys-object-mapper))
                     (recur))
                 (throw (IllegalStateException. "Couldn't read enough bytes"))))))))
  (-> (Thread/ofVirtual)
      (.name "lsp-base-out")
      (.start
        #(while true
           (let [^bytes message-bytes (json/write-value-as-bytes (.take server-out))]
             (doto out
               (.write (.getBytes (str "Content-Length: "
                                       (alength message-bytes)
                                       "\r\nContent-Type: application/vscode-jsonrpc; charset=utf-8\r\n\r\n")
                                  StandardCharsets/UTF_8))
               (.write message-bytes)
               (.flush)))))))
```
This function converts the client/server communication from InputStream+OutputStream pair (bytes) to input+output BlockingQueues of json blobs. The `"lsp-base-in"` part reads headers from the InputStream, then reads a JSON object and finally puts it onto a `server-in` queue. This way, whenever a language server sends us something, we'll get it as a JSON in a queue. The `"lsp-base-out"` is an inverse: it reads JSON objects from `server-out` and writes them to the server. This way, when we will want to send a message to the language server, we will only need to put a JSON value onto a `server-out` queue.

## JSON-RPC layer

LSP client and server exchange JSON blobs in a special format called [JSON-RPC](https://www.jsonrpc.org/specification). The main idea is to agree on the shape and meaning of the exchanged data so that exchanging JSON objects supports these use cases:
1. send a request to perform a specific action and receive a response for this request (aka "remote procedure call")
2. send a notification that does not expect a response

This use case is achieved by exchanging JSON objects with special combinations of fields, i.e.:
1. to send a request, use a JSON object with fields `id` (request identifier) and `method` (action identifier). Optionally, you can provide `params`, i.e. an "argument" to the "method call".
2. to send a notification, use a request, but without the `id` field
3. to respond to a request, send a JSON object with `id` of the received request, and either an `error` or a `result` field, depending on whether we got an error or a successfully produced a result. The error has to be an object with `code` and `message` fields.

Now I'll walk you through the implementation of JSON-RPC protocol, which happens to be [a single function](https://github.com/vlaaad/lsp-clj-client/blob/main/src/io/github/vlaaad/lsp.clj#L58-L121).

We start with this argument list:
```clj
(defn- lsp-jsonrpc [^BlockingQueue client-in ^BlockingQueue server-in ^BlockingQueue server-out handlers] 
  ...)
```
`server-in` and `server-out` are the base layer of the LSP commucation. We will put JSON-RPC objects to `server-out` to send messages to the language server. We will read from `server-in` to receive language server JSON-RPC objects from the language servers. So, what are `client-in` and `handlers`?

`client-in` is another queue that we will use to send requests and notifications to the language server. Our `lsp-jsonrpc` function will take objects from `client-in`, perform some pre-processing, and then will post the JSON-RPC objects to `server-out`. This will enable us to write a simple API to send messages to the language server.

`handler` is a map from JSON-RPC "method name" to a function. When language server decides to notify us about something, or sends us a request, we will lookup a function to handle this notification in the `handlers` map. This enables us to respond to requests from language servers.

The next bit of code in the function "merges" `client-in` and `server-in` into a single queue (`in`):
```clj
  (let [in (SynchronousQueue.)]
    (-> (Thread/ofVirtual)
        (.name "lsp-jsonrpc-client")
        (.start #(while true (.put in [:client (.take client-in)]))))
    (-> (Thread/ofVirtual)
        (.name "lsp-jsonrpc-server")
        (.start #(while true (.put in [:server (.take server-in)]))))
    ...)
```
Now, we can write a single sequential loop that take messages from `in` and handles both messages from "us", i.e. the client, and "them", i.e. remote language server. With virtual threads, this blocking code stays lightweight and performant. On a side note, I think the only reason for [core.async](https://github.com/clojure/core.async/) to exist post JDK 24 is the observability tooling that [flow](https://clojure.github.io/core.async/flow.html) provides. And, maybe, sliding buffers — AFAIK, there are no blocking alternatives to them in the JDK.

Okay, let's move on. The next piece of code in the JSON-RPC implementation is the loop:
```clj
    (-> (Thread/ofVirtual)
        (.name "lsp-jsonrpc")
        (.start
          #(loop [next-id 0
                  requests {}]
             (let [[src message] (.take in)]
               (case src
                  ...)))))
```
We start another lightweight process that handles incoming messages from both language server and client. We need `next-id` and `requests` to support sending requests and then handling the incoming responses to these requests. We are taking from `in`, so `src` is either `:client` or `:server`, and message is a JSON-RPC message. Now, let's start handling stuff! First we'll handle the `:client` case, i.e. messages that we send to the server:
```clj
                 :client (let [out-message (cond-> {:jsonrpc "2.0"
                                                    :method (:method message)}
                                             (contains? message :params)
                                             (assoc :params (:params message)))]
                           (if-let [response-queue (:response message)]
                             (do
                               (.put server-out (assoc out-message :id next-id))
                               (recur (inc next-id) (assoc requests next-id response-queue)))
                             (do
                               (.put server-out out-message)
                               (recur next-id requests))))
```
Remember, we need to support both notifications (don't expect a response) and requests (need a response). We will differentiate between them by using `:response` key on the client messages. The value for the key is going to be a `BlockingQueue` — once we receive a response from the language server, we will put the response value onto this queue. If we are sending a response, we increment the `next-id` counter and store the queue that awaits a response in the in-flight `requests` map. If we are sending a notification, we simply send a JSON-RPC object and continue.

That's it for the client! Now we handle incoming messages from server. There are 3 possible message types:
1. responses to our requests: those have an `id` and either `result` or `error`.
2. notifications: those have `method`, but not `id`
3. requests: those have both `method` and `id`

Here is the `:server` case:
```clj
                 :server (cond
                           ;; response?
                           (and (contains? message :id)
                                (or (contains? message :result)
                                    (contains? message :error)))
                           (let [id (:id message)
                                 ^BlockingQueue response-out (get requests id)]
                             (.put response-out message)
                             (recur next-id (dissoc requests id)))

                           ;; notification?
                           (and (contains? message :method)
                                (not (contains? message :id)))
                           (do
                             (when-let [handler (get handlers (:method message))]
                               (handler (:params message)))
                             (recur next-id requests))

                           ;; request?
                           (and (contains? message :method)
                                (contains? message :id))
                           (do
                             (.put
                               server-out
                               (try
                                 {:jsonrpc "2.0"
                                  :id (:id message)
                                  :result ((get handlers (:method message)) (:params message))}
                                 (catch Throwable e
                                   {:jsonrpc "2.0"
                                    :id (:id message)
                                    :error {:code -32603 :message (or (ex-message e) "Internal Error")}})))
                             (recur next-id requests))

                           :else
                           (do
                             (.put server-out {:jsonrpc "2.0" :id (:id message) :error {:code -32600 :message "Invalid Request"}})
                             (recur next-id requests))))))))))
```
When we receive a response to our request, we put it on the queue stored in the in-flight `requests` map, and remove the queue from the map. When we get a notification, we simply invoke the handler if it exists. Handling requests is a bit different, because we want to ensure the server will always receive a response. So we do a try/catch and always send back something. We do the request handling on the JSON-RPC process thread, so if it blocks for a long time, no other messages are processed. That's actually a downside. So let's just say I kept things simple for illustrative purposes, and spawning one more virtual thread to compute and send a response to the server is left as an exercise for the reader :D

Finally, there is an `:else` branch that responds to unexpected messages with an error. Which, I guess, is unnecessarily defensive given the lack of error handling and validations in other places.

## The API

Now that all communication is implemented, it's time to create an API. We will only need 3 functions:
1. `start!` to start a language server.
2. `request!` to send a request to the language server and get a result back
3. `notify!` to send a notification to the language server and get nothing back

Let's start with `start!`-ing a server:
```clj
(defn start!
  ([^Process process handlers]
   (start! (.getInputStream process) (.getOutputStream process) handlers))
  ([^InputStream in ^OutputStream out handlers]
   (let [client-in (ArrayBlockingQueue. 16)
         server-in (ArrayBlockingQueue. 16)
         server-out (ArrayBlockingQueue. 16)]
     (lsp-jsonrpc client-in server-in server-out handlers)
     (lsp-base in server-in out server-out)
     client-in)))
```

I made 2 arities for the `start!` function:
1. Helper process arity specifically for process stdio, since this is what is used in 99% of LSP client/server communication implementations. We are going to use it to start the server.
2. Generic arity over InputStream+OutputStream pair. This arity is the one that does the work. LSP allows various transports, e.g. pipes, network sockets, or stdio communication between processes. The generic arity supports it all, you only need to provide the input and output streams. In the setup, I allocate small buffers so if some part of the commucation consumes too slow (or produces too fast), there is some buffering and then backpressure. I don't know if these buffer sizes are any good to be honest, I just made them up. Anyway, here, we call `lsp-jsonrpc` and `lsp-base` to wire everything together, and finally return the `client-in`. Yes, the LSP client object is just a queue. Yes, it probably should be something else, like a custom type, in a proper implementation.

Next step is sending a notification. This is simpler than sending a request because we don't get a response back:
```clj
(defn notify!
  ([^BlockingQueue lsp method]
   (.put lsp {:method method}))
  ([^BlockingQueue lsp method params]
   (.put lsp {:method method :params params})))
```

Finally, sending a request. If you remember, back when we were implementing the `lsp-jsonrpc` function, we agreed that LSP request maps will use a `:response` key with a queue value. Now is the time to do it:
```clj
(defn request!
  ([lsp method]
   (request! lsp method nil))
  ([^BlockingQueue lsp-client method params]
   (let [queue (SynchronousQueue.)]
     (.put lsp-client (cond-> {:method method :response queue} params (assoc :params params)))
     (let [m (.take queue)]
       (if-let [e (:error m)]
         (throw (ex-info (:message e) e))
         (:result m))))))
```
`SynchronousQueue` is a queue with a buffer of size 0. This means every blocking `.take` (which we do here) will wait until someone else (`lsp-jsonrpc` function) puts a value onto the queue. So this is like a promise that we await here. This implementation creates a request map, submits it to the lsp client, and then blocks until a response arrives from the language server. What's extra nice here is that JSON-RPC errors are thrown as java exceptions, and successful results are simply returned as values. As if this is some sort of synchronous "method call". That also performs well because virtual threads. Java 24 is really nice.

Anyway, that's it! We now can start language servers and do stuff with them! Yay, we implemented an LSP client, all in 150 (not even 200) lines of code! 

Yay?

You might feel a bit let down now because everything we did — base and jsonrpc layer — although required for the LSP, don't actually have anything to do with actual language servers. But it's so nice and short and focused! Oh, well. Now, I guess, the time has come to destroy all this beauty by actually trying to use a language server. After all, we still have a budget for 50 more LoC.

# The ugly linter

Let's discuss the language server lifecycle first. When client starts a language server, it's not actually immediately ready for use. Now we are entering the real LSP integration territory. We have to initialize it (a request), then notify it that it's initialized (a notification), then use it (issue 0 or more requests or notifications), then shut it down (a request), and then finally notify it so it can exit (one more notification). The initialization process is necessary to exchange **capabilities**: the client says what it can do, and then the server says what it can do, and LSP demands both client and server to honor what they said to each other. For example, a proper language client (like a text editor, not the toy that we build here) might say "I will ask you about code completion, but please don't notify me about your linting since I don't support displaying squiggly lines yet", and the server might say "I can provide both code completion and notify you about code issues as you type, but I won't do that since you don't support it". 

All capabilities are defined in the LSP specification, and almost all of them are optional to implement. This allows for both LSP client and server developers to build the support gradually over time. For example, in [Defold editor](https://defold.com/), the LSP support story started only with displaying *diagnostics* (this is the term LSP specification uses for linting squigglies), and then was gradually expanded to code completion, hovers and symbol renaming.

Let's see what we have in stock for diagnostics. A diagnostic is a data describing the code issue. It has a text range (something like "from line 20 char 5 to line 20 char 10"), severity (warning/error etc.) and a text message.
LSP specification defines these 2 methods that we could use to get diagnostics from the language server:
1. [document diagnostics](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_diagnostic): a client may request a server to lint a particular file and return a result.
2. [workspace diagnostics](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_diagnostic): a client may request a server to lint the whole project and return a result.

So, with these 2 methods at hand, and with our nice LSP client implementation, we could sketch a linting function that does linting using roughly this algorithm:
1. start a server
2. initialize it, telling the server that we may ask it for workspace and document diagnostics
3. if server supports workspace diagnostics, we use that; if server supports document diagnostics, we list all files in a project and ask it to lint them; otherwise, we report an error that the server can't do what we want it to do.
4. we shut down the server

Should be easy. Really, it should be this easy! It should be easy!!! Why isn't it this easy?!?!..

Okay.

Here comes the ugly part.

When preparing this post, I went through a lot of language servers to use as an example. I only needed one of them to implement either of the methods. But no. Not single one of them did. All these language servers that boast that they provide diagnostics. They are not even lying. But! They don't actually implement diagnostics on request. You see, there is a third way language servers can use to provide these pesky little squigglies. They can post them, out of the blue, whenever they want, as a notification. No way to ask them about it. And that's what they do. All of them. And they do it, mostly, as a response to 2 specific notifications from the client: when the client notifies the server that it opened a document, and when the client notifies the server that a text of an open document has changed. This notification approach existed first, and every language server implementor just uses it because it's easy and it works and everything else is unnecessary. It makes total sense for a text editor: most of the time, you are only interested in squigglies for the file you are editing, while you are editing it. But unfortunately it means that I can't make a nice example of using our tiny language client to do something useful without building a full-blown text editor — all the other features only make sense in the code editing context where we have cursors and text selection and we can ask a language server about this thing on this line.

So. It's going to be ugly. But this not a problem of the LSP specification. It's just that I got unlucky with the example that I wanted to use. Instead of this simple straightforward request/response thing I'm going to do something awful. I'll start a language server. I will initialize it, saying only that I am open to receiving diagnostic notifications. I will ignore server capabilities completely because at this point why bother. And then I will open every file in a project, and then I'll wait a bit to receive diagnostic notifications, and then I'll shut this abomination down. I'm not going to explain all the code, because it's so awful, but [here it is in all it's glory](https://github.com/vlaaad/lsp-clj-client/blob/main/src/io/github/vlaaad/lsp.clj#L156-L200). Here, I'll only show the good parts.

We start with a function signature:
```clj
(defn lint [& {:keys [cmd path ext]}] 
  ...)
```
The function takes an LSP shell `cmd` to run (either a string or a coll of strings), a directory `path` to lint, and a file `ext`ension to select the files to lint. Since the function accepts kv-args, and it's on github, and you are using an up-to-date `clj` tool (aren't you?), you can actually try to run it. Maybe it will even work! For example, you can download [clojure-lsp](https://github.com/clojure-lsp/clojure-lsp/releases), and then run the following command in your project:
```shell
clj -Sdeps '{:deps {io.github.vlaaad/lsp-clj-client {:git/sha "57c618d7ecfc9f94fbef9157cfe4534a4816be45"}}}' \
    -X io.github.vlaaad.lsp/lint \
    :cmd '"/Users/vlaaad/Downloads/clojure-lsp.exe"' \
    :path '"."' \ 
    :ext '"clj"'
```
For the code that we discussed in this post, the output will look like this:
```
file:///Users/vlaaad/Projects/lsp-clj-client/src/io/github/vlaaad/lsp.clj at 168:22:  Redundant let expression.
```
Turns out there is a warning in the `lint` function implementation! But the warning is in a bad, messy part of the code, so there is no point in fixing it in the function. Nothing can fix this function... Anyway, we start a process and then make it a server:
```clj
(let [... ...
      ^Process process (apply process/start {:err :inherit} (if (string? cmd) [cmd] cmd))
      ... ...
      server (start! process {"textDocument/publishDiagnostics" (fn [diagnostics] ...)})]
  ...)
```
We are only going to listen to `textDocument/publishDiagnostics` notification that might be sent by the language server when we open files. At this point, the server is not initialized yet, so we do it next:
```clj
(request! server "initialize" {:processId (.pid (ProcessHandle/current))
                               :rootUri (uri path)
                               :capabilities {:textDocument {:publishDiagnostics {}}}})
```
We issue a blocking `initialize` call, and tell the server our process id (so it can exit if we die before stopping it), which directory is the project root, and what are our capabilities. You are expected to take the return value and check if it e.g. supports the diagnostics, but I decided to skip it in this example. 

Next step: we notify the server that it's `initialized`:
```clj
(notify! server "initialized")
```
Not sure why it's necessary, but the protocol demands it. Then we use the server and print the results (horrors omitted). Then we shut it down:
```clj
(request! server "shutdown")
(notify! server "exit")
```

And that's it!

# Discussion

Okay, let's take a deep breath. I took a deep breath and spent some time reflecting on all this. I like LSP. It's great for the ecosystem: IDEs get better support for more programming languages, and programming languages are easier to integrate into more IDEs. It's not a great protocol for building command line linters: even though the protocol supports it, in reality it's going to be hard to find a server that has the necessary capabilites. But it's much better for building text editors, I promise :)

I built LSP support for the Defold editor. Now that I also spent a bit of time reflecting on it, I'd like to share my opinions on the matter. First of all, integrating diagnostics into the text editor was actually pretty easy, since there was no requirement to explicitly request diagnostics, they just appear and get displayed. That wasn't the complex part. Defold LSP support is much more complex than our toy implementation because a text editor needs to manage the whole zoo of language servers, each with it's own lifecycle, initialization process and capabilities. When implementing the LSP support in a text editor, I found that most of the complexity comes from having to manage this zoo, where each server has different runtime state (starting, running, stopped), and where each of language server processes might decide to die at any point. This complicates, for example, the following:
- Tracking open files with unsaved changes. Not only does the text editor need to notify running language servers when the user opens a files, it should also notify a freshly started (or restarted) servers about all currently open documents. There needs to be book-keeping of open (visible to the user) and unsaved files (not necessarily visible to the user).
- Sending requests to multiple servers at the same time. This might be not immediately obvious, but LSP does not get in the way of running multiple language servers — for the same language, in the same project — simultaneously. VSCode does it. Defold editor does it too. When the editor asks for code completions to present a completion popup, the LSP integration actually asks all capable running language servers for the target language, and then merges the results. Same applies for displaying diagnostics. Having multiple language servers per file is very useful. For example, you might run a language server dedicated to the code analysis and, additionally, a spell checking language server that highlights typos, and the editor will display diagnostics from both in the same file. So, implementing support for sending a request to multiple language servers at once, with different capabilities, where every server might die at any moment, but we still wan't to receive a response from all matching servers, within a time frame, wasn't easy. 

Compared to that, here is a critique of LSP that I've [read about before](https://www.michaelpj.com/blog/2024/09/03/lsp-good-bad-ugly.html), but don't find convincing:
1. Missing causality. The editor changes the code, then immediately asks for something like code actions from the server. It's possible that the server won't have a chance to update it's internal state and will return results for an outdated text state. Or it will post diagnostics that no longer apply. But then it will post the correct ones a bit later. I think it doesn't matter since the problem is easily recoverable with e.g. an undo in a text editor, or with repeating a request, or it will recover itself automatically a bit later. There is no need for strong causalty/consistency guarantees: interactions with language servers are mostly read-only, there is no harm in the thing being a bit lax/late.
2. Different endpoints encode data slightly differently. For example, unsaved changes to text files are communicated incrementally (as diffs), but text document outline (i.e. list of defined classes/functions/modules etc.) is always refreshed in full. I think inconsistencies here don't matter: writing a pre/post processing is easy. Different state synchronization approaches are dictated by the context and there are trade-offs. Text state synchronization should be fast, therefore requiring support for incremental text synchronization for clients and servers is reasonable — we might be editing very large files, we shouldn't constantly send them in full on every change. Outline refreshes, on the other hand, are requested as needed, and not on typing, so there is no need for incremental diffs there.
3. Specification is big. It is, but it doesn't matter: we can opt into into parts of it using capabilities.
4. Weird type definitions. A lot of JSON schema of requests/response is written using Typescript types. Truth be told, I was perplexed by it initially, but I quicky got used to it. It communicates the data shape well enough.

LSP has it's warts and inconsistencies, as every successful protocol that has grown over time. If it was designed from scratch now, it would be simpler, particularly around request and response data shapes. But that's not as hard as e.g. managing the state of the servers, which is an unfortunate consequence of the fact that language servers are separate stateful processes. Perhaps, LSP successor will be not a better protocol for inter-process communication, but a WASM "interface" that will allow writing language servers in-process, synchronous, in whatever language, as long as it compiles to WASM. And then, every code editor will run some WASM runtime. Meanwhile, LSP is infinitely better than building bespoke language integrations, so I'm happy to use it.