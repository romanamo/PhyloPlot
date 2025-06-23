using Phylo

struct BaryCentricContext 
    coefficient::Dict{Phylo.AbstractNode, Real} #c
    offset::Dict{Any, Real} #d
    weights::Dict{Phylo.AbstractBranch, Real} #s
    coords::Dict{Phylo.AbstractNode, Vector{Real}}
    total::Int
    current::Int
end

function baryplot(tree)
    leaves = getleaves(tree)
    context = BaryCentricContext(Dict(), Dict(), Dict(), Dict(), length(leaves), 0)
    context = tpostorder(tree, getroot(tree), context)
    context = tpreorder(tree, getroot(tree), context)

    return context
end

function tpostorder(tree, node, context::BaryCentricContext)
    for child in Phylo.getchildren(tree, node)
        context = tpostorder(tree, child, context)
    end
    # fix leaves on outer circle
    if isleaf(tree, node) || (isroot(tree, node) && degree(tree, node) == 1)
        context.coefficient[node] = 0
        segment = (2*pi*context.current)/context.total
        context.coords[node] = [cos(segment), sin(segment)]
        context.current += 1
    else
        s = 0
        for branch in getconnections(tree, node)
            if isroot(tree, node) || src(tree, branch) == getparent(tree, node) # check parent case
                context.weights[branch] = 1.0/getlength(tree, branch)
            else
                context.weights[branch] = 1.0/getlength(tree, branch)*(degree(tree, node)-1)
            end
            global s += context.weights[branch]
        end
        t = t1 = 0
        for outgoing in getoutbounds(tree, node)
            global t = t + context.weights[outgoing]/s * context.coefficient[dst(tree, outgoing)]
            global t1 = t1 + context.weights[outgoing]/s * context.offset[dst(tree, outgoing)]
        end
        if !isroot(tree, node)
            e = getbranch(tree, getparent(tree, node), node)
            context.coefficient[e] = context.weights[e]/(S*(1-t))
        end
        context.offset[node] = t1/(1-t)
    end
    return context
end

function tpreorder(tree, node, context::BaryCentricContext)
    if isroot(tree, node)
       context.coords[node] = context.coefficient[node] 
    else
        parent = getparent(tree, node)
        context.coords[parent] = context.coefficient[node] * context.coords[parent] + context.offset[node]
    end
    for child in getchildren(tree, node)
        context = tpreorder(tree, child, context)
    end
    return context
end