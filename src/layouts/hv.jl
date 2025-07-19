using Phylo
using DocStringExtensions
using ...PhyloPlot.Util

"""
$(TYPEDSIGNATURES)

Produces a horizontal vertical tree layout of a binary tree.
In this case bigger subtrees (measured by #nodes) are drawn to the right (x-direction)
and smaller subtrees are drawn in down (y-direction).
"""
function layouthv(tree::Phylo.NamedTree)::DrawingResult
    coords = Dict()
    leaves = subtreesizes(tree, getroot(tree))

    function layoutnode(node, ix::Int=0, iy::Int=0)
        children = getchildren(tree, node)
        coords[node] = [ix, -iy]

        if isleaf(tree, node)
            # if node is leaf, subtree has a width of 0
            return 0
        elseif length(children) == 1
            # if node has exactly one child, draw subtree in x direction
            childwidth = layoutnode(first(children), ix+1, iy)
            return childwidth + 1
        elseif length(children) == 2
            # if 2 nodes are present, draw bigger subtree in x direction
            small, large = sort(children;by=l->leaves[l])
            
            # bigger subtree needs to be shifted to the right by smaller subtree width
            widthsmall = layoutnode(small, ix, iy+1)
            widthlarge = layoutnode(large, ix+1+widthsmall, iy)

            return widthsmall + widthlarge + 1
        else
            error("Tree contains branch with more than 2 children")
        end
    end
    layoutnode(getroot(tree))

    return DrawingResult(coords)
end