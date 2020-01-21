---
layout: post
title: "Transparent Functions with Equality Semantics"
description: "You don't have them. Do you need them? How do you get them?"
---

## Opaque and transparent functions

Opaque functions are functions that encapsulate all the state and scope they have and provide only one interaction interface: invoke. This is how functions in Clojure operate by default, and this seems to be a great fundamental building block.

By transparent functions I mean functions that might also be data, meaning they provide some sort of additional insight into what kind of scope they have, possibly allowing to create derived functions with changed scope, and by being data, additionally providing equality semantics. 

There are good reasons why functions are opaque by default: 
- It is very hard to define equality for functions. The class name of a function is not a guarantee of equality. Bytecode or source code equivalence is not enough if function closes over some state. Functions with equal behavior on any input can have different code structure.
- You can't easily serialize function as you can serialize data. Putting function that closes over database connection on a wire just does not make any sense.

## Partial transparency

With that said, for *some* functions it's very easy to define equality semantics. For `partial` it's equality of wrapped function and arguments. For `comp` it's a chain of wrapped functions. For `constantly` it's its return value. Middleware pattern (wrapping functions with functions) can be viewed as the interceptor chain. 

## How to make transparent functions

The trick is to define a record that implements `IFn` interface. That way you get a function that is also a map, so you can create derived functions by changing it as a map. Example:

```clojure
(defrecord Add [x]
  clojure.lang.IFn
  (invoke [_ y]
    (+ x y)))
;; => user.Add

(def add-5 (->Add 5)) 
;; => #user.Add{:x 5}

(def add-6 (update add-5 :x inc))
;; => #user.Add{:x 6}

(add-6 1)
;; => 7
```

If you want it to work with `apply`, you will also need to override `applyTo` method defined on `IFn`.

## Do you need it?

I've felt the need for transparent functions twice, and both times later I decided to achieve my goals using other means, so it might be a sign of some issues with the approach taken. That's why I decided against writing a helper library to reduce [boilerplate](https://github.com/reagent-project/reagent/blob/8de886d8b15132070d66bff86796e11e6f51536e/src/reagent/impl/util.cljs#L62-L115) that might be involved. Hopefully, you'll find it useful at least as food for thought.

What do you think?