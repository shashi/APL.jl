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
 #( '⌹', (:nonce, nonce)),
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
  ( 'ρ', (:([size(ω)...]), :(reshape(ω, tuple(α...))))),
]
const function_names = map(x->x[1], prim_fns)
const numeric = ['⁻', ' ', '0':'9'..., '.']
const monadic_operators = ['\\', '/', '¨', '↔']
const dyadic_operators = ['.', '∘']
const argnames = ['α', 'ω']

