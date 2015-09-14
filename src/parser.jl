
include("defns.jl")

"e.g. 1 2 3"
cons(l, ::Nothing) = l

"e.g. +/"
cons{L<:Fn, c}(l::L, ::Op1Sym{c}) = Op1{c, L}(l)

"e.g. / 1 2 3"
cons{L<:Fn, c}(l::L, ::Op1Sym{c}) = Op1{c, L}(l)

"e.g. .×"
cons{c, R<:Fn}(l::Op2Sym{c}, r::R) = Op2Partial{c, R}(r)

"e.g. +⋅×"
cons{c, L<:Fn, R}(l::L, r::Op2Partial{c,R}) = Op2{c, L, R}(l, r.r)

"e.g. - 1 2 3"
cons(l::Union(Fn, Op), r::Arr) = Apply(l, r)

"e.g. .- 1 2 3"
cons(l::Union(Fn, Op), r::Apply) = Apply(cons(l, r.f), r.r)

"e.g 1 2 3 ω"
cons(a::Arr, b::Arr) = ConcArr(a,b) # is this even correct?

"e.g 1 2 3 × 1 2 3"
cons(l::Arr, r::Apply) = Apply2(r.f, l, r.r)

"e.g. /ι10"
cons{T<:Fn}(l::Op1Sym, r::Apply{T}) = Apply(l, r)

"e.g. -/ι10"
cons{T<:Fn}(l::Fn, r::Apply{T}) = Apply(l, r)

"e.g. ↔/⍬"
cons{c}(l::Op1Sym{c}, r::Union(Op1Sym,OpSymPair)) = OpSymPair{c}(r)

"e.g. ×↔/⍬"
cons{L<:Fn, c}(l::L, ops::OpSymPair{c}) = cons(Op1{c, L}(l), ops.r)

# "e.g ι3 × ι3"
# cons(l::Fn, r::Apply2) = Apply2(r.f, cons(l, r.l), r.r)

cons(x, y) = error("Invalid syntax: $x next to $y")

parse_apl(str) = parse_apl(reverse(replace(str, r"\s+", " ")), start(str), 0, 0)[1]
function parse_apl(s, i, paren_level, curly_level)
    # top-level parsing
    exp = nothing

    arity = 0

    while !done(s, i)
        c, nxt = next(s, i)
        if c == ' '
        elseif c == ')'
            subexp,nxt,plvl,clvl,arity = parse_apl(s, nxt, paren_level+1, curly_level)
            plvl != paren_level && error("Parenthesis error")
            exp = cons(subexp, exp)
        elseif c == '('
            return exp, nxt, paren_level-1, curly_level, arity
        elseif c == '}'
            fn_exp,nxt,plvl,clvl,arity = parse_apl(s, nxt, paren_level, curly_level+1)
            clvl != curly_level && error("Parenthesis error")
            exp = cons(UDefFn{arity}(fn_exp), exp)
        elseif c == '{'
            return exp, nxt, paren_level, curly_level-1,arity
        elseif c in dyadic_operators
            exp = cons(Op2Sym{c}(), exp)
        elseif c in numeric
            nums, nxt = parse_strand(s, i)
            exp = cons(JlVal(nums), exp)
        elseif c in function_names
            exp = cons(PrimFn{c}(), exp)
        elseif c in monadic_operators
            exp = cons(Op1Sym{c}(), exp)
        elseif c == 'α'
            arity = 2
            exp = cons(Α(), exp)
        elseif c == 'ω'
            arity = max(arity, 1)
            exp = cons(Ω(), exp)
        elseif c == '⍬'
            exp = JlVal(Float64[])
        else
            error("$c: undefined APL symbol")
        end
        i=nxt
    end
    exp,i,paren_level, curly_level, arity
end

function parse_strand(str, i)
    buf = IOBuffer()
    p = i
    broke = false
    scalar = true
    while !done(str, i)
        p = i
        c, i = next(str, i)
        if c == ' '
            write(buf, ',')
            scalar=false
        elseif c == '⁻'
            write(buf, '-')
        elseif c == '.'
            write(buf, '.')
        elseif c in '0':'9'
            write(buf, c)
        else
            broke = true
            break
        end
    end
    s = reverse(strip(takebuf_string(buf), ['\,']))
    parse(scalar ? s : "[$s]") |> eval, broke ? p : i
end

