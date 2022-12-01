module AoC2022

using TestItems
using Printf: @sprintf

include("day1.jl")

const BufferType = Vector{NamedTuple{(:result, :time, :day), Tuple{Any, Float64, Int}}}

function solve(solver, parser, day::Int)
    open("data/day$(day).txt") do io
        solver(parser(io))
    end
end

macro time(ex)
    quote
        t1 = time_ns()
        val = $(esc(ex))
        ((time_ns() - t1) / 1e9, val)
    end
end

macro timesolve(day)
    quote
        (time, val) = @time begin
            solve($(Symbol("Day$(day)")).solve, $(Symbol("Day$(day)")).parse, $day)
        end
        push!($(esc(:buffer)), (;result=val, time=time, day=$day))
    end
end

function solve_all()
    buffer = BufferType()

    (time, _) = @time begin
        @timesolve 1
    end

    (time, sort!(buffer, by=i -> i.day))
end

function print_all()
    (time, buffer) = solve_all()
    io = IOBuffer()
    for (;result, time, day) in buffer
        (part1, part2) = if result isa Tuple{Any, Any}
            result
        else
            (result, nothing)
        end
        println(io, "Day ", string(day), " (", @sprintf("%.6f", time), " seconds", "):")
        println(io, "\tPart 1: ", part1)
        isnothing(part2) || println(io, "\tPart 2: ", part2)
        println(io)
    end
    print(io, "Total time: ", @sprintf("%.6f", time), " seconds")
    print(String(take!(io)))
end

end # module AoC2022
