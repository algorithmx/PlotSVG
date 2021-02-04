__precompile__()

module PlotSVG


using Rsvg
using Cairo
using Colors
using ColorSchemes
using LinearAlgebra

#* ===================================

export LineStyle, CircFuncDict

LineStyle =    Dict(  :solid=>(false,false),
                      :dashed=>(true,false),
                      :dotted=>(false,true)  ) # (dashed,dotted)

CircFuncDict = Dict(  :dot=>svg_points,
                      :circle=>svg_circles,
                      :circledot=>svg_dot_circles,
                      :crossdot=>svg_cross_circles  )

#* ===================================

export svg_dot, svg_dots, svg_circle, svg_circles, svg_point, svg_points, svg_line, svg_lines, svg_arrows
include("elementary_svg.jl")

export scale_helper, join_svg,  save_svg
include("helper_svg.jl")

export plot_vectors, plot_graph, plot_graph_centre
include("plotters.jl")

export scatter
include("scatter.jl")

end
