module APL

export @apl_str, parse_apl, eval_apl

include("parser.jl")
include("eval.jl")
include("show.jl")

macro apl_str(str)
    parse_apl(str) |> eval_apl |> esc
end

end # module
