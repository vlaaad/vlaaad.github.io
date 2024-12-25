---
layout: reveal
title: "Reveal Pro: JSON Schema and Vega(-Lite) Forms"
permalink: /reveal/feature/json-schema-forms
---
Reveal Pro's Forms allow you to convert data structure specifications to UI input components for creating these data structures. This is a generic and multi-purpose tool that supports Clojure spec and JSON Schema out of the box and can be extended to other data specification libraries.

Since [Vega(-Lite)](https://vega.github.io/) provides JSON Schemas that are supported by Forms, it is very useful to explore [vega visualizations](/reveal/feature/vega) using Form views:

<video controls><source src="/assets/reveal/vega-form.mp4" type="video/mp4"></source></video>

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
