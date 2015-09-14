
export eval_apl
import Base.call

immutable Env
    env
    α
    ω
end
eval_apl(ex) = eval_apl(ex, Env(nothing, nothing,nothing))
eval_apl(f, env) = f
eval_apl(v::JlVal, env) = v.val
eval_apl(::Α, env) = env.α
eval_apl(::Ω, env) = env.ω
eval_apl(x::Apply, env)  = eval_apl(x.f, env)(eval_apl(x.r, env))
eval_apl(x::Apply2, env) = eval_apl(x.f, env)(eval_apl(x.l, env), eval_apl(x.r, env))

mkbody1(x::Symbol) = :($x(ω))
mkbody1(x::Expr) = x
mkbody2(x::Symbol) = :($x(α, ω))
mkbody2(x::Expr) = x
for (sym, fns) in prim_fns
    mon, dya = fns
    mon != nothing && @eval call(f::PrimFn{$sym}, ω) = $(mkbody1(mon))
    dya != nothing && @eval call(f::PrimFn{$sym}, α, ω) = $(mkbody2(dya))
end

identity(::PrimFn{'+'}) = 0
identity(::PrimFn{'-'}) = 0
identity(::PrimFn{'*'}) = 1
identity(::PrimFn{','}) = [] # ...
function prefix_scan(f, x) # optimizations are just dispatch on f!
    fst = f(identity(f), x[1])
    y = Array(typeof(fst), length(x))
    y[1] = fst
    for i=2:length(y)
      y[i] =f(y[i-1], x[i])
    end
    y
end
call(op::Op1{'/'}, ω) = reduce(op.l, ω)
call(op::Op1{'\\'}, ω) = prefix_scan(op.l, ω)
call(op::Op1{'¨'}, ω) = map(op.l, ω)
call(op::Op1{'↔'}, α, ω) = op.l(ω, α)
call(op::Op2{'.'}, α, ω) = reduce(op.l, op.r(convert(Array, α), convert(Array, ω)))
call(op::Op2{'∘'}, α) = op.l(op.r(α))
