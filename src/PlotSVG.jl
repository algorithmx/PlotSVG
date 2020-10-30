module PlotSVG

using Rsvg
using Cairo
using Colors
using ColorSchemes
using LinearAlgebra

export svg_dot, svg_dots
export svg_circle, svg_circles
export svg_point, svg_points
export svg_line, svg_lines
export svg_arrows
export join_svg, ⦷
export plot_vectors
export plot_graph
export plot_graph_centre
export save_svg
export LineStyle, CircFuncDict


real2str(x::Real) = string(Float64(round(x,digits=5)))


function svg_dot(
    CENTER::Tuple,
    RADIUS::Real, FILLCOLOR::String,
    EDGECOLOR::String, EDGEWIDTH::Real
    )::String
    return "<circle cx=\"$(real2str(CENTER[1]))\" cy=\"$(real2str(CENTER[2]))\" r=\"$(real2str(RADIUS))\" " *
           " stroke=\"$(EDGECOLOR)\" stroke-width=\"$(real2str(EDGEWIDTH))\" fill=\"$(FILLCOLOR)\" />"
end


function svg_dots(
    CENTS::Vector,
    R::Real, FILLCOLOR::String,
    EDGECOLOR::String, EDGEWIDTH::Real
    )::String
    d = []
    for CENTER ∈ CENTS
        circ = "M $(real2str(CENTER[1]-R)),$(real2str(CENTER[2])) a $(R),$(R) 0 1,0 $(R*2),0  a $(R),$(R) 0 1,0 $(-R*2),0 "
        push!(d, circ)
    end
    return "<path d=\"$(join(d," "))\" " *
           " stroke=\"$(EDGECOLOR)\" stroke-width=\"$(real2str(EDGEWIDTH))\" fill=\"$(FILLCOLOR)\" />"
end


function svg_point(
    CENTER::Tuple,
    RADIUS::Real,
    COLOR::String
    )
    svg_dot(CENTER, RADIUS, COLOR, COLOR, 0)
end


function svg_points(
    CENTS::Vector,
    RADIUS::Real,
    COLOR::String)
    svg_dots(CENTS, RADIUS, COLOR, COLOR, 0)
end


function svg_circle(
    CENTER::Tuple,
    RADIUS::Real,
    COLOR::String
    )
    svg_dot(CENTER, RADIUS, "none", COLOR, 0.382*RADIUS)
end


function svg_circles(
    CENTS::Vector,
    RADIUS::Real,
    COLOR::String)
    svg_dots(CENTS, RADIUS, "none", COLOR, 0.382*RADIUS)
end


function svg_cross_circles(
    CENTS::Vector,
    RADIUS::Real,
    COLOR::String)
    R = RADIUS
    d = []
    for CENTER ∈ CENTS
        circ = "M $(real2str(CENTER[1]-R)),$(real2str(CENTER[2])) a $(R),$(R) 0 1,0 $(R*2),0  a $(R),$(R) 0 1,0 $(-R*2),0 "
        push!(d, circ)
        crs1 = "M $(real2str(CENTER[1]-sqrt(0.5)*R)),$(real2str(CENTER[2]+sqrt(0.5)*R)) L $(real2str(CENTER[1]+sqrt(0.5)*R)),$(real2str(CENTER[2]-sqrt(0.5)*R))"
        push!(d, crs1)
        crs2 = "M $(real2str(CENTER[1]+sqrt(0.5)*R)),$(real2str(CENTER[2]+sqrt(0.5)*R)) L $(real2str(CENTER[1]-sqrt(0.5)*R)),$(real2str(CENTER[2]-sqrt(0.5)*R))"
        push!(d, crs2)
    end
    return "<path d=\"$(join(d," "))\" " *
           " stroke=\"$(COLOR)\" stroke-width=\"$(real2str(0.382*R))\" fill=\"none\" />"
end


function svg_dot_circles(
    CENTS::Vector,
    RADIUS::Real,
    COLOR::String)
    d = []
    R = RADIUS
    Rp = 0.382*R
    for CENTER ∈ CENTS
        circ = "M $(real2str(CENTER[1]-R)),$(real2str(CENTER[2])) a $(R),$(R) 0 1,0 $(R*2),0  a $(R),$(R) 0 1,0 $(-R*2),0 "
        push!(d, circ)
        dot  = "M $(real2str(CENTER[1]-Rp)),$(real2str(CENTER[2])) a $(Rp),$(Rp) 0 1,0 $(Rp*2),0  a $(Rp),$(Rp) 0 1,0 $(-Rp*2),0 "
        push!(d, dot)
    end
    return "<path d=\"$(join(d," "))\" " *
           " stroke=\"$(COLOR)\" stroke-width=\"$(real2str(Rp))\" fill=\"none\" />"
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
    DA = (dasharray==nothing) ? (dashed ? (dotted ? " 8 2 2 2" : " 8") : (dotted ? " 2" : "")) : dasharray
    if dashed || dotted
        return "<line x1=\"$(real2str(P1[1]))\" y1=\"$(real2str(P1[2]))\" x2=\"$(real2str(P2[1]))\" y2=\"$(real2str(P2[2]))\" " *
               "style=\"stroke:$(COLOR);stroke-width:$(real2str(LINEWIDTH));stroke-dasharray:$(DA)\" />"
    else
        return "<line x1=\"$(real2str(P1[1]))\" y1=\"$(real2str(P1[2]))\" x2=\"$(real2str(P2[1]))\" y2=\"$(real2str(P2[2]))\" " *
              "style=\"stroke:$(COLOR);stroke-width:$(real2str(LINEWIDTH))\" />"
    end
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
    DA = (dasharray==nothing) ? (dashed ? (dotted ? " 8 2 2 2" : " 8") : (dotted ? " 2" : "")) : dasharray
    if dashed || dotted
        return "<path d=\"$(join(d," "))\" " *
               "style=\"stroke:$(COLOR);stroke-width:$(real2str(LINEWIDTH));stroke-dasharray:$(DA)\" />"
    else
        return "<path d=\"$(join(d," "))\" " *
               "style=\"stroke:$(COLOR);stroke-width:$(real2str(LINEWIDTH))\" />"
    end
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

