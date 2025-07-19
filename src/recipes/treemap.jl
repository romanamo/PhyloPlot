using Makie
using Phylo

using ...PhyloPlot.Layouts

@recipe TreeMapPlot begin
    layout = :slicedice
end

function Makie.plot!(obj::TreeMapPlot{<:Tuple{<:Phylo.NamedTree}})
    # calculate tree layout
    map!(obj.attributes, [:converted_1], [:result]) do tree
        return (layoutslicedicetreemap(tree),)
    end

    # draw rectangles
    map!(obj.attributes, [:converted_1, :result], [:rects]) do tree, result
        rects = [Makie.Rect(r.x, r.y, r.width, r.height) for r in values(result.rects)]

        return (rects,)
    end
    poly!(obj, obj.rects, strokewidth = 3, strokecolor=:blue, color=(:white, 0.1), colormap=:heat)

    return obj
end