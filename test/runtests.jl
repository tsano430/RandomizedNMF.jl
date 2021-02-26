using Test
using Random
using RandomizedNMF

Random.seed!(5678)

X = rand(100, 50)
k = 5
maxiter = 10

ret = rnmf(X, k, maxiter=10, verbose=true)