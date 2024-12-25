---
layout: reveal
title: "Reveal: Extend for your project"
permalink: /reveal/extend
---

There are 3 ways to extend Reveal to your needs: custom formatters, actions, and views.

One feature that they all share is annotations — non-intrusive metadata that exists alongside your objects in the Reveal state. Unlike datafy/nav based tooling, it does not obstruct your objects, leaving Clojure's metadata exactly as it is in your program, and, since the annotation is *alongside* the object, Reveal allows any object to be annotated — not just `IMeta`s.

* auto-gen table of contents
{:toc}

# Formatters

Formatters define how values are stringified, formatted and syntax-highlighted in the output panel. Formatter dispatch is a multimethod that looks at `:vlaaad.reveal.stream/type` meta key or, if it's absent, at object's class. The recommended way to extend this multi-method is using `(r/defstream dispatch-val [x ann?] sf)` macro that automatically marks the formatted region with the value that is being formatted. There is a small set of functions that perform the streaming of the formatting in an efficient way called streaming functions (sfs for short).

## Low-level text emitting sfs

These are usually used in the `r/defstream` body to configure how something looks as text. There are only 5 of them:
- `(r/raw-string x style?)` and `(r/escaped-string x style? escape-fn escape-style?)` emit syntax-highlighted text. Both accept style map that support following keys:
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
- `(r/horizontal sf*)` and `(r/vertical sf*)` wrap a variable number of sfs and align them, e.g. you can think of streaming a map as horizontal `{`, entries and `}`, where in entries each entry is aligned vertically;
- `r/separator` visually separates emitted forms, in horizontal blocks it's a non-selectable space, in vertical blocks it's an empty line;

## Delegating sfs

These sfs allow you to stream other values using their default streaming. This is also a place to annotate the streamed values.

- `(r/stream x ann?)` emits a formatting for passed value — this is the heart of a formatting process;
- `(r/horizontally xs ann?)` and `(r/vertically xs ann?)` work on collections. The difference with their low-level sf counterparts is that they don't realize the whole collection before streaming. You can easily do `(r/vertically (range))`, and it will not block the process of streaming;
- `(r/items xs ann?)` guesses the formatting: depending on the input, might behave either as `r/horizontally` or as `r/vertically`. Might realize the whole collection before streaming;
- `(r/entries m ann?)` is a variation of `r/vertically` optimized for map entries.

Annotations are only useful if they are used, and they are used from actions. There is an example that configures formatting with annotations and uses these annotations for data inspections [here](https://github.com/vlaaad/reveal/blob/master/examples/e01_loom_formatters_and_actions.clj).

## Overriding sfs

These sfs allow modifying some aspect of a streaming:
- `(r/as x ann? sf)` allows using non-default streaming function for some value x, while making `view:value` action available to view the value using its default formatting. An example where this might be useful is showing identity hash code that usually has a different representation of an int to signify its meaning:
   ```clj
   (defn identity-hash-code-sf [x]
     (let [hash (System/identityHashCode x)]
       (r/as hash
         (r/raw-string (format "0x%x" hash) {:fill :scalar}))))
   ```
- `(r/override-style sf f args*)` transforms the text style of another sf, useful in cases where you might want to mark entire objects and their constituents differently (e.g. styling semantically "ignored" objects as grey).

# Actions

If selected text in Reveal UI has associated value, requesting a context menu on it will show a popup that checks all registered actions and suggests ones that apply. Use `(r/defaction id [x ann?] body*)` macro to register new actions.

Action body should return a 0-arg function to indicate that this action is available: this function will be executed if the action is selected in the context menu popup. Any other results, including thrown exceptions, are ignored. The action body should be reasonobly fast (e.g. not performing disk IO) since all actions are always checked when the user asks for a popup. Returned function, on the other hand, may block for as long as needed: Reveal will show a loading indicator while it's executed.

Minimal action example that shows how strings look unescaped (e.g. display `"hello\nworld"` as `hello` and `world` on separate lines):

```clj
(r/defaction ::unescape [x]
  (when (string? x)
    #(r/as x (r/raw-string x {:fill :string}))))
```

As mentioned earlier, there is [a bigger example](https://github.com/vlaaad/reveal/blob/master/examples/e01_loom_formatters_and_actions.clj) that shows how actions and formatting can build on each other to aid with data exploration.

You can execute registered actions programmatically by calling `(r/execute-action id x ann?)` — it will return future with execution result (that will be completed exceptionally if action is unavailable for supplied value). All built-in action keyword ids use `vlaaad.reveal.action` namespace, e.g. `:vlaaad.reveal.action/java-bean`.

# Views

A major difference between Output panel and Results panel is that the latter can show any graphical node allowed by Reveal's UI framework ([JavaFX](https://openjfx.io/)). Reveal is built on [cljfx](https://github.com/cljfx/cljfx) — declarative, functional and extensible wrapper of JavaFX inspired by react. Reveal converts all action results to cljfx component descriptions, and if returned action result is cljfx description, it is rendered as UI element.

## Short cljfx intro

To describe a node, cljfx uses maps with a special key — `:fx/type` — that defines a type of node, while other keys define properties of that node. Value on `:fx/type` key can be a keyword (kebab-cased JavaFX class name) or a function (that receives a map of props and returns another description).

Some examples of most commonly used descriptions:

```clj
;; Showing a text
{:fx/type :label
 :text (str (range 10))}

;; Showing a button with a callback:
{:fx/type :button
 :text "Deploy"
 :on-action (fn [event] (deploy-to-production!))}

;; Combining views together
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

## Built-in views

All built-in views that you can use and compose are described in the [views section](/reveal/use#using-views) of using reveal at the REPL documentation.

## Pluggable context menu

Fancy visualizations don't have to be leaf nodes that you can only look at — wouldn't it be nice to select a data point on a plot and explore it as a value? Reveal supports this continued data exploration for built-in views like charts and tables out of the box. In addition to that it provides a way to install the action popup on any JavaFX node with a special component — `r/popup-view`:

```clj
{:fx/type r/popup-view
 :value (the-ns 'clojure.core)
 :desc {:fx/type :label
        :text "The Clojure language library"}}
```
This description shows label that you can request a context menu on, and its popup will suggest acions on `clojure.core` ns. There is [a bigger example](https://github.com/vlaaad/reveal/blob/master/examples/e03_chess_server_popups.clj) showing how to create a custom view for a chess server that displays active games as chess boards and allows inspecting any piece.
