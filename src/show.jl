import Base.show

show(io::IO, ::Α) = write(io, "α")
show(io::IO, ::Ω) = write(io, "ω")
show(io::IO, jl::JlExpr) = write(io, join(map(string, eval(jl.exp)), ' '))
show(io::IO, a::Apply) = (show(io, a.f); write(io, ' '); show(io, a.r))
function show(io::IO, a::Apply2)
    show(io, a.l)
    write(io, ' ')
    show(io, a.f)
    write(io, ' ')
    show(io, a.r)
end
function show{c}(io::IO, a::Op2{c})
    write(io, '(')
    show(a.l)
    write(io, c)
    show(a.r)
    write(io, ')')
end
function show{c}(io::IO, a::Op1{c})
    write(io, '(')
    show(a.l)
    write(io, c)
    write(io, ')')
end
show(io::IO, a::ConcArr) = (show(io, a.l); write(io, ' '); show(io, a.r))
show{c}(io::IO, a::PrimFn{c}) = write(io, c)
