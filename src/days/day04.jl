module Day4

import ..@testitem

function parse(io::IO)
    map(Iterators.map(rstrip, eachline(io))) do line
        map(something(split_once(line, UInt8(',')))) do range
            (a, b) = map(something(split_once(range, UInt8('-')))) do num
                Base.parse(Int, num; base=10)
            end
            a:b
        end        
    end
end

function split_once(s::Union{String, SubString{String}}, byte::UInt8)
    cu = codeunits(s)
    p = findfirst(isequal(byte), cu)
    p === nothing && return nothing
    (view(s, 1:prevind(s, p)), view(s, p+1:lastindex(s)))
end

function solve(v::AbstractVector{<:NTuple{2, AbstractUnitRange}})
    (p1, p2) = (0, 0)
    for (a, b) in v
        p1 += encompasses(a,b) || encompasses(b,a)
        p2 += overlaps(a, b)
    end
    (p1, p2)
end

function overlaps(a::AbstractUnitRange{T}, b::AbstractUnitRange{T}) where T
    first(a) in b || last(a) in b || first(b) in a
end

function encompasses(a::AbstractUnitRange{T}, b::AbstractUnitRange{T}) where T
    isempty(b) && return true
    isempty(a) && return false
    first(a) <= first(b) && last(a) >= last(b)
end

@testitem "Day4" begin
    using AoC2022.Day4: parse, solve
    using JET

    TEST_INPUT = """2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8"""

    v = parse(IOBuffer(TEST_INPUT))
    @test solve(v) == (2, 4)
    @test_opt solve(v)
    @test_call solve(v)
end


end # module
