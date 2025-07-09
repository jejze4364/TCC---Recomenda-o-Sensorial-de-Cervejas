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
    load_beer_data(path::AbstractString="data/2015_Guidelines_numbers_OK.csv") -> DataFrame

Carrega e processa os dados do arquivo oficial do BJCP, extraindo colunas relevantes
e calculando médias entre colunas min/max (ex: ABV, IBU, SRM).
"""
function load_beer_data(path::AbstractString="data/2015_Guidelines_numbers_OK.csv")
    df = CSV.read(path, DataFrame; delim=',', ignorerepeated=true)
    clean_numeric!(df)

    # Calcular médias
    df[!, :ABV] = mean.([df[!, Symbol("ABV min")] df[!, Symbol("ABV max")]], dims=2)
    df[!, :IBU] = mean.([df[!, Symbol("IBUs min")] df[!, Symbol("IBUs max")]], dims=2)
    df[!, :SRM] = mean.([df[!, Symbol("SRM min")] df[!, Symbol("SRM max")]], dims=2)
    df[!, :OG]  = mean.([df[!, Symbol("OG min")] df[!, Symbol("OG max")]], dims=2)
    df[!, :FG]  = mean.([df[!, Symbol("FG min")] df[!, Symbol("FG max")]], dims=2)

    # Renomear colunas para facilitar
    rename!(df, Dict(
        "BJCP Categories" => :Category,
        "Styles" => :Style,
        "Style Family" => :Family,
        "Style History" => :Style_History,
        "Overall Impression" => :Impression,
        "Characteristic Ingredients" => :Ingredients,
        "Style Comparison" => :Comparison,
        "Commercial Examples" => :Examples
    ))

    selected = [
        :Code, :Category, :Style, :Family, :Origin,
        :ABV, :IBU, :SRM, :OG, :FG,
        :Impression, :Aroma, :Appearance, :Flavor, :Mouthfell,
        :Comments, :Style_History, :Ingredients, :Comparison, :Examples, :Notes
    ]

    df_clean = select(df, selected)
    impute_missing!(df_clean)
    return df_clean
end

"""
    parse_style_file(path::AbstractString) -> Dict{String,String}

Read a beer style description in LaTeX format and return a dictionary
mapping section titles (e.g. `"Aroma"`, `"Sabor"`) to cleaned text.
"""
function parse_style_file(path::AbstractString)
    txt = read(path, String)
    txt = replace(txt, r"\\begin\{[^}]*\}" => " ")
    txt = replace(txt, r"\\end\{[^}]*\}" => " ")
    txt = replace(txt, r"\\(?:subsection|section|addcontentsline|phantomsection)\*?\{[^}]*\}" => " ")
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
            style = basename(root)
            sections = parse_style_file(joinpath(root, f))
            if haskey(styles, style)
                merge!(styles[style], sections)
            else
                styles[style] = sections
            end
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
