---
layout: post
title: "Tripping around REPL"
description: "In which I'm talking round-tripping, syntax highlighting, and even switching namespaces"
---

What does it mean, tripping around? Is it about round-tripping values between the REPL and the editor? Or about tripping over obstacles? In this post, I talk about both!

# Round-tripping

In the context of REPL use, round-tripping means a particular property of printed data: the printed string representation of data, if evaluated, produces an equivalent data structure. For example, this map is round-trippable:
```clj
{
    :a 1 
    :b true 
    "str" 0
}
```
If you print it, you'll get the same thing back. This is very useful because it speeds up development at the REPL: maps can be copied, saved, loaded, programmatically re-read, you get the point. 

Some things cannot be round-tripped. Take this function, for example:
```clj
;; normal Clojure REPL
user=> assoc
#object[clojure.core$assoc__5416 0x4a9486c0 "clojure.core$assoc__5416@4a9486c0"]
```
Function is not data; it cannot always be round-tripped exactly, so you get this. It makes sense to a degree, though I don't like it. The utility of round-tripping during development far outweighs the drawback of some inaccuracy. For this reason, [Reveal](https://vlaaad.github.io/reveal/) — Read Eval Visualize Loop for Clojure — always used this representation instead:
```clj
;; Reveal REPL output
assoc
=> clojure.core/assoc
```
Why did I use this representation? Two reasons:
1. It is round-trippable. I can copy a data structure with a function from the Reveal output pane into REPL, and it will evaluate to the same function without problem.
2. Due to syntax highlighting, it is visually distinct from symbol `clojure.core/assoc`:
   <img src="/assets/tripping-around-repl/assoc.png" style="width: 398px;">

Did you notice `#_0x4a9486c0` after the function name? This is a new addition to the Reveal function printer, available in [Reveal 1.3.296](https://clojars.org/vlaaad/reveal/versions/1.3.296). It fixes a problem I was tripping over from time to time.

# Tripping over identity

Default Clojure representation of a function includes an important bit of information: the object's identity hash code. Identity matters, and hiding it makes it harder to discover identity-related issues; for example:
- When comparing objects for equality to determine if some computation has to be repeated, using a function as a part of a "cache entry" requires care. <small>Yes, I have a custom `partial` implementation with equality semantics in production.</small>
- Using objects with unique identity as keys requires care.

One particular gotcha is regex: instances of `java.util.regex.Pattern` do **NOT** define value equality and hash code. This means using them as keys is dangerous. This is why Reveal also shows regexes with their identity:
<img src="/assets/tripping-around-repl/regex.png" style="width: 397px;">

Yes, this code is not even a duplicate key error:
```clj
{#"a|b" :a-or-b
 #"a|b" :a-or-b}
```

You might ask, why use `#_0xcafebabe` to show identity? Well, that's because it does not sacrifice round-tripping! `#_` is a reader macro that ignores the next form, and `0xcafebabe` is a valid, complete Clojure form. With this approach, you can both:
- see identities of objects
- copy them from the output pane to the editor, evaluate, and get (more or less) equivalent objects, whose identities, again, you can see.

# More round-tripping with syntax highlighting

Syntax highlighting adds color — an extra dimension to printed data that allows for differentiating related things when the text is the same. Earlier, I showed how the symbol `clojure.core/assoc` and the function `clojure.core/assoc` use the same text, but different colors. But there is more! If we can use colors to differentiate symbols and functions, we can use them to differentiate objects and Clojure forms that produce such objects when evaluated. What kinds of objects? Refs! Futures! Files! Other stuff!

<img src="/assets/tripping-around-repl/objects.png" style="width: 556px;">

When dogfooding this feature, I found it important to use a separate color for parens, making them grey so they are not mistaken for collections (which also use parens — of yellow color). I think it's very useful!

# Tripping over namespaces (in Cursive)

In the final part of the post, I want to talk about using socket REPL in [Cursive](https://cursive-ide.com/). I've been using it with Reveal for ages. One aspect in which a socket REPL is inferior to nREPL is automatic switching of a namespace to the current file. Cursive — a Clojure plugin for Intellij IDEA — only sends evaluated forms verbatim when using socket REPL. This means every time you switch between Clojure files in IDEA, you need to trigger a shortcut that will explicitly switch the ns so that sent forms will evaluate without errors. It's annoying that I have to have this habit.

Had to have this habit. Turns out, since Cursive also sends file and line as form metadata, Reveal (or any other REPL implementation, really) can infer the right namespace for evaluation by inspecting the file content. The newest version of [Reveal](https://vlaaad.github.io/reveal/) now supports this (under a flag, but enabled by default)! This means Reveal, when used as a socket REPL in IDEA, will now automatically evaluate forms in the right namespace — this greatly improves the experience!

<video controls><source src="/assets/tripping-around-repl/socket-repl.mp4" type="video/mp4"></source></video>