---
layout: reveal
title: "Reveal Pro: System Watchers"
permalink: /reveal/feature/system-watchers
---
If you are using component, integrant or mount, you will find it useful to have a small [sticker](https://vlaaad.github.io/reveal-stickers) window that shows current state of your dev system with controls to start and stop it. You don't need to remember if it's running or not when you can always see it!

<video controls><source src="/assets/reveal/system-watchers.mp4" type="video/mp4"></source></video>

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
