using Phylo
using Makie
using Makie.GeometryBasics

"""
$(SIGNATURES)

Generates a ditionary containing a mapping from nodes to rectangles. 
Combining all rectangles yields a treemap based on the slice and dice algorithm by Ben Shneiderman. 
See [Slice and Dice](https://www.cs.umd.edu/~ben/papers/Shneiderman2001Ordered.pdf)
"""
function generateslicedicetreemap(tree)
    sizes = subtreesizes(tree, getroot(tree))
    allrects = Dict()
    function sliceanddice(parent, children, depth::Int, rect::Rectangle)
        progress = 0.0
        for child in children
            # draw horizontal boxes if depth is even, otherwise draw vertical boxes
            if depth % 2 == 0
                w = (sizes[child]/sizes[parent]) * rect.width
                r = Rectangle(rect.x + progress, rect.y, w, rect.height)
                allrects[child] = r
                progress += w
            else
                h = (sizes[child]/sizes[parent]) * rect.height
                r = Rectangle(rect.x, rect.y+progress, rect.width, h)
                allrects[child] = r
                progress += h
            end
        end
    end
    function generateslicedicetreemap(tree, node, depth)
        # calculate initial rectangle for root node
        if isroot(tree, node)
            allrects[node] = Rectangle(0.0, 0.0, 1.0, 1.0)
        end
        # calculate rectangles for children
        sliceanddice(node, getchildren(tree, node), depth, allrects[node])
        for child in getchildren(tree, node)
            generateslicedicetreemap(tree, child, depth+1)
        end
    end
    generateslicedicetreemap(tree, getroot(tree), 0)
    return allrects
end

"""
$(SIGNATURES)

Draws a treemap based on the slice and dice algorithm by Ben Shneiderman. 
See [Slice and Dice](https://www.cs.umd.edu/~ben/papers/Shneiderman2001Ordered.pdf)
"""
function drawslicedicetreemap(tree)
    rects = generateslicedicetreemap(tree)
    poly!([Rect(rect.x, rect.y, rect.width, rect.height) for rect in values(rects)], 
        strokewidth = 3, 
        strokecolor=:blue, 
        color=(:white, 0.1), 
        colormap=:heat
    )
end