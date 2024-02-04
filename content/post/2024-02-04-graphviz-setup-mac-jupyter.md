---
layout: post
title: "Graphviz setup on a Mac to be used with Python/Jupyter"
comments: true
math: true
slug: graphviz-setup-mac-jupyter
date: "2024-02-04"
tags: [macos, python, jupyter]
---

[Graphviz](https://graphviz.org) is a powertful software for visualization of graphs. Back in the days, particularly during my time as a PhD candidate, I used Graphviz pretty actively, often in combination with Jupyter notebooks. Back then, I had a custom [Conda](https://docs.conda.io/projects/miniconda/en/latest/) environment, which contained all the necessary packages. One of those was [nxpd](https://github.com/chebee7i/nxpd), which is not actively maintained. I got curious what might be a today's solution, without requiring Conda and with minimal selection of dependencies. This post contains my notes on that.

The Graphviz software can be [installed using Brew](https://formulae.brew.sh/formula/graphviz):

```sh
brew install graphviz
```

This gives access to [`dot` rendering program](https://graphviz.org/doc/info/command.html) in your terminal.

Furthermore, there are several Graphviz-related packages you can install from PyPI:

 * [graphviz](https://pypi.org/project/graphviz/): simple tool that invokes `dot`.
 * [pygraphviz](https://pypi.org/project/pygraphviz/): full-blown library containing Graphviz.
 * [graphviz-python](https://pypi.org/project/graphviz-python/): Graphviz's official Python bindings.
 * [pydot](https://pypi.org/project/pydot/): tool for reading and constructing files in [DOT language](https://en.wikipedia.org/wiki/DOT_%28graph_description_language%29).

I decided to follow [this blog post](https://h1ros.github.io/posts/introduction-to-graphviz-in-jupyter-notebook/), and went along with the first option:

```sh
pip install graphviz
```

As such, the setup comprises Graphviz's `dot` on your `$PATH` together with the `graphviz` Python library.

You can, for instance, convert `networkx.DiGraph` to `graphviz.Digraph`:

```python
import graphviz
import networkx

def to_graphviz(nxg: networkx.DiGraph) -> graphviz.Digraph:

    graph = graphviz.Digraph()

    for node_name in nxg.nodes:
        graph.node(node_name)    

    graph.edges(tuple(nxg.edges))

    return graph
```

When working in a  Jupyter notebook, and having an object named `graph` of type `graphviz.Digraph`, the simple expression

```python
graph
```

will render the graph inline in the notebook. The rendered result will be in SVG, which is pretty neat, given the advantages of vector graphics. 

