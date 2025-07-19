module Layouts

export AbstractDrawingResult, DrawingResult
export layouthv, layoutclassicdendrogram, layoutslicedicetreemap, layoutbarycentric, layoutradial

export getcenter

abstract type AbstractDrawingResult end

struct LabelInfo
    coords::Vector{Real}
    rotation::Real
end

struct DrawingResult <: AbstractDrawingResult
    "node coordinates"
    coords::Dict{Any, Vector{Real}}
    "label coordinates"
    labels::Dict{Any, LabelInfo}
end

include("barycentric.jl")
include("dendrogram.jl")
include("hv.jl")
include("radial.jl")
include("treemap.jl")

end