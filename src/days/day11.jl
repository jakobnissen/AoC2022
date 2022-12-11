module Day11

import ..@testitem

struct Item
    monkey_index::Int
    worry_level::Int
end

const Inv = Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int}

@enum OpCode add mul exp

struct Operation <: Function
    code::OpCode
    n::Int
end
function (x::Operation)(y)
    if x.code == exp
        y*y
    elseif x.code == add
        y + x.n
    elseif x.code == mul
        y * x.n
    else
        @assert false
    end
end

struct Monkey
    operation::Operation
    divisor::Inv
    targets::Tuple{Int, Int}
end

function parse(::Type{Monkey}, chunk::AbstractString, expected_index::Int)
    lines = map(strip, eachsplit(chunk, r"\r?\n"))
    m = match(r"^Monkey (\d+):$", lines[1])
    Base.parse(Int, m.captures[1]; base=10) == expected_index || error("Wrong index")
    m = match(r"^Starting items: ([0-9, ]+)$", lines[2])
    items = map(i -> Base.parse(Int, i; base=10), split(m.captures[1], ','))
    m = match(r"^Operation: new = old (\+|\*) (old|\d+)", lines[3])
    (m1, m2) = m.captures
    operation = if m2 == "old"
        @assert m1 == "*"
        Operation(exp, 0)
    elseif m1 == "+"
        Operation(add, Base.parse(Int, m2; base=10))
    else
        Operation(mul, Base.parse(Int, m2; base=10))
    end
    m = match(r"^Test: divisible by (\d+)$", lines[4])
    divisor = Base.parse(Int, m.captures[1]; base=10)
    m = match(r"^If true: throw to monkey (\d+)$", lines[5])
    target_2 = Base.parse(Int, m.captures[1]; base=10) + 1
    m = match(r"^If false: throw to monkey (\d+)$", lines[6])
    target_1 = Base.parse(Int, m.captures[1]; base=10) + 1
    (Monkey(operation, Inv(divisor), (target_1, target_2)), items)
end

function parse(io::IO)
    items = Item[]
    monkeys = Monkey[]
    chunks = split(strip(read(io, String)), r"\r?\n(\r?\n)+")
    for (i, chunk) in enumerate(chunks)
        monkey, things = parse(Monkey, chunk, i-1)
        push!(monkeys, monkey)
        append!(items, (Item(i, thing) for thing in things))
    end
    if any(enumerate(monkeys)) do (i, monkey)
            !all(monkey.targets) do target
                in(target, eachindex(monkeys)) &&
                target != i
            end
        end
        error("Invalid monkey")
    end
    (monkeys, items)
end

function process!(monkey::Monkey, index::Int, items::Vector{Item}, modulo::Union{Nothing, Inv})
    inspected = 0
    @inbounds for (i, item) in enumerate(items)
        item.monkey_index == index || continue
        inspected += 1
        worry_level = monkey.operation(item.worry_level)
        worry_level = if modulo === nothing
            div(worry_level, 3)
        else
            worry_level % modulo
        end 
        target = monkey.targets[iszero(worry_level % monkey.divisor) + 1]
        items[i] = Item(target, worry_level)
    end
    inspected
end

function part(
    monkeys::Vector{Monkey},
    items::Vector{Item},
    inspections::Vector{<:Integer},
    rounds::Int,
    modulo::Union{Nothing, Inv}
)
    fill!(inspections, 0)
    item_copy = copy(items)
    for i in 1:rounds
        for i in eachindex(monkeys, inspections)
            inspections[i] += process!(monkeys[i], i, item_copy, modulo)
        end
    end
    partialsort!(inspections, 1:2; rev=true)
    inspections[1] * inspections[2]
end

solve(v::Tuple{Vector{Monkey}, Vector{Item}}) = solve(v...)
function solve(monkeys::Vector{Monkey}, items::Vector{Item})
    inspections = Vector{Int}(undef, length(monkeys))
    modulo = Inv(prod(i -> i.divisor.divisor, monkeys))
    (
        part(monkeys, items, inspections, 20, nothing),
        part(monkeys, items, inspections, 10000, modulo)
    )
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
    using JET

    data = parse(IOBuffer(TEST_INPUT))
    @test solve(data) == (10605, 2713310158)
    @test_opt solve(data)
    @test_call solve(data)
end

end # module