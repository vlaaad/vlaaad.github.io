---
layout: reveal
title: "Reveal: Customization"
permalink: /reveal/customize
---

Reveal bundles light and dark themes and allows for font customization:

![Light and Dark themes](/assets/reveal/customize.png)

Reveal is customized using `vlaaad.reveal.prefs` java property that defines and edn map with following optional keys:

| Key            | Value                                                                         |
|----------------|-------------------------------------------------------------------------------|
| `:theme`       | Theme, `:light` or `:dark`                                                    |
| `:font-family` | System font name (like `"Consolas"`) or URL (like `"file:/path/to/font.ttf"`) |
| `:font-size`   | Font size, number                                                             |

Example:
```sh
clj \
-Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.3.295"}}}' \
-J-Dvlaaad.reveal.prefs='{:font-family "Consolas" :font-size 15}' \
-X vlaaad.reveal/repl
```
