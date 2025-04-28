module Day11

import ..@testitem

const Inv = Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int}

@enum OpCode add mul exp

struct Operation <: Function
    code::OpCode
    n::Int
end
function (x::Operation)(y)
    return if x.code == exp
        y * y
    elseif x.code == add
        y + x.n
    elseif x.code == mul
        y * x.n
    else
        @assert false
    end
end

mutable struct Monkey
    const items::Vector{Int}
    const operation::Operation
    const divisor::Inv
    const targets::Tuple{Int, Int}
    len::Int
    interactions::Int
end

function reset!(m::Monkey, items::Vector{Int})
    copyto!(m.items, items)
    m.len = length(items)
    m.interactions = 0
    return m
end

function parse(::Type{Monkey}, chunk::AbstractString, expected_index::Int)
    lines = map(strip, eachsplit(chunk, r"\r?\n"))
    m = match(r"^Monkey (\d+):$", lines[1])
    Base.parse(Int, m.captures[1]; base = 10) == expected_index || error("Wrong index")
    m = match(r"^Starting items: ([0-9, ]+)$", lines[2])
    items = map(i -> Base.parse(Int, i; base = 10), split(m.captures[1], ','))
    m = match(r"^Operation: new = old (\+|\*) (old|\d+)", lines[3])
    (m1, m2) = m.captures
    operation = if m2 == "old"
        @assert m1 == "*"
        Operation(exp, 0)
    elseif m1 == "+"
        Operation(add, Base.parse(Int, m2; base = 10))
    else
        Operation(mul, Base.parse(Int, m2; base = 10))
    end
    m = match(r"^Test: divisible by (\d+)$", lines[4])
    divisor = Base.parse(Int, m.captures[1]; base = 10)
    m = match(r"^If true: throw to monkey (\d+)$", lines[5])
    target_2 = Base.parse(Int, m.captures[1]; base = 10) + 1
    m = match(r"^If false: throw to monkey (\d+)$", lines[6])
    target_1 = Base.parse(Int, m.captures[1]; base = 10) + 1
    return Monkey(items, operation, Inv(divisor), (target_1, target_2), length(items), 0)
end

function parse(io::IO)
    monkeys = map(enumerate(split(strip(read(io, String)), r"\r?\n(\r?\n)+"))) do (i, chunk)
        parse(Monkey, chunk, i - 1)
    end
    n_items = sum(i -> i.len, monkeys; init = 0)
    for monkey in monkeys
        resize!(monkey.items, n_items)
    end
    length(monkeys) < 2 && error("Monkey business takes two monkeys or more")
    if any(enumerate(monkeys)) do (i, monkey)
            !all(monkey.targets) do target
                in(target, eachindex(monkeys)) && target != i
            end
        end
        error("Invalid monkey")
    end
    return monkeys
end

function process!(monkey::Monkey, monkeys::Vector{Monkey}, modulo::Union{Nothing, Inv})
    @inbounds for i in 1:monkey.len
        worry_level = monkey.operation(monkey.items[i])
        worry_level = if modulo === nothing
            div(worry_level, 3)
        else
            worry_level % modulo
        end
        target = monkeys[monkey.targets[iszero(worry_level % monkey.divisor) + 1]]
        len = target.len
        target.items[len + 1] = worry_level
        target.len = len + 1
    end
    monkey.interactions += monkey.len
    return monkey.len = 0
end

function part(
        monkeys::Vector{Monkey},
        rounds::Int,
        modulo::Union{Nothing, Inv},
        copies::Vector{Vector{Int}},
    )
    for _ in 1:rounds
        for i in eachindex(monkeys)
            process!(monkeys[i], monkeys, modulo)
        end
    end
    inspections = [m.interactions for m in monkeys]
    partialsort!(inspections, 1:2; rev = true)
    result = inspections[1] * inspections[2]

    for (monkey, items) in zip(monkeys, copies)
        reset!(monkey, items)
    end
    return result
end

function solve(monkeys::Vector{Monkey})
    copies = map(i -> i.items[1:i.len], monkeys)
    modulo = Inv(prod(i -> i.divisor.divisor, monkeys))
    return (part(monkeys, 20, nothing, copies), part(monkeys, 10000, modulo, copies))
end

const TEST_INPUT = """Monkey 0:
Starting items: 79, 98
Operation: new = old * 19
Test: divisible by 23
  If true: throw to monkey 2
  If false: throw to monkey 3

Monkey 1:
Starting items: 54, 65, 75, 74
Operation: new = old + 6
Test: divisible by 19
  If true: throw to monkey 2
  If false: throw to monkey 0

Monkey 2:
Starting items: 79, 60, 97
Operation: new = old * old
Test: divisible by 13
  If true: throw to monkey 1
  If false: throw to monkey 3

Monkey 3:
Starting items: 74
Operation: new = old + 3
Test: divisible by 17
  If true: throw to monkey 0
  If false: throw to monkey 1"""

@testitem "Day11" begin
    using AoC2022.Day11: solve, parse, TEST_INPUT

    data = parse(IOBuffer(TEST_INPUT))
    @test solve(data) == (10605, 2713310158)
end

end # module
