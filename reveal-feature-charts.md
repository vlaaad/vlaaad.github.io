---
layout: reveal
title: "Reveal: Charts"
permalink: /reveal/feature/charts
---
Reveal can show data of particular shapes as charts that are usually explorable: when you find an interesting data point on the chart, you can then further inspect the data in that data point.

The simplest shape is labeled numbers. Labeled means that those numbers exist in some collection that has a unique label for every number. For maps, keys are labels, for sequential collections, indices are labels and for sets, numbers themselves are labels.

A pie chart shows labeled numbers:

<video controls><source src="/assets/reveal/pie-chart.mp4" type="video/mp4"></source></video>

Other charts support more flexible data shapes — both because they can show more than one data series, and because they can be explored, where it might be useful to attach some metadata with the number. Since JVM numbers don't allow metadata, you can instead use tuples where the first item is a number and second is the metadata. Bar charts can display labeled numbers (single data series) or labeled numbers that are themselves labeled (multiple data series):

<video controls><source src="/assets/reveal/bar-chart.mp4" type="video/mp4"></source></video>

Line charts are useful to display progressions, so Reveal suggests them to display sequential numbers (and labeled sequential numbers):

<video controls><source src="/assets/reveal/line-chart.mp4" type="video/mp4"></source></video>

Finally, Reveal has scatter charts to display coordinates on a 2D plane. A coordinate is represented as a tuple of 2 numbers and as with numbers, you can use a tuple of coordinate and arbitrary value in the place of coordinate. Reveal will suggest scatter charts for collections of coordinates and labeled collections of coordinates.

<video controls><source src="/assets/reveal/scatter-chart.mp4" type="video/mp4"></source></video>
