
digit(V,n)=(mod(n,V),(n-mod(n,V))/V)
function ⊤(V,state) # alan wrote this!
   z=copy(V)
   for i=length(V):-1:1
        z[i], state = digit(z[i],state)
   end
   z
end
⊤(V,n::Array)=[[⊤(V,nn)' for nn in n]...]'
const prim_fns = [
  ( '+', (:+, :+)),
  ( '-', (:-, :-)),
  ( '÷', (:(1/ω), :/)),
  ( '×', (:sign, :(α.*ω))),
  ( '⌈', (:ceil, :max)),
  ( '⌊', (:floor, :min)),
  ( '*', (:exp, :^)),
  ( '!', (:factorial, :(factorial(ω) / (factorial(α) * factorial(ω-α))))), # Factorial on floats
  ( '|', (:abs, :(ω%α))),    
  ( '⊛', (:log, :log)),
  ( '○', (:(π*ω), nothing)),
  ( '~', (:!, nothing)),
  ( '⌹', (:inv, :\)),
  ( 'ι', (:(1:ω[1]), :(find(α, ω)))), # ω[1] is not really right
  ( '?', (:(rand(1:ω[1])), nothing)),
  ( '>', (nothing, :>)),
  ( '<', (nothing, :<)),
  ( '=', (nothing, :(.==))),
  ( '≠', (nothing, :(.!=))),
  ( '≤', (nothing, :≤)),
  ( '≥', (nothing, :≥)),
  ( '∧', (nothing, :&)),
  ( '∨', (nothing, :|)),
  ( '⊃', (nothing, :getindex)),
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
const monadic_operators = ['\\', '/', '⌿', '¨', '↔', '∘']
const dyadic_operators = ['.', '⋅']
const argnames = ['α', 'ω']

