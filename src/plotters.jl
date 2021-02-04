
function preprocess_points(
    pts,
    margin;
    ORIGIN=nothing,
    vy_min_plus_max_input=0
    )
    (vx_min, vx_max, vy_min, vy_max) = find_bounding_box(pts)
    # flip within the box
    sx(x) = x + (ORIGIN===nothing ? (margin-vx_min) : ORIGIN[1])
    sy(y) = y + (ORIGIN===nothing ? (margin-vy_min) : ORIGIN[2])
    # parameter may be inherited, when ORIGIN is given
    # (vy_min+vy_max) must be given
    vy_min_plus_max = (ORIGIN===nothing ? (vy_min+vy_max) : vy_min_plus_max_input)
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
