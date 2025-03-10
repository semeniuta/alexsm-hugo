---
layout: post
title: Optimization with Python
comments: true
slug: optimization-with-python
summary: "Resources on doing mathematical optimization with Python (SciPy and other tools)."
date: "2021-04-11"
tags: [python, optimization, datascience]
---

Mathematical optimization is a pervasive task in numerous engineering applications. It is concerned with algorithmic search for a value (usually a vector) that minimizes or maximizes a predefined objective function. In machine learning (ML), for instance, a search for the best configuration of model parameters is performed with an optimization algorithm minimizing the objective function that measures misfit between the known response values and those predicted by the ML model. 

Problems of different nature require different optimization algorithms. Luckily, the open-source Python ecosystem provides a good selection of those. This post is aimed as an overview of the available Python libraries/modules suitable for different classes of mathematical optimization, along with some good resources on where to learn the respective methods and tools. 

The primary module containing most of the optimization-related functionality is [`scipy.optimize`](https://docs.scipy.org/doc/scipy/reference/optimize.html). Let's call it `opt` (as in `from scipy import optimize as opt`) in our further discussion. 

Let's take a look at the classes of optimization problems and the associated tools to tackle them:

 - **Least-squares minimization**: the very common problem of minizing the sum of squred residuals. The tools of the trade are [`opt.curve_fit`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.curve_fit.html), as well as [`np.polyfit`](https://numpy.org/doc/stable/reference/generated/numpy.polyfit.html) and [`np.linalg.lstsq`](https://numpy.org/doc/stable/reference/generated/numpy.linalg.lstsq.html). 
 
 - **Constrained optimization**: in addition to the objective function, the problem involves a set of constraints that have to be satisfied. These problems typically fall into the categories of linear programming (LP) or quadratic programming (QP). The methods that can be invoked via [`opt.minimize`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.minimize.html) function are `COBYLA` and `SLSQP`. Additionally, the [`cvxopt`](https://cvxopt.org/) library for convex optimization is available. 
 
 - **Unconstrained optimization**: the most general category of optimization problems, only the objective function (and sometimes its first and second derivatives) are specified. Different methods available through the [`opt.minimize`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.minimize.html) function call can be used to tackle these problems. Some methods, such as `BFGS` and `Nelder-Mead` require only the objective function itself. Conversely, some methods rely on the gradient and sometimes Hessian of the objective function to select the direction of the most profound change. Examples of these methods are `CG` and `Netwon-CG`. One might be interested in looking at the [mystic](https://mystic.readthedocs.io/) library, tackling specifically the unconstrained optimization problems and providing an object-orinted API with extensive callback functionality. 
 
 - **Solving multivariate equations**: this boils down to finding roots of vector functions, with the main entry point being the `opt.root` function. 
 
 - **Global brute-force optmization**: some complex problems require time-consuming brute-force methods, especially in situation with multiple local minima. Examples of the functions of this sort are [`opt.differential_evolution`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.differential_evolution.html) and [`opt.basinhopping`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.basinhopping.html). 

Other useful tools I wanted to highlight are those related to **automatic computation of gradients** to be further used with the methods relying on the objective function derivatives:

 - [`autograd`](https://github.com/HIPS/autograd): computes derivatives of arbitrary Python functions based on NumPy code with automatic differentiation.
 - `theano`/[`aesara`](https://github.com/pymc-devs/aesara): allows for constructing, evaluation and optimizing mathematical expression with multi-dimensional arrays. 

To learn more about using optimization methods in the Python ecosystem, I would recommend the following resources:

 - Video tutoriasl by Mike McKerns:
    - [SciPy 2015](https://www.youtube.com/watch?v=avRx2cdNZmk)
    - [SciPy 2017](https://www.youtube.com/watch?v=geFER2oVvvU)
 - RealPython tutorials
    - [Using SciPy for Optimization](https://realpython.com/python-scipy-cluster-optimize/)
    - [Stochastic Gradient Descent Algorithm With Python and NumPy](https://realpython.com/gradient-descent-algorithm-python/)
 
 




