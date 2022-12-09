module AoC2022

using TestItems: @testitem
using Printf: @sprintf
using Downloads: Downloads
using SnoopPrecompile: @precompile_all_calls

# When we reach the 25th of December, we can remove the Dates dependency used
# in download.jl, which is only used to avoid downloading data which is not
# yet released.
using Dates: Dates
@assert Dates.today() < Dates.Date(2022, 12, 25)

const SOLVED_DAYS = 1:9
const DATA_DIR = joinpath(dirname(@__DIR__), "data")

include("download.jl")
# This expands to `include("days/day01.jl")` etc for all solved days
eval(Expr(:block, [:(include($("days/day$(lpad(i, 2, '0')).jl"))) for i in SOLVED_DAYS]...))
include("utils.jl")

import .Download: download_data, download_all

# This expands to @precompile begin @solve_test 1 solve_test 2 ...
eval(:(@precompile_all_calls $(Expr(:block, [:(@solve_test $i) for i in SOLVED_DAYS]...))))

export @solve, print_all, solve_all, download_all, download_data

end # module AoC2022
