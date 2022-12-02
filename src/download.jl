module Download

export download_data

using Downloads: Downloads
using Dates: day, today # TODO: Remove this dep when December is over

const DST_DIR = joinpath(dirname(@__DIR__), "data")
const URL_BASE = "https://adventofcode.com/2022/day/"

struct Session
    hex::String

    function Session(s::AbstractString)
        str = lowercase(String(s))
        if startswith(s, "session=")
            str = s[9:end]
        end
        if !all(codeunits(str)) do byte
                byte in UInt8('0'):UInt8('9') || byte in UInt8('a'):UInt8('f')
            end
            error(
                "Session cookie must be 128 hex chars, ",
                "optionally beginning with \"session=\""
            )
        end
        new(str)
    end
end

header(s::Session) = Dict("cookie" => "session=$(s.hex)")
load_session(path::AbstractString) = Session(strip(read(path, String)))

function download_data(days, session::Session)
    mkpath(DST_DIR)
    days = vec(collect(Int(i)::Int for i in days))
    headers = header(session)
    for day in days
        day in 1:25 || error("Can only pick days 1:25")
        target = joinpath(DST_DIR, "day$(lpad(day, 2, '0')).txt")
        if isfile(target)
            println("Skipping existing file \"$target\"")
            continue
        else
            source = URL_BASE * string(day) * "/input"
            Downloads.download(source, target; headers=headers)
            println("Downloaded file to \"$target\"")
        end
    end
end

function download_data(days, session_path::AbstractString)
    download_data(days, load_session(session_path))
end

# TODO: Update to 25 when this December is over
download_all(cookie::AbstractString) = download_data(1:day(today()), cookie)

end # module
