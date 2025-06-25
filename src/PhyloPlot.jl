module PhyloPlot

# dependencies
using Phylo

# utilities

include("util.jl")

# Plot types
include("treemap.jl")
include("hv.jl")
include("barycentric.jl")
include("radial.jl")
include("dendrogram.jl")

export generateslicedicetreemap, drawslicedicetreemap
export generatehvtree, drawhvtree
export generatebarycentrictree, drawbarycentrictree
export generateradialtree, drawradialtree
export generatedendrogram, drawdendrogram, generateradialdendrogram, drawradialdendrogram

include("plot.jl")

export Rectangle


end
