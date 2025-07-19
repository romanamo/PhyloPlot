using Phylo
using DocStringExtensions

using ...PhyloPlot.Util

"""
Rectangle

$(FIELDS)
"""
struct Rectangle
    "upper left corner x-value"
    x::Real
    "upper left corner y-value"
    y::Real
    "rectangle width"
    width::Real
    "rectangle height"
    height::Real
end

struct TreeMapDrawingResult <: AbstractDrawingResult
    rects::Dict{Any, Rectangle}
end

"""
$(TYPEDSIGNATURES)

Combining all rectangles yields a treemap based on the slice and dice algorithm by Ben Shneiderman. 
See [Slice and Dice](https://www.cs.umd.edu/~ben/papers/Shneiderman2001Ordered.pdf)
"""
function layoutslicedicetreemap(tree::Phylo.NamedTree)::TreeMapDrawingResult
    sizes = subtreesizes(tree, getroot(tree))
    rects = Dict()

    function slicedice(parent, children, depth::Int, rect::Rectangle)
        progress = 0.0
        for child in children
            # fill space of the given rectangle
            # draw horizontal boxes if depth is even, otherwise draw vertical boxes
            if depth % 2 == 0
                w = (sizes[child]/sizes[parent]) * rect.width
                r = Rectangle(rect.x + progress, rect.y, w, rect.height)
                rects[child] = r
                progress += w
            else
                h = (sizes[child]/sizes[parent]) * rect.height
                r = Rectangle(rect.x, rect.y+progress, rect.width, h)
                rects[child] = r
                progress += h
            end
        end
    end

    function layoutnode(node, depth::Int=0)
        # calculate initial rectangle for root node
        if isroot(tree, node)
            rects[node] = Rectangle(0.0, 0.0, 1.0, 1.0)
        end
        # calculate rectangles for children
        slicedice(node, getchildren(tree, node), depth, rects[node])
        # recursively draw child rectangles
        for child in getchildren(tree, node)
            layoutnode(child, depth+1)
        end
    end

    layoutnode(getroot(tree))

    return TreeMapDrawingResult(rects)
end