check_compat(str::AbstractString) = (ss=strip(str,'\n'); startswith(ss,"<svg")&&endswith(ss,"</svg>"))

function save_svg(
    str::String,
    fn::String;
    format="svg"
    )::String
    svg_string = strip(str,'\n')
    @assert check_compat(svg_string)
    svg_header = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
    html_header = ""
    html_tail = ""
    if format=="html"
        html_header = "<!DOCTYPE html>\n<html>\n<body>\n"
        html_tail   = "\n</body>\n</html>\n"
    end
    SS = html_header *svg_header *"\n" *svg_string *html_tail
    if format=="svg"
        open(fn,"w") do file
            write(file, SS)
        end
    elseif format=="png"
        #using Rsvg
        #using Cairo
        filename_in = "temp.svg"
        open(filename_in,"w") do file
            write(file, SS)
        end
        r = Rsvg.handle_new_from_file(filename_in)
        d = Rsvg.handle_get_dimensions(r)
        cs = Cairo.CairoImageSurface(d.width,d.height,Cairo.FORMAT_ARGB32)
        c = Cairo.CairoContext(cs)
        Rsvg.handle_render_cairo(c,r)
        Cairo.write_to_png(cs,fn)
    end
    return SS
end

function get_svg_header(svg::AbstractString)::String
   @assert check_compat(svg)
   return split(svg,"\n")[1]
end

function get_svg_WH(svg::AbstractString)
   @assert check_compat(svg)
   head = get_svg_header(svg)
   regex_width  = r"width\s*=\s*\"[+-]?([0-9]*[.])?[0-9]+\""
   regex_height = r"height\s*=\s*\"[+-]?([0-9]*[.])?[0-9]+\""
   match_width  = match(regex_width,head)
   match_height = match(regex_height,head)
   @assert match_width!=nothing && match_height!=nothing
   w = split(match_width.match,"=")[end]
   w = strip(w,'"')
   h = split(match_height.match,"=")[end]
   h = strip(h,'"')
   return parse(Float64,w),parse(Float64,h)
end

strip_svg_str(svg::AbstractString) = join(split(svg,"\n")[2:end-1],"\n")

# does not consider the aligning
function join_svg(svg1::AbstractString, svg2::AbstractString)
   @assert check_compat(svg1)
   @assert check_compat(svg2)
   (w1,h1) = get_svg_WH(svg1)
   (w2,h2) = get_svg_WH(svg2)
   svg_head = "<svg width=\"$(real2str(max(w1,w2)))\" height=\"$(real2str(max(h1,h2)))\">"
   svg_tail = "</svg>"
   return svg_head * "\n" * strip_svg_str(svg1) * "\n" * strip_svg_str(svg2) * "\n" * svg_tail
end

@inline ⦷(svg1::AbstractString, svg2::AbstractString) = join_svg(svg1,svg2)

function find_bounding_box(V)
    (vx_min, vx_max) = (100000.0, -100000.0)
    (vy_min, vy_max) = (100000.0, -100000.0)
    for v in V
        vx_max  = max(v[1],vx_max)
        vx_min  = min(v[1],vx_min)
        vy_max  = max(v[2],vy_max)
        vy_min  = min(v[2],vy_min)
    end
    return (vx_min, vx_max, vy_min, vy_max)
end

LineStyle =    Dict(  :solid=>(false,false),
                      :dashed=>(true,false),
                      :dotted=>(false,true)  ) # (dashed,dotted)

CircFuncDict = Dict(  :dot=>svg_points,
                      :circle=>svg_circles,
                      :circledot=>svg_dot_circles,
                      :crossdot=>svg_cross_circles  )


