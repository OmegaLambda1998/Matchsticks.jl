module Matchsticks

export MatchstickEquation
export eval_equation
export distance

const NUM_MATCHSTICK = Dict{String, UInt8}(
    #  -  1
    # | | 23
    #  -  4
    # | | 56
    #  -  7
    "0" => 0b1110111,
    "1" => 0b0010010,
    "2" => 0b1011101,
    "3" => 0b1011011,
    "4" => 0b0111010,
    "5" => 0b1101011,
    "6" => 0b1101111,
    "7" => 0b1010010,
    "8" => 0b1111111,
    "9" => 0b1111011,
    # | 1
    # - 2
    # / 3
    # \ 4
    "+" => 0b1100,
    "-" => 0b0100,
    "x" => 0b0011,
    "/" => 0b0010,
    # -
    # - 
    # /
    # \
    # \
    # /
    "=" => 0b110000,
    "≠" => 0b111000,
    "<" => 0b001100,
    ">" => 0b000011
)

abstract type MatchstickObject end

struct MatchstickInt <: MatchstickObject
    value::Int64
    num_matchsticks::UInt8
    MatchstickInt(value::Int64, num_matchsticks::UInt8) = 0 <= value <= 9 ? new(value, num_matchsticks) : error("0 ≰ $value ≰ 9")
end

function MatchstickInt(value::String)
    v = parse(Int64, value)
    return MatchstickInt(v, NUM_MATCHSTICK[value])
end

struct MatchstickOperator <: MatchstickObject
    value::String
    num_matchsticks::UInt8
    MatchstickOperator(value::String, num_matchsticks::UInt8) = occursin(value, "+-x/") ? new(value, num_matchsticks) : error("$value ∉ [\"+\", \"-\", \"x\", \"/\"]") 
end

function MatchstickOperator(value::String)
    return MatchstickOperator(value, NUM_MATCHSTICK[value])
end

struct MatchstickEquality <: MatchstickObject
    value::String
    num_matchsticks::UInt8
    MatchstickEquality(value::String, num_matchsticks::UInt8) = occursin(value, "=≠<>") ? new(value, num_matchsticks) : error("$value ∉ [\"=\", \"≠\", \"<\", \">\"]") 
end

function MatchstickEquality(value::String)
    return MatchstickEquality(value, NUM_MATCHSTICK[value])
end

struct MatchstickEquation
    n1::MatchstickInt
    o::MatchstickOperator
    n2::MatchstickInt
    e::MatchstickEquality
    n3::MatchstickInt
end

"""
    MatchstickEquation(matchsticks::String)

Takes a string of the form "n o n e n",
where "n" is an integer between 0 and 9, o is an operator in ["+", "-", "x", "/"], and e is an equality in ["=", "≠"].

This function parses that into its individual components and returns a MatchstickEquation type
"""
function MatchstickEquation(matchsticks::String)
    form = string.(split(matchsticks, " "))
    @assert length(form) == 5 "$matchsticks not of the form \"n o n e n\""
    n1 = MatchstickInt(form[1])
    o = MatchstickOperator(form[2])
    n2 = MatchstickInt(form[3])
    e = MatchstickEquality(form[4])
    n3 = MatchstickInt(form[5])
    return MatchstickEquation(n1, o, n2, e, n3)
end

function Base.string(equation::MatchstickEquation)
    n1 = equation.n1.value
    o = equation.o.value
    if o == "x"
        o = "*"
    end
    n2 = equation.n2.value
    e = equation.e.value
    if e == "="
        e = "=="
    end
    n3 = equation.n3.value
    return "$n1$o$n2$e$n3"
end

function Base.show(io::IO, equation::MatchstickEquation)
    return print(string(equation))
end

function Base.show(io::IO, m::MIME"text/plain", equation::MatchstickEquation)
    return print(string(equation))
end

function Base.length(equation::MatchstickEquation)
    n1 = count_ones(equation.n1.num_matchsticks)
    o = count_ones(equation.o.num_matchsticks)
    n2 = count_ones(equation.n2.num_matchsticks)
    e = count_ones(equation.e.num_matchsticks)
    n3 = count_ones(equation.n3.num_matchsticks)
    return n1 + o + n2 + e + n3
end

function distance(eq1::MatchstickEquation, eq2::MatchstickEquation)
    if length(eq1) != length(eq2)
        return Inf
    end
    n1 = count_ones(eq1.n1.num_matchsticks & ~eq2.n1.num_matchsticks)
    o = count_ones(eq1.o.num_matchsticks & ~eq2.o.num_matchsticks)
    n2 = count_ones(eq1.n2.num_matchsticks & ~eq2.n2.num_matchsticks)
    e = count_ones(eq1.e.num_matchsticks & ~eq2.e.num_matchsticks)
    n3 = count_ones(eq1.n3.num_matchsticks & ~eq2.n3.num_matchsticks)
    return n1 + o + n2 + e + n3
end

function eval_equation(equation::MatchstickEquation)
    return eval(Meta.parse(string(equation)))
end

end # module Matchsticks
