---
layout: reveal
title: "Reveal: Setup"
permalink: /reveal/setup
---

You can use Reveal in many ways and contexts. Setup instructions will be different depending on various factors:
- your Reveal edition (Free or Pro);
- your build tool (leiningen or clj);
- your IDE or text editor;
- whether you want to use Reveal as REPL, pREPL, nREPL middleware or a library.

Table of contents:

* auto-gen table of contents
{:toc}

# Reveal edition

The only difference between Reveal Free and Reveal Pro in terms of setting it up and running is dependency coordinate.

| Edition | Lib                     | Version   |
|---------|-------------------------|-----------|
| Free    | `vlaaad/reveal`         | `1.3.286` |
| Pro     | `dev.vlaaad/reveal-pro` | `1.3.370` |

# Build tool

The best way to make Reveal available in your project is to add a dependency on it in a system level build tool configuration. 

## Clj dependency

Edit your `~/.clojure/deps.edn` to contain the following:

```clj
{:aliases {:reveal {:extra-deps {vlaaad/reveal {:mvn/version "1.3.286"}}
                    ;; optional: preferences
                    :jvm-opts ["-Dvlaaad.reveal.prefs={:theme,:light}"]}}}
```
After that, Reveal will be available for use as a library when you launch `clj -A:reveal`:
```clj
$ clj -A:reveal
Clojure 1.10.3
user=> (require '[vlaaad.reveal :as r])
nil
user=> (r/tap-log)
nil ;; tap log window opens
user=> (tap> (System/getProperties))
true ;; system properties are shown in the tap log
```

## Leiningen dependency

Edit your `~/.lein/profiles.clj` to contain the following:

```clj
{:repl {:dependencies [[vlaaad/reveal "1.3.286"]]
        ;; optional: preferences
        :jvm-opts ["-Dvlaaad.reveal.prefs={:theme,:light}"]}}
```
After that, Reveal will be available for use as a library when you launch `lein repl`:
```clj
$ lein repl
nREPL server started on port 58651 on host 127.0.0.1 - nrepl://127.0.0.1:58651
user=> (require '[vlaaad.reveal :as r])
nil
user=> (r/tap-log)
nil ;; tap log window opens
user=> (tap> (System/getProperties))
true ;; system properties are shown in the tap log
```

# Configuring Reveal for REPL output

## Leiningen + nREPL middleware

Reveal provides nREPL middleware that can be enabled in `~/.lein/profiles.clj`: 
```clj
{:repl {:dependencies [[vlaaad/reveal "1.3.286"]]
        :repl-options {:nrepl-middleware [vlaaad.reveal.nrepl/middleware]}}}
```
This way, running `lein repl` will automatically open a Reveal output window and all evaluations will be shown in the window. This setup works well with IDE plugins like:
- Calva (Visual Studio Code) — just jack in using Leiningen;
- Cursive (Intellij) — just create a run configuration with nREPL type that is run with Leiningen;
- etc.

## Clj + nREPL middleware

When using `clj`, you need to specify nREPL middleware either in `.nrepl.edn` file in your project like so:
```clj
{:middleware [vlaaad.reveal.nrepl/middleware]}
```
...or as a command line argument that launches nrepl:
```clj 
clj \
-Sdeps '{:deps {nrepl/nrepl {:mvn/version "0.9.0"}}}' \
-A:reveal \
-M -m nrepl.cmdline --middleware '[vlaaad.reveal.nrepl/middleware]'
```

## Cursive + Clj + REPL

When using Cursive with Clj, it's usually enough to launch a Reveal REPL using a following "Clojure REPL - Local" run configuration:
- Type of REPL to run: clojure.main;
- How to run it: Run with Deps: `-A:reveal`;
- Parameters: `-m vlaaad.reveal repl` (or as a sticker window: `-m vlaaad.reveal repl :always-on-top true`).

## Cursive + Clj + remote REPL

There might be cases where you want to launch `clj` tool yourself and then connect to it from Cursive. In that case, you should **not** use a "Clojure REPL - Remote" run configuration, since it will rewrite your forms and results to something unreadable. Instead, you should still use the "Local" run configuration that uses a remote repl client that connects to your process. Example:

1. Make your target process a reveal server:

   ```sh
   clj -A:reveal -J-Dclojure.server.repl='{:port 5555 :accept vlaaad.reveal/repl :args [:always-on-top true]}'
   ```
2. Add a dependency on [remote-repl](https://github.com/vlaaad/remote-repl) to your `~/.clojure/deps.edn`:

   ```clj
   {:aliases
    {:remote-repl {:extra-deps {vlaaad/remote-repl {:mvn/version "1.2.12"}}}}}
   ```
3. Create a "Local" run configuration with:
   - Type of REPL to run: clojure.main;
   - How to run it: Run with Deps;
   - Aliases: `remote-repl` (not `reveal`!);
   - Parameters: `-m vlaaad.remote-repl :port 5555 :reconnect true`. The `:reconnect` option is especially useful — it will keep trying to connect to the REPL, which allows you to restart the REPL server and make IDE automatically restore the connection.

This configuration will run Reveal in a separate dev process that you control, and will use Cursive only to connect to it and send forms. 

## Cursive + Clj + remote pREPL client

You can use Reveal to act as a REPL output for remote processes that don't have Reveal on the classpath (e.g. a production process or a ClojureScript environment). This is useful for data visualization, but is somewhat limited because it inspects only the data that arrived from the network, not the actual data in the target process. Here is an example configuration:

1. Suppose we have a ClojureScript prepl on port 5555, e.g.:
   ```clj
   clj \
   -Sdeps '{:deps {org.clojure/clojurescript {:mvn/version "1.10.764"}}}' \
   -X clojure.core.server/start-server \
   :name '"cljs"' \
   :accept cljs.server.browser/prepl \
   :port 5555 \
   :server-daemon false
   ```
2. To connect to it from Cursive, create "Clojure REPL - Local" run configuration with:
   - Type of REPL to run: clojure.main;
   - How to run it: Run with Deps;
   - Aliases: `reveal`;
   - Parameters: `-m vlaaad.reveal remote-prepl :port 5555`

That way, whenever you launch this run configuration, Cursive will show a Reveal window with pREPL connection to a cljs pREPL server, and sending forms from Cursive to the REPL will evaluate them in cljs environment.

## Rebel Readline

You can combine Reveal with Rebel-Readline using following snippet:
```clj
clojure -Sdeps '{:deps {com.bhauman/rebel-readline {:mvn/version "0.1.4"}}}' -A:reveal
Clojure 1.10.3
user=> (require 'rebel-readline.core)
nil
user=> (require 'rebel-readline.clojure.line-reader)
nil
user=> (require 'rebel-readline.clojure.service.local)
nil
user=> (require 'vlaaad.reveal)
nil
user=> (rebel-readline.core/with-readline-in
         (rebel-readline.clojure.line-reader/create
           (rebel-readline.clojure.service.local/create))
         (vlaaad.reveal/repl :prompt (fn[])))
user=> ;; Rebel Readline starts with a Reveal window output
```
