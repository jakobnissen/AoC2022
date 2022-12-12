## Day 1
I sum each chunk during parsing, such that the input is parsed to a `Vector{<:Integer}`.
That may be considered cheating, but whatever.
It's awkward to efficiently represent a `Vector{<:Vector{<:Integer}}`.

## Day 2
I parse my move and my opponent's move for both p1 and p2 at the same time, into a `Vector{NTuple{3, Choice}}`, `Choice` being an enum.
To get the score for each round, I look up into a table. This can't vectorize, but I find playing with `mod` is too magical here.

## Day 3
I parse each line (a `RuckSack`) into two bitsets - one for each half. Since there are only 52 letters, 64-bit integers will do for the sets.
The parser then emits `NTuple{3, RuckSack}`.
The solution is straightforwardly expressed as bitwise operations + `trailing_zeros` (which maps onto a tzcnt instruction). This is extremely fast.

## Day 4
I parse each line to `NTuple{2, UnitRange}`. To improve parsing speed, I implement my own `split_once`, which really ought to be in `Base` Julia.
Computing whether ranges overlap can easily be done only looking at the endpoints of each range. The implementation is generic.

## Day 5
Parsing absolutely sucks for this, especially because the problem does not specify that each tower is listed from 1:N. My solution assumes the towers can have arbitrary integer names.
Regex to the rescue. The tower is parsed into `Dict{<:Integer, <:Vector}`, they keys being the name of the tower. Each vector is bottom-up, so the top can be added and removed with `push!` and `pop!`.
When parsing moves, I use a regex, then parsed into an `NTuple{3, Integer}`.
To move in part 1, I `append!` to the target and truncate the source, then reverse the appended bit. For part 2, I simply don't reverse. 

## Day 6
Parsing this is trivial. I simply strip the input line and check it's only composed of `'a':'z'`, then put it into a struct.
For each part, I keep a length 26 vector with one element for each possible letter. In it, I store the last index where the given letter was seen. We keep track of the remaining letters needed before N distinct letters is seen. For each letter, we look up in the vector where it was last seen, and update `remaining` accordingly. If `remaining` reaches 0, it returns. Hence, the cost does not scale with N, but is linear for each letter examined.

## Day 7
Parsing is tough here. I parse into a `Directory` structure, which contain a name, a link to a parent, a vector of subdirectories, and the sum of sizes of files in that dir.
A recursive function can then easily and effectively get the total size of each directory.

## Day 8
Parse to `Matrix{<:Integer}`. Every solution can be computed by taking views of a single column or row into the matrix (reversed and not), and keeping a scratch vector for the computation. In other words, the computation of each col/row vector is independent. These view needs to be takes for every row and column, in both direction of the matrix, and then accumulated into a destination matrix.
The solution is similar to mapreduce:
* `f` is the function that, given a vector view and a scratch buffer, fills in the vector view
* `op` is the operation that accumulate into the destination vector: `|` for p1, and `*` for p1.
* The iterable is the rows/cols of the destination vector and input vector.

For part 2, I use a trick similar to day 6, keeping a list of the last index where a tree of a given height is. This makes the solution for this day scale linearly with the number of elements in the matrix.

## Day 9
Straightforward parsing into `Vector{<:Tuple{Direction, Integer}}`, where `Direction` is an enum. The trick is that the tail always moves `(sign(dy), sign(dx))` relative to the head, unless it'll end up on top of the head.
Visited positions is kept track of in a `Set`.

For part 2, whenever a knot in the tail didn't move, the rest of the rope can be skipped that iteration.

As another optimisation, the last position of the tail can be kept track of in a variable. Only add it to the `Set` if it did move, to cut down on the number of set operations, which are slow.

## Day 10
I parse into a `Vector{<:Union{Nothing, <:Integer}}`. The processor can be simulated very efficiency by directly looping over each cycle.
The screen is `Vector{Bool}`.
I make a function `avance`, which given a `State` struct advances exactly `N` cycles, returning a new `State`. This means that during the inntermost loop, there is no need to keep track of whether the cycle number is one of the threshold numbers.

## Day 11
This one was tough to parse and optimise.
Parsing is done with lots of regex, and assuming the lines are in the same order all the time. Seems inefficient, but is quite fast.

Each monkey is modeled as a `mutable struct`, containing its own items. This allows you to loop over the items of each monkey directly. The monkey's operation is stored in a custom `Operation` struct which can only square, multiply and add. This prevents dynamic dispatch, trading away generality.

Instead of computing modulo directly, compute a `MultiplicativeInverse` for each monkey, and for the product of the monkeys' divisors. This speeds up modulo operations.

Because `push!` is slow in Julia, each monkey's item vector is resized to be able to hold all items, and the actual number of items in the array is kept track of by an integer stored in the monkey. This prevents calling into C to resize any arrays.

A total of ~750,000 items are examined, and each examination is necessarily serial and takes multiple steps. To get below 1 ms, each item need to take only ~1 ns.

In order to get this down below 1 ms, it will be necessary to exploit that each item follows a cycle. Compute the cycle for each item.

## Day 12
Parse into `Matrix{<:Integer}`, as well as `CartesianIndex` for start and end points. Straightforward dynamic programming approach similar to Smith-Waterman as taught to me in bioinformatics class: It takes 0 steps to reach the starting point. The neighbors of all points reachable in N steps are reachable in N+1 steps. Start from 0 until the end point is reached.

The queue of upcoming points to process is stored in a `Vector`. This creates some duplicate work, but it's much faster than using `Set`s, as each point is cheap to compute.

Return as soon as the end point is found.
