---
layout: post
title: Searching for the closest value in a sorted vector with C++
comments: true
slug: cpp-closest-lower-bound
date: "2021-04-24"
tags: [c++, programming]
---

In this post I am going to show how to efficiently search for the closest element in sorted `std::vector` using the `std::lower_bound` function from the Standard Template Library (STL). 

The problem is a follows: you have a bunch of numbers (e.g. `double`s) that you have stored in a `std::vector`, which you have subsequently sorted, and you want to, given a new number `x`, find the element in the sorted vector that is the closest to `x`. This problem sounds very similar to binary search, although the goal here is not to find exacly the same value as `x`, but to report on the value having the lowest difference with `x`.

The C++ function that does the work is presented below. It takes a reference to a sorted vector, along with the value to search for (`x`), and returns the index of the element closest to `x`. Further, we will go step-by-step and examine what the function does.

```cpp
long search_closest(const std::vector<double>& sorted_array, double x) {

    auto iter_geq = std::lower_bound(
        sorted_array.begin(), 
        sorted_array.end(), 
        x
    );

    if (iter_geq == sorted_array.begin()) {
        return 0;
    }

    double a = *(iter_geq - 1);
    double b = *(iter_geq);

    if (fabs(x - a) < fabs(x - b)) {
        return iter_geq - sorted_array.begin() - 1;
    }

    return iter_geq - sorted_array.begin();

}
```

The main function we are using here is `std::lower_bound`:

```c++
auto iter_geq = std::lower_bound(
    sorted_array.begin(), 
    sorted_array.end(), 
    x
);
```

As you may read in the [reference](https://en.cppreference.com/w/cpp/algorithm/lower_bound), it returns an iterator that points to the first element in the range between the two supplied iterators that is **greater or equal** to the searched value. That's exacly what we need: the returned iterator either points to the exact element we are searching for, or the element we want is actually one position in front (depending which one is closer to `x`). 

If the returned lower bound corresponds to the first element in the vector, there is no point to check for the element to the left, so we just return 0:

```cpp
if (iter_geq == sorted_array.begin()) {
    return 0;
}
```

Otherwise, we dereference `iter_geq - 1` and `iter_geq` and check which one is closest to `x`:

```cpp
double a = *(iter_geq - 1);
double b = *(iter_geq);

if (fabs(x - a) < fabs(x - b)) {
    return iter_geq - sorted_array.begin() - 1;
}

return iter_geq - sorted_array.begin();
```

That's all. We've got the required result. Let's see how this function works for a simple example application that you may find [here](https://github.com/semeniuta/demo_cpp/blob/master/src/demo_find_closest.cpp) (with the code for `print_vector` [here](https://github.com/semeniuta/demo_cpp/blob/master/src/helpers.h)). 

```cpp
int main() {

    // Define a vector of unsorted doubles
    std::vector<double> numbers = {
        3.14, 4.89, 1.2, 9.4, 0.57, -1.9, 5.3, 4.65
    };

    // Sort the vector
    std::sort(numbers.begin(), numbers.end());

    std::cout << "Sorted vector:" << std::endl; 
    print_vector(numbers);

    // Search for the closest 
    for (double x : std::vector<double>{5, 5.1}) {

        std::cout << "\nSearching element closest to " << x;
        std::cout << std::endl;

        long idx_closest = search_closest(numbers, x);

        std::cout << "Index of the closest element: " << idx_closest;
        std::cout << std::endl;

        std::cout << "The closest element itself: " << numbers[idx_closest];
        std::cout << std::endl;
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
The closest element itself: 5.3
```

As you can see, the numbers 4.89 and 5.3 sort of compete in this situation. For both 5 and 5.1 as input value, the `std::lower_bound` returns an iterator pointing to 5.3 as the first greater or equal element than `x`. However, the final result is based on the actual closeness. 

