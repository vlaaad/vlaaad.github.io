---
layout: reveal
title: "Reveal: windows and stickers"
permalink: /reveal/windows-and-stickers
---
Reveal lives in the process where the development happens, and this means it has to be a separate OS window: it can't be integrated into an IDE or text editor. To make Reveal easier to use, it provides 2 types of windows:
- ordinary windows, better for bigger screens and multi-monitor setups;
- sticker windows, more suitable for smaller screens and single-monitor setups;

# Ordinary windows

When you are using ordinary windows, you place them alongside your text editor or IDE. Reveal windows remember their location, so you won't have to move them on every REPL launch. It's good if your text editor or IDE can remember its location too.

![Ordinary Reveal Window](/assets/reveal/ordinary-window.png)

# Sticker windows

Stickers are small windows that are shown always on top of other windows. Using these, you can create an overlay over your text editor or IDE that can be used to show REPL output and temporary inspection popups. It's good if your text editor or IDE lives on a separate virtual desktop so other windows won't be blocked by the stickers.

![Ordinary Reveal Window](/assets/reveal/sticker-window.png)

# Setting window type

All reveal functions that open a window accept parameters to configure the window. Window type is configured with `:always-on-top` paramater, which should be set to `true` for sticker windows and to `false` for ordinary windows.