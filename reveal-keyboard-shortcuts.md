---
layout: reveal
title: "Reveal: Keyboard Shortcuts"
permalink: /reveal/keyboard-shortcuts
---
Reveal can be fully controlled using keyboard. The single most important shortcut is <kbd>Space</kbd> (or <kbd>Enter</kbd>) to open a context menu on a selected object.

# Window

These shortcuts work in Reveal window:

| Key Combination                     | Action                                                                                        |
|-------------------------------------|-----------------------------------------------------------------------------------------------|
| <kbd>Tab</kbd>                      | Switch focus to next focusable UI element (e.g. switch between output and result panels)      |
| <kbd>Shift Tab</kbd>                | Switch focus to previous focusable UI element                                                 |
| <kbd>F11</kbd> / <kbd>⌘⇧M</kbd>     | Toggle between maximized and unmaximized window state                                         |
| <kbd>Alt F11</kbd> / <kbd>⌘M</kbd>  | Toggle between minimized and unminimized window state                                         |
| <kbd>Space</kbd> / <kbd>Enter</kbd> | Open context menu (works on Reveal views that display data, e.g. output panel, tables, trees) |
| <kbd>Escape</kbd>                   | Close a closable UI element (e.g. conext menu, results panel, temporary inspector popup)      |

# Output panel 

These shortcuts work in the output panel — syntax-highlighted text-like UI:

| Key Combination                                                     | Action                                   |
|---------------------------------------------------------------------|------------------------------------------|
| <kbd>←</kbd> <kbd>↑</kbd> <kbd>→</kbd> <kbd>↓</kbd>                 | Textual navigation of data structures    |
| <kbd>Alt ←</kbd> <kbd>Alt ↑</kbd> <kbd>Alt →</kbd> <kbd>Alt ↓</kbd> | Structural navigation of data structures |
| <kbd>/</kbd> / <kbd>Ctrl F</kbd> / <kbd>⌘F</kbd>                    | Search the output panel                  |
| <kbd>Ctrl L</kbd>                                                   | Clear the output panel                   |

# Context menu

These shortcuts work in an action context menu (opened by pressing <kbd>Space</kbd> or <kbd>Enter</kbd>) on selected object:

| Key Combination                           | Action                                                                   |
|-------------------------------------------|--------------------------------------------------------------------------|
| <kbd>↑</kbd> <kbd>↓</kbd>                 | Switch focus between available actions and eval form input text field    |
| <kbd>Enter</kbd>                          | Execute selected action or evaluate the form written in the text field   |
| <kbd>Alt ↑</kbd> <kbd>Alt ↓</kbd>         | In the text field: traverse history of previously evaluated code forms   |
| <kbd>Ctrl Enter</kbd> / <kbd>⌘Enter</kbd> | Execute action or form and open the result in a new results panel        |
| <kbd>Shift Enter</kbd>                    | Execute action or form and open the result in a temporary sticker window |


# Results panel

These shortcuts work in a results panel that shows result of some previously selected action:

| Key Combination                                                   | Action                                                                                      |
|-------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| <kbd>Ctrl ←</kbd> <kbd>Ctrl →</kbd> / <kbd>⌘←</kbd> <kbd>⌘→</kbd> | Switch between result tabs in the results panel                                             |
| <kbd>Ctrl ↑</kbd> / <kbd>⌘↑</kbd>                                 | Open results panel's tab tree that provides hierarchical overview of all tabs in this panel |
| <kbd>Backspace</kbd>                                              | In the tab tree: close currently selected tab                                               |
