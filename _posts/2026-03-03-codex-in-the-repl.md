---
layout: post
title: "Codex in the REPL"
description: "Or how I taught an agent to use Clojure and got my feedback loops back"
---

As I started using coding agents more, development got faster in general. But as usually happens, when some roadblocks disappear, other inconveniences become more visible and annoying. Yeah... this time it was Clojure startup time.

In one of my bigger projects, the [Defold](https://defold.com/) editor, `lein test` can spend 10 to 30 seconds loading namespaces to run a test that itself takes less than a second. This is fine when you run a full test suite, but painful for agent-driven iteration. And yes, I know about [Improving Dev Startup Time](https://clojure.org/guides/dev_startup_time), and no, it does not help enough.

While it would be nice to improve startup time, it would be even better for an agent to actually use the REPL-driven development workflow that Clojure is designed for. Agents won't naturally do it unless nudged in the right direction. So today I took the time to set it up, and I'm so happy with it that I want to share the experience!

# The Setup

To make an agent use RDD, it needs to find a REPL, send a form to it, and get a result back. Doing that is surprisingly easy: one convention for discovery, one tiny script, and one skill prompt.

## 1. Start a discoverable REPL in project context

The important part is discoverability. I prefer to use socket REPLs, but I don't want to pass ports around; the agent should find a running REPL by itself.

To do that, I added a Leiningen injection in a `:user` profile that:
- starts `clojure.core.server` REPL on a random port
- writes the port into `.repls/pid-{process-pid}.port` in the current directory used to start a Leiningen project
- ensures `.repls/.gitignore` exists and ignores everything in that directory
- removes the port file on JVM exit

This makes it easy to discover the REPLs programmatically while keeping git clean.

## 2. Add a script that evaluates forms through that REPL

To find the port, I vibe-coded an `eval.sh` script that:
- looks for port files in `.repls` to find a running REPL
- sends one or more Clojure forms to a running REPL using `nc`
- prints a friendly message when no REPL is running

The implementation is trivial, so there is no point in sharing it here. The idea is what matters: find the port in a known location and pipe input forms to the REPL server.

## 3. Teach Codex to use it by default for Clojure work

I added a Codex skill that points to this script and includes common patterns, such as:

### Evaluating in a namespace
```sh
./eval.sh '(in-ns (quote clojure.string)) (join "," [1 2 3])'
```

### Running tests in-process
```sh
./eval.sh '(binding [clojure.test/*test-out* *out*] (clojure.test/run-tests (quote test-ns)))'
```

### Some general advice

Iterate in small steps, etc. You know the drill.

# Findings

First of all, agentic engineering got noticeably faster. With a warm REPL, Codex can run many small checks while iterating on code.

But what impressed me more is that it was actually quite capable of using the REPL to iterate in a running VM. For example, when it wanted to check a non-trivial invariant in a function it was working on, it used fuzzing to generate many examples to see whether the implementation worked as expected. That was cool and useful! I don't typically do that in the REPL myself.

Turns out Codex can do REPL-driven development quite well!
