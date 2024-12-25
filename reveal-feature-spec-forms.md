---
layout: reveal
title: "Reveal Pro: Forms"
permalink: /reveal/feature/spec-forms
---
Reveal Pro's Forms allow you to convert data structure specifications to UI input components for creating these data structures. This is a generic and multi-purpose tool that supports Clojure spec and JSON Schema out of the box and can be extended to other data specification libraries.

What leverage can it give you?

1. Learn possible shapes of expected data.

   Specs describe the data shape, but looking at the spec is not the easiest way to understand what are the possible shapes for the specified data. Do you remember all the clauses `ns` form supports? Where to look for available `:gen-class` options? With Forms, you can learn all that simply starting from the `clojure.core/ns` symbol:

   <video controls><source src="/assets/reveal/ns-form.mp4" type="video/mp4"></source></video>

2. Explore data-driven APIs

   Form state is a ref that can be observed — you can watch it and create derived views that refresh on form changes:

   <video controls><source src="/assets/reveal/observable-form.mp4" type="video/mp4"></source></video>

3. Create data structures with contextual help

   Forms provide contextual actions and information on selectable parts of data structures that you can activate by pressing <kbd>F1</kbd> or <kbd>Ctrl Space</kbd>. For example, with spec forms, you can use fine-grained generators to generate parts of the data structures. You can also copy and paste these data structures as text:

   <video controls><source src="/assets/reveal/form-create.mp4" type="video/mp4"></source></video>

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
