module Day6

import ..@testitem

struct Letters
    s::SubString{String}

    function Letters(s::SubString{String})
        ncodeunits(s) > typemax(UInt32) && error("String too long")
        all(codeunits(s)) do i
            i in UInt8('a'):UInt8('z')
        end || error("Must be a-z only")
        new(s)
    end
end

parse(io::IO) = Letters(strip(read(io, String)))

function solve(v::Letters)
    buffer = Vector{UInt32}(undef, 26)
    solve(v, buffer, 4), solve(v, buffer, 14)
end

function solve(v::Letters, buffer::Vector{UInt32}, n::Int)
    fill!(buffer, typemin(UInt32))
    remaining = n
    @inbounds for (pos, byte) in pairs(codeunits(v.s))
        remaining -= 1
        byte_index = byte - UInt8('a') + 0x01
        last_seen = buffer[byte_index]
        if last_seen > pos - n
            remaining = max(remaining, last_seen + n - pos)
        elseif iszero(remaining)
            return pos
        end
        buffer[byte_index] = pos % UInt32
    end
    nothing
end

@testitem "Day6" begin
    using AoC2022.Day6: solve, parse
    using JET

    TEST_STRINGS = [
        "mjqjpqmgbljsphdztnvjfqwrcgsmlb",
        "bvwbjplbgvbhsrlpgdmjqwftvncz",
        "nppdvjthqldpwncqszvftbrmjlhg",
        "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg",
        "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
    ]
    @test map(i -> solve(parse(IOBuffer(i))), TEST_STRINGS) == [
        (7, 19),
        (5, 23),
        (6, 23),
        (10, 29),
        (11, 26)
    ]
    letters = parse(IOBuffer("abcdefg"))
    @test_opt solve(letters)
    @test_call solve(letters)
end

end # module