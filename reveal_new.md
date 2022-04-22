---
layout: reveal
title: "Reveal:<br>Read Eval Visualize Loop for&nbsp;Clojure"
head_title: "Reveal: Read Eval Visualize Loop for Clojure"
permalink: /reveal/
---
![Demo](/assets/reveal/new-demo.gif)

| [![Clojars Free](https://img.shields.io/clojars/v/vlaaad/reveal.svg?logo=clojure&logoColor=white&style=for-the-badge&label=free)](https://clojars.org/vlaaad/reveal) | [![Clojars Pro](https://img.shields.io/clojars/v/dev.vlaaad/reveal-pro.svg?logo=clojure&logoColor=white&style=for-the-badge&label=pro)](https://clojars.org/dev.vlaaad/reveal-pro) | [![Github page](https://img.shields.io/badge/github-vlaaad%2Freveal-informational?logo=github&style=for-the-badge&label=)](https://github.com/vlaaad/reveal) | [![Slack Channel](https://img.shields.io/badge/slack-%20%23reveal-blue.svg?logo=slack&style=for-the-badge&label=)](https://clojurians.slack.com/messages/reveal/) |

# Overview

Reveal is a Clojure-oriented data inspection toolbox that aims to remove the barrier between you and objects in your VM. 

The goals of Reveal are:
- to empower you to hold a value in your hand — meaning you can look at it from different angles, pick it apart and analyze different pieces of the data just by pointing at them;
- to complement REPL-aided development — providing both interactive output panes for the REPL and tools to use at the REPL;
- to get the most from being in-process — in addition to working with remote processes.

There are 2 versions of Reveal:
- Reveal Free: FOSS, [sponsored on GitHub](https://github.com/sponsors/vlaaad);
- Reveal Pro: $9.99 per month, [start a free trial here](https://buy.stripe.com/8wM9Dz5bKand5ck3cc){: .buy-button}. For residents and citizens of Ukraine Reveal Pro is free forever — use "PUTINKHUILO" promocode during checkout.

# Try it out

To try Reveal Free:
1. Start a Reveal Free REPL:
    ```sh
    clj \
    -Sdeps '{:deps {vlaaad/reveal {:mvn/version "1.3.273"}}}' \
    -X vlaaad.reveal/repl
    ```
2. Evaluate some forms and inspect the results.

To try Reveal Pro:
1. Start a Reveal Pro REPL:
   ```sh
   clj \
   -Sdeps '{:deps {dev.vlaaad/reveal-pro {:mvn/version "1.3.344"}}}' \
   -X vlaaad.reveal/repl
   ```
2. [Start a free trial here](https://buy.stripe.com/8wM9Dz5bKand5ck3cc){: .buy-button};
3. Paste the license key from confirmation email into a license input field in the Reveal Pro window;
4. Evaluate some forms and inspect the results.

# Features

<div class="pricing">
    <h2 class="pricing-col1 pricing-row1">Free</h2>
    <a href="/reveal/feature/eval-on-selection" class="pricing-feature pricing-col1 pricing-row2"><img src="/assets/reveal/eval.png">Eval on selection</a>
    <a href="/reveal/feature/inspector-popup" class="pricing-feature pricing-col2 pricing-row2"><img src="/assets/reveal/popup.png">Inspector popup</a>
    <a href="/reveal/feature/vega" class="pricing-feature pricing-col1 pricing-row3"><img src="/assets/reveal/vega.png">Vega(-Lite) visualizations</a>
    <a href="/reveal/feature/java-bean" class="pricing-feature pricing-col2 pricing-row3"><img src="/assets/reveal/java-bean.png">Object inspector</a>
    <a href="/reveal/feature/test-runner" class="pricing-feature pricing-col1 pricing-row4"><img src="/assets/reveal/test.png">Test runner</a>
    <a href="/reveal/feature/repls" class="pricing-feature pricing-col2 pricing-row4"><img src="/assets/reveal/remote-prepl.png">REPL, pREPL, nREPL</a>
    <a href="/reveal/feature/customization" class="pricing-feature pricing-col1 pricing-row5"><img src="/assets/reveal/light-theme-2.png">Look and feel customization</a>
    <a href="/reveal/feature/tap" class="pricing-feature pricing-col2 pricing-row5"><img src="/assets/reveal/tap.png">Tap support</a>
    <a href="/reveal/feature/browsers" class="pricing-feature pricing-col1 pricing-row6"><img src="/assets/reveal/browser.png">URL and file browsers</a>
    <a href="/reveal/feature/docs-and-sources" class="pricing-feature pricing-col2 pricing-row6"><img src="/assets/reveal/docs.png">Docs and sources</a>
    <a href="/reveal/feature/ref-watchers" class="pricing-feature pricing-col1 pricing-row7"><img src="/assets/reveal/watch.png">Ref watchers</a>
    <a href="/reveal/feature/charts" class="pricing-feature pricing-col2 pricing-row7"><img src="/assets/reveal/charts.png">Charts</a>
    <a href="/reveal/feature/table" class="pricing-feature pricing-col1 pricing-row8"><img src="/assets/reveal/tables.png">Table view</a>
    <div class="pricing-col3 pricing-row1">
        <h2>Pro</h2>
        <p>Everything in Free, plus:</p>
    </div>
    <a href="/reveal/feature/sql" class="pricing-feature pricing-col3 pricing-row2"><img src="/assets/reveal/db.png">SQL DB explorer</a>
    <a href="/reveal/feature/system-watchers" class="pricing-feature pricing-col3 pricing-row3"><img src="/assets/reveal/sys.png">System watchers</a>
    <a href="/reveal/feature/spec-forms" class="pricing-feature pricing-col3 pricing-row4"><img src="/assets/reveal/spec-forms.png">Forms</a>
    <a href="/reveal/feature/json-schema-forms" class="pricing-feature pricing-col3 pricing-row5"><img src="/assets/reveal/vega-form.png">JSON schema and Vega(-Lite) forms</a>
    <a href="/reveal/feature/fs" class="pricing-feature pricing-col3 pricing-row6"><img src="/assets/reveal/fs.png">File system navigation</a>
    <a href="/reveal/feature/resource-watchers" class="pricing-feature pricing-col3 pricing-row7"><img src="/assets/reveal/resources.png">Resources sticker</a>
</div>

# Learn Reveal

Here you can find useful high-level information about Reveal:
- [main UI and inspection concepts](/reveal/main-concepts);
- [windows and stickers](/reveal/windows-and-stickers);
- [keyboard shortcuts](/reveal/keyboard-shortcuts);
- [tips and tricks](/reveal/tips-and-tricks).

# Documentation

Lower-level guides:
- [setup Reveal in your project](/reveal/setup);
- [customize Reveal](/reveal/customize);
- [use Reveal at the REPL](/reveal/use);
- [extend Reveal for your project](/reveal/extend).

# Reveal in media

I gave 3 talks about Reveal:
- [Reclojure 2020](https://www.youtube.com/watch?v=jq-7aiXPRKs), 24 minutes;
- [Reclojure 2021 data science special: visual tools](https://youtu.be/lqb4XlFI-08?t=1220), 10 minutes;
- [Scicloj meeting](https://www.youtube.com/watch?v=hm7LoqvaYXk), 2 hours including Q&A, cljfx and live demo.

Other videos about Reveal:
- [Practicalli](https://www.youtube.com/watch?v=1jy09_16EeY) demo, 5 minutes;
- [REPL Driven Development, Clojure's Superpower](https://www.youtube.com/watch?v=gIoadGfm5T8) by Sean Corfield (1h15m), not about Reveal per se, but uses Reveal extensively.

I also talked about Reveal on [defn](https://soundcloud.com/defn-771544745/65-vlad-protsenko) podcast (1h30m).

Various written setup instructions using Reveal:
- [Practicalli](https://practical.li/clojure/clojure-cli/data-browsers/reveal.html) page describes Reveal setup for CLI, nrepl editors, emacs (using cider) and rebel-readline;
- [Calva](https://calva.io/reveal/) page describes vscode setup with Calva extension (using both tools-deps and leiningen examples);
- my [blog post](/reveal-repls-and-networking) describes various Reveal socket REPL setups that talk with remote processes.

# Closing thoughts

If repl is a window to a running program, then Reveal is an open door — and you are welcome to come in. I get a lot of leverage from the ability to inspect any object I see, and I hope you will find Reveal useful too.

If you do, please consider supporting my work either by [sponsoring the development](https://github.com/sponsors/vlaaad) of the free version or by [buying the subscription](https://buy.stripe.com/8wM9Dz5bKand5ck3cc){: .buy-button} for Pro version.
