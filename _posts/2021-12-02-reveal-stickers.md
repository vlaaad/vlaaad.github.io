---
layout: post
title: "Reveal stickers"
description: "You'll be surprised what side of the laptop these stickers apply to..."
---

The year is 2011. "It's just a jar", you say to your colleagues, adding Clojure to the classpath. They look at you with disbelief as you cackle diabolically, and open a real-time chat with Mrs. Eval, a witch of Java Vast Magicland. She gives you the power to debug and fix a running server without ever restarting it again.

Present times. "It's just a jar", you say to your colleagues, adding Reveal to the classpath. They look at you with disbelief as you cackle diabolically, and your screen opens a vortex directly to the JV Magicland. "I can finally see it with my own eyes" are the last words your colleagues hear from you as you jump into the vortex. Now you are no longer restricted to conjure JVM magic, as well as observe the spells' effects, through a letter correspondence with Mrs. Eval.

Ahem.

I made [Reveal](/reveal/) — Read Eval Visualize Loop for Clojure. One defining property of Reveal is that it runs in the JVM, which allows for some [deep object exploration](/reveal/#inspect-object-fields-and-properties) capabilities and [live views](/reveal/#ref-watchers). This comes with a trade-off.

# The Reveal trade-off

The main trade-off when using Reveal is that it comes as an OS window separate from your IDE. This means that when you use it as a REPL, you have to arrange your desktop so your IDE takes roughly 3/4 of the screen, with the Reveal REPL window taking the other 1/4. You have to sacrifice some of your screen space for REPL output that you don't even need 60% of the time — most REPL evaluation results are small and would be better off inlined in the code buffer. It sucks.

# A new old hope

When I was going through my notes about Reveal, the very first note with an idea of this project describes "a tool that pops up small popup windows (like postit notes/devcards) that are always on top, easily closable and don't steal focus when created/shown". This idea started Reveal, and I think there is value in this approach because it's a non-intrusive overlay that can be easily integrated into existing IDE-based dev workflows. And now Reveal finally works this way! I'm proud to present Reveal stickers — a new approach to developing with Reveal that is released in Reveal Free v1.3.250 and [Reveal Pro](/reveal-pro){: .buy-button} v1.3.293.

Reveal stickers are small always-on-top windows that you can:

- create with whatever view you want;
- arrange on your screen in a place that will be remembered by the window the next time it's shown;
- maximize and restore to its designated place with a single keypress;
- minimize all at once for moments when you need your full focus on IDE.

This allows you to make your IDE take the whole screen while Reveal consumes as little screen space as you want, and you can more easily focus on data explorations that require more screen space. It also makes it more convenient to use Reveal without Reveal REPL or Reveal nREPL middleware, since you can create stickers in the REPL.

Let's see what's fresh out of the oven:

# Built-in stickers

## Tap log

If you don't use Reveal REPL or Reveal nREPL middleware, at least you should be using tap log, and you should be using `tap>` instead of `println`. The difference in usefulness for debugging is immense! 

To show a tap log, you need to invoke `vlaaad.reveal/tap-log` fn:

```clj
(require '[vlaaad.reveal :as r])

(r/tap-log)
```

Then you can make it as small as you want and keep it around on top of your IDE. When you need to inspect some big tapped data structure, you can do so by focusing the window and pressing <kbd>F11</kbd> (<kbd>Cmd Shift M</kbd> on mac) to toggle maximized window state.

Here is an example showing tap log in a situation where I create an endpoint for a web server and use `tap>` to inspect ring request map in search for a handler param that is supplied in a URI path:

<video controls><source src="/assets/2021-12-02/tap-log.mp4" type="video/mp4"></source></video>

## Inspect

Sometimes you need to inspect some value that is hard to explore as text. You can open a temporary sticker that can be closed by pressing <kbd>Escape</kbd>:
```clj
;; Use vlaaad.reveal/inspect fn to open inspector sticker
(r/inspect (map bean (all-ns)))

;; It might be easier to use reader tag if you 
;; don't have vlaaad.reveal ns required in current ns
#reveal/inspect (map bean (all-ns))
```
You can also open inspector popups by pressing <kbd>Shift Enter</kbd> instead of <kbd>Enter</kbd> when selecting and Reveal action to execute for some value. 

<video controls><source src="/assets/2021-12-02/inspect.mp4" type="video/mp4"></source></video>

# Custom stickers

Now, this is where things get interesting. You can use and compose various built-in views to create an overlay that matches the system you are developing. Is there some state you always have to mentally keep track of? Maybe an Integrant or Component or Mount system that is either running or not? Make it visible in a small sticker so you can always know (and control!) its current state.

Here is an [example](https://github.com/vlaaad/reveal/blob/master/examples/e02_integrant_live_system_view.clj):

<video controls><source src="/assets/2021-12-02/sticker.mp4" type="video/mp4"></source></video>

By default, this window will remember its bounds per window title, so it's easy to define a specialized place for a sticker just by giving it a distinct title.

# Convert Reveal REPLs to stickers

In the tradition of keeping things as simple as possible, stickers are implemented as a bunch of independent options. While the default presentation for Reveal REPLs is a boring OS window, you can easily convert these to stickers by supplying `:always-on-top true` option, e.g.

```sh
clj \
-Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.3.250"}}}' \
-X vlaaad.reveal/repl :always-on-top true
```
If you use Reveal as a REPL server, you can add this option to `:args` of a launcher alias, e.g.:
```clj
:reveal-server {:exec-fn clojure.core.server/start-server
                :exec-args {:name "reveal-server"
                            :port 5555
                            :accept vlaaad.reveal/repl
                            :args [:always-on-top true]
                            :server-daemon false}}
```

# Editor integration

Now you can easily configure Reveal to play nicely with your IDE setup. What else might be needed? I think some light editor integration can still be useful: some predefined forms that you might want to send to your REPL bound to shortcuts — like the "REPL Command" feature in Cursive. In my experience with using stickers, I found 2 commands useful as a starting point:

## Inspect the last result

Most of the time, the value you want to inspect is an evaluation result of the latest code form you submitted to REPL. For that, I use the following REPL command:

```clj
#reveal/inspect *1
```

## Minimize/unminimize all stickers at once

Sometimes you need a full screen space of your IDE. Looking at you merge conflict resolution UI... For that case, I find it useful to have the following REPL command at the ready:

```clj
(vlaaad.reveal/submit-command! :always-on-top (vlaaad.reveal/toggle-minimized))
```

# The end

Now you know how to use Reveal stickers to setup an overlay with live view of your system that is easy to manage. Give it a try and tell me what you think!