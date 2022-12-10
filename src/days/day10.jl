module Day10

import ..@testitem

const IntT = Int32
const Instruction = Union{Nothing, IntT}

struct State
    cycle::Int
    index::Int
    register::IntT
    value_to_add::Union{Nothing, IntT}
end
State() = State(1, 1, 1, nothing)

function parse(io::IO)::Vector{Instruction}
    map(Iterators.filter(!isempty, Iterators.map(rstrip, eachline(io)))) do line
        if line == "noop"
            nothing
        elseif isvalid(line, 5) && view(line, 1:5) == "addx "
            Base.parse(IntT, view(line, 6:lastindex(line)); base=10)
        else
            error(lazy"Unknown instruction: \"$line\"")
        end
    end
end

function advance(
    v::Vector{Instruction},
    screen::Vector{Bool},
    state::State,
    cycles::Integer,
)
    len = length(v)
    index = state.index
    value_to_add = state.value_to_add
    register = state.register
    state.cycle+cycles-1 > length(screen) && error("Too many cycles")
    for current_cycle in state.cycle:state.cycle+cycles-1
        if mod(current_cycle - 1, 40) in register-1:register+1
            @inbounds screen[current_cycle] = true
        end
        if value_to_add !== nothing
            register += value_to_add
            index += 1
            value_to_add = nothing
        else
            value_to_add = v[index]
            if value_to_add === nothing
                index += 1
            end
        end
    end
    return State(state.cycle+cycles, index, register, value_to_add)
end

function solve(v)
    screen = fill(false, 240)
    state = State()
    signal = 0
    for cycle in (20, 60, 100, 140, 180, 220)
        state = advance(v, screen, state, cycle - state.cycle)
        signal += cycle * state.register
    end
    advance(v, screen, state, 20)
    (signal, screen_string(screen))
end

function screen_string(screen)
    buffer = IOBuffer()
    for i in 1:40:240
        write(
            buffer,
            '\n',
            [i ? UInt8('#') : UInt8(' ') for i in view(screen, i:i+39)],
        )
    end
    String(take!(buffer))
end

const TEST_INPUT = """addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop"""

@testitem "Day10" begin
    using AoC2022.Day10: solve, parse, TEST_INPUT
    using JET

    v = parse(IOBuffer(TEST_INPUT))
    solution = solve(v)
    @test solution[1] == 13140
    @test solution[2] == '\n' * join([
        "##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ",
        "###   ###   ###   ###   ###   ###   ### ",
        "####    ####    ####    ####    ####    ",
        "#####     #####     #####     #####     ",
        "######      ######      ######      ####",
        "#######       #######       #######     "
        ], '\n')
    @test_opt solve(v)
    @test_call solve(v)
end

end # module