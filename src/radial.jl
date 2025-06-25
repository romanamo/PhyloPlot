using Phylo

mutable struct RadialContext
    coords::Dict{Any, Vector{Real}} #x
    angle::Dict{Any, Real} #τ
    wedge::Dict{Any, Real} #ω
    leaves::Dict{Any, Int}
end

function generateradialtree(tree)
    context = RadialContext(Dict(), Dict(), Dict(), Dict())
    root = getroot(tree)
    context.leaves = subtreesizes(tree, root)
    context.coords[root] = [0.0, 0.0]
    context.wedge[root] = 2*pi
    context.angle[root] = 0.0
    context = rpreorder(tree, root, context)
    return context
end

function rpreorder(tree, node, ctx::RadialContext)
    if !isroot(tree, node)
        parent = getparent(tree, node)
        branch = getbranch(tree, parent, node)
        segment = ctx.angle[node] + ctx.wedge[node]/2.0
        ctx.coords[node] = ctx.coords[parent] + getlength(tree, branch) .* [cos(segment), sin(segment)]
    end
    mu = ctx.angle[node]
    for child in getchildren(tree, node)
        ctx.wedge[child] = ctx.leaves[child]/ctx.leaves[getroot(tree)] * 2.0 *pi
        ctx.angle[child] = mu
        mu += ctx.wedge[child]
        ctx = rpreorder(tree, child, ctx)
    end
    return ctx
end

function drawradialtree(tree)
    radialdata = generateradialtree(tree)

    c = reduce(hcat,values(radialdata.coords))'

    for node in getnodes(tree)
        for child in getchildren(tree, node)
            cx, cy = radialdata.coords[child]
            px, py = radialdata.coords[node]
            lines!([cx, px], [cy, py])
        end
    end

    current_figure()
end