---
layout: post
title: "Different methods of search and insertion into std::map"
comments: true
slug: cpp-map-lookup-and-insert
date: "2022-01-29"
tags: [c++, programming]
---

`std::map` is a widely-used container from the C++ Standard Template Library (STL) realizing the function of "dictionary", with efficient insertion and lookup of values identified with their keys. The interface of this data type is quite flexible, in a sense that it allows for achieving seemingly the same task in several different ways. This also makes it a bit confusing how these varying methods differ from one another. This blog post provides a summary of insertion and lookup operations in `std::map`. 

`std::map` is a part of the so-called **associative containers** in STL, and is structured internally as  a balanced search tree. This is different from another associative container, namely `std::unordered_map`, which internally is realized as a hash table, in the same way as [Python dictionary](https://docs.python.org/3/tutorial/datastructures.html#dictionaries). 

A canonical example of application of a `std::map` (and `std::unordered_map` for that matter) is counting frequencies of words. My first example of lookup/inserion logic with `std::map` is what I consider the most universal, namely using `find` and `insert` methods:

```c++
std::map<std::string, int> frequencies;

for (const auto& w : words) {
    auto search = frequencies.find(w);
    if (search == frequencies.end()) {
        frequencies.insert(search, {w, 1});
    } else {
        ++(search->second);
    }
}
```
The `find` method performs lookup in logarithmic running time, returning an iterator, either pointing to the `std::pair` of key/value if one exists, or to `frequencies.end()` if the key was not found. 

The `insert` method can be used in several ways. In the example above, it takes the iterator as a **hint** to where the key/value pair should be inserted, and the key/value `std::pair` itself. Providing the hint, if optimal, will optimize the insertion operation. Alternatively, the hint can be skipped, with only the key/value pair provided:

```c++
frequencies.insert({w, 1});
```
A very similar way is to use `emplace`, without explicit creation of `std::pair`:

```c++
frequencies.emplace(w, 1);
```

This latter variant can be more efficient than its `insert` counterpart. `emplace` works also with hints, so the following call is also supported:

```c++
frequencies.emplace(search, w, 1);
```

Both insertion and lookup can also be realized with `operator[]`, making the code more "Pythonic", i.e. with calls like `m[k] = v;`.  There is a catch, however: if the key does not exist, a call `m[k]` will create a new tree node for `k` and return the default value for the value data type (e.g. `0` for `int`). 

An alternative for `operator[]` when it comes to lookup is the method `at`, used as follows:

```c++
auto value = m.at(k); // alternative to m[k]
```

The difference between the two manifests itself when the key doesn't exist. A call to `at` will throw an `out_of_range` exception if the key is not found.

Some links to check out on the topic:

 * [std::map at cplusplus.com](https://www.cplusplus.com/reference/map/map/)
 * Section 31.4.3 "Associative Containers" of [Stroustrup's "The C++ Programming Language"](https://www.stroustrup.com/4th.html)
 * [Inserting elements in std::map (insert, emplace and operator [])
](https://www.geeksforgeeks.org/inserting-elements-in-stdmap-insert-emplace-and-operator/)
 * [Check if a Key Exists in a Map in C++](https://www.delftstack.com/howto/cpp/cpp-map-check-if-key-exists/)
