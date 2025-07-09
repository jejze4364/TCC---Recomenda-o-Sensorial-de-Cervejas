module BeerData

using CSV
using DataFrames
using Statistics
using Missings

export load_style_data, load_beer_data

"""
    load_style_data(path::AbstractString) -> (Vector{String}, Matrix{Float64})

Read a CSV file with a column ``Estilo`` and return the style names and
numeric matrix of the remaining columns.
"""
function load_style_data(path::AbstractString)
    df = CSV.read(path, DataFrame; delim=';', ignorerepeated=true)
    estilos = df[!, :Estilo]
    df_num = convert(Matrix{Float64}, select(df, Not(:Estilo)))
    return estilos, df_num
end

"""
    _parsefloat(x)

Utility to parse numbers replacing comma decimal separators. Returns
`missing` if parsing fails.
"""
function _parsefloat(x)
    s = replace(String(x), "," => ".")
    if isempty(strip(s))
        return missing
    end
    try
        return parse(Float64, s)
    catch
        return missing
    end
end

"""
    clean_numeric!(df)

Convert string columns that contain numeric values to `Float64`,
handling missing data automatically.
"""
function clean_numeric!(df::DataFrame)
    for c in names(df)
        col = df[!, c]
        if eltype(col) <: AbstractString || eltype(col) <: Union{Missing, AbstractString}
            parsed = [_parsefloat(v) for v in col]
            if any(!ismissing, parsed)
                df[!, c] = parsed
            end
        end
    end
    return df
end

"""
    impute_missing!(df)

Replace missing numeric values with the mean of their column.
"""
function impute_missing!(df::DataFrame)
    for c in names(df)
        col = df[!, c]
        if eltype(col) <: Union{Missing, Float64}
            m = mean(skipmissing(col))
            replace!(col, missing => m)
        end
    end
    return df
end

"""
    load_beer_data(; data_dir="data") -> DataFrame

Automatically load all CSV files inside `data_dir` and merge them on
common textual keys, cleaning and imputing numeric data.
"""
function load_beer_data(; data_dir="data")
    files = filter(f -> endswith(lowercase(f), ".csv"), readdir(data_dir))
    dfs = DataFrame[]
    for f in files
        path = joinpath(data_dir, f)
        df = CSV.read(path, DataFrame; delim=';', ignorerepeated=true)
        clean_numeric!(df)
        push!(dfs, df)
    end

    combined = DataFrame()
    for df in dfs
        key = if :Estilo in names(df)
            :Estilo
        elseif :Categoria in names(df)
            :Categoria
        else
            first(names(df))
        end
        if ncol(combined) == 0
            combined = df
        elseif key in names(combined)
            combined = outerjoin(combined, df, on=key, makeunique=true)
        else
            combined = hcat(combined, df; makeunique=true)
        end
    end

    impute_missing!(combined)
    return combined
end

end # module
