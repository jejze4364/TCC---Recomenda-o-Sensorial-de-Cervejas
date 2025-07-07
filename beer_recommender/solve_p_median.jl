module PMedianSolver

using JuMP, GLPK, LinearAlgebra

"""
    solve_p_median(df::AbstractMatrix, p::Int)

Resolve o problema da p-mediana diretamente a partir dos dados normalizados.
"""
function solve_p_median(df::AbstractMatrix, p::Int)
    n = size(df, 1)
    
    # Construir matriz de distâncias absolutas (L1)
    D = zeros(n, n)
    for i in 1:n
        for j in 1:n
            D[i, j] = sum(abs.(df[i, :] .- df[j, :]))
        end
    end

    model = Model(GLPK.Optimizer)

    @variable(model, x[1:n,1:n], Bin)
    @variable(model, y[1:n], Bin)

    @objective(model, Min, sum(D[i,j]*x[i,j] for i in 1:n, j in 1:n))

    @constraint(model, [i=1:n], sum(x[i,j] for j in 1:n) == 1)
    @constraint(model, [i=1:n, j=1:n], x[i,j] <= y[j])
    @constraint(model, sum(y[j] for j in 1:n) == p)

    optimize!(model)

    clusters = Dict{Int,Int}()
    medians = Int[]

    for i in 1:n
        for j in 1:n
            if value(x[i,j]) > 0.5
                clusters[i] = j
            end
        end
        if value(y[i]) > 0.5
            push!(medians, i)
        end
    end

    return clusters, medians
end

end
