---
layout: post
title:  "Dream language"
description: "Dream language"
date: 2019-09-20
---
> Developers know value of everything and trade-offs of nothing

Here is what I want my dream language to be
What kinds of problems this dream language should be trying to solve?

# semantics related

## REPL like excel — update affected results automatically

## The best protocol method count is 1

(defprotofn datafy [x] "convert x into its data representation")
(extendprotofn datafy Throwable [t] (Throwable->map t))
(extendprotofn datafy nil [x] x)
(extendprotofn datafy Object [x] x)

## not static types, but a whole-program change aid

Main benefit of static types is being more or less able to answer the question "what will be affected if I change this into that?". The question is asked by changing this into that, and the answer is a list of compiler errors.

## purity and immutability to emit efficient code?

Another (the last) benefit of static typing is the ability to emit efficient code if compiler can see certain invariants

## transducer framework

semantics are wonderful. extend it to less transducery functions like group-by? extend it to support parallelism?

# non-important

## Name
It should have a name that is at least 2 syllables long. It should be nice to pronounce. It should not be a generic word like rust or go. You don't have to add suffix "lang" in a search term to find information about it on the internet.

## indentation: 3 spaces

## syntax

Lisp is better than C-style syntax, but I don't like it even in Clojure. I'm not a fan of `let` syntax in clojure: it's verbose and has visual nesting. I think placing variable declaration and using it on the next line already semantically implies nesting. I like macros though. I'm fine with slightly harder syntax to parse — as a human, I'm used to that. Perhaps indentation-based?

(let [x 1]
  (+ x 5))

(let x 1)
(+ x 5)

## violent formatter. 





## Performance and size are priorities from day 1
## Expressive power

## Less code, faster feedback
It is not known whether statically or dynamically typed languages produce more reliable programs. Dynamic languages allow summing strings and numbers. 
Faster feedback
## First-class dependencies
When importing a namespace, I should be able to refer to it by more than a name: maybe a version or even a full repo url:
```
import https://github.com/user/library@v12
```
During develop
It's probably tedious to repeat it in every ns. maybe define it once and then simply refer to that definition?

## Release-debug separation
## Cross-platform
## Immutability
## Type system
## Static-dynamic synergy 
## Macros
## Optimization
## Greppable
## Testing support 
## ide support
## formatter
## development over time
## No implementation inheritance
### Epilogue
No silver bullet.