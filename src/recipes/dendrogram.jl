using Makie
using Phylo

using ...PhyloPlot.Layouts
using ...PhyloPlot.Util

@recipe DendrogramPlot begin
    "Layout options"
    layout = :classic #:fan
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
    "Fontsize"
    fontsize=8
end


function Makie.plot!(obj::DendrogramPlot{<:Tuple{<:Phylo.NamedTree}})
    # calculate tree layout
    map!(obj.attributes, [:converted_1], [:result]) do tree
        return (layoutclassicdendrogram(tree),)
    end

    #draw edges
    map!(obj.attributes, [:converted_1, :result, :layout], [:linex, :liney]) do tree, result, layout
        linex, liney = Float64[], Float64[]
        
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
            linex, liney = Phylo._circle_transform_segments(linex, adjust.(tree, liney))
        end
        return (linex, liney)
    end
    lines!(obj, obj.linex, obj.liney, color=obj.edgecolor)

    # draw vertices
    map!(obj.attributes, [:converted_1, :result, :layout, :showinternalnodes], [:vx, :vy]) do tree, result, layout, showinternalnodes
        positions = values(result.coords)
        
        if !showinternalnodes
            positions = [pos for (node, pos) in result.coords if isleaf(tree, node)]
        end

        if layout == :fan
            positions = [tocartesian(pos[1], adjust(tree, pos[2])) for pos in positions]
        end

        xs, ys = collect(getindex.(positions, 1)), collect(getindex.(positions, 2))
        return (xs, ys)
    end
    scatter!(obj, obj.vx, obj.vy, color=obj.nodecolor)

    #draw root
    map!(obj.attributes, [:converted_1, :result, :showroot, :layout], [:rx, :ry]) do tree, result, showroot, layout
        rx, ry = Float64[], Float64[]
        if showroot
            rx, ry = result.coords[getroot(tree)]
            if layout == :fan
                rx, ry = tocartesian(rx, adjust(tree, ry))
            end
        end
        return (rx, ry)
    end
    scatter!(obj, obj.rx, obj.ry, color=obj.rootcolor)

    #draw edge weights
    map!(obj.attributes, [:converted_1, :result, :showedgeweights, :layout], [:wx, :wy, :weights]) do tree, result, showedgeweights, layout
        wx, wy, weights = Float64[], Float64[], String[]
        if showedgeweights
            for edge in getbranches(tree)
                child = dst(tree, edge)
                parent = src(tree, edge)
                if haslength(tree, edge)
                    cx, cy = c = result.coords[child]
                    px, py = p = result.coords[parent]
                    p = [px, cy]
                    mid = c + (p-c)/2
                    if layout == :fan
                        mid = tocartesian(mid[1], adjust(tree, mid[2]))
                    end
                    push!(wx, mid[1])
                    push!(wy, mid[2])
                    push!(weights, string(getlength(tree, edge)))
                end
            end
        end
        return (wx, wy, weights)
    end
    text!(obj, obj.wx, obj.wy, text=obj.weights, fontsize=obj.fontsize, align=(:center, :top))

    #draw labels
    label_input = [:converted_1, :result, :layout, :showleaflabels]
    label_output = [:labelx, :labely, :labelrotation, :labeltext]
    map!(obj.attributes, label_input, label_output) do tree, result, layout, showleaflabels
        labelx, labely, labelrotation = Float64[], Float64[], Float64[]
        labeltext = String[]

        if showleaflabels
            for (label, info) in result.labels
                push!(labelx, info.coords[1])
                push!(labely, info.coords[2])
                push!(labelrotation, info.rotation)
                push!(labeltext, string(label))
            end
            if layout == :fan
                rotatedx, rotatedy, rotatedangle = Float64[], Float64[], Float64[]
                for (r, angle) in zip(labelx, adjust.(tree, labely))
                    rx, ry = tocartesian(r, angle)
                    push!(rotatedx, rx)
                    push!(rotatedy, ry)
                    push!(rotatedangle, angle)
                end
                labelx = rotatedx
                labely = rotatedy
                labelrotation = rotatedangle
            end
        end

        return (labelx, labely, labelrotation, labeltext)
    end
    text!(obj, obj.labelx, obj.labely, text=obj.labeltext, rotation=obj.labelrotation, align=(:left, :bottom), fontsize=obj.fontsize)
    
    
    return obj
end