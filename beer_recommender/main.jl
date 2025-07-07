include("data_loader.jl")
include("preprocessing.jl")
include("solve_p_median.jl")

using .BeerData, .Preprocessing, .PMedianSolver

# Carregar dados
estilos, df = load_style_data("data/por_estilo.csv")

# Normalizar
normalized_df = normalize_data(df)

# Resolver p-mediana
p = 3
clusters, medians = solve_p_median(normalized_df, p)

println("Estilos selecionados como medianas:")
for m in medians
    println("• ", estilos[m])
end

println("\nClusters:")
for (i, j) in sort(collect(pairs(clusters)))
    println("• ", estilos[i], " pertence ao cluster de ", estilos[j])
end
