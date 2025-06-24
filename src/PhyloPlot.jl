module PhyloPlot

# dependencies
using Phylo

# utilities

include("util.jl")

# Plot types
include("./plots/treemap.jl")
include("./plots/hv.jl")
include("./plots/barycentric.jl")
include("./plots/radial.jl")

export generateslicedicetreemap, drawslicedicetreemap
export generatehvtree, drawhvtree
export generatebarycentrictree, drawbarycentrictree
export generateradialtree, drawradialtree

include("plot.jl")

export Rectangle


end
