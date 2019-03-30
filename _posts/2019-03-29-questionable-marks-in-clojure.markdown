---
layout: post
title:  "Questionable marks in&nbsp;Clojure"
date: 2019-03-29
---
Clojure's flexible syntax allows special characters such `?`, `!` or `*` to be a part of variable names, which gives ability to enhance symbols with additional meaning, but I regularly see that `?`-suffixes get misused, so I decided to make a list of dos and donts regarding question marks.

## Do: Predicates
By convention question mark suffix should be used for predicates only. It is like that in clojure core, and, if you like Appeal to Authority, Stuart Holloway [also said so](https://groups.google.com/d/msg/clojure/IdSGKwTYqPU/QC0udWGuLMQJ). Example:
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

It's simple to understand what's wrong here: `disabled?` is not a predicate. First, using question mark here introduces confusion, because now we have symbols ending with `?` that are both functions and booleans. Second, predicate is a question, calling a predicate is asking a question and getting answer, and `disabled?` in this case is an answer. Answer to the question is affirmative: we know for sure that it is either `true` or `false`, so there is nothing questionable here.

## Don't: Keywords
Keywords are most puzzling here, because they can be invoked as functions, so it is tempting to put question mark at the end of a keyword:

{% highlight clojure %}
(filter :online? users)
{% endhighlight %}

This is problematic because if you have code like this, you also have these keywords as identifiers for data. Using keywords that way is affirmative, there are no questions here, only assertions of facts:

{% highlight clojure %}
(def system-user
  {:login "system"
   :online? true}) ;; meh
{% endhighlight %}

Also, if you destructure map with such keys, you will again end up in a situation where you have a boolean binding ending with `?`:

{% highlight clojure %}
(let [{:keys [login online?]} user]
  [:div (str login 
             (when online? ;; meh
               " ●"))])
{% endhighlight %}

In my experience I've seen more uses of such keywords as data identifiers than as predicates.

## Sometimes Do(?): Keywords
I think an exception here could be a keyword that corresponds to predicate function:
{% highlight clojure %}
{:width 20
 :height 40
 :big? #(<= 100 (* (:width %) (:height %)))}
{% endhighlight %}
Destructuring it will give you a `?`-ending predicate that you can call and get an answer, which makes sense

What do you think?