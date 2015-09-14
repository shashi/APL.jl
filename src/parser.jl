abstract Arr
abstract Op
abstract Fn

immutable Α <: Arr end
immutable Ω <: Arr end
immutable Apply{T} <: Arr # This could both be a funciton or an array....
    f::T
    r::Arr
end
immutable Apply2{T} <: Arr
    f::T
    l::Arr
    r::Arr
end
immutable JlVal <: Arr
    val
end

immutable Op1Sym{c} <: Op end

immutable Op1{c, L} <: Fn
    l::L
end

immutable Op2Sym{c} <: Op end
immutable Op2Partial{c, R} <: Op
    r::R
end
immutable Op2{c, L, R} <: Fn
    l::L
    r::R
end

immutable ConcArr <: Arr
    l
    r
end

immutable PrimFn{c} <: Fn end

immutable UDefFn{arity}
    ast
end

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

"e.g ι3 × ι3"
cons(l::Fn, r::Apply2) = Apply2(r.f, cons(l, r.l), r.r)

cons(x, y) = error("Invalid syntax: $x next to $y")

function parse_apl(str)
    # top-level parsing
    isempty(str) && return rhs
    s = reverse(str)
    i = start(s)
    exp = nothing

    arity = 0

    while !done(s, i)
        c, nxt = next(s, i)
        if c == ' '
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
            arity = 1
            exp = cons(Ω(), exp)
        else
            error("$c: undefined APL symbol")
        end
        i=nxt
    end
    exp
end

function parse_strand(str, i)
    buf = IOBuffer()
    p = i
    broke = false
    while !done(str, i)
        p = i
        c, i = next(str, i)
        if c == ' '
            write(buf, ',')
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
    strand = strip(takebuf_string(buf), ['\,'])
    parse("[" * reverse(strand) * "]") |> eval, broke ? p : i
end

