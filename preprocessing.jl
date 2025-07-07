module Preprocessing

function normalize_data(df)
    return (df .- minimum(df, dims=1)) ./ (maximum(df, dims=1) .- minimum(df, dims=1))
end

end
