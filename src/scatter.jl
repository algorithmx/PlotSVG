function scatter(X::Vector{Float64}, Y::Vector{Float64}, SZ::Vector{Float64}, COL::Vector{String}, STYLE, FILL)
end

function scatter(X::Vector{Float64}, Y::Vector{Float64}, SZ::Float64, COL::Vector{String}, STYLE, FILL)
    scatter(X, Y, [SZ for i=1:length(X)], COL, STYLE, FILL)
end

scatter(X::Vector{Float64}, Y::Vector{Float64}, SZ, COL::String, STYLE, FILL) = scatter(X, Y, SZ, [COL for i=1:length(X)], STYLE, FILL)
