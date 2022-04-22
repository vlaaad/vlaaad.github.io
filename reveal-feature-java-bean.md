---
layout: reveal
title: "Reveal: Object Inspector"
permalink: /reveal/feature/java-bean
---
Any object in the JVM has class and fields, making them easily accessible for inspection is extremely important. With `java-bean` contextual action you get a debugger-like view of objects in the VM. Access to this information greatly improves the visibility of the VM and allows searching of object hierarchies. For example, for any class you have on the classpath you can get the place where it's coming from:

<video controls><source src="/assets/reveal/java-bean.mp4" type="video/mp4"></source></video>

I learned about it after implementing this feature :)