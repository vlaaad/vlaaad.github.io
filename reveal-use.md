---
layout: reveal
title: "Reveal: Use at the REPL"
permalink: /reveal/use
---
In addition to using Reveal as a REPL output pane, you can also use Reveal at the REPL to create and show various views. All Reveal public functions live in `vlaaad.reveal` namespace, which is assumed to be aliased to `r` in following Clojure snippets.

* auto-gen table of contents
{:toc}

# Launching REPLs

These functions are mainly intended to be invoked from the command line via `-X`.

## repl

It is a repl that wraps `clojure.main/repl` with additional support for `:repl/quit` and `tap>`. It is as simple as it gets. I use it all the time. Example:

```sh
clj \
-Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.3.312"}}}' \
-X vlaaad.reveal/repl :always-on-top true
# Reveal sticker window appears
Clojure 1.10.1
user=>
```

## io-prepl

This prepl works like `clojure.core.server/io-prepl`. Its purpose is to be run in a process on your machine that you want to connect to using another prepl-aware tool. Example:

```sh
clj \
-Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.3.312"}}}' \
-J-Dclojure.server.reveal='{:port 5555 :accept vlaaad.reveal/io-prepl}'
```
Now you can connect to this process using any socket repl and it will show a new Reveal sticker (always-on-top) window for every connection:
```sh
nc localhost 5555
# Reveal sticker window appears
# Input:
(+ 1 2 3) 
# Prepl output (+ displayed in Reveal):
{:tag :ret, :val "6", :ns "user", :ms 1, :form "(+ 1 2 3)"} 
```

## remote-prepl

Reveal is the most useful when it runs in the process where the development happens. This prepl, unlike the previous two, is not like that: it connects to a remote process and shows a window for values that arrived from the network. It can't benefit from easy access to printed references because these references are pointing to values deserialized from bytes, not values in the target VM. It's still nice and performant repl, and it's useful when you want to use Reveal to talk to another process that does not have Reveal on the classpath (e.g. production or ClojureScript prepl).

Example:
1. Start a prepl without Reveal on the classpath:
   ```sh
   clj \
   -Sdeps '{:deps {org.clojure/clojurescript {:mvn/version "1.10.764"}}}' \
   -J-Dclojure.server.cljs-prepl='{:port 50505 :accept cljs.server.browser/prepl}'
   ```
2. Connect to that prepl using Reveal:
   ```
   clj \
   -Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.3.312"}}}' \
   -X vlaaad.reveal/remote-prepl :always-on-top true :port 50505
   # at this point, 2 things happen:
   # 1. Browser window with cljs prepl appears
   # 2. Reveal window opens

   # Input:
   js/window

   # Output:
   {:tag :ret,
    :val #object [Window [object Window]],
    :ns "cljs.user",
    :ms 25,
    :form "js/window"}
   ```

# Opening windows

## ui

Calling this function will create and show a Reveal window. It returns a function that you can submit values to — they will appear in the output panel. All built-in visual REPLs use a window created by this generic function. Example:

```clj
;; Create and show a window
(def window (r/ui))
;; Submit huge data structure that is hard to explore when printed:
(window (map bean (all-ns)))
```

## tap-log

To display tapped values in Reveal window without using Reveal as a REPL, you can use the specialized tap log window:

```clj
;; Open a window that will show tapped values:
(r/tap-log)
;; Submit values from anywhere to the window:
(tap> (all-ns))
```

## inspect

You can open a new temporary sticker window for value inspection using `r/inspect` or `#reveal/inspect` data reader:

```clj
;; Inspect all loaded namespaces
#reveal/inspect (all-ns)
```

## sticker

This is a generic sticker window that is similar to `inspect`. It exists for a different purpose though — creating longer-lived always-on-top windows for frequently used views (e.g. Component/Integrant/Mount state trackers). It's harder to close — you need to use close window shortcut like <kbd>Ctrl W</kbd> instead of <kbd>Escape</kbd>.

```clj
;; Simple mount sticker window:
(r/sticker 
  {:fx/type r/ref-watch-latest-view
   :ref @#'mount.core/running}
  :title "mount system")
```

# Using views

