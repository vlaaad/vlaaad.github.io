---
layout: post
title: "Reveal, REPLs and networking"
description: "REPL: if you don't know it, you don't know it; if you know it, you enjoy it"
---
I recently got a question whether it's possible to configure [Reveal](vlaaad.github.io/reveal/) in such a way that it works across 3 machines:
- machine A runs editor;
- machine B runs only Reveal;
- machine C runs runs target server.

It also reminded me of [an article](https://suvratapte.com/nREPL-middleware/) I read awhile ago about nREPL middlewares that gives a good overview of how those work, but unfortunately contains a mistake in a section where it discusses Clojure REPL, where it states that:

> there is no easy way to start this REPL on a socket. So if you are using this REPL, you cannot connect to it from remote machines. So the default REPL clearly cannot be used as your daily development REPL. That is where the need for other types of REPLs comes in.

I enjoy using simple tooling, and REPL is a wonderful example of such a concept (it's not a single tool really) that enables a variety of non-trivial use-cases. In this post I'll try to explain what makes it special as well as give an example of using the configurability of REPL.

## What REPL is, what nREPL isn't

REPL is Read-Eval-Print Loop, a programming environment that enables you to interact with a running Clojure program and modify it by evaluating one code expression at a time. An important characteristic of REPL is that every part of REP is independent and thus swappable:
- _Read_ is a protocol on character streams — one of the most widely available and simple transports. You can swap Read easily: consume from standart input, consume from network, consume from pre-recorded REPL interaction to replay it etc;
- _Eval_ is the full power of Clojure, and you can augment it when necessary by e.g. starting new REPLs with [lexical scope](https://github.com/TristeFigure/lexikon/blob/master/src/lexikon/core.clj#L129-L148) which might be seen as a break point on steroids;
- _Print_ is a way to show the output of code evaluation to the user, by default it transforms values to text, but you can do much more than that with a tool like [Reveal](vlaaad.github.io/reveal/) that acts as a REPL output panel that enables inspection and visualization super powers;

nREPL, despite its name, is not a REPL, it's a eval RPC server. It does not have independent Read Eval and Print concepts, instead its main building blocks are [handlers](https://nrepl.org/nrepl/0.8/design/handlers.html), [transport](https://nrepl.org/nrepl/0.8/design/transports.html) and [middlewares](https://nrepl.org/nrepl/0.8/design/middleware.html). It's a different model that, like REPL, gives some powers and takes some powers away. I personally find REPL model simpler, more powerful and more approachable, so I use it, but YMMV.

## Starting REPL socket server

It is simple to start a REPL that can be reached from a remote machine, you won't even need any external dependencies, it's all here in [clojure.core.server](https://clojure.github.io/clojure/clojure.core-api.html#clojure.core.server/start-server) namespace. The easiest way to start it is to specify a JVM property that [starts socket server](https://clojure.org/reference/repl_and_main#_launching_a_socket_server) automatically on the JVM startup:
```
clj \
-J-Dclojure.server.repl='{:port 5555 :accept clojure.core.server/repl}'
```
This property configures required args to `clojure.core.server/start-repl` fn:
- `:name` is a part of a property name after `clojure.server.`, i.e. `"repl"`;
- `:port` is a server port;
- `:accept` is a symbol of a repl function.

## Connecting to remote socket REPL

You can connect to it using `nc` and start sending forms:
```
nc localhost 5555
user=> (+ 1 2 3)
6
```
How about nesting REPLs to connect to this REPL server from another clojure REPL? There is no built-in way to do it, but the implementation of [REPL client](https://github.com/vlaaad/remote-repl) is less than 50 lines of code, thanks to the simplicity of REPL concept. Let's try it:
```
clj \
-Sdeps '{:deps {vlaaad/remote-repl {:mvn/version "1.1"}}}'
Clojure 1.10.1
user=> (require '[vlaaad.remote-repl :as rr])
nil
user=> (rr/repl :port 5555)
;; at this point, forms sent to the repl are evaluated in the remote process
user=> (System/getProperty "clojure.server.repl")
"{:port 5555 :accept clojure.core.server/repl}"
user=> :repl/quit
;; now we are back to evaluating in our local process.
nil
user=> 
```

## REPLs for humans, prepls for tools

How about using Reveal to connect to this server? Reveal is a tool that needs structured REPL output to process it properly, it can't really work on REPL prompts like `user=>`. There is [prepl](https://oli.me.uk/clojure-socket-prepl-cookbook/) (programmable REPL), which is a socket REPL with output structured as edn maps — bread and butter of Clojure. To connect Reveal to remote socket REPL server it needs to be a prepl, like that:
```
clj \
-J-Dclojure.server.repl='{:port 5555 :accept clojure.core.server/io-prepl}'
```
If you are curious how this REPL's output looks like, here is an example at the command line:
```
clj \
-Sdeps '{:deps {vlaaad/remote-repl {:mvn/version "1.1"}}}' \
-M -m vlaaad.remote-repl :port 5555
(+ 1 2 3)
{:tag :ret, :val "6", :ns "user", :ms 9, :form "(+ 1 2 3)"}
```
Reveal can talk to this prepl server out of the box with its [remote-prepl](https://vlaaad.github.io/reveal/#remote-prepl) entry point:
```
clj \
-Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.2.182"}}}' \
-M -m vlaaad.reveal remote-prepl :port 5555
(+ 1 2 3)
{:tag :ret, :val 6, :ns "user", :ms 2, :form "(+ 1 2 3)"}
```
Console output is the same, but there is now a Reveal window that shows evaluations results in it's window:

![](/assets/2021-01-02/remote-prepl.png)

## Reveal client's clients

Now, lets get back to the original question of having REPL configuration where editor is on machine A, Reveal on machine B and target process on machine C. We already have most of the pieces laid out, the only missing part is how to setup reveal to run as a server that is itself a client, and that part is `:args` — additional arguments to a repl function specified by `:accept` symbol.

Lets setup it piece by piece. I'll use everything on the same machine because I'm lazy, but the real world example will differ only in having to specify `:host` in addition to `:port`. Machine C with ClojureScript prepl just for fun:
```
clj \
-Sdeps '{:deps {org.clojure/clojurescript {:mvn/version "1.10.764"}}}' \
-J-Dclojure.server.cljs='{:port 5555 :accept cljs.server.browser/prepl}'
```

Machine B, that uses Reveal to connect to C while acting as a REPL server:
```
clj \
-Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.2.182"}}}' \
-J-Dclojure.server.reveal='{:port 6666 :accept vlaaad.reveal/remote-prepl :args [:port 5555]}'
```

Finally, we can connect from machine A to machine B on port `6666`, and that will make it open a Reveal window with connection to machine C:
```
clj \
-Sdeps '{:deps {vlaaad/remote-repl {:mvn/version "1.1"}}}' 
-M -m vlaaad.remote-repl :port 6666
```
Evaluating code like `js/window` on machine A will make ClojureScript evaluate code in the browser on machine C and send it to machine B where Reveal will show the output:

![](/assets/2021-01-02/cljs-prepl.png)

## Conclusion

Once I've got the simplicity of REPL, I've got a lot more power at my disposal, with a significantly smaller cognitive footprint and improved understanding of underlying stack (e.g. Clojure evaluation semantics). If you don't know it, you don't know it; if you know it, you enjoy it.