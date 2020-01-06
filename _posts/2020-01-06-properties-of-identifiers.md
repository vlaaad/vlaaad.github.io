---
layout: post
title: "Properties of Identifiers"
description: "What constitutes a good id? When?"
---

## Properties 

Recently with my increasing use of [spec](https://github.com/clojure/spec.alpha) I've been thinking that properties (as opposed to types) of values and data structures are their essential aspect in programming. Both vectors and sets can contain values, but one is useful for maintaining insertion order, and another for inclusion checks. Opinion: recognizing what set of properties you need in a given situation makes you a better programmer, having tools with useful properties makes you a more productive programmer.

Fun fact: I've read somewhere long time ago that we will have programming languages where constructing a data structure will be done by specifying a list of properties we need from this data structure, so asking for "associative" will give you a hash map, for "associative + sorted" will give you a tree map, "associative + insertion order" — linked hash map etc. Don't know if that will happen, or if it's going to be very useful, but that's an interesting perspective.

Here is a definition of a property:

> Property — an essential or distinctive attribute or quality of a thing

And here is a definition of an attribute:

> Attribute — something attributed as belonging to a person, thing, group, etc.; a quality, character, characteristic, or property

And here is a definition of a quality:

> Quality — an essential or distinctive characteristic, property, or attribute

And characteristic:

> Characteristic — a distinguishing feature or quality

Pretty self-referential, huh. But the main gist is this is something that belongs to a thing. This means you already have a thing, but in addition to that thing you have something more. Sometimes the sole purpose of a thing is to use it for that something more. For example, to figure out what beats what in rock-paper-scissors, both map and function will do the trick:
```clojure
(def beats
  {:rock :scissors
   :paper :rock
   :scissors :paper})
```
or
```clojure
(defn beats [x]
  (case x 
    :rock :scissors
    :paper :rock
    :scissors :paper))
```
Regardless of the definition of `beats`, code `(beats :paper)` will behave roughly the same. You might use a map, but if all you need is an answer to a question who would win, you don't need properties of a map other than being a function. Usually, maps are very useful for their properties though — the ability to enumerate all valid inputs might come in quite handy.

Some other times, you need just a thing, but it will still have some properties whether you want it or not, and it might be useful to think a little about your options when you get a chance to make this thing, which brings me to identifiers. What is an identifier?

## Identifiers

> Identifier — a name that identifies (that is, labels the identity of) either a unique object or a unique class of objects

So, an identifier is a label of something else, a way to refer to something without being that something. In programming, the main property of an identifier is being able to retrieve (or assert) some information from a system for the entity identified by this identifier. After that, there are different kinds of identifiers with various properties that I came across in my experience.

### Auto-incremented integers

This kind of ID is well-known in traditional databases that usually allow generating ids when inserting new rows into tables. What properties such IDs have? First of all, they are created for you automatically, so you don't have to worry about that. 
  
They are *meaningless* in a sense that they don't refer to some attribute of an entity they identify. This is sometimes very useful, for example, using phone numbers is identifiers is meaningful (describes some real-world entity belonging to a user), but might become problematic (user changes a phone number, or has many phone numbers) and can be a security risk. *Ordered* nature of IDs allows users to know who registered first (will have smaller number). 
  
Since auto-incremented IDs are *monotonically* increasing, with lack of authentication/rate-limiting it might be easy to scrape publicly available information about users just by going through all numbers after 1 until users exist. 
  
Usually, each table has its own ID sequence starting with 1, which means you can have both user Foo Barson with ID 10 and organization Acme with ID 10, and they might be completely unrelated. It means these IDs are not *unique* enough for users of your system, and actual entity id is a tuple like `[:user 10]` or `[:org 10]`. Is it good or bad? Probably neither. Fun fact: Github uses a shared auto-incremented ID generator for different types of things: both issues and PRs share the same ID generator. This makes it easier to refer to them in comments just by mentioning their number.
### UUIDs

Universally unique identifiers are 128-bit numbers that are usually written this way: `1eadc509-dedf-4e10-a9a3-2a2d9c582357`. Their universal uniqueness is guaranteed by a source of randomness being not only time, but also a mac address of a machine generating this ID. 
  
Besides being *globally unique* and *meaningless* by themselves, they *don't require coordination* for generation (as auto-incremented IDs in RDBMSes do), which makes them more suitable in cases of massive write load on DB. 
  
Since they are random, there is *no notion of order* in them, and no way to figure out other IDs. 

### Content hashes

This is a less widespread type of identifier, mostly because of a constraint it imposes on a thing it identifies. Content hash is a fixed-size byte array produced from arbitrary big input using one-way transformation that will always be the same for the same input, and will always be different for different input. 

It's imposed constraint (which is also a property!) is immutability: content hash identifies a value that will never change because the changed value will have a different hash identifier. Most relatable examples of such identifiers are SHA1 hashes that Git uses for objects it stores, be it commits, files or file trees. This hash looks like this: `985a2882a8f7d1ea551ebe09726cee3c12d34039`. SHA1 is 160 bit — less chance of collision than with UUIDs (don't quote me on this though — SHA1 and UUIDs are produced in different ways, so actual collision chances might vary). It's probably a good idea to use SHA2 (256 bit) nowadays that google managed to produce a hash collision for SHA1 with only 6500 years of CPU time. 

Hashes are meaningful in the sense that they capture all available information about a thing they identify, but being one-way transformation, they can't be a security risk. 

Content hashes are great for data distribution: one system can ask another if it has content with a particular hash, and then verify downloaded content by checking it's hash — torrents work on content hashes, for example.

### URLs

Usually used to identify web pages, they can also be used to identify other stuff. [RDF](https://en.wikipedia.org/wiki/Resource_Description_Framework), for example, uses URLs to describe both entities and their attributes. Even though RDF is not very popular today, using URLs to identify information is still an interesting approach because, in addition to being an identifier *of* something, it also has contains information *how* to get something. For example, combining this property with the assumption that identified entity is immutable might be useful for making a package manager: using URLs to commit hashes as dependency coordinates (like `clj` does) makes it easy to make a stable and vibrant ecosystem without central repositories ensuring immutability of artifacts.

What do you think?