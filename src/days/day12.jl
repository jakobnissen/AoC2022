module Day12

import ..@testitem

const Index = CartesianIndex{2}

function parse(io::IO)
    buffer = UInt8[]
    start, stop = nothing, nothing
    linewidth = 0
    lines = Iterators.map(rstrip, eachline(io))
    for (row, line) in enumerate(lines)
        if isempty(line)
            any(!isempty, lines) && error("Non-trailing blank line in input")
        end
        if iszero(linewidth)
            linewidth = ncodeunits(line)
        elseif linewidth != ncodeunits(line)
            error("Not all lines equally long")
        end
        for (col, byte) in enumerate(codeunits(line))
            if byte == UInt8('S')
                start === nothing || error("Multiple starting positions")
                start = (row, col)
                push!(buffer, 0x00)
            elseif byte == UInt8('E')
                stop === nothing || error("Multiple ending positions")
                stop = (row, col)
                push!(buffer, UInt8('z') - UInt8('a'))
            elseif byte in UInt8('a'):UInt8('z')
                push!(buffer, byte - UInt8('a'))
            else
                error("Expected only bytes E, S and a-z in input lines")
            end
        end
    end
    return (
        permutedims(reshape(buffer, (linewidth, :))),
        CartesianIndex(start),
        CartesianIndex(stop),
    )
end

function count_steps(
        m::AbstractMatrix{<:Integer},
        steps::Matrix{<:Signed},
        start::Vector{Index},
        stop::Index,
    )
    fill!(steps, eltype(steps)(-1))
    for i in start
        steps[i] = 0
    end
    next = empty(start)
    @inbounds while !isempty(start)
        for index in start
            current_steps = steps[index]
            current_height = m[index]
            for delta in CartesianIndex.(((-1, 0), (1, 0), (0, -1), (0, 1)))
                new_index = delta + index
                checkbounds(Bool, m, new_index) || continue
                steps[new_index] == -1 || continue
                m[new_index] < current_height + 0x02 || continue
                new_index == stop && return current_steps + 1
                steps[new_index] = current_steps + 1
                push!(next, new_index)
            end
        end
        empty!(start)
        (start, next) = (next, start)
    end
    return steps
end

solve(t::Tuple{<:AbstractMatrix{<:Integer}, Index, Index}) = solve(t...)
function solve(m::AbstractMatrix{<:Integer}, start::Index, stop::Index)
    steps = Matrix{Int16}(undef, size(m))
    start_p2 = filter(i -> m[i] == 0x00, CartesianIndices(m))
    return (count_steps(m, steps, [start], stop), count_steps(m, steps, start_p2, stop))
end

const TEST_INPUT = """Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi"""

@testitem "Day12" begin
    using AoC2022.Day12: solve, parse, TEST_INPUT

    data = parse(IOBuffer(TEST_INPUT))
    @test solve(data) == (31, 29)
end

end # module
