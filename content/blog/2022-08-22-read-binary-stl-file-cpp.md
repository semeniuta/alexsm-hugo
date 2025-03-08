---
layout: post
title: "Reading a binary STL file with C++"
comments: true
math: true
slug: read-binary-stl-file-cpp
date: "2022-08-22"
tags: [programming, c++]
---

[STL](https://en.wikipedia.org/wiki/STL_(file_format)) is a common file format, originated in the area of [additive manufacturing](https://en.wikipedia.org/wiki/3D_printing), used for storing trinagular meshes. It exists in two forms: binary STL and ASCII STL, differing by whether the data is written directly in a binary form or using a special text-based syntax. Obviously, the former variant is more efficient, and in this blog post I am going to provide some tips on how to read such a file using C++.

The structure of a binary STL file is as follows (here by *byte* I mean an octet, i.e. 8 bits):

 * 80 bytes: header (`char[80]`)
 * 4 bytes: number of facets (`unsigned int`)
 * `n` blocks of 50 bytes, where `n` is the number of facets:
   - 12 bytes: normal vector (`float[3]`)
   - 12 bytes: vertex 1 (`float[3]`)
   - 12 bytes: vertex 2 (`float[3]`)
   - 12 bytes: vertex 3 (`float[3]`)
   - 2 bytes: attribute byte count (`short`)

We are going to use `std::ifstream` to read the file. As such, we include the `<fstream>` header and, for convenience, define a helper function to create an input file stream for reading binary data:

```c++
std::ifstream open_binary_file(const char* filename)
{
    return std::ifstream{filename, std::ifstream::in | std::ifstream::binary};
}
```

The primary elementary piece of data we will be reading is a facet. Let's define a `struct` with the fields correspoding to the four $\mathbb{R}^3$ vectors:

```c++
struct Facet
{
    float normal[3];
    float v1[3];
    float v2[3];
    float v3[3];
};
```

Looking at the structure of the file above, you may see that the elementary types to be read are `char` (to read the fixed-sized header string), `unsigned int` (to read the number of facets), and `float` (to read an individual scalar). Let's define some generic helper functions to decode these values from the binary representations. The first one would read a single binary value of the given type:

```c++
template <typename T>
void read_binary_value(std::ifstream& in, T* dst)
{
    in.read(as_char_ptr(dst), sizeof(T));
}
```

The idea here is as follows. An input stream expects a `char*`, along with the number of bytes to be read. We can cast a pointer to some other type to `char*` using [`reinterpret_cast`](https://cplusplus.com/doc/tutorial/typecasting/). To unclutter the code, we use a helper function:

```c++
template <typename T>
char* as_char_ptr(T* pointer)
{
    return reinterpret_cast<char*>(pointer);
}
```

Further, we create a similar function, reading a C array of values of some type:

```c++
template <typename T>
void read_binary_array(std::ifstream& in, T* dst, size_t array_length)
{
    size_t n_bytes = array_length * sizeof(T);
    in.read(as_char_ptr(dst), n_bytes);
}
```

A simplified flow of the actual reading of the file is then as follows:

```c++
auto in = open_binary_file(filename);

char header[81];
unsigned int n_facets;
std::vector<Facet> facets;

read_binary_array<char>(in, header, 80);
header[80] = '\0'; // to ensure a proper C string

read_binary_value<unsigned int>(in, &n_facets);

facets.reserve(n_facets);

for (size_t i = 0; i < n_facets; ++i) {
    Facet f{};
    
    read_binary_array<float>(in, f.normal, 3);
    read_binary_array<float>(in, f.v1, 3);
    read_binary_array<float>(in, f.v2, 3);
    read_binary_array<float>(in, f.v3, 3);

    facets.emplace_back(f);
}
```

