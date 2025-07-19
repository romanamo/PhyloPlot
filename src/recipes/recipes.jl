module Recipes
    export hvplot, dendrogramplot, treemapplot, treeplot

    include("hv.jl")
    include("dendrogram.jl")
    include("treemap.jl")
    include("treeplot.jl")
end