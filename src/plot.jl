function plot(
    X::Vector{Float64}, Y::Vector{Float64}, 
    COLOR::String, LINEWIDTH::Float64;
    dashed=false,
    dotted=false,
    dasharray=nothing
    )
    @assert length(X)==length(Y)
    svg_lines(  [([X[i],Y[i]],[X[i+1],Y[i+1]]) for i=1:length(X)-1],
                COLOR,
                LINEWIDTH;
                dashed=dashed,
                dotted=dotted,
                dasharray=dasharray )
end
