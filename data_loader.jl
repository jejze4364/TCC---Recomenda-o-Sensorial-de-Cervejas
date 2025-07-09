module BeerData

using CSV
using DataFrames
using Statistics
using Unicode
using Missings

export load_style_data, load_beer_data, parse_tex_directory

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

"""
    parse_style_file(path::AbstractString) -> Dict{String,String}

Read a beer style description in LaTeX format and return a dictionary
mapping section titles (e.g. `"Aroma"`, `"Sabor"`) to cleaned text.
"""
function parse_style_file(path::AbstractString)
    txt = read(path, String)
    # Remove common LaTeX commands and environments
    txt = replace(txt, r"\\begin\{[^}]*\}" => " ")
    txt = replace(txt, r"\\end\{[^}]*\}" => " ")
    txt = replace(txt, r"\\(?:subsection|section|addcontentsline|phantomsection)\*?\{[^}]*\}" => " ")
    # Split using bold section titles
    parts = split(txt, r"\\textbf\{")
    sections = Dict{String,String}()
    for part in parts[2:end]
        m = match(r"([^}]*)\}:\s*(.*)", part)
        m === nothing && continue
        key = strip(m.captures[1])
        val = m.captures[2]
        val = replace(val, r"\\[a-zA-Z]+" => " ")
        val = replace(val, r"[{}]" => "")
        val = replace(val, '\n' => ' ')
        val = replace(val, r"\s+" => " ")
        sections[key] = strip(val)
    end
    return sections
end

"""
    parse_tex_directory(dir::AbstractString) -> DataFrame

Walk through `dir` recursively and parse all `.tex` files, returning a
`DataFrame` where each row corresponds to a style and each column to a
section found in the files.
"""
function parse_tex_directory(dir::AbstractString)
    styles = Dict{String,Dict{String,String}}()
    for (root, _, files) in walkdir(dir)
        for f in files
            endswith(f, ".tex") || continue
            f in ["header.tex", "index.tex"] && continue
            style = replace(basename(f), ".tex" => "")
            sections = parse_style_file(joinpath(root, f))
            styles[style] = sections
        end
    end

    cols = Set{String}()
    for sec in values(styles)
        union!(cols, keys(sec))
    end
    df = DataFrame(Estilo=collect(keys(styles)))
    for c in cols
        df[!, c] = [get(styles[s], c, missing) for s in keys(styles)]
    end
    return df
end

end # module