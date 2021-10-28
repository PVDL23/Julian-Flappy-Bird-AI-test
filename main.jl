#TODO:
#===
Add Score
make UI better
===#

#====================
Imports
====================#

include("agent.jl")
include("geneticAlgorithm.jl")
include("neuralNetwork.jl")
include("pipe.jl")

using Luxor
using MiniFB

# #====================
# Structs
# ====================#

Base.@kwdef mutable struct FlappyBirdAI
    running::Bool = true
    deadAgents::Int64 = 0
    agents::Vector{Agent}
    geneticAlgorithm::GeneticAlgorithm
    generation::Int64 = 1
    sortedAgents::Vector{Agent}
end

#====================
Create functions
====================#

function create_Ai(numberOfAgents)
    agents = Vector{Agent}(undef, numberOfAgents)
    for i = 1:numberOfAgents
        agents[i] = create_agent()
    end

    numberOfBiases = getNumberOfBiases(agents[1].neuralNet)
    NumberOfWeights = getNumberOfWeights(agents[1].neuralNet)

    geneticAlgorithm = create_geneticAlgorithm(numberOfAgents, NumberOfWeights, numberOfBiases)

    for i = 1:numberOfAgents
        setWeights!(agents[i].neuralNet, geneticAlgorithm.population[i].weights)
        setBiases!(agents[i].neuralNet, geneticAlgorithm.population[i].biases)
    end

    sorted = sort(agents)

    FlappyBirdAI(; agents=agents, geneticAlgorithm=geneticAlgorithm, sortedAgents=sorted)
end

function run(AI::FlappyBirdAI)
    width = 400
    height = 700

    mfb_set_target_fps(60)
    
    window = mfb_open_ex("Flappy Bird", width, height, false)

    pipes = reset(height, width)

    @info "Generation: $(AI.generation)"

    while AI.running && mfb_wait_sync(window)
        if passedPipe(AI, pipes)
            pipes = reset(height, width)
        end
        update!(pipes)
        if update!(AI, pipes)
            pipes = reset(height, width)
        end
        buffer = draw(AI, pipes, width, height)
        state = mfb_update(window, permutedims(buffer, (2, 1)))
        if state != MiniFB.STATE_OK
            AI.running = false
        end
    end
    mfb_close(window)
end

function update!(AI::FlappyBirdAI, pipe::Pipes)
    for agent in AI.agents
        if update!(agent, pipe)
            AI.deadAgents += 1
        end
    end

    if AI.deadAgents == length(AI.agents)
        sort!(AI.agents; rev = true)
        @info "Fittness: $(AI.agents[1].fitness)"
        @info "Generation: $(AI.generation)"
        update!(AI.geneticAlgorithm, AI.agents)
        AI.deadAgents = 0
        AI.generation += 1
        upgrade!(AI.geneticAlgorithm)
        for (i, agent) in enumerate(AI.agents)
            reset!(agent)
            setWeights!(agent.neuralNet, AI.geneticAlgorithm.population[i].weights)
            setBiases!(agent.neuralNet, AI.geneticAlgorithm.population[i].biases)
        end
        return true
    end
    return false
end

function passedPipe(AI::FlappyBirdAI, pipes::Pipes)
    if pipes.top.x+pipes.top.width < AI.agents[1].x
        for (i, agent) in enumerate(AI.agents)
            if agent.isAlive
                updateScore!(agent)
            end
        end
        return true
    end
    return false
end
                

function draw(AI::FlappyBirdAI, pipes::Pipes, width, height)
    sorted = sort(AI.agents; rev = true)
    buffer = @imagematrix begin
        origin(Point(0,0)) # resets origin to top left
        background("black")
        fontsize(20)
        sethue("yellow")
        draw(AI.agents)
        sethue("red")
        # draw best agent
        draw(sorted[1])
        sethue("green")
        draw(pipes)
        sethue("white")
        text(string("score: ", sorted[1].score), 
            boxtop(BoundingBox(;centered=false)*0.9))
    end width height
    return buffer
end

AI = create_Ai(90)
run(AI)