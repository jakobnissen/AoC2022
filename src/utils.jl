const BufferType = Vector{NamedTuple{(:result, :time, :day), Tuple{Any, Float64, Int}}}

function solve(solver, parser, day::Int)
    open("data/day$(lpad(day, 2, '0')).txt") do io
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

"""
    @solve day

Parse and solve the given day. The day must be in `1:25`, and the requisite data
must have been downloaded to `data/day\$i.txt`.

# Examples
```julia
julia> @solve 1
(69528, 206152)
```
"""
macro solve(day)
    :(solve($(Symbol("Day$(day)")).solve, $(Symbol("Day$(day)")).parse, $day))
end

# This is a macro so that the parser and solver function is resolved at parse time,
# so it does not rely on reflection at runtime.
macro push_day(day)
    quote
        (time, result) = @time @solve $day
        push!($(esc(:buffer)), (;result, time, day=$day))
    end     
end

"""
    solve_all()::Vector{@NamedTuple result::Any, time::Float64, day::Int}

Load and solve all puzzles, returning `(total_time::Float64, solutions)``\

`solutions` is a vector containing `NamedTuples` with the following fields:
    * `.result` is a Tuple{Any, Any} if and only if both parts of the day is
      returned
    * `.time` is the approximate elapsed time in seconds to solve the day's puzzle(s)
    * `.day` is the day
"""
function solve_all()
    buffer = BufferType()

    (time, _) = @time begin
        @push_day 1
        @push_day 2
        @push_day 3
        @push_day 4
        @push_day 5
    end

    (time, sort!(buffer, by=i -> i.day))
end

"""
    print_all()

Load, solve, and print the solution to, and timing of, all puzzles to stdout.
"""
print_all() = print_solution(solve_all()...)

function print_solution(total_time::Real, buffer::BufferType)
    io = IOBuffer()
    for (;result, time, day) in buffer
        # Some days I might only have solved part 1.
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
    print(io, "Total time: ", @sprintf("%.6f", total_time), " seconds")
    print(String(take!(io)))
end
