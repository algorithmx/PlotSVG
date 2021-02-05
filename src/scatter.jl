function scatter(
    X::Vector{Float64}, Y::Vector{Float64}, 
    SZ::Vector{Float64}, COL::Vector{String}, 
    STYLE::Symbol, 
    FILL::Bool,
    OPACITY::Real=1
    )
    f = nothing
    if FILL
        f = svg_points
    else
        if STYLE==:circle
            f = svg_circles
        elseif STYLE==:dot
            f = svg_points
        else
            f = svg_circles
        end
    end
    lsvg = [f(collect(zip(X[COL.==color],Y[COL.==color])), SZ[COL.==color], color, OPACITY) for color ∈ COL]
    return vcat(lsvg...)
end


function scatter(
    X::Vector{Float64}, Y::Vector{Float64}, 
    SZ::Float64, COL::Vector{String}, 
    STYLE::Symbol, 
    FILL::Bool,
    OPACITY::Real=1
    )
    scatter(X, Y, [SZ for i=1:length(X)], COL, STYLE, FILL, OPACITY)
end


function scatter(
    X::Vector{Float64}, Y::Vector{Float64}, 
    SZ, COL::String, 
    STYLE::Symbol, 
    FILL::Bool,
    OPACITY::Real=1
    )
    scatter(X, Y, SZ, [COL for i=1:length(X)], STYLE, FILL, OPACITY)
end