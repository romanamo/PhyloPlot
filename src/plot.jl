@recipe PhyloTreePlot begin
    
end


function Makie.plot!(tmp::PhyloTreePlot{<:Tuple{<:Phylo.NamedTree}})
    function draw(rects)
        poly!(tmp, rects,
            strokewidth = 3,
            strokecolor=:blue,
            color=(:white, 0.1),
            colormap=:heat
        )
    end
    rs = treemap(tmp[1][])
    draw(values(rs))
    return tmp
end