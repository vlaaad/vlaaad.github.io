---
layout: reveal
title: "Reveal: Main concepts"
permalink: /reveal/main-concepts
---
![Concepts](/assets/reveal/concepts.png)

Reveal UI is made of 3 components: output panel, context menus and results panels

They work together to enable data inspection.

# Output panel

Output panel is a main view of Reveal window. By default, it shows data submitted to the window (e.g. REPL output), but it can be configured to show any UI element whatsoever. 

# Context menus

Views that show user-submitted data allow selecting some parts of the data and then executing actions on it using context menu. A list of actions is contextual, and can be extended by the user from the code. In addition to predefined actions, context menu has a text input that allows to evaluate any code on selected object.

# Results panels

After executing action on some selection, the resulting view is displayed in a results panel. Any subsequent results are shown by default in the same panel, but you can change this behavior to either open a new results panel (by holding <kbd>Ctrl</kbd>/<kbd>⌘</kbd> when selecting an action) or open a new popup window (by holding <kbd>Shift</kbd>).
