---
layout: post
title: "References as C++ class members"
comments: true
math: true
slug: cpp-references-as-class-members
date: "2024-03-16"
tags: [c++, programming]
---

It is not an uncommon, although frowned upon, practice to have references or const references as class members in C++. If there is a long-living object you want your class to have associacion with and you are sure its lifespan is by design greater than the your object using it, why not having it as reference?

```c++
class Thingy
{
public:
    // public members

private:
    const UsefulService & service_;
    // other private members
};
```

Although it might seem like a totally sensible idea, such design is generally considered bad. There is [a specific rule in the C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rc-constref) that advices against that:

> C.12: Don’t make data members const or references in a copyable or movable type

The primary objection is of course the requirement for the objects to be **copyable/moveable**. Imagine the `Thingy` class in the example above: it would be messy if you wanted to have several "thingies" with copying and moving involved. The issues include the following:

 * a C++ references cannot rebind to point to another object;
 * having several references to the same object from different classes violate encapsulation (in case the referenced object is changed);
 * `const` class members mess up `std::move` (see [this](https://quuxplusone.github.io/blog/2022/01/23/dont-const-all-the-things/#data-members-never-const)).

In [this GitHub issue](https://github.com/isocpp/CppCoreGuidelines/issues/1809) Bjarne Stroustrup voices an even stronger opinion:

> I think we need a rule banning reference members.

As a proper solution, **it is recommended to use pointers, either raw or smart, or `std::reference_wrapper`** (emulates a references while being copy-constructible and copy-assignable, see example [here](https://lesleylai.info/en/const-and-reference-member-variables/)). This gives more control over ownership and lifetime of the referred objects.

An alternative opinion is that there can be situations when it is perfectly fine to have reference members. Let's say we have only one `Thingy` in our system, without any need for copying or moving, and the instance of `UsefulService` we refer to has a longer lifetime that the instance of `Thingy` by design. It is interesting to read the discussion [here](https://github.com/isocpp/CppCoreGuidelines/issues/1707) with both pros and cons on this matter.
