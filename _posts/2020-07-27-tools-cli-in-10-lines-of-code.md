---
layout: post
title: "Alternative to tools.cli in 10 lines of code"
description: "With this simple snippet you can build extremely powerful command line entry point to your clojure application"
---
Let me start with what I think command line interface to a program should do:
- it should teach its user how to use it by invoking it with some well-known argument such as `-h` or `--help`;
- it should run a program, optionally with some arguments.

## Status quo

For its purpose, writing command line entry point is too damn verbose: parsing args, performing validation, providing defaults — all this is a boring busywork. There are libraries such as [tools.cli](https://github.com/clojure/tools.cli) that help with that, but if you look at it's API, you will see yet another ad-hoc implementation of half of clojure spec: it's a data-driven parser of a sequence of strings with schema, validations and defaults. Its benefit is conformance to GNU Program Argument Syntax Guidelines, but I would prefer to have an API that is simple and straightforward than having to remember what every letter means in the context of a particular command. 

If only defining a command was as easy as defining a function... If only parsing arguments was as predictable as using clojure reader... Perhaps it's possible? Without further ado, let's jump straight into 10 lines of Clojure this post is about.

## 10 lines of Clojure this post is about

```clojure
(defn -main [& opts]
  (let [f #(try
             (let [form (read-string %)]
               (cond
                 (qualified-symbol? form) @(requiring-resolve form)
                 (symbol? form) @((ns-publics (symbol (namespace `-main))) form)
                 :else form))
             (catch Exception _ %))
        [f & args] (map f opts)]
    (some-> (apply f args) prn)))
```
This entry point establishes a convention for invoking a program and parsing arguments that is a bit vague, but simple, straightforward and powerful. The convention: it is a function call in main ns with parens omitted. The important implication of this convention is that you learn both clojure and command line APIs at the same time. Here is how invocation of this CLI might look like:
```sh
$ clj -m cli foo :x bar :y true
```
And here is how using this ns from clojure might look like:
```clj
(cli/foo :x "bar" :y true)
```
Looks pretty similar, isn't it? The actual implementation allows a bit more in one place and a bit less in another, but I think that's fine. Let's explore the possibilities and limitations! 

## Arguments, defaults, validation

With this entry point creating tasks is done by defining new functions. Let's start with a simple task that we will use to see how arguments are parsed:
```clojure
(ns cli)

(defn echo [& args]
  (apply prn args))

(defn -main [] ...)
```
Now lets invoke it:
```sh
$ clj -m cli echo :host 127.0.0.1 :port 8080 :async true
:host "127.0.0.1" :port 8080 :async true
```
As you can see, `:host`, `:port` and `:async` are keywords, `true` is a boolean, and `127.0.0.1` is a string. We can easily and consistently parse arguments to values that make sense and invoke a function! What about defaults and validation? Just use normal Clojure code to do both! Here is an example:

```clojure
(defn ensure-connection
  "Ensure a connection to a network resource is possible

  Available options:
  - :host (optional, defaults to localhost) - target host
  - :port (required) - target port
  - :timeout (ms, optional, defaults to 10000) - connection timeout"
  [& {:keys [host port timeout]
      :or {host "localhost"
           timeout 10000}}]
  {:pre [(string? host) (int? port) (int? timeout)]}
  (doto (java.net.Socket.)
    (.connect (java.net.InetSocketAddress. ^String host ^int port) timeout)
    (.close))
  (println "Connection can be established"))
```
It certainly looks like a regular clojure function you might find in your code or someone's library. Let's try invoking it from the command line with required parameter missing:
```sh
$ clj -m cli ensure-connection
Execution error (AssertionError) at cli/ensure-connection (cli.clj:16).
Assert failed: (int? port)

Full report at:
/tmp/clojure-10136260048334273705.edn
```
Wonderful, we have validation! You can use spec or hand-written error messages to improve error reporting. Now let's add missing parameter:
```sh
clj -m cli ensure-connection :port 443
Execution error (ConnectException) at sun.nio.ch.Net/pollConnect (Net.java:-2).
Connection refused

Full report at:
/tmp/clojure-1463050396010033872.edn
```
Exit code is 1, since I don't have anything running on port 443. Overriding defaults is dead simple:
```sh
$ clj -m cli ensure-connection :port 443 :host google.com
Connection can be established
```

## More power to the user

You may have noticed that this entry point resolves symbols. One unintended consequence is that this CLI allows invoking any function by specifying its fully qualified symbol:
```sh
$ clj -m cli clojure.core/prn :woot
:woot
```
While this particular behavior is certainly not intended and can be restricted with a bit more code, the ability to supply symbols is extremely useful for improving expressivity available to this CLI: it supports any def-ed value as an argument! Suppose we write a custom repl that in its first iteration behaves exactly like `clojure.main/repl`:
```clojure
(defn repl [& options]
  (apply clojure.main/repl options))
```
Invoking it from the command line supports all options expecting functions, so we can e.g. configure its printing behavior from the command line:
```
$ clj -m cli repl :print clojure.pprint/pprint
user=> (meta #'tap>)
{:arglists ([x]),
 :doc "sends x to any taps. Will not block. Returns true if there was room in the queue,\n  false if not (dropped).",
 :added "1.10",
 :line 7886,
 :column 1,
 :file "clojure/core.clj",
 :name tap>,
 :ns #object[clojure.lang.Namespace 0x30404dba "clojure.core"]}
```

## Getting help

What about learning the API? First of all, it's easy to create `help` command that prints function's docstrings:
```clojure
(defn help [f]
  (println (:doc (meta (resolve (symbol (Compiler/demunge (.getName (class f)))))))))
```
Your documentation in code is now available in the command line:
```sh
$ clj -m cli help ensure-connection
Tests a connection to a network resource.
  Available options:
  - :host (optional, defaults to localhost) - target host
  - :port (required) - target port
  - :timeout (ms, optional, defaults to 10000) - connection timeout
```
Now, what about well-known higher-level help using `--help` or `-h`? Wait, aren't those valid clojure symbols? Lets try defining those!
```clojure
(defn --help []
  (println "Available commands:")
  (doseq [sym (sort (keys (dissoc (ns-publics (symbol (namespace `--help))) '-main)))]
    (println (str "  " sym)))
  (println "Use help <command> to see description of that command"))

(def -h --help)
```
Would that work? Yes it would!
```sh
$ clj -m cli --help
Available commands:
  --help
  -h
  echo
  ensure-connection
  help
  repl
Use help <command> to see description of that command
```

## Limitations

This entry point does not evaluate S-expressions, instead forms are read as is:
```
$ clj -m cli echo "(if 1 :foo :bar)"
(if 1 :foo :bar)
```
I think this is a good thing: if you want to start writing code for such command line invocation, it's a sign you should write a proper program. But now that you learned the command line API, you also learned the library API!

## Summary

If you are willing to give up GNU Program Argument Syntax Guidelines for your command line entry point to a Clojure library, you might find yourself having a simple, concise, powerful and straightforward API that will make your code transparent to your users.

What do you think? Discuss [on reddit](https://www.reddit.com/r/Clojure/comments/hynnhy/alternative_to_toolscli_in_10_lines_of_code/).
