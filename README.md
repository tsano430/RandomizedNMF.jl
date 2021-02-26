# RandomizedNMF.jl

[![Build Status](https://travis-ci.org/tsano430/RandomizedNMF.jl.svg?branch=main)](https://travis-ci.org/tsano430/RandomizedNMF.jl)
[![Coverage Status](https://coveralls.io/repos/github/tsano430/RandomizedNMF.jl/badge.svg?branch=main)](https://coveralls.io/github/tsano430/RandomizedNMF.jl?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


Randomized nonnegative matrix factorization in Julia

Installation
------------

```
]add RandomizedNMF
```

Usage
-----

```julia
julia> using RandomizedNMF

julia> X = rand(100, 200)

julia> W, H = rnmf(X, 5, oversampling=20, n_subspace=2)
```

**Note:** Increasing `oversampling` and `n_subspace` leads to decrease the objective function value, but take a long time to execute `rnmf`.

Advantage
---------

```julia
julia> using RandomizedNMF, NMF, BenchmarkTools

julia> X = rand(100, 200);

julia> @btime nnmf($X, 5, maxiter=100);
  91.854 ms (1532888 allocations: 190.36 MiB)

julia> @btime rnmf($X, 5, maxiter=100);
  73.596 ms (1165547 allocations: 146.14 MiB)
```

Reference
---------

[1] N. B. Erichson, A. Mendible, S. Wihlborn, and J. N. Kutz, 
Randomized nonnegative matrix factorization. Pattern Recognition Letters, 
vol. 104, pp. 1–7, 2018.