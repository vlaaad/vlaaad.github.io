---
layout: reveal
title: "Reveal: Tap Support"
permalink: /reveal/feature/tap
---

Clojure 1.10 added `tap>` function with the purpose similar to printing the value for debugging, but instead of characters you get the object. Reveal REPLs show tapped values in their output windows — you won't need `println` anymore!

<video controls><source src="/assets/reveal/tap-vs-println.mp4" type="video/mp4"></source></video>

If you don't want to use Reveal as a REPL output pane, you can instead use `(r/tap-log)` to show tapped values in a separate window.