function preprocess_points(
    pts,
    margin;
    ORIGIN=nothing,
    vy_min_plus_max_input=0
    )
    (vx_min, vx_max, vy_min, vy_max) = find_bounding_box(pts)
    # flip within the box
    sx(x) = x + (ORIGIN==nothing ? (margin-vx_min) : ORIGIN[1])
    sy(y) = y + (ORIGIN==nothing ? (margin-vy_min) : ORIGIN[2])
    # parameter may be inherited, when ORIGIN is given
    # (vy_min+vy_max) must be given
    vy_min_plus_max = (ORIGIN==nothing ? (vy_min+vy_max) : vy_min_plus_max_input)
    # transform the point into a region with padding
    invY(v) = (sx(v[1]),sy(vy_min_plus_max-v[2]))
    pts_refl = invY.(pts)
    origin = invY((0,0))
    svg_head = "<svg width=\"$(real2str(vx_max-vx_min+2margin))\" height=\"$(real2str(vy_max-vy_min+2margin))\">"
    svg_tail = "</svg>"
    return (svg_head,svg_tail), (vx_min, vx_max, vy_min, vy_max), origin, pts_refl
end


function plot_vectors(
    vectors;
    headsize=0.1,
    line_style=("blue",4.0,:solid),
    margin=20.0
    )
    # ---------------------
    ϵ0 = 1e-8.*vectors[1]
    B = [v.+ϵ0 for v ∈ vectors]
    # ---------------------
    # find bounding box and revert y-axis within bbox
    ( (svg_head, svg_tail),
      (vx_min, vx_max, vy_min, vy_max),
      origin, pts_refl ) = preprocess_points( B, margin )
    lines = [(origin,v) for v ∈ pts_refl]
    # ---------------------
    (dashed,dotted) = LineStyle[line_style[3]]
    arrows = svg_arrows( lines,
                         line_style[1], line_style[2];
                         headsize=headsize,
                         dashed=dashed, dotted=dotted, dasharray=nothing )
    # ---------------------
    return (svg_head * "\n" * arrows * "\n" * svg_tail)
end


#NOTE This function is not responsible for any coordinate transformations !!
function plot_graph(
    V::Vector{Tuple{Float64,Float64}},
    E::Vector{Tuple{Int64,Int64}};
    MARGIN = 20.0,
    EDGECOLOR="red", EDGEWIDTH=1.0, EDGESTYLE=:solid,
    VERTEXCOLOR="black", VERTEXRAD=3.0, VERTEXSTYLE=:dot,
    HIGHLIGHT=[]
    )

    lines_svg = []

    # edges
    EC = (typeof(EDGECOLOR)<:Vector) ? EDGECOLOR : fill(EDGECOLOR,length(E))
    EW = (typeof(EDGEWIDTH)<:Vector) ? EDGEWIDTH : fill(EDGEWIDTH,length(E))
    ET = (typeof(EDGESTYLE)<:Vector) ? EDGESTYLE : fill(EDGESTYLE,length(E))
    EINFO = collect(zip(EC,EW,ET))

    # find the distinct pairs of (color, width)
    edges = Dict(p=>Vector{Tuple}() for p ∈ unique(EINFO))
    for (c,w,t) ∈ keys(edges)
        for (l,e) ∈ enumerate(E)
            if EINFO[l] == (c,w,t)
                e1 = V[e[1]]
                e2 = V[e[2]]
                push!( edges[(c,w,t)], ([e1[1],e1[2]],[e2[1],e2[2]]) )
            end
        end
    end

    # draw lines
    for (c,w,t) ∈ keys(edges)
        push!( lines_svg, svg_lines( edges[(c,w,t)], c, w,
                                     dashed=LineStyle[t][1],
                                     dotted=LineStyle[t][2] ) ) # (dashed,dotted)
    end

    # vertices
    VC = (typeof(VERTEXCOLOR)<:Vector) ? VERTEXCOLOR : fill(VERTEXCOLOR,length(V))
    VR = (typeof(VERTEXRAD  )<:Vector) ? VERTEXRAD   : fill(VERTEXRAD,  length(V))
    VT = (typeof(VERTEXSTYLE)<:Vector) ? VERTEXSTYLE : fill(VERTEXSTYLE,length(V))
    VINFO = collect(zip(VC,VR,VT))

    # find the distinct pairs of (color, width)
    vertices = Dict(p=>[] for p ∈ unique(VINFO))
    for (c,r,t) ∈ keys(vertices) # for each combination of c(color) r(radius) t(type)
        for (l,v) ∈ enumerate(V)
            if VINFO[l] == (c,r,t)
                push!( vertices[(c,r,t)], [v[1],v[2]] )
            end
        end
    end
    for (c,r,t) ∈ keys(vertices)
        push!( lines_svg, CircFuncDict[t](vertices[(c,r,t)], r, c) )
    end

    # highlights
    minVR = 0.618*minimum(VR)
    for (pos,col) ∈ HIGHLIGHT
        push!( lines_svg, svg_points(pos,minVR,col) )
    end

    # finalize
    (vx_min, vx_max, vy_min, vy_max) = find_bounding_box(V)
    W = real2str(vx_max-vx_min+2MARGIN)
    H = real2str(vy_max-vy_min+2MARGIN)
    svg_head = "<svg width=\"$W\" height=\"$H\">"
    svg_tail = "</svg>"

    return (svg_head * "\n" * join(lines_svg,"\n") * "\n" * svg_tail)
end

end

