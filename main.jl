include("data_loader.jl")
include("preprocessing.jl")
include("solve_p_median.jl")

using .BeerData
using .Preprocessing
using .PMedianSolver

# Carregar dados a partir do arquivo BJCP 2015
beer_df = load_beer_data()

# Extrair descrições em texto dos arquivos .tex
tex_df = parse_tex_directory("data")

# Determinar coluna de identificacao (Estilo ou Categoria)
key = :Estilo in names(beer_df) ? :Estilo : ( :Categoria in names(beer_df) ? :Categoria : first(names(beer_df)) )

estilos = beer_df[!, key]
features = convert(Matrix{Float64}, select(beer_df, Not(key)))

# Normalizar
normalized_df = normalize_data(features)

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
