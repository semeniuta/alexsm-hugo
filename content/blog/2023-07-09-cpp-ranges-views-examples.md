---
layout: post
title: "Some example of std::ranges and std::views usage in C++20"
comments: true
math: true
slug: cpp-ranges-views-examples
summary: "Useful examples with ranges and views, allowing for more functional style of C++ code."
date: "2023-07-09"
tags: [c++, programming]
---

C++20 came with a bunch of useful new features, including *concepts*, *ranges*, and *views*. Here I will provide some examples of these new language features. 

Let's start with a simple vector of 10 integers, staring from 0 and incrementing towards 9 (to use `std::iota`, inbclude the `<numeric>` header):

```c++
constexpr size_t n_numbers = 10;
std::vector<int> numbers(n_numbers);
std::iota(numbers.begin(), numbers.end(), 0);
```

The first task is just to print the numbers. To inspect a range with integers or elements of other type, we'll create a helper function template:

```c++
template <std::ranges::range Range>
void print_elements(Range v)
{
    for (auto element : v) {
        std::cout << element << " ";
    }
    std::cout << "\n";
}
```

Note that I am using `std::ranges::range` instead of the typical `typename` in the template definition. This signifies that I am using a range concept (I recomment to check out [this blog post](https://hannes.hauswedell.net/post/2019/11/30/range_intro/) that explains the idea of different range concepts). In short, I am constraining the template to accept a type you can iterate over. This can be a `std::vector`, but it can also be something alse, such as a *view* (which we will go back to shortly).

When used, on `numbers`, we get the expected result:

```c++
print_elements(numbers);
```

```
0 1 2 3 4 5 6 7 8 9
```

Let's now use `std::ranges::for_each` to apply a function to every element in a range. As an example, let's print each number ending in a newline character:

```c++
std::ranges::for_each(numbers, [](auto n) { std::cout << n << "\n"; });
```

```
0
1
2
3
4
5
6
7
8
9
```

The next example is to filter the input range, by keeping only the even numbers. Here, we use `std::views::filter` and the new piping syntax:

```c++
auto view_even = numbers | std::views::filter([](int x) { return x % 2 == 0; });
print_elements(view_even);
```

```
0 2 4 6 8
```

The variable `view_even` in the example above is of a type of `std::ranges::filter_view`. It is a lazy data structure that let you "view" the filtered elements when requested. I find it conceptually similar to the lazy interators in Python, returned by the functions such as `filter` and `map`. In our example it was OK to supply the view to `print_elements`, since it also a range.

We can construct more complex pipelines with views, such as the following: retain only even numbers, multiply each such mumber by 100 and convert the result to a string representing its value in hexadecimal. In addition to `std::views::filter`, we'll use `std::views::transform`. We first define a helper function:

```c++
#include <iomanip> // for std::hex

std::string int_to_hex(int number)
{
    std::stringstream ss;
    ss << "0x" << std::hex << number;
    return ss.str();
}
```

Then, we use it in the views expression:

```c++
auto view_even_times_100_as_hex = numbers
    | std::views::filter([](int x) { return x % 2 == 0; })
    | std::views::transform([](int x) { return x * 100; })
    | std::views::transform(int_to_hex);

print_elements(view_even_times_100_as_hex);
```

The result is as follows:

```
0x0 0xc8 0x190 0x258 0x320
```

The next example is using `std::ranges::transform`. Here out goal is to create an actual container, rather than a view. The task is to produce a vector of strings, based on the vector of numbers, where each number will map to a string, e.g. the integer 5 will map to `"user_5"`. In the example below we are using the [fmt](https://fmt.dev) library to format the strings:

```c++
// assumes <fmt/core.h> is included

std::vector<std::string> users;
users.reserve(numbers.size());

std::ranges::transform(
    numbers,
    std::back_inserter(users),
    [](int n) { return fmt::format("user_{}", n); }
);

print_elements(users);
```
The `std::ranges::transform` function accepts a range, a back insert iterator, and a callable that realizes the mapping. The result of the snippet above is as follows:

```
user_0 user_1 user_2 user_3 user_4 user_5 user_6 user_7 user_8 user_9
```

Another useful function is `std::ranges::count_if`. It returns the count of how many times a certain condition is true for each element in a range. The code below counts how many weights are greater or equal to 0.5:

```c++
const std::vector<float> weights = {0.2, 0.68, 0.31, 0.59, 0.81, 0.74, 0.14};

const auto is_high = [](float w) { return w >= 0.5f; };
const auto n_high = std::ranges::count_if(weights, is_high);

std::cout << "number of weights >= 0.5: " << n_high << "\n";
```

In case you've got a view, but want to collect the results in an actual container, you could use `std::ranges::copy`. In the example below we have a view of hexadecimal representation of numbers from 0 to 20. In the end, we collect them in a vector of strings:s

```c++
const auto view_int_to_hex = std::views::iota(0, 21) | std::views::transform(int_to_hex);

std::vector<std::string> hex_strings;
hex_strings.reserve(view_int_to_hex.size());
std::ranges::copy(view_int_to_hex, std::back_inserter(hex_strings));

print_elements(hex_strings);
```

The printed result is the following:

```
0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xa 0xb 0xc 0xd 0xe 0xf 0x10 0x11 0x12 0x13 0x14
```

The final example is a bit bigger. We start with a custom struct that defines a person's name together with a certain score:

```c++
struct PersonScore
{
    std::string name;
    int value;
};
```

Then, let's imagine we have a bunch of such score records in a vector:

```c++
std::vector<PersonScore> office_scores = {
    {"Jim Halpert", 176},
    {"Michael Scott", 201},
    {"Pam Beesly", 203},
    {"Samuel L. Chang", 85},
};
```

Our goal is to sort the values in descending order of the score and format this list in a string. First, we do the sorting (using the `ranges`-version of `sort`):

```c++
std::ranges::sort(office_scores, std::ranges::greater{}, &PersonScore::value);
```

The first argument here is the range to be sorted, the second one is the comparison function, and the thid is the field of the struct to sort by.

The next step is to create a view of the sorted range, in which we map each struct value to a string with the name followed by the score in a parentheses:

```c++
const auto office_view = office_scores | std::views::transform(
    [](const PersonScore& score) { return fmt::format("{} ({})", score.name, score.value); }
);
```

As the last step, we want feed the values in this view into `boost::algorithm::join`. However, we'll need to create an actual container first. Let's do it using the following helper function template:

```c++
template <std::ranges::range Range>
auto range_to_vector(const Range& range)
{
    using T = std::ranges::range_value_t<decltype(range)>;

    std::vector<T> elements;
    elements.reserve(range.size());

    std::ranges::copy(range, std::back_inserter(elements));

    return elements;
}
```

Thus function template is a bit funky, as we specify the return type as `auto`. The final return type is deduced during compilation, and the cool part is that we obtain the type `T` of the range elements using `decltype` and `std::ranges::range_value_t`. Having this helper, we finalize our code as follows:

```c++
// assumes <boost/algorithm/string.hpp> is included

const auto descriptions_of_scores = range_to_vector(office_view);
fmt::print("Scores: {}.\n", boost::algorithm::join(descriptions_of_scores, ", "));
```

The result is the neat string of the sorted and formatted enties, separated by a comma + space:

```
Scores: Pam Beesly (203), Michael Scott (201), Jim Halpert (176), Samuel L. Chang (85).
```

The examples from this blog post are available on [GitHub](https://github.com/semeniuta/demo_cpp/blob/master/src/demo_ranges.cpp).

Some useful resources on `std::ranges`:

 * [Introduction to C++ Ranges (a "Fluent C++" video)](https://www.youtube.com/watch?v=4p21wBOplPQ)
 * [A beginner's guide to C++ Ranges and Views.](https://hannes.hauswedell.net/post/2019/11/30/range_intro)
 * [C++20 Ranges Algorithms - 11 Modifying Operations](https://www.cppstories.com/2022/ranges-alg-part-two)
 * [How to make a container from a C++20 range](https://timur.audio/how-to-make-a-container-from-a-c20-range)
 * [C++20 Ranges Algorithms - sorting, sets, other and C++23 updates](https://www.cppstories.com/2022/ranges-alg-part-three)




