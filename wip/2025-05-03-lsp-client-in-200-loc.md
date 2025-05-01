---
layout: post
title: "LSP client in Clojure in 200 lines of code"
description: "I wrote a small LSP client, it was kinda neat so I'm sharing it"
---
Awhile ago I was prototyping integrating LLMs with [LSP](https://microsoft.github.io/language-server-protocol/) to enable a language model to answer questions about code while having access to code navigation tools provided by language servers. I wasn't that successful with this prototype, but I found it cool that I could write a minimal LSP client in around 200 lines of code. Of course, it was very helpful that I previously wrote a much more featureful [LSP client for the Defold editor](https://github.com/defold/defold/blob/dev/editor/src/clj/editor/lsp.clj)... So let me share with you a minimal LSP client, written in Clojure, in under 200 lines.

# Target audience

Who is the target audience of this blog post? I don't even know... Clojure developers writing code editors? There are, like, 3 of us! Okay, let's try to change the scope of this exercise a bit: let's build a command line linter that uses a language server to do the work.

# The what

Some terminology and scope first. LSP stands for Language Server Protocol, basically a standard that defines how some code editor — language client — that knows how to edit text might talk to some language-specific tool — language server — that knows the semantics of a programming language and may provide contextual information like code navigation, refactoring, linting etc.

The main benefit of LSP is that the so called MxN problem of IDEs and languages becomes M+N with LSP. In other words, as a language author, previously you had to write integration for every code editor. Or, as an IDE author, you had to write a separate integration for every language. Now there is a common interface — LSP — and both language authors and IDE authors only need to support this interface. LSP is a win-win for the PL/IDE ecosystem.

In 200 LoC, we will implement essential blocks of the [LSP Specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/) that supports programmatic read-only querying of language servers. We will implement:
1. base communication layer between language clients and servers. It is similar to HTTP protocol: client and server talk to each other using byte streams with messages formatted as headers + JSON message bodies. The base layer establishes a way to exchange JSON blobs.
2. [JSON-RPC](https://www.jsonrpc.org/) — a layer on top of the base layer that adds meaning to JSON blobs, turning them into either requests/responses, or notifications.
3. A wrapper around JSON-RPC connection that is a leaving breathing language server we can talk to.

We will use Java 24 with virtual threads: writing blocking code that performs well is a very nice. We will use a single dependency: a JSON library. I picked [jsonista](https://github.com/metosin/jsonista/) because it's fast and has a cool name. Let's go!

# The how

The im