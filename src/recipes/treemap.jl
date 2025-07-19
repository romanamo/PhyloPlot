using Makie
using Phylo
using Makie.GeometryBasics

using ...PhyloPlot.Layouts

@recipe TreeMapPlot begin
    layout = :slicedice
    colormap = :viridis
    strokecolor = :black
    strokewidth = 2
    fontcolor = :black
    fontsize = 0.01
    labeldirection = :automatic #(:vertical, horizontal)
end

function Makie.plot!(obj::TreeMapPlot{<:Tuple{<:Phylo.NamedTree}})
    # calculate tree layout
    map!(obj.attributes, [:converted_1], [:result]) do tree
        return (layoutslicedicetreemap(tree),)
    end

    # draw rectangles
    map!(obj.attributes, [:converted_1, :result], [:rects, :leafcolors, :leafrange]) do tree, result
        colors = []
        
        rects = [Rect(r.x, r.y, r.width, r.height) for r in values(result.rects)]
        leafnames = [getnodename(tree, x) for x in traversal(tree, preorder) if isleaf(tree, x)]
        orders = Dict(tip => i for (i, tip) in enumerate(leafnames))

        
        for (node, _) in result.rects
            if isleaf(tree, node)
                push!(colors, orders[node])
            else
                # NaN is transparent
                push!(colors, NaN)
            end
        end

        return (rects, colors, 1:nleaves(tree))
    end
    poly!(obj, obj.rects, color=obj.leafcolors, colormap=obj.colormap, strokecolor=obj.strokecolor, strokewidth=obj.strokewidth)
    
    #draw labels
    map!(obj.attributes, [:converted_1, :result, :labeldirection], [:labelx, :labely, :labelrotation, :labeltext]) do tree, result, labeldirection
        labelx, labely, labelrotation, labeltext = Float64[], Float64[], Float64[], String[]

        for leaf in getleaves(tree)
            rect = result.rects[leaf]
            cx, cy = getcenter(rect)
            rotation = 0
            # make text vertical if box is vertical
            if labeldirection == :automatic
                if rect.height > rect.width
                    rotation = pi/2
                end
            elseif labeldirection == :vertical
                rotation = pi/2
            end
            push!(labelx, cx)
            push!(labely, cy)
            push!(labelrotation, rotation)
            push!(labeltext, string(leaf))
        end

        return (labelx, labely, labelrotation, labeltext)
    end
    text!(obj, obj.labelx, obj.labely, text=obj.labeltext, align=(:center, :center), fontsize=obj.fontsize, rotation=obj.labelrotation, color=obj.fontcolor, markerspace=:data)
    return obj
end