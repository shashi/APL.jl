
abstract type Arr end
abstract type Op end
abstract type Fn end

struct Α <: Arr end
struct Ω <: Arr end
struct Apply{T} <: Arr # This could both be a funciton or an array....
    f::T
    r::Arr
end
struct Apply2{T} <: Arr
    f::T
    l::Arr
    r::Arr
end
struct JlVal <: Arr
    val
end

struct Op1Sym{c} <: Op end

struct Op1{c, L} <: Fn
    l::L
end
struct OpSymPair{c} <: Op
    r # Op1Sym
end

struct Op2Sym{c} <: Op end
struct Op2Partial{c, R} <: Op
    r::R
end
struct Op2{c, L, R} <: Fn
    l::L
    r::R
end

struct ConcArr <: Arr
    l
    r
end

struct PrimFn{c} <: Fn end

struct UDefFn{arity} <: Fn
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
ι(V,W)=[v∈W ? findfirst(isequal(v), W) : 1+length(W) for v in V] 

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
  ( '+', (:.+, :.+)),
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
  ( '⍉', (:(x->permutedims(x, ntuple(i->ndims(x) - i + 1, ndims(x)))), :permutedims)),
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
identity(::PrimFn{'+'}, T::Type) = zero(T)
identity(::PrimFn{'+'}, ::Type{Bool}) = 0
identity(::PrimFn{'-'}, ::Type{Bool}) = 0
identity(::PrimFn{'-'}, T::Type) = zero(T)
identity(::PrimFn{'×'}, T::Type) = one(T)
identity(::PrimFn{'∨'}, T::Type) = zero(T)
identity(::PrimFn{'∧'}, T::Type) = one(T)
identity(::PrimFn{'⌈'}, T::Type) = typemin(T)
identity(::PrimFn{'⌊'}, T::Type) = typemax(T)
identity(::PrimFn{'='}, T::Type) = true
identity(::PrimFn{','}, T::Type) = [] # ...
identity(op::Op1, T::Type) = identity(op.l, T)
identity(x,T::Type) = error("Could not determine the identity element for the operation $(x) for argtype $T")
