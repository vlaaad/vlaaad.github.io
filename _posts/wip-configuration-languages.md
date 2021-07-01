
## Configuration language problem

"Big program" languages besides Clojure (think Java, C#, C, C++) — languages used to create complex softwate — are usually complex enough to not be a good fit for smaller "accompanying programs" around the big program like tools that do build and deploy. Because of that, big program projects usually use different languages to perform these tasks. No one ever considers writing a deploy script in java, and this is where CLI is typically used: shell scripts glue together various command-line tools, each using their own configuration files. The problem is: now there is an explosion of various progamming languages used in a single project, where some of those languages pretend to be configuration files. Here are some examples of programming languages that pretend to be configuration:
- gradle DSL: a build DSL (on top of Groovy or Kotlin) to define builds and deps. Allows some declarative configuration, but as soon as you need something custom, you'll need to write imperative code;
- docker files: a DSL for building application archives that extends shell scripts;
- github actions: a programming language that uses yaml syntax to mix some declarative configuration and imperative code that does CI/CD;
- kubectl: a programming language that uses yaml syntax to define objects that live in the cloud;
- terraform: pretends to be a configuration language, while in fact it's a programming language with some insane ideas like "a directory is a function" and "lets use different files for function parameters and function body".


- dhall: finally someone admits that configuring large projects is complex enough to be a programming activity. But now I have to learn some Haskell dialect in addition to whatever progamming language I am using in a project.

I'm not trying to argue that these projects are bad — all of them solve real problems. 



bad because congnitive load

not every program is java :(

I argue for looking at both CLI and REPL as IDEs.

This is something I'm converging to, and I feel this is something Clojure tooling converges to.

A weird comparison that is very biased towards REPL.

Awhile ago I wrote a post about [alternative to tools.cli in 10 lines of code][1]. Then, a [new version of clj was released][2] that introduced `-X` flag to execute functions. 

This got me thinking about my relationship with command line and REPL. 

I use terminal daily, mostly for changing current directory, doing git operations and launching JVMs. 

What is terminal? It's [an IDE][3] (sic!) that has good composable building blocks (independent commands that only communicate via pipes of byte streams) and line-at-a-time interaction mode.

There is a mindset problem that originates from horrible non-interactive languages like java — people want to use the primary development language (like java) only for "the program", and never consider using the primary development language for other tools surrounding "the programs". And the only feasible alternative is command-line tools, because they so concise, fast to start and composable.

This leads to an explosion of tools and weird configurationey programming languages to learn, e.g.:
- gradle: supposedly it's Groovy but devs went all in on DSL it probably should be considered it's own programming language. The fact that it's being rewritten in Kotlin with extremely similar syntax only adds to the case that this DSL is it's own programming language.
- maven: xml syntax of declarative configurations and imperative code
- github actions the progamming language: yaml syntax, a mix of declarative configurations on imperative code.
- kubectl: same as github actions, yaml syntax, still programming language
- terraform: pretends to be a configuration language, actually a progamming language with some insane ideas like "a directory is a function" and "lets use different files for function arguments and function body"
- dhall: finally someone admits that configuring large projects is programming. The downside is that I have to learn Haskell-like language in addition to whatever language is used in a project. "At least it's not turing complete" — said no one ever. It's also used by the turing complete build pipeline so...
