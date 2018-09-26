import Base.show

show(io::IO, ::Α) = write(io, "α")
show(io::IO, ::Ω) = write(io, "ω")
show(io::IO, jl::JlVal) = write(io, join(map(string, jl.val), ' '))
function show(io::IO, a::Apply)
    write(io, '(')
    show(io, a.f)
    write(io, ' ')
    show(io, a.r)
    write(io, ')')
end
function show(io::IO, a::Apply2)
    write(io, '(')
    show(io, a.l)
    write(io, ' ')
    show(io, a.f)
    write(io, ' ')
    show(io, a.r)
    write(io, ')')
end
function show(io::IO, a::Op2{c}) where c
    write(io, '(')
    show(io, a.l)
    write(io, c)
    show(io, a.r)
    write(io, ')')
end
function show(io::IO, a::Op1{c}) where c
    write(io, '(')
    show(io, a.l)
    write(io, c)
    write(io, ')')
end
show(io::IO, a::ConcArr) = (show(io, a.l); write(io, ' '); show(io, a.r))
show(io::IO, a::PrimFn{c}) where {c} = write(io, c)
show(io::IO, f::UDefFn) = (write(io, '{'); show(io, f.ast); write(io, '}'))
