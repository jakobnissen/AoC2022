module AoC2022

using TestItems: @testitem
using Printf: @sprintf
using Downloads: Downloads

# When we reach the 25th of December, we can remove the Dates dependency used
# in download.jl, which is only used to avoid downloading data which is not
# yet released.
using Dates: Dates
@assert Dates.today() < Dates.Date(2022, 12, 25)

const DATA_DIR = joinpath(dirname(@__DIR__), "data")

include("download.jl")
include("days/day01.jl")
include("days/day02.jl")
include("days/day03.jl")
include("days/day04.jl")
include("days/day05.jl")
include("days/day06.jl")
include("days/day07.jl")
include("utils.jl")

import .Download: download_data, download_all

export @solve, print_all, solve_all, download_all, download_data

end # module AoC2022