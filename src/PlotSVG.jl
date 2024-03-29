__precompile__()

module PlotSVG


#using Rsvg
#using Cairo
using Colors
using ColorSchemes
using LinearAlgebra


#* ===================================

export svg_dot, svg_dots, svg_circle, svg_circles, svg_point, svg_points, svg_line, svg_lines, svg_arrows
export svg_text, svg_texts, svg_circled_texts
include("elementary_svg.jl")


export LineStyle, CircFuncDict

LineStyle =    Dict(  :solid=>(false,false),
                      :dashed=>(true,false),
                      :dotted=>(false,true)  ) # (dashed,dotted)

CircFuncDict = Dict(  :dot=>svg_points,
                      :circle=>svg_circles,
                      :circledot=>svg_dot_circles,
                      :crossdot=>svg_cross_circles  )


export scale_helper,  join_svg,  save_svg,  make_svg_str
include("helper_svg.jl")

export plot_vectors, plot_graph, plot_graph_centre
include("plotters.jl")

export scatter
include("scatter.jl")

export plot
include("plot.jl")

end
