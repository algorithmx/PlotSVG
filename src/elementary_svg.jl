# elementary_svg.jl


real2str(x::Real) = string(Float64(round(x,digits=5)))


function svg_dot(
    CENTER::Tuple,
    RADIUS::Real, 
    FILLCOLOR::String,
    EDGECOLOR::String, 
    EDGEWIDTH::Real
    )::String
    return "<circle cx=\"$(real2str(CENTER[1]))\" cy=\"$(real2str(CENTER[2]))\" r=\"$(real2str(RADIUS))\" " *
           " stroke=\"$(EDGECOLOR)\" stroke-width=\"$(real2str(EDGEWIDTH))\" fill=\"$(FILLCOLOR)\" />"
end


function svg_dots(
    CENTS::Vector,
    RS::Vector, 
    FILLCOLOR::String,
    EDGECOLOR::String, 
    EDGEWIDTH::Real,
    OPACITY=1.0
    )::String
    @assert eltype(CENTS) <: Tuple
    @assert length(CENTS)==length(RS)
    d = [   "M $(real2str(C[1]-R)),$(real2str(C[2])) a $(R),$(R) 0 1,0 $(R*2),0  a $(R),$(R) 0 1,0 $(-R*2),0 "
            for (C,R) ∈ zip(CENTS,RS)    ]
    return "<path d=\"$(join(d," "))\" " *
           " stroke=\"$(EDGECOLOR)\" stroke-width=\"$(real2str(EDGEWIDTH))\" stroke-opacity=\"$(100OPACITY)%\" fill=\"$(FILLCOLOR)\" />"
end


function svg_dots(CENTS::Vector, R::Real, FILLCOLOR::String, EDGECOLOR::String, EDGEWIDTH::Real, OPACITY=1.0)
    return svg_dots(CENTS, R.*ones(length(CENTS)), FILLCOLOR, EDGECOLOR, EDGEWIDTH, OPACITY)
end


svg_point(CENTER::Tuple, RADIUS::Real, COLOR::String) = svg_dot(CENTER, RADIUS, COLOR, COLOR, 0)


svg_points(CENTS::Vector, RADIUS, COLOR::String) = svg_dots(CENTS, RADIUS, COLOR, COLOR, 0)


svg_circle(CENTER::Tuple, RADIUS::Real, COLOR::String) = svg_dot(CENTER, RADIUS, "none", COLOR, 0.382*RADIUS)


svg_circles(CENTS::Vector, RADIUS, COLOR::String) = svg_dots(CENTS, RADIUS, "none", COLOR, 0.382*RADIUS)


svg_circles(CENTS::Vector, RADIUS::Vector, COLOR::String) = svg_dots(CENTS, RADIUS, "none", COLOR, 0.382*RADIUS)


function svg_cross_circles(
    CENTS::Vector,
    RADIUS::Vector,
    COLOR::String
    )
    @assert length(CENTS)==length(RADIUS)
    d = [[  "M $(real2str(C[1]-R)),$(real2str(C[2])) a $(R),$(R) 0 1,0 $(R*2),0  a $(R),$(R) 0 1,0 $(-R*2),0 ",
            "M $(real2str(C[1]-sqrt(0.5)*R)),$(real2str(C[2]+sqrt(0.5)*R)) L $(real2str(C[1]+sqrt(0.5)*R)),$(real2str(C[2]-sqrt(0.5)*R))",
            "M $(real2str(C[1]+sqrt(0.5)*R)),$(real2str(C[2]+sqrt(0.5)*R)) L $(real2str(C[1]-sqrt(0.5)*R)),$(real2str(C[2]-sqrt(0.5)*R))" ]
            for (C,R) ∈ zip(CENTS,RADIUS) ]
    return "<path d=\"$(join(vcat(d...)," "))\" stroke=\"$(COLOR)\" stroke-width=\"$(real2str(0.382*R))\" fill=\"none\" />"
end


