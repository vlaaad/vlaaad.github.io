---
layout: redirected
permalink: /reveal-pro
redirect_to: /reveal
---

![Demo](/assets/reveal-pro/main.gif)

| [![Clojars Project](https://img.shields.io/clojars/v/dev.vlaaad/reveal-pro.svg?logo=clojure&logoColor=white&style=for-the-badge)](https://clojars.org/dev.vlaaad/reveal-pro) | [![Slack Channel](https://img.shields.io/badge/slack-%20%23reveal-blue.svg?logo=slack&style=for-the-badge)](https://clojurians.slack.com/messages/reveal/) |

* auto-gen table of contents
{:toc}

# What is Reveal Pro

Reveal Pro is an improved version of [Reveal](/reveal/) that aims to be batteries included so you can focus on your problems with data and knowledge you need, available as soon as you need it. 

It is a fork of Reveal that should be used instead of Reveal, not alongside it.

Reveal Pro costs $9.99 per month — [start a free trial](https://buy.stripe.com/8wM9Dz5bKand5ck3cc){: .buy-button}! For residents or citizens of Ukraine Reveal Pro is free forever — use "PUTINKHUILO" promocode during checkout.

# Getting started

Here are the steps needed to start using Reveal Pro:

1. Add a dependency on Reveal Pro, e.g.

   ```sh
   $ clj \
     -Sdeps '{:deps {dev.vlaaad/reveal-pro {:mvn/version "1.3.408"}}}' \
     -X vlaaad.reveal/repl
   ```

2. [Start a free trial here](https://buy.stripe.com/8wM9Dz5bKand5ck3cc){: .buy-button}.

3. Once you start a trial, you'll receive an email with the Reveal Pro license key — paste it into a license input field in the Reveal Pro window. 

You are good to go!

# Configuration

Everything the applies to Reveal also applies to Reveal Pro (sans the dependency coordinate), see [Reveal docs](/reveal/) for all available configuration options and instructions.

# Unique features

## SQL DB explorer

You can get a better view of SQL database you use in your project using `db:explore` action on your JDBC connection source description (e.g. DataSource instance, JDBC URL or, if you use [next.jdbc](https://github.com/seancorfield/next-jdbc) or [clojure.java.jdbc](https://github.com/clojure/java.jdbc), a db spec map).

Here is what you can do with DB explorer:

1. Visualize database schema.

   You can view your database in the same way you think about it — as a graph with relations.

   <video controls><source src="/assets/reveal-pro/db-schema.mp4" type="video/mp4"></source></video>

2. Explore relational data across multiple tables without writing joins.

   You can load data from multiple tables using schema-aware relation and column picker. In the same picker interface, you can apply free-form filters to columns, quickly getting the data you need.

   <video controls><source src="/assets/reveal-pro/db-explore-table.mp4" type="video/mp4"></source></video>

3. Work with query results in the REPL.

   Working with data loaded from the database usually requires post-processing. With this explorer, you don't need to perform an export/import step that is necessary with external SQL clients — query results are available in the REPL as simple data structures.

   <video controls><source src="/assets/reveal-pro/db-table-to-repl.mp4" type="video/mp4"></source></video>

## Forms

Forms allow you to convert data structure specifications to UI input components for creating these data structures. This is a generic and multi-purpose tool that supports Clojure spec and json schema out of the box and can be extended to other data specification libraries.

What leverage can it give you?

1. Learn possible shapes of expected data.

   Specs describe the data shape, but looking at the spec is not the easiest way to understand what are the possible shapes for the specified data. Do you remember all the clauses `ns` form supports? Where to look for available `:gen-class` options? With Forms, you can learn all that simply starting from the `clojure.core/ns` symbol:

   ![ns form demo](/assets/reveal-pro/ns-form.gif)

2. Explore data-driven APIs

   Form state is a ref that can be observed — you can watch it and create derived views that refresh on form changes:

   ![explore form demo](/assets/reveal-pro/explore.gif)

3. Create data structures with contextual help

   Forms provide contextual actions and information on selectable parts of data structures that you can activate by pressing <kbd>F1</kbd> or <kbd>Ctrl Space</kbd>. For example, with spec forms, you can use fine-grained generators to generate parts of the data structures. You can also copy and paste these data structures as text:

   ![contextual help demo](/assets/reveal-pro/create.gif)

Forms are available either with:
- `form:spec` contextual action on Clojure specs;
- `vlaaad.reveal.pro.form` ns that allows creating fine grained forms as well as reactive views that update on form state changes, e.g.:
  ```clj
  (require '[vlaaad.reveal.pro.form :as form]
           '[clojure.spec.alpha :as s])

  {:fx/type form/form-view
   :form (form/spec-alpha-form `ns)}
  ```
  After evaluating this map, you can select `view` action on it in Reveal Pro window to see the form. Tip: see [Interacting with Reveal from code](/reveal/#interacting-with-reveal-from-code) to be able to immediately open the form without having to interact with Reveal window.

## Vega forms

Since [Vega(-Lite)](https://vega.github.io/) provides json schemas that are supported by Forms, it is very useful to explore [vega visualizations](/reveal/#vega-lite-visualizations) using Form views:

<video controls><source src="/assets/reveal-pro/vega-form-view.mp4" type="video/mp4"></source></video>

Vega forms are available with:
- `view:vega-form` action on vega datasets — collections of maps or collections of numbers (as well as on refs that point to vega datasets);
- `vlaaad.reveal/vega-form-view` view that shows both vega editor form and vega visualization, e.g.:
  ```clj
  (require '[vlaaad.reveal :as r])
  #reveal/inspect {:fx/type r/vega-form-view
                   :spec {:data {:name "source"}
                          :mark {:type "line"}
                          :encoding {:x {:field "data" :type "quantitative"}
                                     :y {:field "data" :type "quantitative"}}}
                   :data {"source" (range 1000)}}
  ```

## System watcher stickers

If you are using component, integrant or mount, you will find it useful to have a small [sticker](https://vlaaad.github.io/reveal-stickers) window that shows current state of your dev system with controls to start and stop it. You don't need to remember if it's running or not when you can always see it!

<video controls><source src="/assets/reveal-pro/system-stickers.mp4" type="video/mp4"></source></video>

System watcher stickers are available in `vlaaad.reveal` ns:

```clj
(require '[vlaaad.reveal :as r])

;; mount can be used straight away
(r/mount-sticker)

;; integrant requires system ref and config
(r/integrant-sticker :ref #'my-system :config my-integrant-config)
;; integrant repl library support: uses integrant.repl's system state and config
(r/integrant-repl-sticker)

;; component has no way to tell if system is running, so you need to tell it
(r/component-sticker :ref #'my-system :running #(-> % :db :connection))
```

## File system navigation

Reveal Pro adds support for Java's file system APIs that allow navigating folders and zip/jar archives. Explore your classpath:

![fs demo](/assets/reveal-pro/fs.gif)

## ...And more are on the way

More tools are being developed for Reveal Pro that aim to solve common development problems. You can stay up to date and talk to me or other Reveal users in [#reveal](https://clojurians.slack.com/messages/reveal/) channel of Clojurians slack.

# Subscription management and cancellation

When you start a trial and receive a license key, you'll also get a subscription management link where you'll be able to change the payment method or cancel the subscription. You can also write to [reveal@vlaaad.dev](mailto:reveal@vlaaad.dev) to request cancellation.

After your trial period, you will automatically be billed monthly. You may cancel your subscription at any time. You are responsible for the full subscription fee in the monthly billing cycle in which you cancel. Once your account has been billed, all sales are final and there will be no refunds. You'll be able to continue using Reveal Pro after cancellation until the end of the billing cycle.

See also: [terms of service](/reveal-pro/terms) and [privacy policy](/reveal-pro/privacy).
