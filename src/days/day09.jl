module Day9

import ..@testitem

@enum Direction::UInt8 up down left right

function delta(x::Direction)::Tuple{Int32, Int32}
    if x == up
        (0, 1)
    elseif x == down
        (0, -1)
    elseif x == left
        (-1, 0)
    else
        (1, 0)
    end
end

function parse(io::IO)
    lines = Iterators.map(rstrip, eachline(io))
    result = Tuple{Direction, UInt}[]
    for line in lines
        if isempty(line)
            all(isempty, lines) || error("Blank line in input")
        end
        ncodeunits(line) < 3 && @goto malformed
        (c1, c2) = @inbounds (codeunit(line, 1), codeunit(line, 2))
        direction = if c1 == UInt8('U')
            up
        elseif c1 == UInt8('D')
            down
        elseif c1 == UInt8('L')
            left
        elseif c1 == UInt8('R')
            right
        else
            @goto malformed
        end
        c2 == UInt8(' ') || @goto malformed
        num = Base.parse(UInt, view(line, 3:lastindex(line)); base=10)
        push!(result, (direction, num))
    end
    return result
    @label malformed
    error("Malformed line")
end

function follow_pos(head, tail)
    (hx, hy), (tx, ty) = head, tail
    dx, dy = hx - tx, hy - ty
    tail .+ (sign(dx), sign(dy))
end

function solve(v::AbstractVector{<:Tuple{Direction, Integer}})
    head = old_p1 = old_p2 = Int32.((0, 0))
    tails = fill(head, 9)
    all_p1_pos = Set((last(tails),))
    all_p2_pos = copy(all_p1_pos)
    @inbounds for (direction, n) in v
        delt = delta(direction)
        for _ in 1:n
            head = head .+ delt
            leader = head
            for j in 1:9
                old_pos = tails[j]
                new_pos = follow_pos(leader, old_pos)
                new_pos == leader && break
                leader = new_pos
                tails[j] = new_pos
            end
            p1, p2 = first(tails), last(tails)
            if p1 != old_p1
                old_p1 = p1
                push!(all_p1_pos, first(tails))
            end
            if p2 != old_p2
                old_p2 = p2
                push!(all_p2_pos, last(tails))
            end
        end
    end
    length(all_p1_pos), length(all_p2_pos)
end

const TEST_INPUT = """R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2"""

const TEST_INPUT2 = """R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20"""

@testitem "Day9" begin
    using AoC2022.Day9: solve, parse, TEST_INPUT
    using JET

    v = parse(IOBuffer(TEST_INPUT))
    @test solve(v) == (13, 1)
    @test_opt solve(v)
    @test_call solve(v)
end

end # module