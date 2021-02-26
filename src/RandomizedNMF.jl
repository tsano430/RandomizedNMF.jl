module RandomizedNMF

    using LinearAlgebra
    using NMF
    using Printf
    using StatsBase

    export rnmf

    function compute_objv(upd, s, X::Matrix{T}, W, H) where T
        mul!(s.WH, W, H)
        convert(T, 0.5) * sqL2dist(X, s.WH)
    end

    function compute_qb(X::Matrix{T}, k, oversampling, n_subspace) where T
        row, col = size(X)
        rand_mat = randn(col, k + oversampling)
        Y = X * rand_mat
        for i in 1:n_subspace
            Q, _ = qr(Y)
            Q, _ = qr(X' * Q)
            Y = X * Q
        end
        
        Q, _ = qr(Y)
        B = Q' * X
        return Q, B
    end

    function rnmf(X::Matrix{T}, k::Integer;
                  maxiter::Integer=100,
                  oversampling::Integer=20, 
                  n_subspace::Integer=2,
                  verbose::Bool=false) where T

        flipped = false
        row, col = size(X)
        if col > row
            X = X'
            flipped = true
        end

        # Initialize
        W, H = NMF.nndsvd(X, k, variant=:ar)

        # QB factorization
        Q, B = compute_qb(X, k, oversampling, n_subspace)
        Wtilde = Q' * W

        # Preparation
        upd = NMF.GreedyCDUpd{T}(zero(T), zero(T))
        s = NMF.GreedyCDUpd_State{T}(X, W, H)

        # Display info
        if verbose
            start = time()
            objv = compute_objv(upd, s, X, W, H)
            @printf("%-5s    %-13s    %-13s\n", "Iter", "Elapsed time", "objv")
            @printf("%5d    %13.6e    %13.6e\n", 0, 0.0, objv)
        end

        objvs = []

        # Optimize
        Ht = transpose(H)
        Bt = transpose(B)
        QB = Matrix{T}(undef, size(Q)[1], size(B)[2])
        for i in 1:maxiter
            # update H
            NMF._update_GreedyCD!(upd, s, Bt, Ht, Wtilde, false)

            # update W
            mul!(W, Q, Wtilde)
            mul!(QB, Q, B)
            NMF._update_GreedyCD!(upd, s, QB, W, Ht, true)
            mul!(Wtilde, Q', W)

            objv = compute_objv(upd, s, X, W, H)
            push!(objvs, objv)

            # Display info
            if verbose
                elapsed = time() - start
                objv = compute_objv(upd, s, X, W, H)
                @printf("%-5s    %-13s    %-13s\n", "Iter", "Elapsed time", "objv")
                @printf("%5d    %13.6e    %13.6e\n", i, elapsed, objv)
            end
        end

        if flipped
            return Ht, W', objvs
        else
            return W, H, objvs
        end
    end
end