module Download

import ..Downloads
import ..Dates

const DST_DIR = joinpath(dirname(@__DIR__), "data")

function get_source(day::Int)
    day in 1:25 || error()
    "https://adventofcode.com/2022/day/" * string(day) * "/input"
end

struct Session
    bytes::Vector{UInt8}
end

function Session(s::Union{String, SubString{String}})
    Session(hex2bytes(chopprefix(s, "session=")))
end

load_session(path::AbstractString) = Session(strip(read(path, String)))
header(s::Session) = Dict("cookie" => "session=$(bytes2hex(s.bytes))")

function download_data(day_iter, session::Session)
    days = unique!(sort!(vec(collect(Int, day_iter))))
    all(in(1:25), days) || error("Can only pick days in 1:25")
    mkpath(DST_DIR)
    headers = header(session)
    for day in days
        target = joinpath(DST_DIR, "day$(lpad(day, 2, '0')).txt")
        if isfile(target)
            println("Skipping existing file \"$target\"")
        else
            Downloads.download(get_source(day), target; headers=headers, timeout=10)
            println("Downloaded file to \"$target\"")
        end
    end
end

"""
    download_data(days, cookie_path::AbstractString)

Download data for the given days, given a path to the session cookie.
`days` must be an iterable of days to download.

# Examples
```julia
julia> download_data(1:3, "cookie.txt")
```
"""
function download_data(days, cookie_path::AbstractString)
    download_data(days, load_session(cookie_path))
end

# TODO: Update to 25 when this December is over
"""
    download_all(cookie_path::AbstractString)

Download data for all available days, given a path to the session cookie.

See also: [`download_data`](@ref)

# Examples
```julia
julia> download_all("cookie.txt")
[...]
```
"""
download_all(cookie_path::AbstractString) = download_data(1:Dates.day(Dates.today()), cookie_path)

end # module
