---
layout: post
title: "Layered software architecture and dependecies"
comments: true
math: true
slug: layered-architecture-and-dependencies
date: "2024-04-14"
tags: [software-design, programming]
---

Having dependencies is an ever-present trait of software development, as it stems from the idea of modularity: one component naturally depends on funtionality "outsourced" to other components, creating dependencies. At the same time, for maintainability and extensibility of a software project, one is interested in minimizing dependencies and creating loosely coupled systems. In this blog post, I will briefly describe two slightly different views on how to minimize dependencies in a layered architecture.

Designing a software in terms of layers is a natural way to decouple different parts of the code, roughly in a progression from the closeness to the user to the closeness to the hardware/infrastructure. As such, the layers (high to low) can often be the following:

 * **User interface**: interacting with the user, either by grahical means or via commands or APIs;
 * **Application**: defines the tasks/jobs of the software;
 * **Domain**: contains business logic;
 * **Infrastucture**: realizes basic functions, such as persistence, message passing, rendering and the like.

In this book ["Domain Driven Design"](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215), Eric Evans provides a simple guideline on how to minimize dependencies in a multi-layered system: *depend only on components in the same layer or the layers beneath*. As such, it is OK to refer to a component in a lower layer and call its methods, but one should not do that to realize the bottom-up communication. For that, the tool of trade is to use *callbacks and listeners* (see the [Observer pattern](https://refactoring.guru/design-patterns/observer)). For example, if an event happens in the domain layer, and the application layers needs to know about it, its handler should be registered as a listener.

![png](/layered-architecture-and-dependencies/layers.png)

A bit stricter view is presented by the athors of ["Dependency Injection Principles, Practices, and Patterns"](https://www.manning.com/books/dependency-injection-principles-practices-patterns). With a simple example of a web application with such layers and *UI*, *Domain*, and *Data access*, the preferred way to reduce dependencies is to consolidate definition of interfaces in the *Domain* layer, with both the lower and the higher level containing the implementations of those interfaces, all depending on the *Domain* layer.

![png](/layered-architecture-and-dependencies/loose_coupling_with_interfaces.png)

If this technique is used, the dependency graph becomes much less coupled:

![png](/layered-architecture-and-dependencies/tight_and_loose_coupling.png)