Reveal uses [cljfx](https://github.com/cljfx/cljfx) — declarative, functional and extensible wrapper of JavaFX inspired by react — for its views. In short, views are described using maps with a special key — `:fx/type` — that defines a type of UI element, while other keys define properties of that element. 

Value windows like `r/inspect` and `r/sticker` will show cljfx UI descriptions as UI elements instead of maps. Reveal provides a variety of different cljfx description functions to inspect data.

## Test runner views

Reveal provides a test runner for Clojure tests that you can start from the REPL, for example:
```clj
;; Show test runner for running tests defined in current ns:
#reveal/inspect {:fx/type r/test-runner-view
                 :runner (r/test-runner *ns*)}
;; Or a test view with internally managed runner:
#reveal/inspect {:fx/type r/test-view
                 :test *ns*}

;; Show test runner sticker that only displays a test summary with controls
;; (You can click the summary to open the full output in a new inspector popup)
(r/sticker 
  {:fx/type r/test-runner-controls-view
   :runner (r/test-runner)}
  :title "Project tests")
;; Or show a built-in sticker with managed runner:
(r/test-sticker)
```

## Vega(-Lite) views

Reveal provides Vega(-Lite) visualizations out of the box:
```clj
(r/inspect {:fx/type r/vega-view
            :spec {:mark :bar
                   :encoding {:x {:field :a
                                  :type :nominal
                                  :axis {:labelAngle 0}}
                              :y {:field :b
                                  :type :quantitative}}}
            :data [{:a "A" :b 28}
                   {:a "B" :b 55}
                   {:a "C" :b 43}
                   {:a "D" :b 91}
                   {:a "E" :b 81}
                   {:a "F" :b 53}
                   {:a "G" :b 19}
                   {:a "H" :b 87}
                   {:a "I" :b 52}]})
```

## Ref watchers

You can watch IRef instances (like Vars, Atoms, Agents and Refs) in a live-updated views:
```clj
;; Show the current state of the system
(r/inspect {:fx/type r/ref-watch-latest-view
            :ref #'my.app/integrant-system})

;; Show a log of all state changes of the system
(r/inspect {:fx/type r/ref-watch-all-view
            :ref #'my.app/integrant-system})

;; Iterate on vega spec with vega view that is auto-updated on Var redefinition
(r/inspect {:fx/type r/observable-view
            :ref #'my-vega-spec
            :fn r/vega-view})
```

## Derefable view

This view asynchronously derefs a blocking derefable (e.g. future or promise) and eventually shows the result (or thrown exception):

```clj
(r/inspect {:fx/type r/derefable-view
            :derefable (future (Thread/sleep 10000))})
```

## Table

This view shows a collection of values in a table:
```clj
(r/inspect {:fx/type r/table-view
            :columns [{:fn identity} {:fn first}]
            :items [[:a 1] {:a 1} "a=1"]})
```
## Tree

This view shows a tree-like data structure as a tree view. The API is similar to `tree-seq`. It is fine to run long-running computations (like performing http requests) in `:children` fn.
```clj
(r/inspect {:fx/type r/tree-view
            :root [0 [1 [2] [[3]]] [4 [5 [[6 7 8]]]]]
            :branch? seqable?
            :children seq})
```

## Built-in charts

You can use built-in JavaFX charts with Reveal:
```clj
;; Pie chart
(r/inspect {:fx/type r/pie-chart-view 
            :data {:a 1 :b 2}})

;; Bar chart
(r/inspect {:fx/type r/bar-chart-view
            :data {:me {:apples 10 :oranges 5}
                   :you {:apples 3 :oranges 15}}})

;; Line chart
(r/inspect {:fx/type r/line-chart-view
            :data {:squared (map #(* % %) (range 100))
                   :linear (range 100)}})

;; Scatter chart
(r/inspect {:fx/type r/scatter-chart-view
            :data {:uniform (repeatedly 500 #(vector (rand) (rand)))
                   :gaussian (repeatedly 500 #(vector (* 0.5 (+ (rand) (rand)))
                                                      (* 0.5 (+ (rand) (rand)))))}})
```

## Action view

Reveal provides a variety of contextual actions for objects. You can invoke them from the REPL using action view:
```clj
(r/inspect {:fx/type r/action-view
            :action :vlaaad.reveal.action/java-bean
            :value #'inc})
```

## Value view

This view shows any object using Reveal's syntax-highlighting formatting that allows selecting objects for further inspection, e.g.:
```clj
#reveal/inspect {:fx/type r/value-view
                 :value (all-ns)}
```
This is actually identical to just inspecting the value without explicit cljfx description.

# Interacting with Reveal windows from code

If value submitted to Reveal window is a map with `:vlaaad.reveal/command` key, instead of being shown in the output panel it will be interpreted as a command that will change the UI. Only queue-based windows accept commands by default (e.g. REPLs and a window created using `(r/ui)` fn). 

You can also use `(r/submit-command! ...)` fn to submit a command to all shown windows, or to submit a command to a subset of all windows filtered with predicate of window opts.

There are 2 types of commands: predefined commands and evaluated command forms

## Predefined commands

This is a list of built-in commands that you can evaluate to control Reveal window:

| Command                | Effect                                                            |
|------------------------|-------------------------------------------------------------------|
| `(r/submit value)`     | Submit value to the output panel (even if the value is a command) |
| `(r/clear-output)`     | Clear the output panel                                            |
| `(r/open-view value)`  | Open value in a result panel                                      |
| `(r/all ...commands)`  | Execute a sequence of commands at once                            |
| `(r/dispose)`          | Dispose Reveal window                                             |
| `(r/minimize)`         | Minimize the window                                               |
| `(r/restore)`          | Unminimize the window                                             |
| `(r/toggle-minimized)` | Switch between minimized/unminimized state of the window          |

These are pure functions that return maps with `:vlaaad.reveal/command` key.

## Evaluated command forms

You can evaluate code in a JVM that runs Reveal by submitting a map that has a code form on its `:vlaaad.reveal/command` key, for example:
```clj
{:vlaaad.reveal/command '(clear-output)}
```
The benefit of using this form is that you don't need to have Reveal on the classpath to construct this map, which makes it suitable for use cases where reveal might not be on the classpath, for example it can be in a committed code that taps some values during system startup that is used in development, but ignored in production. It also can be used to control Reveal when it's using remote pREPLs, e.g. talking to ClojureScript environment where it's impossible to have Reveal on the classpath.

By default the form will be evaluated in `vlaaad.reveal` ns, but that is configurable with `:ns` key.

You can also supply `:env` — a map of symbols to arbitrary values that will be resolvable when evaluated. This map is useful when you want to pass a value to code form without embedding it in the form, for example:
```clj
;; Show public vars of this ns as table
{:vlaaad.reveal/command '(open-view {:fx/type action-view
                                     :action :vlaaad.reveal.action/view:table
                                     :value v})
 :env {'v (ns-publics *ns*)}}
```

# Reveal Pro only functionality

You get extra features when using paid version of Reveal.

## Forms

Forms allow you to convert data structure specifications to UI input elements for creating these data structures. This is a generic and multi-purpose library that supports Clojure spec and json schema out of the box and can be extended to other data specification libraries. This library has a big API surface, so it lives in a separate namespace — `vlaaad.reveal.pro.form`.

```clj
;; Add forms ns
(require '[vlaaad.reveal.pro.form :as form])

;; Open a view for creating data structure defined by spec
(r/inspect {:fx/type form/form-view 
            :form (form/spec-alpha-form `ns)})

