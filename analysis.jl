using Matchsticks
using CairoMakie
CairoMakie.activate!(type = "svg")

function find_all_equations()
    ints = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    operators = ["+", "-", "x", "/"]
    equalities = ["=", "≠", "<", ">"]
    equations = Dict{Int64, Vector{MatchstickEquation}}()
    for n1 in ints, o in operators, n2 in ints, e in equalities, n3 in ints
        eq = MatchstickEquation("$n1 $o $n2 $e $n3")
        if eval_equation(eq)
            l = length(eq)
            if !(l in keys(equations))
                equations[l] = Vector{MatchstickEquation}()
            end
            push!(equations[l], eq)
        end
    end
    return equations
end

function plot_histogram(equations)
    fig = Figure()
    ax = Axis(fig[1, 1])
    bins = sort(collect(keys(equations)))
    values = [length(equations[b]) for b in bins]
    @show bins
    @show values
    barplot!(bins, values; bar_labels = :y)
    ax.xlabel = "Number of Matchsticks"
    ax.ylabel = "Number of Valid Equations"
    save("Histogram.svg", fig)
end

function plot_heatmap(equations)
    x = sort(collect(keys(equations)))
    y = collect(1:maximum(x)) 
    z = log10.([num_moves < n ? sum([1 for eq1 in equations[n], eq2 in equations[n] if distance(eq1, eq2) == num_moves]) : Inf for n in x, num_moves in y])
    z = replace(z, Inf => -1, -Inf => 0)
    @show x
    @show y
    @show z
    fig = Figure()
    ax = Axis(fig[1, 1])
    hm = heatmap!(x, y, z)
    ax.xlabel = "Number of Matchsticks"
    ax.ylabel = "Number of Moves"
    Colorbar(fig[:, end+1], hm, label="Log10 Number of Valid Equations")
    save("Heatmap.svg", fig)
end

function main()
    @info "Finding all equations"
    equations = find_all_equations()
    num_matchsticks = sort(collect(keys(equations)))
    @show minimum(num_matchsticks)
    @show maximum(num_matchsticks)
    @show sum([length(equations[n]) for n in num_matchsticks])
    @info "Plotting histogram"
    plot_histogram(equations)
    @info "Plotted histogram"
    @info "Plotting heatmap"
    plot_heatmap(equations)
    @info "Plotted heatmap"
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
