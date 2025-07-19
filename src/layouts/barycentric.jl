using Phylo

function layoutbarycentric(tree::Phylo.NamedTree)::DrawingResult
    coefficient = Dict()
    offset = Dict()
    weights = Dict()
    coords = Dict()
    total= float(nleaves(tree))
    current = 0.

    function layoutbarypostorder(node)
        sortcriteria(child) = getlength(tree, getbranch(tree, node, child))+getheight(tree, child)
        sortedchildren = sort(getchildren(tree, node);by=sortcriteria)

        for child in sortedchildren
            layoutbarypostorder(child)
        end
        if isleaf(tree, node) || isroot(tree, node) && degree(tree, getroot(tree)) == 1
            # fix leaves on outer circle
            coefficient[node] = 0.0
            segment = 2*pi*current/total
            offset[node] = [cos(segment), sin(segment)]
            current += 1
        else
            # place nodes in barycenter of neighbors
            s = 0.0
            for branch in getconnections(tree, node)
                if isroot(tree, node) || src(tree, branch) == getparent(tree, node) # check parent case
                    weights[branch] = 1.0/getlength(tree, branch)
                else
                    weights[branch] = 1.0/(getlength(tree, branch)*(degree(tree, node)-1))
                end
                s += weights[branch]
            end
            t = t1 = 0.0
            for outgoing in getoutbounds(tree, node)
                destination = dst(tree, outgoing)
                t = t + weights[outgoing]/s * coefficient[destination]
                t1 = t1 .+ weights[outgoing]/s .* offset[destination]
            end
            if !isroot(tree, node)
                branch = getbranch(tree, getparent(tree, node), node)
                coefficient[node] = weights[branch]/(s*(1-t))
            end
            offset[node] = t1./(1-t)
        end
    end

    function layoutbarypreorder(node)
        if isroot(tree, node)
            coords[node] = offset[node]
        else
            parent = getparent(tree, node)
            coords[node] = coefficient[node] * coords[parent] + offset[node]
        end
        for child in getchildren(tree, node)
            layoutbarypreorder(child)
        end
    end

    layoutbarypostorder(getroot(tree))
    layoutbarypreorder(getroot(tree))

    return DrawingResult(coords)
end