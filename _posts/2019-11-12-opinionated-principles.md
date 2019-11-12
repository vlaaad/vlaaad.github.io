---
layout: post
title: "Clojure Don't: Buy Into Principles and Opinions"
description: "Break the chains of OCD"
date: 2019-11-12
---
## Highly-opinionated for what?

Too often I find myself carried away by trying to do something The Correct Way™ without really thinking if following such a way really does benefit me even where it gets clunky. I see that everywhere around me: people talk about not going into extremes in some area and then blindly do it in another, [myself included of course](/2019-03-30/question-marks-in-clojure).

And then I look at Clojure's source code and... Don't you find it's style puzzling? [Java](https://github.com/clojure/clojure/blob/master/src/jvm/clojure/lang/RT.java) is formatted really weird, and all Clojure core namespaces are [incredibly inconsistent](https://github.com/clojure/clojure/blob/master/src/clj/clojure/stacktrace.clj#L70-L85) in their indentation. 

## Recognizing patterns

The reason for this is simple: it does not matter. Style does not matter *so much* people build violent formatters that enforce one particular style so they don't have to argue about it. And while gofmt is everyone's favorite, gofmt's style is no one's favorite. People will never find common ground because it's all subjective and irrelevant to actual purpose code exists. Yes, code has to be readable, but readability is about what code does, not about satisfying one's OCD. There is an alternative to violent formatters: just stop bringing up formatting "issues" in code reviews.

It's natural to search for patterns. Highlighting a recognized pattern brings joy, that's why we do it. But we should try to recognize that these patterns are not necessary rules that we should codify and enforce, because many of them work at most 80% of the time, and Clojure is all about [situated programs](https://www.youtube.com/watch?v=2V1FtfBDsLU) that adapt.

## Some examples

Is it okay to have local mutable state? Yes! It does not matter if you use some local mutable counter to simplify logic instead of writing recursive algorithms carrying lots of state around — the problem with mutability is *shared* mutable state, not isolated one. Clojure does it under the hood all the time with transients and transducers (note: in 95% of cases it is still better to use immutable data transformations, just don't stand by it when it gets ugly).

Do you need to sort requires alphabetically? No! Finding if require exists is either seen immediately if list is small or requires ctrl+f is list is big, there is no benefit to it, and if you think you do it to reduce potential merge conflicts, I'd suggest you to compare the time you spend on resolving such conflicts to time it takes to keep requires sorted.

Should you use transducers for every fully-realized collection processing because they are more performant? No, they are hard to read and should be left to performance-critical parts of application (which are, by the way, probably not what you think they are — use profilers first, [and more](https://www.youtube.com/watch?v=r-TLSBdHe1A))!

Do we have to flat-out [disallow multi-arg lambdas](https://stuartsierra.com/2019/09/15/clojure-donts-numbered-parameters)? Is it really hard to read?
```clj
(defn counts [xs]
  (reduce #(update %1 %2 (fnil inc 0)) 
          {} 
          xs))
```
I don't think so.

Is it okay to have `:snake_cased` or `:camelCased` keywords? Yes, keywords are just powerful names, if you receive them like that, just process them like that!

If react-like UI framework suggests to use everything as data, but [leaves showing system file dialog to be a blocking call](https://github.com/cljfx/cljfx/pull/40#issuecomment-543934176), should it be fixed? No, the purpose of data-driven UI is UI-related state synchronization and developer convenience, not imposing particular world view for the sake of it.

Do we have to disregard any conventions from now on? No! This blog post is the same — opinion that should not be taken to an extreme.

## Summary

There is a good reason some principles exists: they capture valuable information about their domain to reduce cognitive load and aid with taking the right turns. It's just so easy to fall into trap of codifying arbitrary patterns into such principles. I would recommend to ask yourself on decision points during programming: does it really matters, or do I do it to satisfy my own OCD?