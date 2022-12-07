module Day7

import ..@testitem

mutable struct Directory
    parent::Union{Directory, Nothing}
    name::String
    subdirs::Vector{Directory}
    total_filesize::Int
end

make_root() = Directory(nothing, "/", Directory[], 0)
function Directory(parent::Directory, name::Union{String, SubString{String}})
    Directory(parent, name, Directory[], 0)
end
parent(d::Directory)::Directory = d.parent

"Make a new subdirectory if it does not exist, or return the existing directory if it does"
function mkpath(parent::Directory, name::Union{String, SubString{String}})
    existing = iterate(Iterators.filter(i -> i.name == name, parent.subdirs))
    # If there is no existing directory
    if isnothing(existing)
        new = Directory(parent, name)
        push!(parent.subdirs, new)
        new
    else
        # Else, iterating produces (directory, state), and we get the dir
        first(existing)
    end
end

# Recursive solution with lookup, in case there are circular paths
# This may hit a StackOverflow error, but it requires thousands of
# nested directories which is unlikely
get_sizes(d::Directory) = (c = IdDict{Directory, Int}(); _size(d, c); c)
function _size(d::Directory, cache)::Int
    existing = get(cache, d, nothing)
    existing === nothing || return existing
    s = mapreduce(i -> _size(i,cache), +, d.subdirs; init=d.total_filesize)
    cache[d] = s
    s
end

function parse(io::IO)
    # Check first command is `cd /`. We must have this in order to begin
    # from a root, so we only create child directories of existing dirs
    lines = Iterators.filter(!isempty, Iterators.map(rstrip, eachline(io)))
    first(lines) == "\$ cd /" || error("Expected first line to cd to root")
    root = make_root()
    cd = root
    # Store `is_ls` to check that files are only listed after an ls command
    is_ls = false
    for line in lines
        # If $ cd 
        if (m = match(r"^\$\s*cd\s+(.+)$", line); m !== nothing)
            is_ls = false
            target = first(m.captures)::AbstractString
            if target == "/"
                cd = root
            elseif target == ".."
                cd = parent(cd)
            else
                cd = mkpath(cd, target)
            end
        # If $ ls, we don't really do anything. The next lines will give us
        # the listed files, and we treat them there
        elseif (m = match(r"^\$\s*ls\s*$", line); m !== nothing)
            is_ls = true
        else
            # Currently, the only non-command output this function can parse is
            # the result of ls.
            startswith(line, '$') && error("Unknown command")
            is_ls || error("Non-command after non-ls output")
            fields = split(line)
            length(fields) == 2 || error("Cannot parse ls output")
            name = last(fields)
            if first(fields) == "dir"
                mkpath(cd, name)
            else
                cd.total_filesize += Base.parse(Int, first(fields); base=10)
            end
        end
    end
    root
end

function solve(root::Directory)
    sizes = get_sizes(root)
    p1 = sum(Iterators.filter(<(100_000), values(sizes)); init=0)
    needed_space = 30_000_000 - (70_000_000 - sizes[root])
    p2 = minimum(Iterators.filter(≥(needed_space), values(sizes)))
    (p1, p2)
end

const TEST_INPUT = raw"""$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k"""

@testitem "Day7" begin
    using AoC2022.Day7: solve, parse, TEST_INPUT
    using JET

    root = parse(IOBuffer(TEST_INPUT))
    @test solve(root) == (95437, 24933642)
    @test_opt solve(root)
    @test_call solve(root)
end

end # module