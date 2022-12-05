module Day5

import ..@testitem

function parse(io::IO)
    lines = Iterators.map(rstrip, eachline(io))
    # Put all lines up until the first blank line into the tower buffer
    # to be parsed as the tower.
    tower_buffer = String[]
    for line in lines
        isempty(line) && break
        push!(tower_buffer, line)
    end
    tower = parse_tower(tower_buffer)
    # The remaining lines are parsed as moves
    return (tower, parse_moves(lines))
end

function parse_tower(buffer::Vector{<:AbstractString})
    # The last line in buffer (above the terminating blank line) gives the 
    # integer labels of each tower. We pop it off here.
    order = map(i -> Base.parse(UInt, i; base=10), eachsplit(pop!(buffer)))
    allunique(order) || error("Not all indices unique")
    vectors = [UInt8[] for i in eachindex(order)]
    for line in buffer
        # We parse each crate from left to right. The number of whitespaces
        # indicate which crate tower the crate belongs to. E.g. 8 whitespaces
        # means the crate is 3 to the right of the previous crate.
        order_index = 0
        for match in eachmatch(r"( *)\[(.)\]", line)
            order_index += let
                leading_spaces = match.captures[1]
                # Only the leftmost crate can have zero leading spaces
                if isnothing(leading_spaces)
                    order_index == 1 || error("Malformed data")
                    1
                else
                    # Crates are separated by 1 space. A missing crate adds 4
                    # spaces. Hence, the remainder must be zero for the leftmost
                    # nonempty crate, else 1.
                    (d, r) = divrem(ncodeunits(leading_spaces), 4)
                    if r != ifelse(iszero(order_index), 0, 1)
                        error("Malformed data")
                    end
                    d + 1
                end
            end
            push!(vectors[order_index], UInt8(only(match.captures[2])))
        end
    end
    # Reverse, each tower, since arrays are easier to append and pop from the
    # end, they must be represented as "bottom-up", even though they are parsed
    # top-down.
    foreach(reverse!, vectors)
    Dict(zip(order, vectors))
end

function parse_moves(lines)
    result = Vector{Tuple{UInt16, UInt8, UInt8}}()
    for line in lines
        if isempty(line)
            all(isempty, lines) || error("Non-trailing empty lines")
            return result
        end
        m = something(match(r"^move (\d+) from (\d+) to (\d+)$", line))
        push!(result, (
            Base.parse(UInt16, m.captures[1]; base=10),
            Base.parse(UInt8, m.captures[2]; base=10),
            Base.parse(UInt8, m.captures[3]; base=10)
        ))
    end
    result
end

solve(x::Tuple{<:AbstractDict, <:AbstractVector}) = solve(x...)
function solve(
    tower::Dict{<:Integer, Vector{UInt8}},
    moves::Vector{<:NTuple{3, Integer}}
)
    # Copy vector for part2 to avoid mutating same arrays for both parts
    copied = Dict(k => (copy(v), copy(v)) for (k, v) in tower)
    for (n, from, to) in moves
        append_pop!(first(copied[to]), first(copied[from]), n)
        # For part 1, they are moved one at a time, which reverses the moved
        # chunk. For part 2, the chunk need not be reverted.
        # Otherwise, the process is the same.
        reverse!(@view(copied[to][1][end-n+1:end]))
        append_pop!(last(copied[to]), last(copied[from]), n)
    end
    # Now we just take the last byte of each array (sorted by their name)
    # and turn it into a string.
    pairs = map(last, sort!(collect(copied)))
    (String(map(i -> last(first(i)), pairs)), String(map(i -> last(last(i)), pairs)))
end

# Move the `n` last elements from `from` to `to`.
function append_pop!(to::Vector{T}, from::Vector{T}, n::Integer) where T
    append!(to, @view(from[end-n+1:end]))
    resize!(from, length(from) - n)
    to
end

@testitem "Day5" begin
    using AoC2022.Day5: solve, parse
    using JET

    TEST_INPUT = """    [D]    
    [N] [C]    
    [Z] [M] [P]
        1   2   3 

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2"""

    data = parse(IOBuffer(TEST_INPUT))
    @test solve(data) == ("CMZ", "MCD")
    @test_opt solve(data)
    @test_call solve(data)
end

end # module
