using Phylo

mutable struct HVContext
    coords::Dict{Any, Vector{Real}}
    leaves::Dict{Any, Int}
end

function generatehvtree(tree)
    ctx = HVContext(Dict(), Dict())
    root = getroot(tree)
    ctx.leaves = subtreesizes(tree, root)
    ctx, _ = hvpreorder(tree, root, ctx)
    return ctx
end

function hvpreorder(tree, node, ctx::HVContext, ix::Int=0, iy::Int=0)
    children = getchildren(tree, node)
    ctx.coords[node] = [ix, iy]
    if isleaf(tree, node)
        return ctx, 0
    elseif length(children) == 1
        child = first(children)
        _, width = hvpreorder(tree, child, ctx, ix+1, iy)
        return ctx, width + 1

    elseif length(children) == 2
        small, large = children
        smallsize, largesize = ctx.leaves[small], ctx.leaves[large]
        if largesize < smallsize
            # do swap so bigger node always sits in large
            tmp = large
            large = small
            small = tmp
        end
        _, widthsmall = hvpreorder(tree, small, ctx, ix, iy+1)
        _, widthlarge = hvpreorder(tree, large, ctx, ix+1+widthsmall, iy)
        return ctx, widthsmall + widthlarge + 1
    else
        error("Tree is not binary")
    end
end

function drawhvtree(tree)
    hvdata = generatehvtree(tree)
    c = reduce(hcat,values(hvdata.coords))'
    scatter!(c[:,1], -c[:,2])

    for node in getnodes(tree)
        for child in getchildren(tree, node)
            cx, cy = hvdata.coords[child]
            px, py = hvdata.coords[node]
            vx, vy = [cx, cy] - [px, py]
            lcolor = :red
            if vx == 0
                lcolor = :blue
            end
            lines!([cx, px], [-cy, -py]; color=lcolor)
        end
    end
end