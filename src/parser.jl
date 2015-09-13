abstract Arr
abstract Op
abstract Fn

immutable Α <: Arr end
immutable Ω <: Arr end
immutable Const <: Arr
    exp
end
immutable Apply <: Arr # This could both be a funciton or an array....
    f::Union(Fn, Op)
    r::Arr
end
immutable Apply2 <: Arr
    f::Union(Fn, Op)
    l::Arr
    r::Arr
end
immutable JlExpr <: Arr
    exp
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

"e.g. ⋅- 1 2 3"
cons(l::Union(Fn, Op), r::Apply) = Apply(cons(l, r.f), r.r)

"e.g 1 2 3 ω"
cons(a::Arr, b::Arr) = ConcArr(a,b) # LOL

"e.g 1 2 3 × 1 2 3"
cons(l::Arr, r::Apply) = Apply2(r.f, l, r.r)

cons(x, y) = error("Invalid syntax: $x next to $y")

const numeric = ['⁻', ' ', '0':'9'..., '.']
const monadic_operators = ['\\', '/']
const diadic_operators = ['⋅']
const functions = ['+', '-', '|', '>', '≥', '≤', '≠', '*', '×', ',']
const argnames = ['α', 'ω']

function parse_apl(str)
    # top-level parsing
    isempty(str) && return rhs
    s = reverse(str)
    i = start(s)
    exp = nothing

    while !done(s, i)
        c, nxt = next(s, i)
        if c in numeric
            nums, nxt = parse_strand(s, i)
            exp = cons(JlExpr(nums), exp)
        elseif c in functions
            exp = cons(PrimFn{c}(), exp)
        elseif c in monadic_operators
            exp = cons(Op1Sym{c}(), exp)
        elseif c in diadic_operators
            exp = cons(Op2Sym{c}(), exp)
        elseif c == 'α'
            exp = cons(Α(), exp)
        elseif c == 'ω'
            exp = cons(Ω(), exp)
        else
            error("$c: undefined symbol")
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
    parse("[" * reverse(strand) * "]"), broke ? p : i
end

