using Phylo
using DocStringExtensions

function layoutradial(tree::Phylo.NamedTree)::DrawingResult
    root = getroot(tree)
    coords = Dict(root => [0., 0.])
    wedge = Dict(root => 2*pi)
    angle = Dict(root => 0.0)
    sizes = subtreesizes(tree, root)

    function layoutnode(node)
        if !isroot(tree , node)
            parent = getparent(tree, node)
            branch = getbranch(tree, parent, node)
            segment = angle[node] + wedge[node]/2.0
            coords[node] = coords[parent] + getlength(tree, branch) .* [cos(segment), sin(segment)]
        end
        mu = angle[node]
        for child in getchildren(tree, node)
            wedge[child] = sizes[child]/sizes[root] * 2.0 *pi
            angle[child] = mu
            mu += wedge[child]
            layoutnode(child)
        end
    end
    layoutnode(root)
    return DrawingResult(coords)
end