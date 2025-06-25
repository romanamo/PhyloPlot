using Phylo
using MakieCore

function generatedendrogram(tree)
    # taken from Phylo.jl
    d, h, n = Phylo._findxy(tree)
    x,y = Float64[], Float64[]

    for node in n
        if hasinbound(tree, node)
            push!(x, d[getparent(tree, node)], d[getparent(tree, node)],
                  d[node], NaN)
            push!(y, h[getparent(tree, node)], h[node], h[node], NaN)
        end
    end
    return x,y
end


function drawdendrogram(tree)
    x, y = generatedendrogram(tree)
    lines!(x, y)
end

function generateradialdendrogram()
    
end

function drawradialdendrogram()
    x, y = generatedendrogram(tree)
    
    lines!(x, y)
end