function svg_dot_circles(
    CENTS::Vector,
    RADIUS::Vector,
    COLOR::String,
    λ=0.382
    )
    Ravg = sum(RADIUS)/length(RADIUS)
    d = [[  "M $(real2str(C[1]-R)),$(real2str(C[2])) a $(R),$(R) 0 1,0 $(R*2),0  a $(R),$(R) 0 1,0 $(-R*2),0 ",
            "M $(real2str(C[1]-λ*R)),$(real2str(C[2])) a $(λ*R),$(λ*R) 0 1,0 $(λ*R*2),0  a $(λ*R),$(λ*R) 0 1,0 $(-λ*R*2),0 " ]
            for (C,R) ∈ zip(CENTS,RADIUS)  ]
    return "<path d=\"$(join(vcat(d...)," "))\" stroke=\"$(COLOR)\" stroke-width=\"$(real2str(λ*Ravg))\" fill=\"none\" />"
end


function svg_lines(
    lsit_of_point_pairs::Vector{T},
    COLOR::String,
    LINEWIDTH::Real;
    dashed=false,
    dotted=false,
    dasharray=nothing
    )::String where {T<:Tuple}
    d = []
    for (p1,p2) ∈ lsit_of_point_pairs
        push!(d, "M $(real2str(p1[1])),$(real2str(p1[2])) L $(real2str(p2[1])),$(real2str(p2[2]))")
    end
    DA = (dasharray===nothing) ? (dashed ? (dotted ? " 8 2 2 2" : " 8") : (dotted ? " 2" : "")) : dasharray
    if dashed || dotted
        return "<path d=\"$(join(d," "))\"  style=\"stroke:$(COLOR);stroke-width:$(real2str(LINEWIDTH));stroke-dasharray:$(DA)\" />"
    else
        return "<path d=\"$(join(d," "))\"  style=\"stroke:$(COLOR);stroke-width:$(real2str(LINEWIDTH))\" />"
    end
end


function svg_line(
    P1::Tuple,
    P2::Tuple,
    COLOR::String,
    LINEWIDTH::Real;
    dashed=false,
    dotted=false,
    dasharray=nothing
    )::String
    svg_lines([(P1,P2),], COLOR, LINEWIDTH; dashed=dashed, dotted=dotted, dasharray=dasharray)
end


# TODO arrow

function svg_arrowheads(
    lsit_of_end_point_directions::Vector{T},
    COLOR::String,
    LINEWIDTH::Real;
    dashed=false,
    dotted=false,
    dasharray=nothing
    )::String where { T <: Tuple }
    rot45p = [[cos(π/4), sin(π/4)] [-sin(π/4), cos(π/4)]]
    rot45m = [[cos(π/4),-sin(π/4)] [ sin(π/4), cos(π/4)]]
    lp1 = [ (pt, pt.-sz.*(rot45p*dir)) for (pt,dir,sz) ∈ lsit_of_end_point_directions]
    lp2 = [ (pt, pt.-sz.*(rot45m*dir)) for (pt,dir,sz) ∈ lsit_of_end_point_directions]
    stroke1 = svg_lines( lp1, COLOR, LINEWIDTH;
                         dashed=dashed, dotted=dotted, dasharray=dasharray )
    stroke2 = svg_lines( lp2, COLOR, LINEWIDTH;
                         dashed=dashed, dotted=dotted, dasharray=dasharray )
    return ( stroke1 * "\n" * stroke2 )
end


function svg_arrows(
    lsit_of_point_pairs::Vector{T},
    COLOR::String,
    LINEWIDTH::Real;
    headsize=0.1,
    dashed=false,
    dotted=false,
    dasharray=nothing
    )::String where {T<:Tuple}
    t2v(x) = vcat(x...)
    lsit_of_end_point_directions = [ (t2v(p2), normalize(t2v(p2).-t2v(p1)), headsize)
                                        for (p1,p2) ∈ lsit_of_point_pairs ]
    arrow_bodys = svg_lines( lsit_of_point_pairs, COLOR, LINEWIDTH;
                             dashed=dashed, dotted=dotted, dasharray=dasharray )
    arrow_heads = svg_arrowheads( lsit_of_end_point_directions, COLOR, LINEWIDTH;
                                  dashed=dashed, dotted=dotted, dasharray=dasharray )
    return arrow_bodys #( arrow_bodys * "\n" * arrow_heads )
end

