module AoC2022

using TestItems
using Printf: @sprintf

include("download.jl")
include("day01.jl")
include("day02.jl")
include("utils.jl")

using .Download: download_data, download_all

export @solve, print_all, solve_all, download_all, download_data

end # module AoC2022
