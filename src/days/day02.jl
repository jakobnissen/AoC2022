module Day2

import ..@testitem

const WIN_SCORES = UInt8.((3, 6, 0, 0, 3, 6, 6, 0, 3))

@enum Choice::UInt8 rock paper scissors

function parse(io::IO)::Vector{NTuple{3, Choice}}
    map(Iterators.filter(!isempty, Iterators.map(rstrip, eachline(io)))) do line
        if ncodeunits(line) != 3 || codeunit(line, 2) != UInt8(' ')
            error("Invalid line in input")
        end
        other = (rock, paper, scissors)[codeunit(line, 1) - UInt8('A') + 1]
        self_index = codeunit(line, 3) - UInt8('X') + 1
        self_p1 = (rock, paper, scissors)[self_index]
        self_p2 = Choice(mod(Integer(other) + (0x02, 0x00, 0x01)[self_index], 0x03))
        (other, self_p1, self_p2)
    end
end

function round_score(other::Choice, you::Choice)::Integer
    choice_score = Integer(you) + 0x01
    outcome_score = @inbounds WIN_SCORES[3*Integer(other) + Integer(you) + 0x01]
    choice_score + outcome_score
end

function solve(v::AbstractVector{Tuple{Choice, Choice, Choice}})
    (score_p1, score_p2) = (0, 0)
    for (other, self_p1, self_p2) in v
        score_p1 += round_score(other, self_p1)
        score_p2 += round_score(other, self_p2)
    end
    (score_p1, score_p2)
end

const TEST_INPUT = """A Y
B X
C Z"""

@testitem "Day2" begin
    using AoC2022.Day2: parse, solve, TEST_INPUT
    using JET

    v = parse(IOBuffer(TEST_INPUT))
    @test solve(v) == (15, 12)
    @test_opt solve(v)
    @test_call solve(v)
end

end # module
