using Phylo
using DocStringExtensions
using ...PhyloPlot.Util

"""
$(TYPEDSIGNATURES)

Produces a classic dendrogram with tree height/depth arranged horizontal.
Leaves are arranged vertically to and all have an integer y-value.
"""
function layoutclassicdendrogram(tree::Phylo.NamedTree)::DrawingResult
    xs = nodeheights(tree)
    ys = getorders(tree)

    coords = Dict(node => [xs[node], ys[node]] for node in getnodes(tree))
    return DrawingResult(coords)
end

"""
$(TYPEDSIGNATURES)

Necessary to calculate the vertical level of internal node. 
These depend on the vertical level of their leaves.
"""
function getorders(tree)
    leafnames = [getnodename(tree, x) for x in traversal(tree, preorder) if isleaf(tree, x)]
    orders = Dict(tip => float(i-1) for (i, tip) in enumerate(leafnames))

    function findorders(node)
        # calculate y for all children
        for child in getchildren(tree, node)
            findorders(child)
        end
        # place order in the center of highest and lowest child
        if !isleaf(tree, node)
            childorders = [orders[child] for child in getchildren(tree, node)]
            orders[node] = (maximum(childorders) + minimum(childorders))/2.0
        end
    end
    findorders(getroot(tree))
    return orders
end