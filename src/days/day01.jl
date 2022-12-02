module Day1

import ..@testitem

function parse(io::IO)
    map(eachsplit(rstrip(read(io, String)), r"\r?\n\r?\n")) do chunk
        sum(eachsplit(chunk, r"\r?\n"); init=UInt(0)) do line
            Base.parse(UInt, line; base=10)
        end
    end
end

function solve(v::AbstractVector)
    partialsort!(v, 1:3, rev=true)
    (Int(first(v)), Int(sum(view(v, 1:3))))
end

@testitem "Day1" begin
    using AoC2022.Day1: parse, solve
    using JET

    TEST_INPUT = """1000
    2000
    3000
    
    4000
    
    5000
    6000
    
    7000
    8000
    9000
    
    10000"""
    v = parse(IOBuffer(TEST_INPUT))
    @test solve(v) == (24000, 45000)
    @test_opt solve(v)
    @test_call solve(v)
end

end # module
