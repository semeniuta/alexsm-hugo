---
layout: post
title: C++ move semantics
comments: true
slug: cpp-move-semantics
date: "2019-09-09"
tags: [c++, programming]
---

In the modern versions of C++ (strarting from C++11) one encounters a concept of *move semantics*. It may confusing a bit, and in this post I am going to provide a succint overview of the topic.

The first important concept is *rvalue reference*. For a type `T`, a rvalue reference is `T&&` (note the double ampresand). It basically represents a reference to a temporary object that is assumed to be modified and not used again. 

The `std::move` constitutes a syntactic sugar for the static cast to the type of rvalue reference, i.e. the following two lines are equivalent:

```cpp
T b = std::move(a);

T b = static_cast<T&&>(a);
```

The snippet above represent a *move assignment*, during which the internal representation of `a` is transferred to `b`, and `a` is remained in a moved-from state (loosely speaking, empty).

The most typical application of rvalue refences is in the move constructor and the move assignment of a class. For a class `X`, the following methods are provided by default:

```cpp

X();                   // default constructor

X(const X&);           // copy constructor
X& operator=(const X&) // copy assignment

X(X&&);                // move constructor
X& operator=(X&&)      // move assignment

~X();                  // destructor
```

Usage examples 



See also:

https://www.internalpointers.com/post/c-rvalue-references-and-move-semantics-beginners

https://mbevin.wordpress.com/2012/11/20/move-semantics/