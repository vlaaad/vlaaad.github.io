---
layout: reveal
title: "Reveal: Graphviz Viewer"
permalink: /reveal/feature/graphviz
---
[Graphviz](https://graphviz.org/) is a well-known data visualization software. You can create graphs using a simple text language, for example:
```
digraph { a -> b }
```
With Reveal, you can view such graphs by selecting a `graphviz` action on strings that start with `"graph"` or `"digraph"`:

<img src="/assets/reveal/graphviz-shot.png" style="width: 50%; height: auto;">

Additionally, `graphviz` action can watch refs (such as vars) so you can incrementally build the graph description with live feedback:

<video controls><source src="/assets/reveal/graphviz.mp4" type="video/mp4"></source></video>
