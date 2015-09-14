
export eval_apl
import Base.call

# eval
eval_apl(ex) = eval_apl(ex, nothing, nothing)
eval_apl(f, α, ω) = f
eval_apl(v::JlVal, α, ω) = v.val
eval_apl(::Α, α, ω) = α
eval_apl(::Ω, α, ω) = ω
eval_apl(x::Apply, α, ω)  = eval_apl(x.f, α, ω)(eval_apl(x.r, α, ω))
eval_apl(x::ConcArr, α, ω)  = vcat(eval_apl(x.l, α, ω), eval_apl(x.r, α, ω))
eval_apl(x::Apply2, α, ω) = eval_apl(x.f, α, ω)(eval_apl(x.l, α, ω), eval_apl(x.r, α, ω))

# call methods for primitive functions
mkbody1(x::Symbol) = :($x(ω))
mkbody1(x::Expr) = x
mkbody2(x::Symbol) = :($x(α, ω))
mkbody2(x::Expr) = x
for (sym, fns) in prim_fns
    mon, dya = fns
    mon != nothing && @eval call(f::PrimFn{$sym}, ω) = $(mkbody1(mon))
    dya != nothing && @eval call(f::PrimFn{$sym}, α, ω) = $(mkbody2(dya))
end

# call methods for primitive operators
call(op::Op1{'/'}, ω) = reducedim(op.l, ω, ndims(ω), identity(op.l, eltype(ω))) # wow Base.reducedim is a mess
call(op::Op1{'⌿'}, ω) = reducedim(op.l, ω, 1, identity(op.l, eltype(ω)))
call(op::Op1{'\\'}, ω) = prefix_scan(op.l, ω, identity(op.l, ω))
call(op::Op1{'⍀'}, ω) = prefix_scan(op.l, ω, identity(op.l, ω)) # Todo
call(op::Op1{'¨'}, ω) = map(op.l, ω)
call(op::Op1{'↔'}, α, ω) = op.l(ω, α)
call(op::Op1{'⍨'}, α, ω) = op.l(ω, α)
call(op::Op2{'.'}, α, ω) = reduce(op.l, op.r(convert(Array, α), convert(Array, ω)))
call(op::Op2{'⋅'}, α) = op.l(op.r(α)) # compose
call(op::Op1{'∘'}, α, ω) = [op.l(x, y) for x in α, y in ω]

# user defined functions
call(fn::UDefFn{0}) = eval_apl(fn.ast)
call(fn::UDefFn{1}, ω) = eval_apl(fn.ast, nothing, ω)
call(fn::UDefFn{2}, α, ω) = eval_apl(fn.ast, α, ω)
