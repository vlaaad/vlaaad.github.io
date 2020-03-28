---
layout: post
title: "Year of Clojure on the Desktop"
description: "With cljfx and Java 14 it's finally here"
---
What is Clojure's use case? [In theory](https://www.quora.com/What-are-the-best-use-cases-for-using-Clojure-for-new-development/answers/653524), it's any situation where JVM is a reasonable choice, but especially for high concurrency and processing large amounts of data. In practice, it's mostly used on the backend for servers. Java is also widely used on Android, but Clojure is [rarely a good choice there](https://blog.ndk.io/state-of-coa.html) due to it's startup time.

## An unexpected journey

Another area where JVM is useful is desktop applications. With web browsers eating the front-end world it's a hard choice, especially with tools like Electron allowing to have the same code base for both web and desktop apps. Countless resources spent on making DOM and Javascript VMs
as efficient and approachable as possible make it a solid choice for many types of applications despite the historical baggage.

I think that even though the web is more popular then ever there are still use cases where JVM is a better choice as an application platform, and coincidentally, these use cases align perfectly with Clojure's advantages over other JVM languages:
- browser-based technology struggles to utilize multiple cores in the same VM instance, while Clojure's immutability by default, concurrency primitives and core.async make writing multi-threaded code a breeze;
- javascript VMs choke on processing large amounts of data, which leaves them a better fit for advanced interactive forms than compilers or data processing pipelines;
- Clojure's REPL-aided development with fast feedback loop is perfect for tinkering with UI, as opposed to compile-and-restart-the-app-and-then-navigate-the-UI-to-see-your-change approach of other languages.

Until recently there were 2 other huge selling points of the web over JVM that are finally getting addressed: react model and app distribution.

## React model

[React](https://reactjs.org/) changed UI development for the better. It brought it's complexity sure, but also it made creating consistent UI wonderfully simple. Funnily enough, Clojure's [equality semantics](https://clojure.org/guides/equality) play extremely well with react model: [reagent](http://reagent-project.github.io/) — ClojureScript wrapper of React — outperforms plain React a lot of the time due to optimizations that re-render components only when their inputs change. 

[JavaFX](https://openjfx.io/) is the largest [supported](https://www.oracle.com/technetwork/java/javafx/overview/faq-1446554.html#6) desktop application platform for the JVM. Clojure has [cljfx](https://github.com/cljfx/cljfx) — declarative, functional and extensible react-like wrapper of JavaFX (which I wrote). Here is an example of a cljfx component:

```clj
(defn todo-view [{:keys [text id done]}]
  {:fx/type :h-box
   :spacing 5
   :padding 5
   :children [{:fx/type :check-box
               :selected done
               :on-selected-changed {:event/type ::set-done :id id}}
              {:fx/type :label
               :style {:-fx-text-fill (if done :grey :black)}
               :text text}]})
```
As you can see, it's a simple function that returns simple data structures: bread and butter of Clojure code. You may notice that it can use event maps (in addition to functions) for event listeners to decouple logic from representation. Another thing to notice is that JavaFX uses styling similar to how it's done on the web: with inline styles or external CSS files. In addition to inline styles being composable data in cljfx, there is also [cljfx/css](https://github.com/cljfx/css) library that allows configuring CSS using same data structures and code.

## App distribution

The problem of compiling a javascript app with various dependencies has many different solutions, and once you bake that js file just right, all you need to do to deliver it to users is upload it to a server. Java compilation, on the other hand, produces classes and jar files that still require JVM to be executed. JVM also needs to be distributed. In addition to that, there are platform differences: apps for Linux are usually in `deb` or `rpm` format, for macOS — `pkg` or `dmg`, for Windows — `msi` or `exe`. 

Thankfully, Java 14 that was released earlier this year includes a new tool called [jpackage](https://openjdk.java.net/jeps/343) that deals with packaging self-contained applications. It does all the heavy lifting needed to produce a platform-specific application package. Using jpackage, it's now easy to create an app from the jar, and all that's left to do is upload it to a server to allow users to download and install it.

What can be a better example of what is possible with Clojure on the desktop than a simple sample application? I made [Hacker News Reader](https://github.com/cljfx/hn) app that shows how cljfx, cljfx/css and jpackage can be used together to create an installable application. You can even [download it](https://github.com/cljfx/hn/releases) and give it a try — packages are built using Github Actions.

## Closing thoughts

I think JVM has a sweet spot for desktop apps that lies between interactive forms / [typesetting](https://www.arp242.net/webui.html) that web is good at and extremely resource-intensive apps like games / 3D modeling software that need to be written in something lower-level. In the middle of that sweet spot, there is Clojure and cljfx that allow developing UI interactively with instant feedback — in the live app, not some static UI builder. It's not all rainbows: JavaFX has some issues here and there, but it's nice nonetheless. [Editors for game engines](https://defold.com/) can be written in Clojure. [Advanced visual REPLs](https://github.com/vlaaad/reveal) can be written in Clojure. Give it a try.

What do you think? Discuss [on reddit](https://www.reddit.com/r/Clojure/comments/fqimas/year_of_clojure_on_the_desktop/).