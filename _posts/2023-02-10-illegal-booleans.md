---
layout: post
title: "Reveal now highlights illegal booleans in Clojure"
description: "If you are wondering what the hell is illegal booleans, read this post — it will save you some headaches in the future"
---

I made [Reveal](/reveal/) — Read Eval Visualize Loop for Clojure — a set of visual tools aiming to improve the development experience by providing better access to the data in your JVM. One core ideas in Reveal is using value-aware syntax-highlighting to display the output to the user, so you can immediately see a difference between e.g. a symbol `clojure.lang.Ratio` and a class `clojure.lang.Ratio`. The newest version of Reveal (Free `1.3.279`, Pro `1.3.357`) introduces a new highlight.

## What are illegal booleans

An illegal boolean is an instance of Boolean that is neither `Boolean/TRUE` nor `Boolean/FALSE`, e.g. a manually created instance of a Boolean like `(Boolean. true)`. They are problematic in Clojure because of its implementation of truthiness — while the semantics define truthiness as "everythin is truthy except nil and false", it is implemented as "everything is truthy except nil and `Boolean/FALSE`". This means `(Boolean. false)` is truthy in Clojure. It's bad. It's a great time sink that can drive you wild if you don't know about it and you see a `false` acting as `true` in your code. 

And what's worse, you can get those pesky little booleanses accidentally.

## When can you get illegal booleans

Of course, no one ever writes `(Boolean. false)`, but new boolean instances will be created if you use reflection:

```clj
(let [eq-meth (.getDeclaredMethod Object "equals" (into-array Class [Object]))]
  (def eq? #(.invoke eq-meth %1 (into-array Object [%2]))))

(eq? 1 2)
=> false ;; So far so good...

(if (eq? 1 2) :equal :not-equal)
=> :equal ;; What the fuuuu....
```

...Yep. The Boolean constructor is deprecated since Java 9, but it's left for compatibility and JVM will create new booleans in cases such as this.

## How Reveal helps you spot the problem

In the newest release of Reveal, you will now be able to spot the problem earlier:

![img](/assets/2022-02-10/img.png)

Neat, isn't it?

## How to fix the problem

If you find illegal booleans in your code, you should find the place where they originate from and wrap it with `boolean` call like so:

```clj
(let [eq-meth (.getDeclaredMethod Object "equals" (into-array Class [Object]))]
  (def eq? #(boolean (.invoke eq-meth %1 (into-array Object [%2])))))

(eq? 1 2)
=> false ;; So far so good...

(if (eq? 1 2) :equal :not-equal)
=> :not-equal ;; Whew!
```

Hope this helps!