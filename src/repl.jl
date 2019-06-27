using ReplMaker

function apl_reader(str)
    parse_apl(str) |> eval_apl
end

function init_repl(; prompt_text="julia-APL> ", prompt_color = :red, start_key = ">", sticky=true)
    ReplMaker.initrepl(str -> eval_apl(parse_apl(str)),
	               repl = Base.active_repl,
	               prompt_text = prompt_text,
	               prompt_color = prompt_color,
	               start_key = start_key,
                       sticky_mode=sticky,
	               mode_name = "APL Mode")
end
