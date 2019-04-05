---
layout: post
title: "Growing cljfx"
description: "When releasing cljfx, I decided to opt in accretion / relaxation / fixation approach to growing an open source project, and now I want to share why I did it and how it's been so far"
date: 2019-04-05
---
When releasing [cljfx](https://github.com/cljfx/cljfx), a declarative, functional and extensible wrapper of JavaFX inspired by better parts of react and re-frame, I decided to opt in accretion / relaxation / fixation approach to growing an open source project, and now I want to share why I did it and how it's been so far.

## Broken Versioning?

In Rich Hickey's [Spec-ulation](https://www.youtube.com/watch?v=oyLBGkS5ICk) talk he argues that semantic versioning is broken, because it allows breaking changes. This rings very true to me. On every long project I worked at, updating dependencies allways been en exercise in dealing with frustration. This is not limited to semantic versioning, there are other versioning approaches, such as [break versioning](https://github.com/metosin/reitit/blob/master/CHANGELOG.md) that reitit uses, which is even worse, because it mimics semantic versioning, but screws you even on minor version updates. 

And, as Rich then says, the underlying problem is not a versioning scheme per se, it's that open source projects are expected to have breaking changes. In other languages it might be less avoidable, but Clojure's idioms usually yield much more stable, minimal and maintainable libraries, so I think we are at a better position to not break our consumers.

## When to Commit to Growing Instead of Breaking

Refusing to introduce breaking changes comes with a cost: you have to be careful when changing the code and keep deprecated code around in some way. But it also gives you a benefit: users of your library are happy and like you for not breaking them instead of being angry at you for breaking them. This benefit outweights the cost for me. I don't want to make users of my library be afraid of updating it. 

And since it's about users, I think it makes sense to commit to growth the moment you announce library to public, because this is the moment you start to get users. So that's what I did: released a library and made it stable from public announcement. To me, announcing library as 0.x.x and saying everything before 1.0.0 is expected to break would be an excuse for a bad practice. Or saying that everything before library becomes "widely used" is expected to break, whetever it means.

Side note regarding maintainability: reitit's [0.3.0 update](https://github.com/metosin/reitit/blob/master/CHANGELOG.md#030-2019-03-17) renamed a function from `validate-spec!` to `validate`. I see a value for such a change in private application where you can update all uses of that function: naming is better when you require namespace containing that function and give it a proper alias. But it's an open a project with [thousands of users](https://clojars.org/metosin/reitit), and I don't see any cost at all of keeping a single `def` in code: `(def validate-spec! "Deprecated" validate)`. I probably spent fewer time writing this code than they spent writing changelog entry about breaking change. Are breaking changes more of a habit than necessity?

## Growth by Accretion, Relaxation, Fixation and Encapsulation

I find it very valuable to think about change in terms of accretion, relaxation and fixation. As defined in Spec-ulation:
- accretion: providing more (more functionality, more results for same input etc.)
- relaxation: requiring less (less required args to functions, less required setup etc.)
- fixation: bashing bugs (fixing stuff, improving performance etc.)

I'd like to add that to successfully grow a project that way, it is beneficial to also clearly communicate what code is public and what is internal. Not only because users can require some internal namespaces directly, or refer to private vars, but we also might leak implementation details through public API. Sometimes we define an interface in terms of object that user somehow creates or obtains, and then give user a set of functions that expect this object as an argument. This object should be treated as a blackbox, but since everything usually is just data, users receives a map with all internal details exposed, and might be tempted to just peek inside that not-so-black-box directly.

This is why cljfx has [a readme section](https://github.com/cljfx/cljfx#api-stability-public-and-internal-code) and [docstrings](https://github.com/cljfx/cljfx/blob/master/src/cljfx/context.clj#L4) explaining that all protocol implementations should be treated as protocol implementations only.

## Bonus Section: Practical Example

This will contain many technical details, so reading it might make you familiar with beautiful internals of cljfx.

In JavaFX you usually describe radio button groups by creating an instance of `ToggleGroup` that is then shared among all `RadioButton` instances. Initial release of cljfx lacked [extension lifecycles](https://github.com/cljfx/cljfx#extending-cljfx) that allowed reusing same declaratively-managed component instance in different places, so support for sharing `ToggleGroup` was extremely limited: you could only specify an instance of it:

{% highlight clojure %}
(defn radio-group [{:keys [options value on-action]}]
  (let [toggle-group (ToggleGroup.)]
    {:fx/type :h-box
     :children (for [option options]
                 {:fx/type :radio-button
                  :toggle-group toggle-group
                  :selected (= option value)
                  :text (str option)
                  :on-action (assoc on-action :option option)})}))
{% endhighlight %}

While this approach works, it's not declarative and it's behavior may be surprising: whenever arguments to `radio-group` change, new instance of ToggleGroup will be created and assigned to RadioButton instances.
Recognizing value at `:toggle-group` key as simple value and assigning it directly to instance is described in a prop map, which looks like that:

{% highlight clojure %}
(def props
  (merge
    fx.button-base/props
    ;; RadioButton's superclass that defines setToggleGroup
    (composite/props ToggleButton
      ... ;; skipping irrelevant details
      :toggle-group [:setter lifecycle/scalar])))
{% endhighlight %}

Lifecycle called `scalar` means that we manage a description of value for such prop as value that is assigned to `ToggleButton` as is, as opposed to `dynamic` lifecycle, which expects description to be a map with `:fx/type` key. 

Once extension lifecycles got released, it became possible to describe toggle groups being shared in fully-declarative way with more reliable lifecycle:

{% highlight clojure %}
(defn radio-group [{:keys [options value on-action]}]
  {:fx/type fx/ext-let-refs
   :refs {::toggle-group {:fx/type :toggle-group}} ;; define toggle group
   :desc {:fx/type :h-box
          :children (for [option options]
                      {:fx/type :radio-button
                       ;; use previously defined toggle group
                       :toggle-group {:fx/type fx/ext-get-ref
                                      :ref ::toggle-group}
                       :selected (= option value)
                       :text (str option)
                       :on-action (assoc on-action :option option)})}})
{% endhighlight %}

Described like that, same instance of `ToggleGroup` will be reused no matter what the arguments to `radio-group` function are.
The problem is, to make `:toggle-group` prop recognize maps with `:fx/type` key, we have to use `dynamic` lifecycle instead of `scalar`, and it does not support instances. It should not support instances, because it is idiomatic in cljfx to describe everything with maps, and if you want instance, there is a special extension lifecycle for that: `fx/ext-instance-factory`, and you still describe your instance with a map.

So I ask myself: will this change provide more? Will it require less? And it turns out replacing `scalar` with `dynamic` will result in opposite: *requiring more* and *providing less*. Code will require more, because providing instance to `:toggle-group` won't be enough, it will have to be wrapped in a map. Code will provide less, because for current input it will throw in exception.

So I made a new lifecycle instead, one that will check if description is instance of a `ToggleGroup`, and then either use `scalar` or `dynamic`, and currently `ToggleButton`'s prop map looks like that:

{% highlight clojure %}
(def props
  (merge
    fx.button-base/props
    (composite/props ToggleButton
      ... ;; skipping irrelevant details
      :toggle-group [:setter (lifecycle/if-desc #(instance? ToggleGroup %)
                               lifecycle/scalar
                               lifecycle/dynamic)])))
{% endhighlight %}

This change introduces a lifecycle which is reusable, works with both instances and maps, and does not affect other code in unexpected ways because it's used only here. It also *requires less*: yesterday you could give it only an instance, today you can give it an instance or a map, and it works the same.

Yes, it took me an hour instead of a minute, but in the end you can always safely update to latest version of cljfx, and it will work the same or even better.

What do you think? Discuss [on reddit](https://www.reddit.com/r/Clojure/comments/b9rhk2/growing_cljfx/).