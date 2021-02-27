# runtests.jl

using Test
using Random
using RandomizedNMF

Random.seed!(5678)

# Test 1
X = rand(100, 50)
k = 5
maxiter = 10
W, H = rnmf(X, k, maxiter=10, verbose=true)
@test all(W .>= 0.0)
@test all(H .>= 0.0)

# Test 2
Y = rand(50, 100)
W, H = rnmf(Y, k, maxiter=10)
@test all(W .>= 0.0)
@test all(H .>= 0.0)

# Test 3
W, H = rnmf(Y, k, maxiter=10, lambda_w=0.1, lambda_h=0.1)
@test all(W .>= 0.0)
@test all(H .>= 0.0)