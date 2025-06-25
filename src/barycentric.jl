using Phylo

mutable struct BaryCentricContext 
    coefficient::Dict{Any, Any} #c
    offset::Dict{Any, Any} #d
    weights::Dict{Any, Any} #s
    coords::Dict{Any, Vector{Any}}
    total::Int
    current::Int
end

function generatebarycentrictree(tree)
    leaves = getleaves(tree)
    context = BaryCentricContext(Dict(), Dict(), Dict(), Dict(), length(leaves), 0)
    context = tpostorder(tree, getroot(tree), context)
    context = tpreorder(tree, getroot(tree), context)

    return context
end

function comparesize(tree, n, a, b)
    asize = getlength(tree, getbranch(tree, n, a)) + getheight(tree, a)
    bsize = getlength(tree, getbranch(tree, n, b)) + getheight(tree, b)

    return asize < bsize
end

function tpostorder(tree, node, context::BaryCentricContext)
    for child in sort(getchildren(tree, node);lt=(a,b) -> comparesize(tree, node, a, b))
        context = tpostorder(tree, child, context)
    end
    # fix leaves on outer circle
    if isleaf(tree, node) || (isroot(tree, node) && degree(tree, node) == 1)
        context.coefficient[node] = 0.0
        segment = (2*pi*context.current)/context.total
        context.offset[node] = [cos(segment), sin(segment)]
        context.current += 1
    else
        s = 0.0
        for branch in getconnections(tree, node)
            if isroot(tree, node) || src(tree, branch) == getparent(tree, node) # check parent case
                context.weights[branch] = 1.0/getlength(tree, branch)
            else
                context.weights[branch] = 1.0/getlength(tree, branch)*(degree(tree, node)-1)
            end
            s += context.weights[branch]
        end
        t = t1 = 0.0
        for outgoing in getoutbounds(tree, node)
            destination = dst(tree, outgoing)
            t = t + context.weights[outgoing]/s * context.coefficient[destination]
            t1 = t1 .+ context.weights[outgoing]/s .* context.offset[destination]
        end
        if !isroot(tree, node)
            e = getbranch(tree, getparent(tree, node), node)
            context.coefficient[node] = context.weights[e]/(s*(1-t))
        end
        context.offset[node] = t1./(1-t)
    end
    return context
end

function tpreorder(tree, node, context::BaryCentricContext)
    if isroot(tree, node)
       context.coords[node] = context.offset[node] 
    else
        parent = getparent(tree, node)
        context.coords[node] = context.coefficient[node] * context.coords[parent] + context.offset[node]
    end
    for child in getchildren(tree, node)
        context = tpreorder(tree, child, context)
    end
    return context
end

function drawbarycentrictree(tree)
    barycentricdata = generatebarycentrictree(tree)

    c = reduce(hcat,values(barycentricdata.coords))'

    for node in getnodes(tree)
        for child in getchildren(tree, node)
            cx, cy = barycentricdata.coords[child]
            px, py = barycentricdata.coords[node]
            lines!([cx, px], [cy, py])
        end
    end
end