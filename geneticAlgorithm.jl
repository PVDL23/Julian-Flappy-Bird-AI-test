using Random
import Base: isless
#====================
Structs
====================#

Base.@kwdef mutable struct Genome
    fitness::Float64 = 0
    weights::Vector{Float64}
    biases::Vector{Float64}
end

mutable struct GeneticAlgorithm
    populationSize::Int64
    population::Vector{Genome}
    numberOfWeights::Int64
    numberOfBiases::Int64
end

#====================
Create functions
====================#

create_genome(weights, biases) =  Genome(; weights, biases)

function create_geneticAlgorithm(populationSize, numberOfWeights, numberOfBiases)
    population = Vector{Genome}(undef, populationSize)
    for i = 1:populationSize
        initialWeights = vec(random_uniform(-1, 1, numberOfWeights))
        initialBiases = vec(random_uniform(-1, 1, numberOfBiases))
        population[i] = create_genome(initialWeights, initialBiases)
    end
    GeneticAlgorithm(populationSize, population, numberOfWeights, numberOfBiases)
end

#====================
Genome functions
====================#

function mutate!(G::Genome)
    mutationRate = 0.1
    for i = 1:length(G.weights)
        if rand() < mutationRate
            G.weights[i] += random_uniform(-1, 1) * 0.2
        end
    end

    for i = 1:length(G.biases)
        if rand() < mutationRate
            G.biases[i] += random_uniform(-1, 1) * 0.2
        end
    end
end

#====================
GeneticAlgorithm functions
====================#

function getGenomeByTournament(GA::GeneticAlgorithm)
    tournamentSize = 4
    combatants = randperm(GA.populationSize)[1:tournamentSize]
    sort!(combatants)
    GA.population[first(combatants)] # fittest genome
end

function crossover(GA::GeneticAlgorithm, parent1::Genome, parent2::Genome)
    crossoverRate = 0.95
    parents = vec([parent1, parent2])
    if rand() > 0.5
        reverse!(parents)
    end

    if rand() < crossoverRate
        randomWeightIndex = randomInt(1, GA.numberOfWeights)
        randomBiasIndex = randomInt(1, GA.numberOfBiases)
        child = create_genome(
                    Vector{Float64}(undef, GA.numberOfWeights),
                    Vector{Float64}(undef, GA.numberOfBiases)
                    )
        child.weights[1:randomWeightIndex] = parents[1].weights[1:randomWeightIndex]
        child.weights[randomWeightIndex+1:end] = parents[2].weights[randomWeightIndex+1:end]
        child.weights[1:randomBiasIndex] = parents[1].weights[1:randomBiasIndex]
        child.weights[randomBiasIndex+1:end] = parents[2].weights[randomBiasIndex+1:end]                

        return child
    else
        return deepcopy(parents[1])
    end
end

function update!(GA::GeneticAlgorithm, agents)
    for (i, agent) in enumerate(agents)
        GA.population[i].fitness = agent.fitness
    end
end

function upgrade!(GA::GeneticAlgorithm)
    sort!(GA.population; rev = true)
    fitnessList = [population.fitness for population in GA.population[1 : 5]]
    println(fitnessList)

    newPopulation = Vector{Genome}(undef, GA.populationSize)
    newPopulation[1] = GA.population[1]
    newPopulation[2] = GA.population[2]
    newPopulation[3] = GA.population[3]
    newPopulation[4] = crossover(GA, GA.population[1], GA.population[2])
    newPopulation[5] = crossover(GA, GA.population[1], GA.population[3])
    newPopulation[6] = crossover(GA, GA.population[2], GA.population[3])

    for i = 7:GA.populationSize
        parent1 = getGenomeByTournament(GA)
        parent2 = getGenomeByTournament(GA)
        newPopulation[i] = crossover(GA, parent1, parent2)
    end

    for i = 1:GA.populationSize
        mutate!(newPopulation[i])
    end

    GA.population = newPopulation
end

#====================
Helper functions
====================#

isless(a::Genome, b::Genome) = isless(a.fitness, b.fitness)

random_uniform(min, max) =  rand(min:1e-8:max)

random_uniform(min, max, n) = rand(min:1e-8:max, 1, n)

randomInt(min, max) = rand(min:max)