module Day8

import ..@testitem

function parse(io::IO)::Matrix{Int8}
    lines = Iterators.map(rstrip, eachline(io))
    width = 0
    buffer = sizehint!(Int8[], 10000)
    for nonempty_line in Iterators.takewhile(!isempty, lines)
        if iszero(width)
            width = ncodeunits(nonempty_line)
        elseif ncodeunits(nonempty_line) != width
            error("Not all lines have uniform width")
        end
        for byte in codeunits(nonempty_line)
            byte in UInt8('0'):UInt8('9') || error("Input must contain only 0:9")
            push!(buffer, (byte - 0x30) % eltype(buffer))
        end
    end
    isempty(buffer) && error("Empty file, or leading blank lines")
    isempty(Iterators.filter(!isempty, lines)) || error("Nonblank lines after blank lines")
    return permutedims(reshape(buffer, :, width))
end

function directional_mapreduce!(f, op!, mats, accs)
    for (acc, mat) in zip(accs, mats)
        op!(acc, f(mat))
    end
end

function bidirectional_mapreduce!(f, op!, matrix, accumulator)
    directional_mapreduce!(f, op!, eachcol(matrix), eachcol(accumulator))
    directional_mapreduce!(f, op!, eachrow(matrix), eachrow(accumulator))
end

function quaddirectional_mapreduce!(f, op!, matrix, accumulator)
    bidirectional_mapreduce!(f, op!, matrix, accumulator)
    bidirectional_mapreduce!(f, op!, reverse!(matrix), reverse!(accumulator))
    accumulator
end

function is_visible!(buffer::AbstractVector{Bool}, trees::AbstractVector{<:Integer})
    max_height = -1
    fill!(buffer, false)
    @inbounds for i in eachindex(trees)
        height = trees[i]
        if height > max_height
            buffer[i] = true
            max_height = height
        end
    end
    view(buffer, eachindex(trees))
end

function part1(m::AbstractMatrix{<:Integer})
    accumulator = falses(size(m))
    buffer = BitVector(undef, max(size(m)...))
    f = i -> is_visible!(buffer, i)
    op!(a, b) = a .|= b
    sum(quaddirectional_mapreduce!(f, op!, m, accumulator))
end

function get_visibility!(
    seenbuffer::AbstractVector{<:Integer},
    viewbuffer::AbstractVector{<:Integer},
    trees::AbstractVector{<:Integer}
)
    fill!(seenbuffer, 1)
    viewbuffer[1] = 0
    @inbounds for i in 2:lastindex(trees)
        height = trees[i]
        viewbuffer[i] = (i - seenbuffer[height+1]) % eltype(viewbuffer)
        @view(seenbuffer[1:height+1]) .= (i % eltype(seenbuffer))
    end
    view(viewbuffer, eachindex(trees))
end

function part2(m::AbstractMatrix{<:Integer})
    accumulator = fill(UInt(1), size(m))
    seenbuffer = Vector{UInt32}(undef, 10)
    viewbuffer = Vector{UInt32}(undef, max(size(m)...))
    f = i -> get_visibility!(seenbuffer, viewbuffer, i)
    op!(a, b) = a .*= b
    Int(maximum(quaddirectional_mapreduce!(f, op!, m, accumulator)))
end

function solve(m::AbstractMatrix{<:Integer})
    minimum(size(m)) < 3 && return (length(m), 0)
    (part1(m), part2(m))
end

const TEST_INPUT = """30373
25512
65332
33549
35390"""

@testitem "Day8" begin
    using AoC2022.Day8: solve, parse, TEST_INPUT
    using JET

    root = parse(IOBuffer(TEST_INPUT))
    @test solve(root) == (21, 8)
    @test_opt solve(root)
    @test_call solve(root)
end

end
