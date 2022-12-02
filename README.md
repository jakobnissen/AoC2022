# Advent of Code, 2022 in Julia

## Principles
* Input is read from files, not hardcoded into the solution.
* Parsing and solving should be separate steps for each day.
* Parsers should be reasonably fault tolerant, accepting `\r\n` and `\n` newlines,
  and trailing whitespace.
* Malformed input files should throw an error.

## How to run
* Obtain a session cookie from Advent of Code (Google how to). Save it in a file.
  For example, I saved mine to `cookie.txt`, and it looks like:

```
$ cat cookie.txt
session=2c7551c06f305d6af59423e55196deb125aaa7305055774d4e809e9dbda5d5618ab5de63fa8d3a73bbc522092d55307a944231b49a3658bc31720af6c1ff1654
```

* Launch Julia and import `AoC2022`:
```julia
julia> using AoC2022
```

* Download the data, using your cookie:
```julia
julia> download_all("cookie.txt")
```

* Individual days can be downloaded with `download_data`:
```julia
julia> download_data(1:9, "cookie.txt")
```

* You can compute and print results using `print_all()`:
```julia
julia> print_all()
```

* Alternatively, you can compute the results without printing it using `solve_all`
```julia
julia> solve_all()
```

* Individual days can be loaded and solve with the `@solve` macro:
```julia
julia> @solve 1
(69528, 206152)
```
