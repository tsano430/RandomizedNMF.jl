# RandomizedNMF.jl

[![Build Status](https://travis-ci.org/tsano430/RandomizedNMF.jl.svg?branch=main)](https://travis-ci.org/tsano430/RandomizedNMF.jl)
[![Coverage Status](https://coveralls.io/repos/github/tsano430/RandomizedNMF.jl/badge.svg?branch=main)](https://coveralls.io/github/tsano430/RandomizedNMF.jl?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


Randomized nonnegative matrix factorization in Julia

Installation
------------

```
Pkg.add("RandomizedNMF")
```

Usage
-----

`rnmf` decomposes a given matrix `X` into two nonnegative factor matrices `W` and `H`, so that `WH` is approximately equal to `X`. 

```julia
julia> using RandomizedNMF

julia> X = rand(100, 200)

julia> W, H = rnmf(X, 5, maxiter=100, oversampling=20, n_subspace=2)
```

- `maxiter`: Maximum number of iterations (default=`100`). 

- `oversampling`: Oversampling of column space (default=`20`).

- `n_subspace`: Number of subspace iterations (default=`2`).

  **Note:** Increasing `oversampling` or `n_subspace` leads to minimize the objective function, but take a long time to execute `rnmf`.

- `lambda_w`: L1 regularization coefficient for W (default=`0.0`).

- `lambda_h`: L1 regularization coefficient for H (default=`0.0`).

- `verbose`: Whether to be verbose (default=`false`).

Advantage
---------

Randomized NMF is faster than NMF.

```julia
julia> using RandomizedNMF, NMF, BenchmarkTools, Random

julia> Random.seed!(1234);

julia> X = rand(100, 200);

julia> @btime nnmf($X, 5, maxiter=500);
  117.547 ms (1035 allocations: 6.80 MiB)

julia> @btime rnmf($X, 5, maxiter=500);
  83.795 ms (1093 allocations: 7.45 MiB)

julia> Y = rand(10000, 5000);

julia> @btime nnmf($Y, 5, maxiter=500);
  85.910 s (2054 allocations: 2.33 GiB)

julia> @btime rnmf($Y, 5, maxiter=500);
  66.060 s (2112 allocations: 2.73 GiB)
```

Reference
---------

[1] N. B. Erichson, A. Mendible, S. Wihlborn, and J. N. Kutz, 
Randomized nonnegative matrix factorization, 
Pattern Recognition Letters, vol. 104, pp. 1–7, 2018.
