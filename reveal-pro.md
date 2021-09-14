---
layout: reveal
title: "Reveal Pro:<br>Read Eval Visualize Loop for&nbsp;Clojure, Supercharged"
permalink: /reveal-pro
---

| [![Clojars Project](https://img.shields.io/clojars/v/dev.vlaaad/reveal-pro.svg?logo=clojure&logoColor=white&style=for-the-badge)](https://clojars.org/dev.vlaaad/reveal-pro) | [![Slack Channel](https://img.shields.io/badge/slack-%20%23reveal-blue.svg?logo=slack&style=for-the-badge)](https://clojurians.slack.com/messages/reveal/) |

* auto-gen table of contents
{:toc}

# What is Reveal Pro

Reveal stands for Read Eval Visualize Loop, it's a REPL output pane that lives in the JVM and provides powerful data inspection capabilities.

Reveal Pro is a fork of Reveal that has everything there is in Reveal and more. While Reveal intends to be infinitely extensible tool for inspecting and developing Clojure programs, Reveal Pro aims to be batteries included so you can focus on your problems with data you need, available as soon as you need it.

Reveal Pro costs $9.99 per month — [start a trial](https://buy.stripe.com/8wM9Dz5bKand5ck3cc){: .buy-button}!

# Getting started

1. Add a dependency on Reveal Pro, e.g.

   ```sh
   $ clj \
     -Sdeps '{:deps {dev.vlaaad/reveal-pro {:mvn/version "1.3.241"}}}' \
     -X vlaaad.reveal/repl
   ```

2. [Start a trial here](https://buy.stripe.com/8wM9Dz5bKand5ck3cc){: .buy-button}.

3. Once you start a trial, you'll receive an email with Reveal Pro license key — paste it into a license input field. 

You are good to go!

# Unique features

## Forms

Forms allow you to convert data structure specifications to UI input components that look like a specified data structure. This is a generic and multi-purpose tool that supports Clojure spec out of the box and can be extended to other data specification libraries.

What leverage can it give you?

1. Learn possible shapes of expected data.

   Specs describe the data shape, but looking at the spec is not the easiest way to understand what are the possible shapes for the specified data. Do you remember all the clauses `ns` form supports? Where to look for available `:gen-class` options? With Forms, you can learn all that simply starting from the `clojure.core/ns` symbol:

   ![ns form demo](/assets/reveal-pro/ns-form.gif)

2. Explore data-driven APIs

   Form state is a ref that can be observed — you can watch it and create derived views that refresh on form changes:

   ![explore form demo](/assets/reveal-pro/explore.gif)

3. Create data structures with contextual help

   Forms provide contextual actions and information on selectable parts of data structures that you can activate by pressing <kbd>F1</kbd> or <kbd>Ctrl Space</kbd>. For example, with spec forms you can use fine-grained generators to generate parts of the data structures. You can also copy and paste these data structures as text:

   ![contextual help demo](/assets/reveal-pro/create.gif)

## File system support

Reveal Pro adds support for Java's file system APIs that allow navigating folders and zip/jar archives. Explore your classpath:

![fs demo](/assets/reveal-pro/fs.gif)

## ...And more are on the way

I intend to add more features in the future, like:
- database exploration support (e.g. Datomic);
- more specification sources for Forms (e.g. Malli).

# Subscription management and cancellation


How to manage cancellation

terms of service

privacy policy
