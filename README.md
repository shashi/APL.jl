# APL

**[Demo notebook](http://nbviewer.jupyter.org/gist/shashi/9ad9de91d1aa12f006c4)**

Video: [APL at Julia's Speed](https://www.youtube.com/watch?v=XVv1GipR5yU) (JuliaCon 2016)

## Implementation notes

Here's the implementation explained in brief.
    
The `apl""` string macro parses and evals an APL expression.
The parser works on the reverse of the string, and consists of a bunch of [concatenation rules](https://github.com/shashi/APL.jl/blob/06570f535862f934e3da12d238501f67b210aec6/src/parser.jl#L4-L41) defined as a generic `cons` function.

APL strings are parsed and executed to produce either a result or an object representing the APL expression.
Primitve functions are of the type `PrimFn{c}` where `c` is the character; similarly, operators are of type `Op1{c, F}` and `Op2{c, F1, F2}`, where `F`, `F1` and `F2` are types of the operand functions — these type parameters let you specialize how these objects are handled all over the place.
An optimization is simply a method defined on an expression of a specific type.

The `call` generic function can be used to make these objects callable!
The [eval-apply is really simple](https://github.com/shashi/APL.jl/blob/master/src/eval.jl) and quite elegant.
