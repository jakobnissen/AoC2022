module Day3

import ..@testitem

struct RuckSack
    first::UInt64
    last::UInt64
end

function RuckSack(v::AbstractVector{<:Integer})
    # Todo: Iterate on subarray is currently ineffective
    bitcount(v) =
        foldl(v; init = UInt64(0)) do n, i
        n | (UInt64(1) << (score(i) % 63))
    end

    iseven(length(v)) || error("Number of elements not divisible by 2")
    all(v) do num
        (num in UInt8('A'):UInt8('Z')) | (num in UInt8('a'):UInt8('z'))
    end || error("Rucksack does not only contain a-zA-Z")
    mid = div(length(v), 2)
    return RuckSack(bitcount(view(v, 1:mid)), bitcount(view(v, (mid + 1):length(v))))
end

function shared(x::RuckSack)
    y = x.first & x.last
    count_ones(y) == 1 || error("Rucksack does not share 1 element between rooms")
    return trailing_zeros(y)
end

function shared_trio(x1::RuckSack, x2::RuckSack, x3::RuckSack)
    bits = x1.first | x1.last
    bits &= (x2.first | x2.last) & (x3.first | x3.last)
    count_ones(bits) == 1 || error("Rucksack trio does share 1 element")
    return trailing_zeros(bits)
end

function parse(io::IO)
    lines = Iterators.filter(!isempty, Iterators.map(rstrip, eachline(io)))
    # Todo: Iterators.partition is type-unstable, and needlessly returns vectors :(
    return map(zip(lines, lines, lines)) do chunk
        length(chunk) == 3 || error("Number of lines not divisible by 3")
        ntuple(line -> RuckSack(codeunits(chunk[line])), 3)
    end
end

function solve(v::AbstractVector{<:NTuple{3, RuckSack}})
    (p1, p2) = 0, 0
    for trio in v
        p1 += sum(shared, trio; init = 0)
        p2 += shared_trio(trio...)
    end
    return (p1, p2)
end

score(n::Integer) = n > Int('Z') ? n - Int('a') + 1 : n - Int('A') + 27

const TEST_INPUT = """vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"""

@testitem "Day3" begin
    using AoC2022.Day3: solve, parse, TEST_INPUT

    v = parse(IOBuffer(TEST_INPUT))
    @test solve(v) == (157, 70)
end

end
