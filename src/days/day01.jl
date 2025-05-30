module Day1

import ..@testitem

function parse(io::IO)
    return map(eachsplit(rstrip(read(io, String)), r"\r?\n\r?\n")) do chunk
        sum(eachsplit(chunk, r"\r?\n"); init = UInt(0)) do line
            Base.parse(UInt, line; base = 10)
        end
    end
end

function solve(v::AbstractVector)
    partialsort!(v, 1:3, rev = true)
    return (Int(first(v)), Int(sum(view(v, 1:3))))
end

const TEST_INPUT = """1000
2000
3000

4000

5000
6000

7000
8000
9000

10000"""

@testitem "Day1" begin
    using AoC2022.Day1: parse, solve, TEST_INPUT

    v = parse(IOBuffer(TEST_INPUT))
    @test solve(v) == (24000, 45000)
end

end # module
