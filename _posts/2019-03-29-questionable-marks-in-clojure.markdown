---
layout: post
title:  "Questionable marks in&nbsp;Clojure"
date: 2019-03-29
---
Clojure's flexible syntax allows special characters such `?`, `!` or `*` to be a part of variable names, which gives ability to enhance symbols with additional meaning, but I regularly see that `?`-suffixes get misused, so I decided to make a list of dos and donts regarding question marks.

## Do: Predicates
By convention question mark suffix should be used for predicates only. It is like that in clojure core, and Stuart Holloway [also said so](https://groups.google.com/d/msg/clojure/IdSGKwTYqPU/QC0udWGuLMQJ). Example:
{% highlight clojure %}
(some? maybe-sheep)
{% endhighlight %}

## Don't: Booleans
Vars and bindings containing boolean values should not end with question mark:

{% highlight clojure %}
(let [disabled? (empty? options)]
  (if disabled? ;; meh
    (do-nothing)
    (do-something options)))
{% endhighlight %}

This is wrong because `disabled?` is not a predicate. First, using question mark here introduces confusion, because now we have symbols ending with `?` that are both functions and booleans. Second, predicate is a question, calling a predicate is asking a question and getting answer, and `disabled?` in this case is an answer. Answer to the question is affirmative: we know for sure that it is either `true` or `false`, so there is nothing questionable here.

## Don't: Keywords
Keywords are most puzzling here, because they can be invoked as functions, so it is tempting to put question mark at the end of a keyword:

{% highlight clojure %}
(filter :online? users)
{% endhighlight %}

The problem here is that keywords are not really a predicates, they don't answer a question (in a sense of computing an answer), they are just getters, and actual answer already exists as a value. Also if you destructure such map, you will again end up in a situation where you have a boolean binding ending with `?`:

{% highlight clojure %}
(let [{:keys [login online?]} user]
  [:div (str login 
             (when online? ;; meh
               " ●"))])
{% endhighlight %}

## Sometimes Do: Keywords
I think an exception here would be a keyword that corresponds to predicate function:
{% highlight clojure %}
{:width 20
 :height 40
 :big? #(<= 100 (* (:width %) (:height %)))}
{% endhighlight %}
Destructuring it will give you a `?`-ending predicate that you can call and get an answer.

Questions?