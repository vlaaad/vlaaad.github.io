---
layout: reveal
title: "Reveal:<br>Read Eval Visualize Loop for&nbsp;Clojure"
permalink: /reveal/
---

![Demo](/assets/reveal/demo.gif)

| [![Clojars Project](https://img.shields.io/clojars/v/vlaaad/reveal.svg?logo=clojure&logoColor=white&style=for-the-badge)](https://clojars.org/vlaaad/reveal) | [![Github page](https://img.shields.io/badge/github-vlaaad%2Freveal-informational?logo=github&style=for-the-badge)](https://github.com/vlaaad/reveal) | [![Slack Channel](https://img.shields.io/badge/slack-%20%23reveal-blue.svg?logo=slack&style=for-the-badge)](https://clojurians.slack.com/messages/reveal/) |

* auto-gen table of contents
{:toc}

# Rationale

Repl is a great window into a running program, but the textual nature of its output limits developer's ability to inspect the program: a text is not an object, and we are dealing with objects in the VM.

Reveal aims to solve this problem by providing a set of tools for the JVM — like REPL output pane and inspector popups — that make exploring objects as easy as pointing at them. It recognizes the value of text as a universal interface, that's why its output looks like a text by default: you can select it, copy it, save it into a file. Unlike text, Reveal output panels hold references to printed values, making inspecting selected value a matter of opening a context menu.

Not being limited to a stream of characters, Reveal uses judicious syntax highlighting to aid in differentiating various objects: text `java.lang.Integer` looks differently depending on whether it was produced from a symbol or a class.

# Reveal Pro

Reveal aims to be an extensible tool suitable for helping with development of any Clojure program. [Reveal Pro](/reveal-pro){: .buy-button} provides a set of extensions that improve developer experience by providing more integrated tools so you can focus on your problem with data and knowledge you need, available as soon as you need it.

# Give it a try

The easiest way to try it is to run a Reveal repl:
```sh
clj \
-Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.3.272"}}}' \
-X vlaaad.reveal/repl
```
Executing this command will start a repl and open Reveal output window that will mirror the evaluations in the shell.

Here is an example alias you can put into your user `deps.edn`:
```clj
:reveal {:extra-deps {vlaaad/reveal {:mvn/version "1.3.272"}}
         :ns-default vlaaad.reveal
         :exec-fn repl}
```

If you are using older version of `clj` (before [1.10.1.672](https://insideclojure.org/2020/09/04/clj-exec/)), you can use this main-style alias:
```clj
:reveal {:extra-deps {vlaaad/reveal {:mvn/version "1.3.272"}}
         :main-opts ["-m" "vlaaad.reveal" "repl"]}
```

# Features

## `tap>` support

Clojure 1.10 added `tap>` function with the purpose similar to printing the value for debugging, but instead of characters you get the object. Reveal REPLs show tapped values in their output windows — you won't need `println` anymore!

![Tap demo](/assets/reveal/tap.gif)

If you don't want to use Reveal as a REPL output pane, you can instead use a tap log sticker (always-on-top) window:

<video controls><source src="/assets/reveal/tap-log.mp4" type="video/mp4"></source></video>

## Eval on selection

You can evaluate code on any selected value by using text input in the context menu. You can write either a single symbol of a function to call or a form where `*v` will be replaced with selected value.

![Eval on selection demo](/assets/reveal/eval-on-selection.gif)

## SQL DB explorer

This feature is only available in [Reveal Pro](/reveal-pro){: .buy-button}. You can view DB schema and browse relational data across multiple tables using a `db:explore` action available on JDBC connection source descriptions (e.g. DataSource instances, JDBC URL strings or db spec maps if you use [next.jdbc](https://github.com/seancorfield/next-jdbc) or [clojure.java.jdbc](https://github.com/clojure/java.jdbc)):

<video controls><source src="/assets/reveal-pro/db-full-demo.mp4" type="video/mp4"></source></video>

## Inspector popup window

You can open a temporary popup window for any value in the REPL either by calling `(vlaaad.reveal/inspect x)` fn, or by using `#reveal/inspect x` reader tag.

<video controls><source src="/assets/2021-12-02/inspect.mp4" type="video/mp4"></source></video>

## System watcher stickers

This feature is only available in [Reveal Pro](/reveal-pro){: .buy-button}. If you are using component, integrant or mount, you will find it useful to have a small [sticker](https://vlaaad.github.io/reveal-stickers) window that shows current state of your dev system with controls to start and stop it. You don't need to remember if it's running or not when you can always see it:

<video controls><source src="/assets/reveal-pro/system-stickers.mp4" type="video/mp4"></source></video>

## Vega(-Lite) visualizations

[Vega(-Lite)](https://vega.github.io/) is a declarative data visualization language that uses json for visualization description. Reveal bundles a view that converts Clojure data structures to json and shows them as vega visualizations, providing a convenient way to explore the data:

<video controls><source src="/assets/reveal/vega-view.mp4" type="video/mp4"></source></video>

## Inspect object fields and properties

Any object in the JVM has class and fields, making them easily accessible for inspection is extremely important. With `java-bean` contextual action you get a debugger-like view of objects in the VM. Access to this information greatly improves the visibility of the VM and allows to explore it. For example, for any class you have on the classpath you can get the place where it's coming from:

![Java bean demo](/assets/reveal/java-bean.gif)
I learned about it after implementing this feature :)

## Test runner

From individual vars to the whole suite, you can use Reveal for running tests and quickly navigating the structured test output. When defining new tests, you can use `test` contextual action to test the var (or the whole ns). You can also use test runner sticker for an always-on UI for running tests. Jump between errors instantly using <kbd>Alt ↑</kbd> and <kbd>Alt ↓</kbd> in test output. Use `diff` contextual action on test failures to see the difference between expected and actual values:

<video controls><source src="/assets/reveal/test-runner.mp4" type="video/mp4"></source></video>

## Forms

This feature is only available in [Reveal Pro](/reveal-pro){: .buy-button}. Forms allow you to convert data structure specifications (e.g. Clojure specs or json schemas) to UI input components for creating these data structures. This is a generic and multi-purpose tool that can be used for:

- learning possible shapes of expected data;
- exploring data-driven APIs;
- creating data structures with contextual help.

Here is how it looks like:

![ns form demo](/assets/reveal-pro/ns-form.gif)

Since Vega(-Lite) provides json schemas that are supported by Forms, it is very useful to explore and build visualizations using Vega Form view:

<video controls><source src="/assets/reveal-pro/vega-form-view.mp4" type="video/mp4"></source></video>

## Look and feel customization

Reveal can be configured with `vlaaad.reveal.prefs` java property to use different font or theme:

![Light theme](/assets/reveal/light-theme.png)

## URL and file browser

You can open URL-like things and files: both internally in Reveal and externally using other applications in your OS e.g. file explorer, browser or text editor.

![Browse demo](/assets/reveal/browse.gif)

## File system navigation

This feature is only available in [Reveal Pro](/reveal-pro){: .buy-button}. Use Java's file system APIs to navigate folders and zip/jar archives. Explore your classpath:

![fs demo](/assets/reveal-pro/fs.gif)

## Doc and source

Reveal can show you documentation and sources for various runtime values — namespaces, vars, symbols, functions, keywords (if they define a spec). Like [cljdoc](https://cljdoc.org/), it supports `[[wikilink]]` syntax in docstrings to refer to other vars, making them accessible for further exploration.

![Doc and source demo](/assets/reveal/doc-and-source.gif)

## Ref watchers
Reveal can watch any object implementing `clojure.lang.IRef` (things like atoms, agents, vars, refs) and display it either automatically updated or as a log of successors.

![Ref watchers demo](/assets/reveal/watchers.gif)

## Charts

Reveal can show data of particular shapes as charts that are usually explorable: when you find an interesting data point on the chart, you can then further inspect the data in that data point.

The simplest shape is labeled numbers. Labeled means that those numbers exist in some collection that has a unique label for every number. For maps, keys are labels, for sequential collections, indices are labels and for sets, numbers themselves are labels.

A pie chart shows labeled numbers:

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

Note: You can use `Alt ↑` and `Alt ↓` to sort table by values in selected column; and `Ctrl C` will copy cell content as text.

## ...and more

Reveal was designed to be performant: it can stream syntax-highlighted output very fast. In addition to that, there are various helpers for data inspection:
- text search that is triggered by <kbd>/</kbd> or <kbd>Ctrl F</kbd>;
- out of the box [lambdaisland's deep-diff](https://github.com/lambdaisland/deep-diff2) output highlighting: all you need to do is have it on the classpath;
- various contextual actions:
  - deref derefable things;
  - get meta if a selected value has some meta;
  - convert java array to vector;
  - view the color of a thing that describes a color (like `"#fff"` or `:red`);
- ability to interact with Reveal and trigger inspections from the REPL.

# Using Reveal

## UI concepts and navigation

![Concepts](/assets/reveal/concepts.png)

Reveal UI is made of 3 components:
- output panel that contains data submitted to reveal window (e.g. repl output);
- a context menu that can invoke actions on selected values;
- results panel that has 1 or more tabs with action results produced from the context menu.

### Navigation

You can navigate around values as you do it in text editors by using arrow keys. Other navigation:

- Use <kbd>Space</kbd>, <kbd>Enter</kbd> or right mouse button to open a context menu on selection;
- Use <kbd>Tab</kbd> to switch focus between output and results panel;
- Use <kbd>F11</kbd> (<kbd>Cmd Shift M</kbd> on mac) to maximize/unmaximize the window;
- Use <kbd>Alt F11</kbd> (<kbd>Cmd M</kbd> on mac) to minimize/unminimize the window;
- In results panel:
  - Use <kbd>Ctrl ←</kbd> and <kbd>Ctrl →</kbd> to switch tabs in results panel;
  - Use <kbd>Ctrl ↑</kbd> to open result panel's tab tree that provides a hierarchical overview of all tabs in this panel, where <kbd>Backspace</kbd> can be used to close views;
  - Use <kbd>Esc</kbd> to close the tab
- In a context menu:
  - Use <kbd>↑</kbd> and <kbd>↓</kbd> to move focus between available actions and input text field;
  - Use <kbd>Enter</kbd> to execute selected action or form written in the text field;
  - Use <kbd>Ctrl Enter</kbd> to display action result in a new results panel;
  - Use <kbd>Shift Enter</kbd> to display action result in a new inspector sticker (always-on-top) window;
  - Use <kbd>Esc</kbd> to close the context menu.

### Structural navigation

Reveal output panel has natural structural navigation that is activated by pressing arrow keys while holding <kbd>Alt</kbd>. The cursor will jump to the next value in a direction of an arrow, making navigation experience similar to navigating tables. Pressing <kbd>Alt ←</kbd> when there is no value to the left in the data structure will move the cursor out of this data structure. You can also use <kbd>Alt Home</kbd> and <kbd>Alt End</kbd> to move to first / last row in a data structure.

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

It is a repl that wraps `clojure.main/repl` with additional support for `:repl/quit` and `tap>`. It is as simple as it gets. I use it all the time. Example:

```sh
$ clj -A:reveal -M -m vlaaad.reveal repl :always-on-top true
# Reveal sticker window appears
Clojure 1.10.1
user=>
```

### `io-prepl`

This prepl works like `clojure.core.server/io-prepl`. Its purpose is to be run in a process on your machine that you want to connect to using another prepl-aware tool. Example:

```sh
$ clj -A:reveal \
-J-Dclojure.server.reveal='{:port 5555 :accept vlaaad.reveal/io-prepl :args [:always-on-top true]}'
```
Now you can connect to this process using any socket repl and it will show a new Reveal sticker (always-on-top) window for every connection:
```sh
$ nc localhost 5555
# Reveal sticker window appears
(+ 1 2 3) # input
{:tag :ret, :val "6", :ns "user", :ms 1, :form "(+ 1 2 3)"} # output (+ displayed in Reveal)
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
   $ clj -A:reveal -M -m vlaaad.reveal remote-prepl :always-on-top true :port 50505
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
(require '[vlaaad.reveal :as r])

;; open a window that will show tapped values:
(add-tap (r/ui))

 ;; submit value to the window:
(tap> {:will-i-see-this-in-reveal-window? true})
```

### `tap-log`

A better way to display tapped values in Reveal is using a specialized tap log window that will unsubscribe from the tap queue when the window is closed:

```clj
(require '[vlaaad.reveal :as r])

(r/tap-log) ;; open a window that will show tapped values

(tap> (all-ns))
```

### `inspect` and `#reveal/inspect`

You can open a new temporary sticker window for value inspection using either `vlaaad.reveal/inspect` fn or `#reveal/inspect` reader tag:
```clj
#reveal/inspect (all-ns) ;; inspect all loaded namespaces
```

### `sticker`

This is a generic sticker window that is similar to `inspect`. It exists for a different purpose though — creating longer-lived always-on-top windows for frequently used views (e.g. Component/Integrant/Mount state trackers). It's harder to close — you need to use close window shortcut like <kbd>Ctrl W</kbd> instead of <kbd>Escape</kbd>. Bounds group defaults to the value of provided title, so it's easier to create a specialized place for the particular sticker just by providing a distinct title.

```clj
(r/sticker 
  {:fx/type r/ref-watch-latest-view
   :ref @#'mount.core/running}
  :title "mount system")
```

# Editor integration

With [user API](#user-api) you should be able to configure your editor to use Reveal, but there are still some points worthy of discussion.

## REPL vs nREPL

REPL is a Read-Eval-Print Loop, a programming environment that enables you to interact with a running Clojure program and modify it by evaluating one code expression at a time. It's simpler, but somewhat harder to integrate into IDEs, so it's more common to see IDEs and text editors work with nREPL instead. nREPL, despite its name, is not a REPL, but an eval RPC server that provides similar development experience. Reveal supports both — it bundles [local and remote REPLs](/reveal-repls-and-networking) for REPL-based dev setups, as well as nREPL middleware for [nREPL-based configurations](#nrepl-based-editors).

## Editor commands

If your editor can be configured to send predefined code forms to REPL, it might be useful to define these commands:

1. Inspect last result: 
   ```clj
   #reveal/inspect *1
   ```
2. Toggle minimized state for all sticker windows:
   ```clj
   (vlaaad.reveal/submit-command! :always-on-top (vlaaad.reveal/toggle-minimized))
   ```

## Cursive

If you want to use REPL instead of nREPL in Cursive, you should create a "Clojure Repl - Local" run configuration with the "clojure.main" repl type, "Run with Deps", and the "Parameters" `-m vlaaad.reveal repl :always-on-top true` (or put those inside `:main-opts` of an alias and add that to the "Aliases" list). For prefs, use "JVM Args" input, but note that it splits args on spaces, so you should use commas, e.g. `-Dvlaaad.reveal.prefs={:theme,:light}`. This is the most simple setup that allows IDEA to start your application and establish a repl connection for sending forms.

Sometimes this setup is not ideal: you might want to start an application using some other means — like `clj` CLI tool — and then connect to it using IDEA. In that case, you should **not** use "remote repl" run configuration, since it will rewrite your forms and results to something unreadable. Instead, you should still use the "local repl" run configuration that uses a remote repl client that connects to your process. Example:

1. Make your target process a reveal server:

   ```sh
   clj -A:reveal -J-Dclojure.server.repl='{:port 5555 :accept vlaaad.reveal/repl :args [:always-on-top true]}'
   ```
2. Add a dependency on [remote-repl](https://github.com/vlaaad/remote-repl) to your `deps.edn`:

   ```clj
   {:aliases
    {:remote-repl {:extra-deps {vlaaad/remote-repl {:mvn/version "1.2.12"}}}}}
   ```
3. Create a "local repl" run configuration with "clojure.main" repl type, make it "Run with Deps" with `remote-repl` alias, and in Parameters specify `-m vlaaad.remote-repl :port 5555 :reconnect true`. The `:reconnect` option is especially useful — it will keep trying to connect to the REPL, which allows you to restart the REPL server and make IDE automatically restore the connection.

## Nrepl-based editors

For development workflows that require nREPL (e.g. Calva, Emacs with Cider) Reveal has a middleware that will show evaluation results produced by nrepl: `vlaaad.reveal.nrepl/middleware`, you will need to add it to your middleware list. The minimum required version of nrepl is `0.6.0`.

Example of using this middleware with command line nrepl entry point:
```sh
$ clj -A:reveal:nrepl -M -m nrepl.cmdline --middleware '[vlaaad.reveal.nrepl/middleware]'
```
Alternatively, you can create [.nrepl.edn](https://nrepl.org/nrepl/usage/server.html#server-options) file in your project directory that will be picked up by nrepl. Example `.nrepl.edn` file:

```clj
{:middleware [vlaaad.reveal.nrepl/middleware]}
```
If you are using leiningen, you can specify Reveal middleware in `project.clj`:
```clj
(defproject com.example/reveal-in-lein "1.0.0-SNAPSHOT"
  :dependencies [[org.clojure/clojure "1.10.2"]]
  :profiles {:reveal {:dependencies [[vlaaad/reveal "1.3.272"]]
                      :repl-options {:nrepl-middleware [vlaaad.reveal.nrepl/middleware]}}})
```

## Windows

It's probably a good idea to add `-Dfile.encoding=UTF-8` to JVM options.

If you want to use reveal from WSL, you will need X server (e.g. [X410](https://x410.dev/)). Make sure you have `libgtk-3-0` installed (e.g. with `sudo apt install libgtk-3-0`). If you have HiDPI screen, you should set `GDK_SCALE` env variable to appropriate scale factor (e.g. `export GDK_SCALE=2`).

# Extending reveal

There are 3 ways to extend Reveal to your needs: custom formatters, actions, and views. All three are available in `vlaaad.reveal` namespace (aliased as `r` in following examples).

One feature that they all share is annotations — non-intrusive metadata that exists alongside your objects in the Reveal state. Unlike datafy/nav based tooling, it does not obstruct your objects, leaving Clojure's metadata exactly as it is in your program, and, since the annotation is *alongside* the object, Reveal allows any object to be annotated — not just `IMeta`s.

## Formatters

Formatters define how values are shown in the output panel. Formatter dispatch is a multimethod that looks at `:vlaaad.reveal.stream/type` meta key or, if it's absent, at object's class. The recommended way to extend this multi-method is using `(defstream dispatch-val [x ann?] sf)` macro that automatically marks the formatted region with the value that is being formatted. There is a small set of functions that perform the streaming of the formatting in an efficient way called streaming functions (sfs for short).

### Low-level text emitting sfs

These are usually used in the `defstream` body to configure how something looks as text. Such sfs don't mark the text they emit with values that will be available for inspection, instead they rely on their context (e.g. `defstream`) to mark what they emit. There is only 5 of them:
- `(raw-string x style?)` and `(escaped-string x style? escape-fn escape-style?)` emit syntax-highlighted text. Both accept style map that support following keys:
  - `:fill` - text fill color, either a string like `"#ff0000"`, web color keyword like `:red`, or one of special values that define theme-dependent color:
    - `:util` for tool-related text, not values (e.g. `=>` for denoting output);
    - `:symbol` for symbol color, this is also a default color for text;
    - `:keyword` for keyword color;
    - `:string` for denoting string values;
    - `:object` for denoting composite objects that usually print some other values as a part of their text representation;
    - `:scalar` for values usually seen as indivisible, such as numbers, booleans and enums;
    - `:success` to denote success (e.g. passed tests message);
    - `:failure` to denote failure (e.g. exception);
  - `:selectable` - whether the emitted text can be selected (defaults to `true`).
- `(horizontal sf*)` and `(vertical sf*)` wrap a variable number of sfs and align them, e.g. you can think of streaming a map as horizontal `{`, entries and `}`, where in entries each entry is aligned vertically;
- `separator` visually separates emitted forms, in horizontal blocks it's a non-selectable space, in vertical blocks it's an empty line;

### Delegating sfs

These sfs allow you to stream other values using their default streaming. This is also a place to annotate the streamed values.

- `(stream x ann?)` emits a formatting for passed value — this is the heart of a formatting process;
- `(horizontally xs ann?)` and `(vertically xs ann?)` work on collections. The difference with their low-level sf counterparts is that they don't realize the whole collection before streaming. You can easily do `(vertically (range))`, and it will not block the process of streaming;
- `(items xs ann?)` guesses the formatting: depending on the input, might behave either as `horizontally` or as `vertically`. Might realize the whole collection before streaming;
- `(entries m ann?)` is a variation of `vertically` optimized for map entries.

Annotations are only useful if they are used, and they are used from actions. There is an example that configures formatting with annotations and uses these annotations for powerful data inspections [here](https://github.com/vlaaad/reveal/blob/master/examples/e01_loom_formatters_and_actions.clj).

### Overriding sfs

These sfs allow modifying some aspect of a streaming:
- `(as x ann? sf)` allows using non-default streaming function for some value x, while making `show:value` action available to view the value's default formatting. An example where this might be useful is showing identity hash code that usually has a different representation of an int to signify its meaning:
   ```clj
   (defn identity-hash-code-sf [x]
     (let [hash (System/identityHashCode x)]
       (r/as hash
         (r/raw-string (format "0x%x" hash) {:fill :scalar}))))
   ```
- `(override-style sf f args*)` transforms the text style of another sf, useful in cases where you might want to mark entire objects and their constituents differently (e.g. styling semantically "ignored" objects as grey).

## Actions

If selected text in Reveal UI has associated value, requesting a context menu on it will show a popup that checks all registered actions and suggests ones that apply. Use `(defaction id [x ann?] body*)` macro to register new actions.

Action body should return a 0-arg function to indicate that this action is available: this function will be executed when the action is selected in the context menu popup. Any other results, including thrown exceptions are ignored. The action body should be reasonobly fast (e.g. not performing disk IO) since all actions are always checked when the user asks for a popup. Returned function, on the other hand, may block for as long as needed: Reveal will show a loading indicator while it's executed.

Minimal action example that shows how strings look unescaped (e.g. display `"hello\nworld"` as `hello` and `world` on separate lines):

```clj
(r/defaction ::unescape [x]
  (when (string? x)
    #(r/as x (r/raw-string x {:fill :string}))))
```

As mentioned earlier, there is [a bigger example](https://github.com/vlaaad/reveal/blob/master/examples/e01_loom_formatters_and_actions.clj) that shows how actions and formatting can build on each other to aid with data exploration:

![Actions demo](/assets/reveal/custom-actions.gif)

You can execute registered actions programmatically by calling `(execute-action id x ann?)` — it will return future with execution result (that will be completed exceptionally if action is unavailable for supplied value). All built-in actions have `vlaaad.reveal.action` ns.

## Views

A major difference between Output panel and Results panel is that the latter can show any graphical node allowed by Reveal's UI framework ([JavaFX](https://openjfx.io/)). Reveal is built on [cljfx](https://github.com/cljfx/cljfx) — declarative, functional and extensible wrapper of JavaFX inspired by react. Reveal converts all action results to cljfx component descriptions, and if returned action result is cljfx description, it is rendered as UI component.

### Short cljfx intro

To describe a node, cljfx uses maps with a special key — `:fx/type` — that defines a type of node, while other keys define properties of that node. Value on `:fx/type` key can be a keyword (kebab-cased JavaFX class name) or a function (that receives a map of props and returns another description).
Some examples of most commonly used descriptions:

```clj
;; showing a text
{:fx/type :label
 :text (str (range 10))}

;; showing a button with a callback:
{:fx/type :button
 :text "Deploy"
 :on-action (fn [event] (deploy-to-production!))}

;; combining views together
{:fx/type :v-box ;; vertically
 :children [{:fx/type r/value-view ;; built-in component
             :value msft-stock}
            {:fx/type :h-box ;; horizontally
             :children [{:fx/type :button
                         :text "Sell"
                         :on-action (fn [_] (sell! :msft))}
                        {:fx/type :button
                         :text "Buy"
                         :on-action (fn [_] (buy! :msft))}]}]}
```
While cljfx supports using maps to define callbacks, you should only use functions — behavior of map event handling is an implementation detail that is subject to change.

To thoroughly learn cljfx/JavaFX, you should go through cljfx [readme](https://github.com/cljfx/cljfx) and [examples](https://github.com/cljfx/cljfx/tree/master/examples) to get familiar with semantics and explore [JavaFX javadoc](https://openjfx.io/javadoc/14/) to find available views.

### Built-in components

Reveal provides access to various built-in components:
- `value-view` is a default view used in Output panel for action results that are not cljfx descriptions. It shows values using streaming formatting, for example:
  ```clj
  {:fx/type r/value-view
   :value (all-ns)}
  ```
- `watch:all` and `watch:latest` actions are powered by `ref-watch-all-view` and `ref-watch-latest-view`. Additionally, there is `(observable ref fn)` utility function that allows seeing a ref through a transform — it is intended to be used with these views, for example:
  ```clj
  {:fx/type r/ref-watch-latest-view
   :ref (r/observable my-int-atom (juxt dec identity inc))}
  ```
- `observable-view` allows deriving the whole cljfx component from `IRef` state (or any other observable data source), and showing it updated live whenever the ref is mutated. There is [an example](https://github.com/vlaaad/reveal/blob/master/examples/e02_integrant_live_system_view.clj) showing how it can be used for creating live monitor and controls for [integrant](https://github.com/weavejester/integrant)-managed app state.
- `derefable-view` asynchronously derefs a blocking derefable (e.g. future or promise);
- `table-view` shows a table. Unlike `view:table` action, it does not guess the columns, instead you need to provide them yourself, for example:
   ```clj
   {:fx/type r/table-view
    :items [:foo :foo/bar :foo/bar/baz :+]
    :columns [{:fn namespace}
              {:fn name}
              {:fn #(resolve (symbol %))
               :header 'resolve}]}
   ```
   A bigger example that combines observable and table views to always show last tapped value as a table can be found [here](https://github.com/vlaaad/reveal/blob/master/examples/e04_tap_to_table.clj).
- chart views: `pie-chart-view`, `bar-chart-view`, `line-chart-view` and `scatter-chart-view`. They do not try to guess the shape of data in the same way that their corresponding actions do, e.g. line chart data sequence always has to be labeled even when there is only one data series:
  ```clj
  {:fx/type r/line-chart-view
   :data #{(map #(* % %) (range 100))}}
  ```
- action view executes action on a value and displays execution result:
  ```clj
  {:fx/type r/action-view
   :action :vlaaad.reveal.action/java-bean
   :value *ns*}
  ```
  All built-in actions have `vlaaad.reveal.action` ns.

### Pluggable context menu

Fancy visualizations don't have to be leaf nodes that you can only look at — wouldn't it be nice to select a data point on a plot and explore it as a value? Reveal supports this continued data exploration for built-in views like charts and tables out of the box. In addition to that it provides a way to install the action popup on any JavaFX node with a special component — `popup-view`:

```clj
{:fx/type r/popup-view
 :value (the-ns 'clojure.core)
 :desc {:fx/type :label
        :text "The Clojure language library"}}
```
This description shows label that you can request a context menu on, and its popup will suggest acions on `clojure.core` ns. There is [a bigger example](https://github.com/vlaaad/reveal/blob/master/examples/e03_chess_server_popups.clj) showing how to create a custom view for a chess server that displays active games as chess boards and allows inspecting any piece:

![Custom views demo](/assets/reveal/custom-views.gif)

# Interacting with Reveal from code

If value submitted to Reveal window is a map with `:vlaaad.reveal/command` key, instead of being shown in the output panel it will be interpreted as a command that will change the UI. Only queue-based windows accept commands by default (e.g. REPLs and a window created using `(ui)` fn). 

You can also use `(submit-command! ...)` fn to submit a command to all shown windows, or to submit a command to a subset of all windows filtered with predicate of window opts.

There are 2 types of commands:

## Predefined commands

There is a set of built-in commands defined in `vlaaad.reveal` namespace that you can evaluate to control Reveal window:
- `(submit value)` - submits a value to the output panel (even if the value is a command);
- `(clear-output)` - clears the output panel;
- `(open-view value)` - opens value in a result panel;
- `(all ...commands)` - executes a sequence of commands at once;
- `(dispose)` - disposes Reveal window;
- `(minimize)` - minimizes the window;
- `(restore)` - unminimizes the window;
- `(toggle-minimized)` - switches between minimized/unminimized state of the window.

## Evaluated command forms

You can evaluate code in a JVM that runs Reveal by submitting a map that has a code form on its `:vlaaad.reveal/command` key, for example:
```clj
{:vlaaad.reveal/command '(clear-output)}
```
The benefit of using this form is that you don't need to have Reveal on the classpath to construct this map, which makes it suitable for use cases where reveal might not be on the classpath, for example it can be in a committed code that taps some values during system startup that is used in development, but ignored in production. It also can be used to control Reveal when it's using remote prepls, e.g. talking to ClojureScript environment where it's impossible to have Reveal on the classpath.

By default the form will be evaluated in `vlaaad.reveal` ns, but that is configurable with `:ns` key.

You can also supply `:env` — a map of symbols to arbitrary values that will be resolvable when evaluated. This map is useful when you want to pass a value to code form without embedding it in the form, for example:
```clj
;; show public vars of this ns as table
{:vlaaad.reveal/command '(open-view {:fx/type action-view
                                     :action :vlaaad.reveal.action/view:table
                                     :value v})
 :env {'v (ns-publics *ns*)}}
```

# Reveal in media

I gave 2 talks about Reveal:
- [Reclojure 2020](https://www.youtube.com/watch?v=jq-7aiXPRKs), 24 minutes;
- [Scicloj meeting](https://www.youtube.com/watch?v=hm7LoqvaYXk), 2 hours including Q&A, cljfx and live demo.

Other videos about Reveal:
- [Practicalli](https://www.youtube.com/watch?v=1jy09_16EeY) demo, 5 minutes;
- [REPL Driven Development, Clojure's Superpower](https://www.youtube.com/watch?v=gIoadGfm5T8) by Sean Corfield (1h15m), not about Reveal per se, but uses Reveal extensively.

I also talked about Reveal on [defn](https://soundcloud.com/defn-771544745/65-vlad-protsenko) podcast (1h30m).

Various written setup instructions using Reveal:
- [Practicalli](https://practicalli.github.io/clojure/clojure-tools/data-browsers/reveal.html) page describes Reveal setup for CLI, nrepl editors, emacs (using cider) and rebel-readline;
- [Calva](https://calva.io/reveal/) page describes vscode setup with Calva extension (using both tools-deps and leiningen examples);
- my [blog post](https://vlaaad.github.io/reveal-repls-and-networking) describes various Reveal socket REPL setups that talk with remote processes.

# Closing thoughts

If repl is a window to a running program, then Reveal is an open door — and you are welcome to come in. I get a lot of leverage from the ability to inspect any object I see, and I hope you will find Reveal useful too.

If you do, please consider supporting my work either by [sponsoring the development](https://github.com/sponsors/vlaaad) of the free version or by [buying the subscription](/reveal-pro){: .buy-button} for Pro version.
