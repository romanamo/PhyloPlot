using Makie
using Phylo

using ...PhyloPlot.Layouts

@recipe TreePlot begin
    "Layout options"
    layout = :radial # :barycentric
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
    "Toggle edge weights"
    showedgeweights=true
    "Toggle special root style"
    showroot=true
    "Font size"
    fontsize=8
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

    #draw edge weights
    map!(obj.attributes, [:converted_1, :result, :showedgeweights], [:wx, :wy, :weights]) do tree, result, showedgeweights
        wx, wy, weights = Float64[], Float64[], String[]
        if showedgeweights
            for edge in getbranches(tree)
                child = dst(tree, edge)
                parent = src(tree, edge)
                if haslength(tree, edge)
                    c = result.coords[child]
                    p = result.coords[parent]

                    mid = c + (p-c)/2
                    push!(wx, mid[1])
                    push!(wy, mid[2])
                    push!(weights, string(getlength(tree, edge)))
                end
            end
        end
        return (wx, wy, weights)
    end
    text!(obj, obj.wx, obj.wy, text=obj.weights, fontsize=obj.fontsize)

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