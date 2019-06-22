# APL
A DSL for embedding the APL programming language in Julia

```julia
using APL

julia> (1:5)*(1:5)'
5×5 Array{Int64,2}:
 1   2   3   4   5
 2   4   6   8  10
 3   6   9  12  15
 4   8  12  16  20
 5  10  15  20  25

julia> apl"(ι5) ×∘ ι5"
5×5 Array{Int64,2}:
 1   2   3   4   5
 2   4   6   8  10
 3   6   9  12  15
 4   8  12  16  20
 5  10  15  20  25
```

```julia
julia> reshape(sortperm(((1:5).+(1:5)')[:]) |> sortperm, 5, 5)
5×5 Array{Int64,2}:
  1   3   6  10  15
  2   5   9  14  19
  4   8  13  18  22
  7  12  17  21  24
 11  16  20  23  25

julia> apl"(5 5) ρ (⍋⍋, (ι5)+∘ι5)"
5×5 Array{Int64,2}:
  1   3   6  10  15
  2   5   9  14  19
  4   8  13  18  22
  7  12  17  21  24
 11  16  20  23  25
```

## REPL mode
APL.jl provides a repl mode to avoid using string macros. You can initialize the repl mode with `init_repl
```julia
julia>  init_repl()
REPL mode APL Mode initialized. Press } to enter and backspace to exit.
```
as instructed, if we press the `}` key, we enter an APL repl mode
```julia
APL_j> (5 5) ρ (⍋⍋,(ι5)+∘ι5)
5×5 Array{Int64,2}:
  1   3   6  10  15
  2   5   9  14  19
  4   8  13  18  22
  7  12  17  21  24
 11  16  20  23  25
```


### Warnings

This repository is still in the process of being updated and has many
bugs. Always make sure you properly enclose code in parentheses,
otherwise the parser can get stuck in an infite loop.