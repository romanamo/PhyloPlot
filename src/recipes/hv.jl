using Makie
using Phylo

using ...PhyloPlot.Layouts

@recipe HVPlot begin
    "Node color"
    nodecolor=:red
    "Edge color"
    edgecolor=:black
    "Root color"
    rootcolor=:blue
    "Toggle leaf labels"
    showleaflabels=true
    "Toggle internal nodes"
    showinternalnodes=true
    "Toggle special root style"
    showroot=true
    "Font size"
    fontsize=8
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
    map!(obj.attributes, [:converted_1, :result, :showinternalnodes], [:vx, :vy]) do tree, result, showinternalnodes
        positions = values(result.coords)

        if !showinternalnodes
            positions = [pos for (node, pos) in result.coords if isleaf(tree, node)]
        end

        xs, ys = collect(getindex.(positions, 1)), collect(getindex.(positions, 2))
        return (xs, ys)
    end
    scatter!(obj, obj.vx, obj.vy, color=obj.nodecolor)

    #draw root
    map!(obj.attributes, [:converted_1, :result, :showroot], [:rx, :ry]) do tree, result, showroot
        rx, ry = Float64[], Float64[]
        if showroot
            rx, ry = result.coords[getroot(tree)]
        end
        return (rx, ry)
    end
    scatter!(obj, obj.rx, obj.ry, color=obj.rootcolor)

    #draw labels
    map!(obj.attributes, [:converted_1, :result, :showleaflabels], [:labelx, :labely, :labelrotation, :labeltext]) do tree, result, showleaflabels
        labelx, labely, labelrotation, labeltext = Float64[], Float64[], Float64[], String[]
        
        if showleaflabels
            for (label, info) in result.labels
                push!(labelx, info.coords[1])
                push!(labely, info.coords[2])
                push!(labelrotation, info.rotation)
                push!(labeltext, string(label))
            end
        end

        return (labelx, labely, labelrotation, labeltext)
    end
    text!(obj, obj.labelx, obj.labely, text=obj.labeltext, rotation=obj.labelrotation, align=(:left, :center), fontsize=obj.fontsize)
    

    return obj
end