module APL

export @apl_str, parse_apl, eval_apl, init_repl

include("parser.jl")
include("eval.jl")
include("show.jl")
include("repl.jl")

macro apl_str(str)
    parse_apl(str) |> eval_apl |> esc
end

__init__() = init_repl()

end # module
