---
layout: post
title: std::vector and C++'s braced initialization
comments: true
slug: cpp-std-vector-braced-init
summary: "When braced initialization is preferred and when it is not (when it comes to std::vector)"
date: "2021-05-13"
tags: [c++, programming]
---

The new versions of C++ (starting from C++11) include a unified initialization syntax based on braces. In most of the cases it offers a more elegant and unified way of initializing objects. Examples of its usage are as follows:

```c++
std::string name{"Michael Scott"}; 
MyClass obj{}; // default constructor
```

Braced initialization can also be used in constructors to initialize class members:

```c++
MyClass::MyClass(const Something& value) : member{value} {
    // Additional operations ...
} 
```

When it comes to be widely-used `std::vector`, braced initialization might be a source of confusion. It is typical that one knows the initial capacity of a vector and wants to set all elements to some constant value. The traditional way to do it is as follows:

```c++
std::vector<int> x(100, 0); // Create vector with 100 zeros
```

One might be tempted to write an expression as such:

```c++
std::vector<int> x{100, 0}; 
```

However, because `std::vector` has one of the constructors based on `std::initializer_list`, the rule is that that particular constructor will always be used if braced syntax is used. As such, the latter snippet will create a 2-element vector with values of 100 and 0. This will actually be the case even if we are talking about `std::vector<double>`. 

A more unambigous way to specify ininialation based on `std::initializer_list` would be with using the equals sing:

```c++
std::vector<int> x = {1, 2, 3, 4, 5}; 
```

A rule of thumb is thus to prefer using braced initialization in most cases, but use `(...)`  and `= {...}` when working with `std::vector` and other classes containing a `std::initializer_list` constructor. 

Read also:
- "Item 7: Distinguish between () and {} when creating objects" in the ["Effective Modern C++"](https://www.oreilly.com/library/view/effective-modern-c/9781491908419/) book
 - [C++ Braced Initialization](https://blog.quasardb.net/2017/03/05/cpp-braced-initialization)
 - [Initialize a vector in C++ (6 different ways)](https://www.geeksforgeeks.org/initialize-a-vector-in-cpp-different-ways/)