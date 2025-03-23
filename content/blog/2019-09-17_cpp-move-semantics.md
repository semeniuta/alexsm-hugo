---
layout: post
title: C++ move semantics
comments: true
slug: cpp-move-semantics
summary: "Some notes on C++ move semantics and an example of copy/move construction and assignment"
date: "2019-09-17"
tags: [c++, programming]
---

In the modern versions of C++ (starting from C++11) one encounters a concept of *move semantics*. It may confusing a bit, and in this post I am going to provide my notes on the topic (mostly based on Bjarne Stroustrup's *The C++ Programming Language* (4th edition): sections 3.3, 7.7.2, 17.5.2).

The first important concept is *rvalue reference*. For a type `T`, a rvalue reference is `T&&` (note the double ampresand). It basically represents a reference to a temporary object that is assumed to be modified and not used again. 

The `std::move` constitutes a syntactic sugar for the static cast to the type of rvalue reference, i.e. the following two lines are equivalent:

```cpp
T b = std::move(a);

T b = static_cast<T&&>(a);
```

The snippet above represent a *move assignment*, during which the internal representation of `a` is transferred to `b`, and `a` is remained in a **moved-from state** (loosely speaking, empty). Similarly, the following code performs *move initialization*, which effectively results in the same states of `a` and `b` as after the move assignment:

```cpp
T b{std::move(a)};
```

In both cases, the logic that performs "moving" and leaving the original object as "moved from", is supplied by the author of type `T`. Specifically, this is achieved through move assingment and move constructor of `T` respectively. 

For a class `X`, the following methods are provided by default:

```cpp

X();                   // default constructor
                       // ^ not generated if any other 
                       //   constructor is declared
    
                       // -------------------------------
X(const X&);           // copy constructor
X& operator=(const X&) // copy assignment

X(X&&);                // move constructor
X& operator=(X&&)      // move assignment

~X();                  // destructor
                       // -------------------------------
                       // ^ if any of those is declared, 
                       //   no default generation happens 
                       //   for the rest

```

Let's say you are writing a custom vector class (let's call it `MyVec`), which internally allocates and grows an array on heap. If the user of `MyVec` requests the regular copy operations when creating a new object from the existing one, all the data should be copied under the hood. Obviously, this may be a rather costly process if there is a lot of data in the container. 

```cpp
MyVec<int> b{a}; // copy construction; a is the existing MyVec
```

Conversely if the existing object is of no interest, the user creates the new one using the move constructor or assignment. In this case, the internal pointer to the array on heap gets transferred to the new object, leaving the original one in the moved-from state, speficially setting the pointer to the data in it to `nullptr`. 

```cpp
MyVec<int> b{std::move(a)}; // move construction
```

As such, move constructor and assignment take rvalue references and leave the original objects empty (so that they can be destructed when going out of scope). An important application of this behavior happens on **return**: when a function returns an object, its move constructor is used. In the example below, the original object `a` shall in this case go out of scope and gets destructed, but its internal representation is moved to the object `b` on the calling side. 

```cpp
MyVec<int> f() {

    MyVec<int> a;
    
    // ...

    return a;

}

int main() {

    // ...

    MyVec<int> b = f();

    // ...
}

```

In my [`demo_cpp`](https://github.com/semeniuta/demo_cpp) Github repo, I have created the following examples illustrating move semantics:

 * [`myvec.h`](https://github.com/semeniuta/demo_cpp/blob/master/src/myvec.h): Implementation of `MyVec` class with diagnostic output functionality.
 * [`demo_cpmv.cpp`](https://github.com/semeniuta/demo_cpp/blob/master/src/demo_cpmv.cpp): Demonstration of copy and move operations based on the `MyVec` class.
 * [`demo_rvalue.cpp`](https://github.com/semeniuta/demo_cpp/blob/master/src/demo_rvalue.cpp): Demonstration of explicit calls of `std::move` for different data types. 

See also:

* [C++ rvalue references and move semantics for beginners](https://www.internalpointers.com/post/c-rvalue-references-and-move-semantics-beginners)
* [Move semantics @ Mike's C++11 Blog](https://mbevin.wordpress.com/2012/11/20/move-semantics/)