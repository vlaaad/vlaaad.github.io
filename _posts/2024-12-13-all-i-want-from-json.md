---
layout: post
title: "All I want from JSON is whitespace commas"
description: "Following the recent uptick of JSON-related discussions, here is my opinion on the matter"
---

Recently there was an uptick in discussions about JSON format, e.g. [about comments](https://news.ycombinator.com/item?id=42360390) and [JSON alternatives](https://news.ycombinator.com/item?id=42360681). My thoughts on the matter are not very original, but this won't prevent me from sharing them anyway.

# What I want from JSON

Basically, the only thing I want from JSON is to treat commas as whitespace.

# Examples

This is JSON:
```json
{
  "name": "John Doe",
  "age": 30,
  "hobbies": ["reading", "swimming", "photography"],
  "isStudent": false
}
```

This is perfect JSON:
```json
{
  "name": "John Doe"
  "age": 30
  "hobbies": ["reading" "swimming" "photography"]
  "isStudent": false
}
```
Ahhh... pure bliss...

# Why

JSON is a data interchange format designed with 2 goals in mind:
- easy for humans to read and write
- easy for machines to parse and generate

When it comes to readabilty, commas at the end of lines are unnecessary clutter. Another issue with commas is unnecessary diffs that only add a comma at the end of a line when new entries are added at the end of an object. Some languages "solve" this by allowing trailing commas, but I think making commas optional is much more sane and readable than trailing commas.

When it comes to parsing, commas don't contain any information about the structure of data, and are only a source of errors. Formatting JSON also becomes easier: when each array element or object entry is on a separate line, there is no need for conditional insertion of comma depending on whether the element is last or not

# Trade-offs and side notes

Treating commas as whitespace is not only about changing the `is_json_whitespace(character)` function: parsers and generators now will need to use non-empty whitespace as a separator for elements.

I also considered treating colons as whitespace, since those don't contain any data structure information and are only used as a source of errors. This change would have converged the discussed superset of JSON into a subset as [EDN](https://github.com/edn-format/edn):
```clojure
{
  "name" "John Doe"
  "age" 30
  "hobbies" ["reading" "swimming" "photography"]
  "isStudent" false
}
```
I think this is harder to read. This might work better for Clojure because it typically uses `:keywords` for keys — this keeps keys and values visually distinct, so  `:name "John Doe"` is easier to parse compared to `"name" "John Doe"`.

Also, I think that using colons as a source of errors works well in the object case, because "Map literal must contain an even number of forms" errors do actually happen during development in Clojure, and they are sometimes hard to find because Clojure reader has no idea where the value is missing.

What do **you** think about JSON?