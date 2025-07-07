module BeerData

using CSV, DataFrames

"""
    load_style_data(path::String) => (estilos, matriz)

Lê o CSV separando os nomes dos estilos da matriz numérica normalizada.
"""
function load_style_data(path::String)
    df = CSV.read(path, DataFrame; delim=';', ignorerepeated=true)
    estilos = df[!, :Estilo]  # coluna com os nomes
    df_numerico = convert(Matrix{Float64}, select(df, Not(:Estilo)))
    return estilos, df_numerico
end

end
