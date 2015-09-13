module APL

export @apl_str, parse_apl

include("parser.jl")
include("show.jl")

macro apl_str(str)
    parse_apl(str) |> esc
end

end # module
