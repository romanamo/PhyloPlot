module Util
    
using Phylo
using DocStringExtensions

export subtreesizes

"""
$(SIGNATURES)

Returns a dictionary `leaves` containing the node size of each subtree rooted 
at given `node` in context of a `tree`.
"""
function subtreesizes(tree, node, leaves=Dict())
    if isleaf(tree, node)
        leaves[node] = 1
    else
        leaves[node] = 0
        for child in getchildren(tree, node)
            leaves = subtreesizes(tree, child, leaves)
            leaves[node] += leaves[child]
        end
    end
    return leaves
end

end


