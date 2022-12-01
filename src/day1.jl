module Day1

using ..TestItems

function parse(io::IO)
    result = UInt[]
    current_sum = nothing
    for line in eachline(io)
        if isempty(line)
            if !isnothing(current_sum)
                push!(result, current_sum)
                current_sum = nothing
            end
        else
            num = Base.parse(UInt, line; base=10)
            current_sum = isnothing(current_sum) ? num : current_sum + num
        end
    end
    isnothing(current_sum) || push!(result, current_sum)
    result
end

function solve(v::AbstractVector)
    partialsort!(v, 1:3, rev=true)
    (Int(first(v)), Int(sum(view(v, 1:3))))
end

@testitem "Day1" begin
    using AoC2022.Day1: parse, solve
    using JET

    INPUT = """1000
    2000
    3000
    
    4000
    
    5000
    6000
    
    7000
    8000
    9000
    
    10000"""
    v = parse(IOBuffer(INPUT))
    @test solve(v) == (24000, 45000)
    @test_opt solve(v)
    @test_call solve(v)
end

end # module