;; Open a view for creating data structures defined by JSON schema
(r/inspect {:fx/type form/form-view 
            :form (form/json-schema-form "https://vega.github.io/schema/vega/v5.json")})

;; ...Or use bundled Vega(-Lite) form:
(r/inspect {:fx/type form/form-view 
            :form (form/vega-form)})
```

## Vega form view

In addition to forms for creating Vega(-Lite) specifications, Reveal Pro bundles a Vega(-Lite) form view with a live-updated corresponding visualization:
```clj
(r/inspect {:fx/type r/vega-form-view})
```

## System stickers

If you are using component, integrant or mount, you will find it useful to have a small sticker window that shows current state of your dev system with controls to start and stop it:

```clj
;; Mount can be used straight away
(r/mount-sticker)

;; Integrant requires system ref and config
(r/integrant-sticker :ref #'my-system :config my-integrant-config)
;; Integrant REPL library support: uses integrant.repl's system state and config
(r/integrant-repl-sticker)

;; Component has no way to tell if the system is running, so you need to tell it
(r/component-sticker :ref #'my-system :running #(-> % :db :connection))
```

There are corresponding cljfx description view functions, e.g. `r/mount-view` etc.

## Resources sticker

Resources sticker window shows memory and CPU utilization by JVM:
```clj
(r/resources-sticker)
```

Like with system stickers, there is a corresponding `r/resources-view` that you can use to embed the view into other views.
