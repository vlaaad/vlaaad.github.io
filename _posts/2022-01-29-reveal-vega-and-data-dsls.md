---
layout: post
title: "Reveal, Vega and data DSLs"
description: "Reveal Free now supports Vega(-Lite) visualizations out of the box. Reveal Pro now solves the difficulty of writing Vega(-Lite) specs."
---

I made [Reveal](/reveal/) — Read Eval Visualize Loop for Clojure — a set of visual tools aiming to improve the development experience by providing better access to the data in your JVM.

# Vega view

[Vega(-Lite)](https://vega.github.io/) is a data visualization library that uses declarative syntax (JSON) to describe charts. Its data-driven API is a good match for Clojure, where everything revolves around simple data structures. While it was [always possible](/vega-in-reveal) to view Vega(-Lite) visualizations in Reveal, it required some setup, and I'm pleased to announce that the newest Reveal release — `1.3.265` — now bundles a proper Vega viewer!

In addition to displaying Vega visualizations, new [vega-view](https://github.com/vlaaad/reveal/blob/aefa8e921175a06e0ee330bed090bcf7950cafc8/src/vlaaad/reveal.clj#L640) includes:
- support for separating data from vega spec that results in a faster update performance for streaming visualizations;
- styling that matches Reveal's look-and-feel;
- visualization auto-sizing by default;
- 2-way signal binding: both providing signals to the visualization and reacting to signal changes in the JVM;
- support for [vega-embed](https://github.com/vega/vega-embed) options.

Here is what it looks like:

<video controls><source src="/assets/reveal/vega-view.mp4" type="video/mp4"></source></video>   

# On data DSLs

Now that we saw some Vega in action, I'd like to discuss something bothering me about data DSLs. Let me start with what I mean by data DSL in Clojure — a pattern of using data structures in a bespoke format to drive some behavior. It's a common and popular way to program in Clojure, and some examples of this approach include:

- [cljfx/css](https://github.com/cljfx/css) to define CSS;
- [weavejester/hiccup](https://github.com/weavejester/hiccup) to define HTML;
- [noprompt/garden](https://github.com/noprompt/garden) to define CSS;
- [metosin/reitit](https://github.com/metosin/reitit) to define routing;
- [seancorfield/honeysql](https://github.com/seancorfield/honeysql/) to build SQL queries;
- Vega(-Lite) wrappers like Reveal's vega view to define visualizations;
- [cljfx/cljfx](https://github.com/cljfx/cljfx) to define dynamic JavaFX UI.

Data structures are a fantastic building material — easily serialized and extensively supported by Clojure standard library — so data DSLs are rightfully widespread in the Clojure ecosystem. Isn't it amazing to write something small and simple that defines a non-trivial visualization?

```clj
{:mark "line"
 :encoding {:x {:field "date"
                :type "temporal"}
            :y {:field "price"
                :type "quantitative"
                :scale {:type "log"}}
            :color {:field "ticker"}}}
```

I would say yes, but only if you know the Vega language. Not all data DSLs are created equal, and some DSLs (like Vega language) have high complexity in terms of behaviors they define and the options they support. 

And here is the problem: data DSLs are a layer of indirection, and there is nothing my IDE can help me with when I assemble the data structures since they are context-free until executed by the engine.

# Solutions

Depending on the difficulty level of data DSLs, there are different solutions for alleviating this problem:
- "easy" DSLs like hiccup don't need anything since they have no learning curve;
- "medium" DSLs rely on extensive documentation (reitit, honeysql) and helper functions (honeysql) whose purpose is to give the developer some autocomplete for building data structures;
- "hard" DSLs like cljfx or Vega require looking at the source or searching for examples on the web.

There also exist data structure specification libraries like [Clojure Spec](https://clojure.org/guides/spec) that can be helpful in this area. They excel at validating data shapes and describing the errors, but they are not very helpful at suggesting available options when creating the data structures. Looking at specs to figure out expected data shapes is not necessarily easier than searching the documentation. While modern editors provide autocomplete support for JSON documents annotated with [JSON Schema](https://json-schema.org/), it is not always sufficient to get an overview of all available data shapes.

I've been thinking about this problem area for a while and eventually created [Reveal Pro](/reveal-pro){: .buy-button} Forms: a tool that converts data structure specifications (like specs) to interactive UI elements that help with creating data structures satisfying the specifications and exploring possible data shapes.

I'm happy to announce that in addition to Clojure Spec, Forms in the newest release of Reveal Pro — `1.3.330` — now support JSON Schemas! 

How is this related to Vega(-Lite)? 

# Vega Forms

Vega(-Lite) provides JSON schemas for their visualization specifications. It means it is now possible to use [Reveal Pro](/reveal-pro){: .buy-button} for creating Vega visualizations with a UI that:

- allows exploring and learning available options in Vega that is more exhaustive than JSON Schema autocompletion of [Vega editor](https://vega.github.io/editor/);
- creates Clojure data structures that satisfy Vega(-Lite) specification;
- shows a live view of visualization.

In addition to generic JSON Schema Forms, Reveal Pro provides Vega(-Lite) JSON schemas and their corresponding forms out of the box. Here is what it looks like in action:

<video controls><source src="/assets/reveal-pro/vega-form-view.mp4" type="video/mp4"></source></video>

So there you have it. Reveal Free now supports Vega(-Lite) visualizations out of the box. Reveal Pro simplifies creating Vega(-Lite) visualizations with interactive forms. Give it a try and tell me what you think!