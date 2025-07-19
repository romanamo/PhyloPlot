using Makie
using Phylo

using ...PhyloPlot.Layouts

@recipe TreePlot begin
    layout = :radial # :barycentric
    nodecolor=:red
    edgecolor=:red
end

function Makie.plot!(obj::TreePlot{<:Tuple{<:Phylo.NamedTree}})
    # calculate tree layout
    map!(obj.attributes, [:converted_1, :layout], [:result]) do tree, layout
        if layout == :barycentric
            return (layoutbarycentric(tree),)
        else
            return (layoutradial(tree),)
        end
    end

    # draw vertices
    map!(obj.attributes, [:converted_1, :result], [:vx, :vy]) do tree, result
        vx, vy = Float64[], Float64[]
        
        for (node, position) in result.coords
            push!(vx, position[1])
            push!(vy, position[2])
        end
        return (vx, vy)
    end
    scatter!(obj, obj.vx, obj.vy, color=obj.nodecolor)

    # draw edges
    map!(obj.attributes, [:converted_1, :result], [:linex, :liney]) do tree, result
        linex, liney = Float64[], Float64[]
        
        for node in getnodes(tree)
            for child in getchildren(tree, node)
                nx, ny = result.coords[node]
                cx, cy = result.coords[child]

                push!(linex, nx, cx, NaN)
                push!(liney, ny, cy, NaN)
            end
        end

        return (linex, liney)
    end
    lines!(obj, obj.linex, obj.liney, color=obj.edgecolor)
    
    return obj
end