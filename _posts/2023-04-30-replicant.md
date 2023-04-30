---
layout: post
title: "First impressions of Morse and Replicant"
description: "I tried out the new Clojure tool, Morse (aka REBL), and its companion library, Replicant, for remote data inspection. Here are my first impressions."
---

# Release of Morse

Awhile ago, the Clojure team [announced](https://clojure.org/news/2023/04/28/introducing-morse) a new data inspection tool called Morse. Unfortunately, it was not clear what the tool is exactly, since the announcement post didn't include any screenshots, only saying that it's an evolution from REBL. Upon closer inspection it turned out that Morse *is* REBL, but rebranded and open sourced. I'm very grateful for all the hard and thoughtful work that Clojure team does to improve the ecosystem of my favorite programming language! I also hope they would spend a bit more time on communicating the work they do... Anyway, here is what Morse looks like:

![](/assets/2023-04-30/morse.png)

As you might know, I made [Reveal](/reveal/) — a tool similar to Morse/REBL that aims to help with data inspection, so one thing that made me curious about the Morse announcement is the mention of new Replicant libraries designed to help with remote data inspection. 

# Replicant

Replicant comes in 2 parts: [client](https://github.com/clojure/data.alpha.replicant-client) and [server](https://github.com/clojure/data.alpha.replicant-server). The idea is that you run replicant server in the process you want to inspect, and use replicant client in a tool like Morse or Reveal to interact with the server. Together, they allow inspecting remote objects as if they are local. The server library is JVM-only, but in principle there is a protocol on top of eval and edn that can be implemented in another Clojure dialect.

Replicant server is a prepl that "remotifes" objects when responding. For example, if I request `*ns*`, it will respond with a following EDN: 
```clj
#r/object {:klass clojure.lang.Namespace, 
           :ref #r/id #uuid "fd88d9ab-42ce-492a-a6ee-3b3ae2c1e152"}
```

Replicant client provides a set of data readers for tagged literals like `r/object`, `r/id` and others. The idea is that your prepl client uses replicant readers to construct remote objects — objects that ask the server on interactions in the client process. [Here is](https://github.com/nubank/morse/blob/330345b9a06abe01bcbb1b6a54cee3f4ee7f891d/src/dev/nu/morse/ui.clj#L543-L565) the code that implements it in Morse.

# First impressions with Replicant and Morse

I tried Morse in a remote mode, and unfortunately it didn't work due to a minor bug ([reported here](https://github.com/nubank/morse/issues/2)). After I fixed the bug in a locally checked out verion of Morse repo, it started to work. When I evaluated with `*ns*`, it responded with a map that looked like this:
```clj
{:klass clojure.lang.Namespace 
 :ref user}
```
Here, `clojure.lang.Namespace` is a symbol, but `user` is deserialized as a "Relay" in replicant terms — a custom type that holds a reference to replicant client and a reference id. When Morse asks for `toString` of Relay, it performs a network request and fetches a string — `"user"` — for the id. 

I also [reported an issue](https://github.com/clojure/data.alpha.replicant-server/issues/1) where evaluating a map literal like `{:a 1}` serialized it as a `r/fn` (remote fn) instead of `r/map` (remote map), so it wasn't possible to inspect maps at all — remote fns don't even fetch `toString`s... I'm not sure if I'm doing something wrong here, but I launched the server as described in the docs:
```sh
clj \
-Sdeps '{:deps {io.github.clojure/data.alpha.replicant-server {:git/tag "v2023.04.25.01" :git/sha "039bea0"}}}' \
-X clojure.data.alpha.replicant.server.prepl/start :host '"localhost"' :port 7272
# Replicant server listening on 7272 ...
```
And then:
```sh
nc localhost 7272
{}
# out => {:tag :ret, :val "#r/fn {:id #uuid \"ac946192-666e-4da8-989c-395e9b10115f\"}", :ns "user", :ms 1, :form "{}"}
```

# Integrating Replicant into Reveal

I prototyped Replicant integration for Reveal. One roadblock I hit was that replicant client is distributed as a git dep only, while Reveal is distributed as a Maven dependency. This means I can't release a version of Reveal that depends on Replicant. I reported the issue [here](https://github.com/clojure/data.alpha.replicant-client/issues/1). It didn't stop me from prototyping the integration though. The main issue when implementing a replicant+reveal-flavored prepl was mixing user-submitted forms to `*in*` with replicant forms that load more data for remote objects. The problem here is that we can evaluate a form like `(read-line)`, and after input an unstructured text until the next newline. I ignored the problem for now and just read from `*in*` form by form and interleaved these forms with replicant forms. Now that I'm writing this blog post I realized that what I actually need is 2 connections to the replicant server — one for `*in*` that has to be piped to the server as is and another for replicant forms.

I also noticed that current implementation of the Replicant client issues a synchonous network request every time the `toString` on a remote object is called, which is, I think, unfortunate, but can be improved, but also maybe it's intentional and completely fine, and Reveal should be more careful about calling `toString` on objects it inspects. When I received `RemoteFn` instance after evaluating `{:a 1}`, I could use it as a function, so invoking `(the-remote-fn :a)` resulted in `1` being loaded, which was pretty neat!

# Conclusion

Even though I can't release any Replicant integration as of now, I'm looking forward to the evolution of Replicant libraries. I like Replicant because many Clojure data inspection tools can benefit from it, which helps the whole ecosystem. I've spent some time thinking about the problem space of inspecting the data from the remote process, and I'm happy to see there is some work in this area!