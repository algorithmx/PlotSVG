using Pkg
Pkg.activate("/home/dabajabaza/jianguoyun/Workspace/PlotSVG")
using PlotSVG

##

#s = PlotSVG.plot(1.0collect(1:100), 2.0collect(1:100), "black", 5.0) ;

s1 = PlotSVG.scatter(1.0collect(1:3:100), 2.0collect(1:3:100), 4.0, "red", :circle, false, 0.04) ;

s2 = PlotSVG.scatter(1.0collect(100:-3:1), 2.0collect(1:3:100), 4.0, "blue", :circle, false, 0.04) ;

s3 = PlotSVG.plot(1.0collect(100:-3:1), 2.0collect(1:3:100).^1.2, "green", 2.0) ;

save_svg(make_svg_str([s1;s2;s3],100,200), "test1.svg") ;

