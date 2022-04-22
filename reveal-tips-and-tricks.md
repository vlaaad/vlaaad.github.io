---
layout: reveal
title: "Reveal: Tips and tricks"
permalink: /reveal/tips-and-tricks
---
Here you can find some tips to effectively using Reveal:

# Use tap> instead of println

Printing objects while developing converts them to strings — this makes inspecting them further impossible. All Reveal REPLs (and `r/tap-log` window) show `tap>`-ed values as themselves, allowing deeper introspection:

<video controls><source src="/assets/reveal/tap-vs-println.mp4" type="video/mp4"></source></video>

# Use observable views on Vars for iterative development

Reveal provides observable view — `r/observable-view` — that can be used to derive continuously updated view from some mutable ref like atoms. Vars are also mutable refs. You can watch changes to Vars as you redefine them during development and show a view of their contents or some computation results involving the var. This is especially useful when you work on something visual:

<video controls><source src="/assets/reveal/vega-view.mp4" type="video/mp4"></source></video>

# Add REPL command in your IDE to control sticker windows

When using Reveal sticker windows that overlay your IDE or text editor, you might want to hide them temporarily from time to time for some IDE-related tasks that take a lot of screen space — like using code diffing tools. To ease this process of hiding/showing the sticker windows, you can add a following REPL command that can be triggered with some keystrokes from your IDE:

```clj
(vlaaad.reveal/submit-command! :always-on-top (vlaaad.reveal/toggle-minimized))
```

Evaluating this code will toggle minimized/unminimized state of all shown sticker windows.
