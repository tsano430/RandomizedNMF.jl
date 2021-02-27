# RandomizedNMF.jl

module RandomizedNMF

    using LinearAlgebra
    using NMF
    using Printf
    using StatsBase

    export rnmf

    # Compute objective function value
    function compute_objv(updater, state, X, W::Matrix{T}, H) where T
        mul!(state.WH, W, H)
        objv = convert(T, 0.5) * sqL2dist(X, state.WH)
        if updater.lambda_w > zero(T)
            objv += updater.lambda_w * norm(W, 1)
        end
        if updater.lambda_h > zero(T)
            objv += updater.lambda_h * norm(H, 1)
        end
        return objv
    end

    # Compute QB factorization
    function compute_qb(X::AbstractMatrix{T}, k, oversampling, n_subspace) where T
        row, col = size(X)
        Y = X * randn(col, k + oversampling)
        XTQ = Matrix{T}(undef, col, k + oversampling)
        for i in 1:n_subspace
            F = qr(Y)
            Q = F.Q * Matrix(I, size(Y)...)
            mul!(XTQ, X', Q)
            F = qr(XTQ)
            Q = F.Q * Matrix(I, size(XTQ)...)
            mul!(Y, X, Q)
        end
        
        F = qr(Y)
        Q = F.Q * Matrix(I, size(Y)...)
        B = Q' * X
        return Q, B
    end

    # Randomized nonnegative matrix factorization
    function rnmf(X::Matrix{T}, k::Integer;
                  maxiter::Integer=100,
                  oversampling::Integer=20, 
                  n_subspace::Integer=2,
                  lambda_w::T=zero(T), 
                  lambda_h::T=zero(T), 
                  verbose::Bool=false) where T

        eltype(X) <: Number && all(t -> t >= zero(T), X) || throw(ArgumentError("The elements of X must be non-negative."))
        row, col = size(X)
        k <= min(row, col) || throw(ArgumentError("The value of k should not exceed min(size(X))."))
        maxiter >= 1 || throw(ArgumentError("The value of maxiter must be positive."))
        oversampling >= 0 || throw(ArgumentError("The value of oversampling must be nonnegative."))
        n_subspace >= 0 || throw(ArgumentError("The value of n_subspace must be nonnegative."))
        lambda_w >= 0 || throw(ArgumentError("The value of lambda_w must be nonnegative."))
        lambda_h >= 0 || throw(ArgumentError("The value of lambda_h must be nonnegative."))

        flipped = false
        if col > row
            X = X'
            flipped = true
        end

        # Initialize (NNDSVDar)
        W, H = NMF.nndsvd(X, k, variant=:ar)

        # QB factorization
        Q, B = compute_qb(X, k, oversampling, n_subspace)
        Wtilde = Q' * W

        # Preparation for optimization
        upd = NMF.GreedyCDUpd{T}(lambda_w, lambda_h)
        s = NMF.GreedyCDUpd_State{T}(X, W, H)
        Ht = transpose(H)
        Bt = transpose(B)
        QB = Q * B

        # Display info
        if verbose
            start = time()
            objv = compute_objv(upd, s, X, W, H)
            @printf("%-5s    %-13s    %-13s\n", "Iter", "Elapsed time", "objv")
            @printf("%5d    %13.6e    %13.6e\n", 0, 0.0, objv)
        end

        # Optimize (Greedy coordinate descent algorithm)
        for t in 1:maxiter
            # update H
            NMF._update_GreedyCD!(upd, s, Bt, Ht, Wtilde, false)

            # update W
            mul!(W, Q, Wtilde)
            NMF._update_GreedyCD!(upd, s, QB, W, Ht, true)
            mul!(Wtilde, Q', W)

            # Display info
            if verbose
                elapsed = time() - start
                objv = compute_objv(upd, s, X, W, H)
                @printf("%-5s    %-13s    %-13s\n", "Iter", "Elapsed time", "objv")
                @printf("%5d    %13.6e    %13.6e\n", t, elapsed, objv)
            end
        end

        if flipped
            return Ht, W'
        else
            return W, H
        end
    end
end