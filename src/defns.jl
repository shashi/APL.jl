
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
immutable OpSymPair{c} <: Op
    r # Op1Sym
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

immutable UDefFn{arity} <: Fn
    ast
end

# Library functions
digit(V,n)=(mod(n,V),(n-mod(n,V))/V)
function ⊤(V,state) # alan's encode function
   V, state
   z=copy(V)
   for i=length(V):-1:1
        z[i], state = digit(z[i],state)
   end
   z
end
function ⊤(V,n::AbstractArray)
    V′ = convert(Array, V)
    n′ = convert(Array, n)
    reduce(vcat, [⊤(V′,nn)' for nn in n′])'
end
ι(V,W)=[v∈W ? findfirst(W,v) : 1+length(W) for v in V] 

function prefix_scan(f, x, v0) # optimizations are just dispatch on f!
    fst = f(v0, x[1])
    y = Array(typeof(fst), length(x))
    y[1] = fst
    for i=2:length(y)
      y[i] =f(y[i-1], x[i])
    end
    y
end

# More definitions
const prim_fns = [
  ( '+', (:+, :+)),
  ( '-', (:-, :-)),
  ( '÷', (:(1/ω), :/)),
  ( '×', (:sign, :(α.*ω))),
  ( '⌈', (:ceil, :max)),
  ( '⌊', (:floor, :min)),
  ( ',', (:(ω[:]), :vcat)),
  ( '*', (:exp, :(.^))),
  ( '!', (:factorial, :(factorial(ω) / (factorial(α) * factorial(ω-α))))), # Factorial on floats
  ( '|', (:abs, :(ω%α))),    
  ( '⊛', (:log, :log)),
  ( '○', (:(π*ω), nothing)),
  ( '~', (:!, nothing)),
  ( '⌹', (:inv, :\)),
  ( 'ι', (:(1:ω[1]), :(ι(α, ω)))), # ω[1] is not really right
  ( '?', (:(rand(1:ω[1])), nothing)),
  ( '>', (nothing, :(.>))),
  ( '<', (nothing, :(.<))),
  ( '=', (nothing, :(.==))),
  ( '≠', (nothing, :(.!=))),
  ( '≤', (nothing, :≤)),
  ( '≥', (nothing, :≥)),
  ( '∧', (nothing, :&)),
  ( '∨', (nothing, :|)),
  ( ']', (nothing, :(getindex(ω, α)))),
  ( '⊤', (nothing, :⊤)),
  ( '⍋', (:sortperm, nothing)),
  ( '⍒', (:(sortperm(ω, rev=true)), nothing)),
  ( 'ρ', (:([size(ω)...]), :(reshape(ω, tuple(α...))))),
  ( '⍉', (:(ω.'), :permutedims)),
  ( '⌽', (:(flipdim(ω, 1)), nothing)),
  ( '↓', (nothing, :(ω[α+1:length(ω)]))),
  ( '↑', (nothing, :(ω[1:α]))),
]
const function_names = map(x->x[1], prim_fns)
const numeric = ['⁻', ' ', '0':'9'..., '.']
const monadic_operators = ['\\', '/', '⌿', '⍀', '¨', '↔', '∘', '⍨']
const dyadic_operators = ['.', '⋅']
const argnames = ['α', 'ω']

# Identity elements
identity{T}(::PrimFn{'+'}, ω::Type{T}) = zero(T)
identity(::PrimFn{'+'}, ω::Type{Bool}) = 0
identity(::PrimFn{'-'}, ω::Type{Bool}) = 0
identity{T}(::PrimFn{'-'}, ω::Type{T}) = zero(T)
identity{T}(::PrimFn{'×'}, ω::Type{T}) = one(T)
identity{T}(::PrimFn{'×'}, ω::Type{T}) = one(T)
identity{T}(::PrimFn{'∨'}, ω::Type{T}) = zero(T)
identity{T}(::PrimFn{'∧'}, ω::Type{T}) = one(T)
identity{T}(::PrimFn{'⌈'}, ω::Type{T}) = typemin(T)
identity{T}(::PrimFn{'⌊'}, ω::Type{T}) = typemax(T)
identity{T}(::PrimFn{'='}, ω::Type{T}) = true
identity{T}(::PrimFn{','}, ω::Type{T}) = [] # ...
identity{T}(op::Op1, ω::Type{T}) = identity(op.l, ω)
identity{T}(x,y::T) = error("Could not determine the identity element for the operation $(x) for argtype $T")
