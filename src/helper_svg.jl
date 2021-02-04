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
   @assert match_width!==nothing && match_height!==nothing
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


## the actual points are X,Y
## since the y-axis points downwards in a SVG figure, 
## we need to transform the points
## γ is the margin ratio, usually 0.03~0.10
## W, H is the proposed canvas size
function scale_helper(X,Y,W,H,γ)
    (X_min, X_max) = (minimum(X), maximum(X))
    (Y_min, Y_max) = (minimum(Y), maximum(Y))
    Mx = γ*(X_max-X_min)
    My = γ*(Y_max-Y_min)
    W0  = (X_max-X_min+2Mx)
    H0  = (Y_max-Y_min+2My)
    @inline transx(t) = (W/W0)*(Mx+(t-X_min))
    @inline transy(t) = H - (H/H0)*(My+(t-Y_min))
    return transx.(X), transy.(Y), (transx(X_min),transx(X_max),transx(0)), (transy(Y_min),transy(Y_max),transy(0))
end
