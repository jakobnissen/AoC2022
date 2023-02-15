module AoC2022

using TestItems: @testitem
using Printf: @sprintf
using Downloads: Downloads
using SnoopPrecompile: @precompile_all_calls

const SOLVED_DAYS = 1:12
const DATA_DIR = joinpath(dirname(@__DIR__), "data")

include("download.jl")
# This expands to `include("days/day01.jl")` etc for all solved days
eval(Expr(:block, [:(include($("days/day$(lpad(i, 2, '0')).jl"))) for i in SOLVED_DAYS]...))
include("utils.jl")

import .Download: download_data, download_all

let
    # This block expands to precompilation statement for all implemented days.
    args = [:(@solve IOBuffer($(Symbol("Day$(day)")).TEST_INPUT) $day) for day in SOLVED_DAYS]
    eval(:(@precompile_all_calls $(Expr(:block, args...))))
end

export @solve, load_all, print_all, solve_all, download_all, download_data

end # module AoC2022
