using Makie
using Phylo

using ...PhyloPlot.Layouts

@recipe HVPlot begin
    nodecolor=:red
    edgecolor=:red
end

function Makie.plot!(obj::HVPlot{<:Tuple{<:Phylo.NamedTree}})
    # calculate tree layout
    map!(obj.attributes, [:converted_1], [:result]) do tree
        return (layouthv(tree),)
    end

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

    # draw vertices
    map!(obj.attributes, [:converted_1, :result], [:vx, :vy]) do tree, result
        positions = values(result.coords)
        xs, ys = collect(getindex.(positions, 1)), collect(getindex.(positions, 2))
        return (xs, ys)
    end

    scatter!(obj, obj.vx, obj.vy, color=obj.nodecolor)

    return obj
end