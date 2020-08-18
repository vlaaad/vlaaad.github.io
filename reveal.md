---
layout: reveal
title: "Reveal:<br>Read Eval Visualize Loop for&nbsp;Clojure"
permalink: /reveal/
---

TODO: new demo
should show:
- how data is displayed (maps, vectors, etc.)
- eval on selection
- watchers
- charts

| [![Clojars Project](https://img.shields.io/clojars/v/vlaaad/reveal.svg?logo=clojure&logoColor=white)](https://clojars.org/vlaaad/reveal) | [![Slack Channel](https://img.shields.io/badge/slack-clojurians%20%23reveal-blue.svg?logo=slack)](https://clojurians.slack.com/messages/reveal/) | [![Github page](https://img.shields.io/badge/github-vlaaad%2Freveal-informational?logo=github)](https://github.com/vlaaad/reveal) |

Table of contents:
* auto-gen table of contents
{:toc}

# Rationale

Repl is a great window into a running program, but the textual nature of its output limits developer's ability to inspect the program: a text is not an object, and we are dealing with objects in the VM.

Reveal aims to solve this problem by creating an in-process repl output pane that makes inspecting values as easy as selecting an interesting datum. It recognizes the value of text as a universal interface, that's why its output looks like a text: you can select it, copy it, save it into a file. Unlike text, reveal output holds references to printed values, making inspecting selected value a matter of opening a context menu.

Unlike datafy/nav based tools, Reveal does not enforce a particular data representation for any given object, making it an open set — that includes datafy/nav as one of the available options. It does not use datafy/nav by default because in the absence of inter-process communication to datafy is to lose.

Not being limited to text, Reveal uses judicious syntax highlighting to aid in differentiating various objects: text `java.lang.Integer` looks differently depending on whether it was produced from a symbol or a class.

# Give it a try

The easiest way to try it is to run a Reveal repl:
```sh
clj \
-Sdeps '{:deps {vlaaad/reveal {:mvn/version "0.1.0-ea29"}}}' \
-m vlaaad.reveal repl
```
Executing this command will start a repl and open Reveal output window that will mirror the evaluations in the repl.

# Features

## `tap>` support

Clojure 1.10 added `tap>` function with the purpose similar to printing the value for debugging, but instead of characters you get the object. Reveal repls show tapped values in their output windows — you won't need `println` anymore!

![Tap demo](/assets/reveal/tap.gif)

## Eval on selection

You can evaluate code on any selected value by using text input in the context menu. You can write either a single symbol of a function to call or a form where `*v` will be replaced with selected value.

![Eval on selection demo](/assets/reveal/eval-on-selection.gif)

## Inspect object fields and properties

Any object in the JVM has class and fields, making them easily accessible for inspection is extremely important. With `java-bean` contextual action you get a debugger-like view of objects in the VM. Access to this information greatly improves the visibility of the VM and allows to explore it. For example, for any class you have on the classpath you can get the place where it's coming from:

![Java bean demo](/assets/reveal/java-bean.gif)
I learned about it after implementing this feature :)

## Look and feel customization

Reveal can be configured with `vlaaad.reveal.prefs` java property to use different font or theme:

![Light theme](/assets/reveal/light-theme.png)

## URL and file browser

You can open URL-like things and files: both internally in Reveal and externally using other applications in your OS e.g. file explorer, browser or text editor.

![Browse demo](/assets/reveal/browse.gif)

## Doc and source

Reveal can show you documentation and sources for various runtime values — namespaces, vars, symbols, functions, keywords (if they define a spec). Like [cljdoc](https://cljdoc.org/), it supports `[[wikilink]]` syntax in docstrings to refer to other vars, making them accessible for further exploration.

![Doc and source demo](/assets/reveal/doc-and-source.gif)

## Ref watchers
Reveal can watch any object implementing `clojure.lang.IRef` (things like atoms, agents, vars, refs) and display it either automatically updated or as a log of successors.

![Ref watchers demo](/assets/reveal/watchers.gif)

## Charts

Reveal can show data of particular shapes as charts that are usually explorable: when you find an interesting data point on the chart, you can then further inspect the data in that data point.

The simplest shape is labeled numbers. Labeled means that those numbers exist in some collection that has a unique label for every number. For maps, keys are labels, for sequential collections, indices are labels and for sets, numbers themselves are labels.

A pie chart is the only chart that shows labeled numbers:

![Pie chart demo](/assets/reveal/pie-chart.gif)

Other charts support more flexible data shapes — both because they can show more than one data series, and because they can be explored, where it might be useful to attach some metadata with the number. Since JVM numbers don't allow metadata, you can instead use tuples where the first item is a number and second is the metadata. Bar charts can display labeled numbers (single data series) or labeled numbers that are themselves labeled (multiple data series):

![Bar chart demo](/assets/reveal/bar-chart.gif)

Line charts are useful to display progressions, so Reveal suggests them to display sequential numbers (and labeled sequential numbers):

![Line chart demo](/assets/reveal/line-chart.gif)

Finally, Reveal has scatter charts to display coordinates on a 2D plane. A coordinate is represented as a tuple of 2 numbers and as with numbers, you can use a tuple of coordinate and arbitrary value in the place of coordinate. Reveal will suggest scatter charts for collections of coordinates and labeled collections of coordinates.

![Scatter chart demo](/assets/reveal/scatter-chart.gif)

## Table view

There are cases where it is better to make sense of the value when it is represented by a table: collections of homogeneous items where columns make it easier to compare corresponding parts of those items, and big deeply nested data structures where it's easier to look at them layer by layer. 

![Table view demo](/assets/reveal/table.gif)

## ...and more

Reveal was designed to be performant: it can stream syntax-highlighted output very fast. In addition to that, there are various helpers for data inspection:
- text search that is triggered by <kbd>/</kbd> or <kbd>Ctrl F</kbd>;
- out of the box [lambdaisland's deep-diff](https://github.com/lambdaisland/deep-diff2) output highlighting: all you need to do is have it on the classpath;
- various contextual actions:
  - deref derefable things;
  - get meta if a selected value has some meta;
  - convert java array to vector;
  - view the color of a thing that describes a color (like `"#fff"` or `:red`);

# Using Reveal

## UI concepts and navigation

![Concepts](/assets/reveal/concepts.png)

Reveal UI is made of 3 components: 
- output panel that contains data submitted to reveal window (e.g. repl output);
- a context menu that can invoke actions on selected values;
- results panel that has 1 or more tabs with action results produced from the context menu.

Navigation:
- Use <kbd>Space</kbd>, <kbd>Enter</kbd> or right mouse button to open a context menu on selection;
- Use <kbd>Tab</kbd> to switch focus between output and results panel;
- In results panel:
  - Use <kbd>Ctrl ←</kbd> and <kbd>Ctrl →</kbd> to switch tabs in results panel;
  - Use <kbd>Esc</kbd> to close the tab
- In a context menu:
  - Use <kbd>↑</kbd> and <kbd>↓</kbd> to move focus between available actions and input text field;
  - Use <kbd>Enter</kbd> to execute selected action or form written in the text field;
  - Use <kbd>Esc</kbd> to close the context menu.

## Customization

Reveal can be customized using `vlaaad.reveal.prefs` java property that contains an edn map of UI preferences. Supported keys (all optional):
- `:theme` — color theme, `:light` or `:dark`;
- `:font-family` — system font name (like `"Consolas"`) or URL (like `"file:/path/to/font.ttf"` or `"https://ff.static.1001fonts.net/u/b/ubuntu.mono.ttf"`) — reveal only supports monospaced fonts;
- `:font-size` — font size, number.

Example:
```sh
$ clj -A:reveal \
-J-Dvlaaad.reveal.prefs='{:font-family "Consolas" :font-size 15}' \
-m vlaaad.reveal repl
```

## User API

The main entry point to Reveal is `vlaaad.reveal` ns that has various repls and lower-level functionality for data inspection.

### `repl`

It is a repl wraps `clojure.main/repl` with additional support for `:repl/quit` and `tap>`. It is as simple as it gets. I use it all the time. Example:

```sh
$ clj -A:reveal -m vlaaad.reveal repl
# Reveal window appears
Clojure 1.10.1
user=>
```

### `io-prepl` 

This prepl works like `clojure.core.server/io-prepl`. Its purpose is to be run in a process on your machine that you want to connect to using another prepl-aware tool. Example:

```sh
$ clj -A:reveal \
-J-Dclojure.server.reveal='{:port 5555 :accept vlaaad.reveal/io-prepl}'
```
Now you can connect to this process using any socket repl and it will show a Reveal window for every connection:
```sh
$ nc localhost 5555
# reveal window appears
(+ 1 2 3) # input
{:tag :ret, :val "6", :ns "user", :ms 1, :form "(+ 1 2 3)"} # output
```

### `remote-prepl`

Reveal is the most useful when it runs in the process where the development happens. This prepl, unlike the previous two, is not like that: it connects to a remote process and shows a window for values that arrived from the network. It can't benefit from easy access to printed references because these references are pointing to values deserialized from bytes, not values in the target VM. It's still nice and performant repl, and it's useful when you want to use Reveal to talk to another process that does not have Reveal on the classpath (e.g. production or ClojureScript prepl).

Example:
1. Start a prepl without Reveal on the classpath:
   ```sh
   $  clj \
   -Sdeps '{:deps {org.clojure/clojurescript {:mvn/version "1.10.764"}}}' \
   -J-Dclojure.server.cljs-prepl='{:port 50505 :accept cljs.server.browser/prepl}'
   ```
2. Connect to that prepl using Reveal:
   ```
   $ clj -A:reveal -m vlaaad.reveal remote-prepl :port 50505
   # at this point, 2 things happen:
   # 1. Browser window with cljs prepl appears
   # 2. Reveal window opens

   # input
   js/window

   # output
   {:tag :ret, 
    :val #object [Window [object Window]], 
    :ns "cljs.user", 
    :ms 25, 
    :form "js/window"}
   ```

### `ui`

Calling this function will create and show a Reveal window. It returns a function that you can submit values to — they will appear in the output panel. All built-in visual repls are thin wrappers of other repls that submit values to a window created by this generic function. You can use it to create custom Reveal-flavored repls, or, instead of using it as a repl, you can configure Reveal to only show tapped values.

Example:
```clj
(require '[vlaaad.reveal :as reveal])

;; open a window that will show tapped values:
(add-tap (reveal/ui))

 ;; submit value to the window:
(tap> {:will-i-see-this-in-reveal-window? true})
```

### Nrepl middleware

For development workflows that require nrepl Reveal has a middleware that will show evaluation results produced by nrepl: `vlaaad.reveal.nrepl/middleware`, you will need to add it to your middleware list. Minimum required version of nrepl is 0.6.0

Example of using this middleware with command line nrepl entry point:
```sh
$ clj -A:reveal -m nrepl.cmdline --middleware '[vlaaad.reveal.nrepl/middleware]'
```
Alternatively, you can create [.nrepl.edn](https://nrepl.org/nrepl/usage/server.html#server-options) file in your project directory that will be picked up by nrepl. Example `.nrepl.edn` file:

```clj
{:middleware [vlaaad.reveal.nrepl/middleware]}
```

# Editor integration

Knowing [User API](#user-api) you should be able to configure your editor to use Reveal, but there are still some points worthy of discussion.

## Cursive

For cursive, you should create a "local repl" run configuration with "clojure.main" repl type. For prefs, use "JVM Args" input, but note that it splits args on spaces, so you should use commas, e.g. `-Dvlaaad.reveal.prefs={:theme,:light}`. This is the most simple setup that allows IDEA to start your application and establish a repl connection for sending forms.

Sometimes this setup is not ideal: you might want to start an application using some other means and then connect to it using IDEA. In that case, you should **not** use "remote repl" run configuration, since it will rewrite your forms and results to something unreadable. Instead, you should still use the "local repl" run configuration, that uses a remote repl client that connects to your process. Example configuration:

1. Make your target process a reveal server:

   ```sh
   clj -A:reveal -J-Dclojure.server.repl='{:port 5555 :accept vlaaad.reveal/repl}'
   ```
2. Add a dependency on [remote-repl](https://github.com/vlaaad/remote-repl) to your `deps.edn`:
   
   ```clj
   {:aliases 
    {:remote-repl {:extra-deps {vlaaad/remote-repl {:mvn/version "1.1"}}}}}
   ```
3. Create a "local repl" run configuration with "clojure.main" repl type, make it "Run with Deps" with `remote-repl` alias, and in Parameters specify `-m vlaaad.remote-repl :port 5555`.


# TODO:
- usage:
  - editor integration:
    - cursive: use local main, mention vlaaad/remote-repl for remoting
    - other editors? emacs, vscode, vim, atom
- extensibility:
  - custom formatting
  - custom actions