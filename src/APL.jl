module APL

export @apl_str, parse_apl, eval_apl

include("defns.jl")
include("parser.jl")
include("show.jl")
include("eval.jl")

macro apl_str(str)
    parse_apl(str) |> eval_apl |> esc
end

end # module
