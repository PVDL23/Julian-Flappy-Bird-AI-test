#====================
Imports
====================#

include("neuralNetwork.jl")
include("pipe.jl")
using Luxor
import Base: isless

#====================
Structs
====================#

Base.@kwdef mutable struct Agent
    x::Int64 = 75
    y::Int64 = 200
    width::Int64 = 20
    height::Int64 = 20
    neuralNet::NeuralNetwork = create_network([5, 10, 1])
    inputs::Vector{Float64} = Vector{Float64}(undef, 5)
    isAlive::Bool = true
    fitness::Float64 = 0
    velocity_y::Float64 = 0
    gravity::Float64 = 0.3 # 0.3
    flap_strength::Float64 = 6.5 #6.5
    score::Int64 = 0
end

#====================
Create functions
====================#

function create_agent()
    Agent()
end


# #====================
# Agent functions
# ====================#

function reset!(agent::Agent)
    agent.y = 200
    agent.isAlive = true
    agent.fitness = 0
    agent.velocity_y = 0
end

function flap!(agent::Agent)
    agent.velocity_y = -agent.flap_strength
end

function update!(agent::Agent)
    uy = agent.velocity_y
    agent.velocity_y += agent.gravity
    agent.y += Int(round((uy + agent.velocity_y) / 2))
    agent.x = 75
end

function update!(agent::Agent, pipe::Pipes)
    if !(agent.isAlive)
        return false
    end

    update!(agent)    

    agent.inputs[1] = agent.y
    agent.inputs[2] = abs(agent.y - pipe.bottom.y)
    agent.inputs[3] = abs(agent.y - pipe.top.height)
    agent.inputs[4] = abs(pipe.top.x - agent.x)
    agent.inputs[4] = agent.velocity_y

    if collide(agent, pipe.top) || collide(agent, pipe.bottom)
        agent.isAlive = false
        return true
    elseif !(0 < agent.y < 720)
        agent.isAlive = false
        return true
    end

    outputs = update(agent.neuralNet, agent.inputs)[1]
    if outputs >0.9
        flap!(agent)
    end

    agent.fitness += 1
    return false
end

updateScore!(agent::Agent) = agent.score += 1

#====================
Draw functions
====================#

function draw(agent::Agent)
    if agent.isAlive
        rect(Point(agent.x, agent.y), agent.width, agent.height, :fill)
    end
end

function draw(agents::Vector{Agent})
    for agent in agents
        draw(agent)
    end
end

function collide(agent::Agent, pipe::PIPE)
    return agent.x < pipe.x + pipe.width &&
        agent.y < pipe.y + pipe.height &&
        agent.x + agent.width > pipe.x &&
        agent.y + agent.height > pipe.y
end

isless(a::Agent, b::Agent) = isless(a.fitness, b.fitness)