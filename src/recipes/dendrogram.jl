using Makie
using Phylo

using ...PhyloPlot.Layouts

@recipe DendrogramPlot begin
    "Layout options "
    layout = :classic #:fan
    nodecolor=:red
    edgecolor=:red
end


function Makie.plot!(obj::DendrogramPlot{<:Tuple{<:Phylo.NamedTree}})
    # calculate tree layout
    map!(obj.attributes, [:converted_1], [:result]) do tree
        return (layoutclassicdendrogram(tree),)
    end

    #draw edges
    map!(obj.attributes, [:converted_1, :result, :layout], [:linex, :liney]) do tree, result, layout
        linex, liney = Float64[], Float64[]
        
        adjust(y) = 2*pi*y/nleaves(tree)
        for node in keys(result.coords)
            if hasinbound(tree, node)
                px, py = result.coords[getparent(tree, node)]
                nx, ny = result.coords[node]

                push!(linex, px, px, nx, NaN)
                push!(liney, py, ny, ny, NaN)
            end
        end
        if layout == :fan
            # Transform line segments to be in a radial layout
            # vertical lines now need to be drawn as multiple lines
            linex, liney = Phylo._circle_transform_segments(linex, adjust(liney))
        end
        return (linex, liney)
    end
    lines!(obj, obj.linex, obj.liney, color=obj.edgecolor)

    # draw vertices
    map!(obj.attributes, [:converted_1, :result, :layout], [:vx, :vy]) do tree, result, layout
        positions = values(result.coords)
        
        adjust(y) = 2*pi*y/nleaves(tree)
        tocartesian(r, angle) = [ r*cos(angle), r*sin(angle)]

        if layout == :fan
            positions = [tocartesian(pos[1], adjust(pos[2])) for pos in positions]
        end

        xs, ys = collect(getindex.(positions, 1)), collect(getindex.(positions, 2))
        return (xs, ys)
    end

    scatter!(obj, obj.vx, obj.vy, color=obj.nodecolor)
    
    return obj
end