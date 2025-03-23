---
layout: post
title: Searching for the closest value in a sorted vector with C++
comments: true
slug: cpp-closest-lower-bound
summary: "Kind of like binary search, but for a std::vector of sorted floats, using std::lower_bound"
date: "2021-04-24"
tags: [c++, programming]
---

**NOTE: This blog post was updated on October 26, 2022 to fix the original buggy implementation. Thanks to Marek Ruszczak for pointing out the problem.**

In this post I am going to show how to efficiently search for the closest element in sorted `std::vector` using the `std::lower_bound` function from the Standard Template Library (STL). 

The problem is a follows: you have a bunch of numbers (e.g. `double`s) that you have stored in a `std::vector`, which you have subsequently sorted, and you want to, given a new number `x`, find the element in the sorted vector that is closest to `x`. This problem sounds very similar to binary search, although the goal here is not to find exacly the same value as `x`, but to report on the value having the lowest difference with `x`.

The C++ function that does the work is presented below. It takes a reference to a sorted vector, along with the value to search for (`x`), and returns an optional to the index of the element closest to `x` (or `std::nullopt` if the vector is empty). Further, we will go step-by-step and examine what the function does.

```cpp
std::optional<size_t> search_closest(const std::vector<double> & sorted_array, double x) {

    if (sorted_array.empty())
        return std::nullopt;

    const auto iter_geq = std::lower_bound(sorted_array.begin(), sorted_array.end(), x);

    if (iter_geq == sorted_array.begin())
        return 0;

    if (iter_geq == sorted_array.end())
        return sorted_array.size() - 1;

    const auto & a = *(iter_geq - 1);
    const auto & b = *(iter_geq);

    if (std::fabs(x - a) < std::fabs(x - b))
        return iter_geq - sorted_array.begin() - 1;

    return iter_geq - sorted_array.begin();
}
```

If the vector is empty, we have no value to return, hence `std::nullopt` is the result:

```cpp
if (sorted_array.empty())
    return std::nullopt;
```

Further, we are using `std::lower_bound`:

```c++
const auto iter_geq = std::lower_bound(
    sorted_array.begin(), 
    sorted_array.end(), 
    x
);
```

As you may read in the [reference](https://en.cppreference.com/w/cpp/algorithm/lower_bound), it returns an iterator that points to the first element in the range between the two supplied iterators that is **greater or equal** to the searched value. That's exacly what we need: the returned iterator either points to the exact element we are searching for, or the element we want is actually one position in front (depending which one is closer to `x`).

If the returned lower bound corresponds to the first element in the vector, there is no point to check for the element to the left, so we just return 0:

```cpp
if (iter_geq == sorted_array.begin())
    return 0;
```

If the returned lower bound is `sorted_array.end()`, there was no element that was greater or equal to `x`. In that case, we can just return the index of the last element:

```cpp
if (iter_geq == sorted_array.end())
    return sorted_array.size() - 1;
```

Otherwise, we dereference `iter_geq - 1` and `iter_geq` and check which one is closest to `x`:

```cpp
const auto & a = *(iter_geq - 1);
const auto & b = *(iter_geq);

if (std::fabs(x - a) < std::fabs(x - b))
    return iter_geq - sorted_array.begin() - 1;

return iter_geq - sorted_array.begin();
```

That's all. We've got the required result. Let's see how this function works for a simple example application that you may find [here](https://github.com/semeniuta/demo_cpp/blob/master/src/demo_find_closest.cpp) (with the code for `print_vector` [here](https://github.com/semeniuta/demo_cpp/blob/master/src/helpers.h)). 

```cpp
int main()
{
    // Define a vector of unsorted doubles
    std::vector<double> numbers = {3.14, 4.89, 1.2, 9.4, 0.57, -1.9, 5.3, 4.65};

    // Sort the vector
    std::sort(numbers.begin(), numbers.end());

    std::cout << "Sorted vector:" << std::endl; 
    print_vector(numbers);

    // Search for the closest 
    for (double x : std::vector<double>{5, 5.1}) {
        fmt::print("\nSearching element closest to {}\n", x);

        if (const auto idx_closest = search_closest(numbers, x)) {
            fmt::print("Index of the closest element: {}\n", *idx_closest);
            fmt::print("The closest element itself: {:.2f}\n", numbers[*idx_closest]);
        } else {
            fmt::print("could not find\n");
        }
    }

    return 0;
}
```

When we build and run the program, the output is as follows:

```
Sorted vector:
[-1.9, 0.57, 1.2, 3.14, 4.65, 4.89, 5.3, 9.4]

Searching element closest to 5
Index of the closest element: 5
The closest element itself: 4.89

Searching element closest to 5.1
Index of the closest element: 6
The closest element itself: 5.30
```

As you can see, the numbers 4.89 and 5.3 sort of compete in this situation. For both 5 and 5.1 as input value, the `std::lower_bound` returns an iterator pointing to 5.3 as the first greater or equal element than `x`. However, the final result is based on the actual closeness. 

Some more test cases are as follows:

```cpp
const std::vector<double> many = {-2, 0, 1, 1.5, 3, 4.7};
const std::vector<double> two = {1, 5};
const std::vector<double> single = {10};
const std::vector<double> empty = {};

assert(std::nullopt == search_closest(empty, 20.0));

assert(0 == search_closest(single, 20.0).value());
assert(0 == search_closest(single, -1.0).value());

assert(1 == search_closest(two, 20.0).value());
assert(1 == search_closest(two, 4.0).value());
assert(0 == search_closest(two, 2.0).value());
assert(0 == search_closest(two, 0.5).value());

assert(5 == search_closest(many, 20.0).value());
assert(5 == search_closest(many, 4.0).value());
assert(3 == search_closest(many, 2.0).value());
assert(0 == search_closest(many, -10.0).value());
```
