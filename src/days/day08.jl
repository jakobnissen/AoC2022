module Day8

import ..@testitem

function parse(io::IO)::Matrix{Int8}
    lines = Iterators.map(rstrip, eachline(io))
    width = 0
    buffer = Int8[]
    for nonempty_line in Iterators.takewhile(!isempty, lines)
        if iszero(width)
            width = ncodeunits(nonempty_line)
        elseif ncodeunits(nonempty_line) != width
            error("Not all lines have uniform width")
        end
        for codeunit in codeunits(nonempty_line)
            codeunit in UInt8('0'):UInt8('9') || error("Input must contain only 0:9")
            push!(buffer, (codeunit - 0x30) % Int8)
        end
    end
    isempty(buffer) && error("Empty file, or leading blank lines")
    return Matrix(reshape(buffer, :, width)')
end

# From each of four directions, takes views of matrix and accumulator.
# v = f(view of matrix) is computed, then accumulator is updated with
# op!(view of accumulator, v)
function directional_mapreduce!(f::Function, op!::Function, matrix::AbstractMatrix, accumulator::AbstractMatrix)
    size(accumulator) == size(matrix) || error("Sizes must match")
    (nrows, ncols) = size(matrix)
    @inbounds for row in 1:nrows
        op!(@view(accumulator[row, :]), f(@view(matrix[row, :])))
        op!(@view(accumulator[row, ncols:-1:1]), f(@view(matrix[row, ncols:-1:1])))
    end
    @inbounds for col in 1:ncols
        op!(@view(accumulator[:, col]), f(@view(matrix[:, col])))
        op!(@view(accumulator[nrows:-1:1, col]), f(@view(matrix[ncols:-1:1, col])))
    end
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
    sum(directional_mapreduce!(f, op!, m, accumulator))
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
        viewbuffer[i] = i - seenbuffer[height+1]
        @view(seenbuffer[1:height+1]) .= i
    end
    view(viewbuffer, eachindex(trees))
end

function part2(m::AbstractMatrix{<:Integer})
    accumulator = fill(Int32(1), size(m))
    seenbuffer = Vector{UInt8}(undef, 10)
    viewbuffer = Vector{Int32}(undef, max(size(m)...))
    f = i -> get_visibility!(seenbuffer, viewbuffer, i)
    op!(a, b) = a .*= b
    maximum(directional_mapreduce!(f, op!, m, accumulator))
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
