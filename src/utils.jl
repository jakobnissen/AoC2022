const BufferType = Vector{NamedTuple{(:result, :time, :day), Tuple{Any, Float64, Int}}}

macro time(ex)
    return quote
        t1 = time_ns()
        val = $(esc(ex))
        ((time_ns() - t1) / 1.0e9, val)
    end
end

macro solve(io, day)
    return :($(Symbol("Day$(day)")).solve($(Symbol("Day$(day)")).parse($(esc(io)))))
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
    return quote
        open(joinpath(DATA_DIR, $("day" * lpad(day, 2, '0') * ".txt"))) do io
            @solve io $day
        end
    end
end

let
    args = Any[
        quote
                let
                    (time, result) = @time @solve $day
                    push!(buffer, (; result, time, day = $day))
            end
            end for day in SOLVED_DAYS
    ]
    solve_all_block = Expr(:block, args...)

    @eval function solve_all()
        buffer = BufferType()
        # This expands to `@push_day 1` etc for all solved days
        (time, _) = @time $solve_all_block
        return (time, sort!(buffer, by = i -> i.day))
    end

    @doc """
        solve_all([input])::Vector{@NamedTuple result::Any, time::Float64, day::Int}

    Load and solve all puzzles, returning `(total_time::Float64, solutions)`.
    If `input` is passed, it must be the output of `load_all`. This allows `solve_all`
    to work from data in memory.
    If not passed, `solve_all` will read the data from disk.

    `solutions` is a vector containing `NamedTuples` with the following fields:
        * `.result` is a Tuple{Any, Any} if and only if both parts of the day is
          returned
        * `.time` is the approximate elapsed time in seconds to solve the day's puzzle(s)
        * `.day` is the day
    """
    solve_all

    args = Any[
        quote
                let
                    io = IOBuffer(data[$day])
                    (time, result) = @time @solve io $day
                    push!(buffer, (; result, time, day = $day))
            end
            end for day in SOLVED_DAYS
    ]
    solve_all_block = Expr(:block, args...)

    @eval function solve_all(data::Vector{Vector{UInt8}})
        buffer = BufferType()
        # This expands to `@push_day 1` etc for all solved days
        (time, _) = @time $solve_all_block
        return (time, sort!(buffer, by = i -> i.day))
    end
end

function load_all()
    return map(SOLVED_DAYS) do day
        open(read, joinpath(DATA_DIR, "day$(lpad(day, 2, '0')).txt"))
    end
end

"""
    print_all()

Load, solve, and print the solution to, and timing of, all puzzles to stdout.
"""
print_all(args...) = print_solution(solve_all(args...)...)

function print_solution(total_time::Real, buffer::BufferType)
    io = IOBuffer()
    for (; result, time, day) in buffer
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
    return print(String(take!(io)))
end
