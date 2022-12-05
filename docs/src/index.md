# AoC2022

## Installation
AoC2022 is not in the General Registry. Hence, you must install it from GitHub directly:
```julia
(@v1.8) pkg> add https://github.com/jakobnissen/aoc2022#master
```

Alternatively, you can download it and install it from a local path:
```
(@v1.8) pkg> add /path/to/aoc2022
```

## How to use
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
