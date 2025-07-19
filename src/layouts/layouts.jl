module Layouts

    export AbstractDrawingResult, DrawingResult
    export layouthv, layoutclassicdendrogram, layoutslicedicetreemap, layoutbarycentric, layoutradial

    abstract type AbstractDrawingResult end

    struct DrawingResult <: AbstractDrawingResult
        coords::Dict{Any, Vector{Real}}
    end

    include("barycentric.jl")
    include("dendrogram.jl")
    include("hv.jl")
    include("radial.jl")
    include("treemap.jl")
end