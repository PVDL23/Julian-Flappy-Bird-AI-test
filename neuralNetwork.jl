#====================
Structs
====================#

Base.@kwdef mutable struct Neuron
    numberOfInputs::Int64 = 0
    weights::Vector{Float64} = vec(random_uniform(-1, 1, numberOfInputs))
    bias::Float64 = random_uniform(-1, 1)
end

struct Layer
    numberOfNeurons::Int64
    numberOfInputsPerNeuron::Int64
    neurons::Vector{Neuron}
end

struct NeuralNetwork
    layerSizes::Vector{Int64}
    numberOfLayers::Int64
    numberOfInputs::Int64
    numberOfOutputs::Int64
    layers::Vector{Layer}
end

#====================
Create functions
====================#

create_neuron(numberOfInputs) = Neuron(; numberOfInputs)

function create_layer(numberOfNeurons, numberOfInputsPerNeuron)
    neurons = Vector{Neuron}(undef, numberOfNeurons)
    for i = 1:numberOfNeurons
        neurons[i] = create_neuron(numberOfInputsPerNeuron)
    end
    Layer(numberOfNeurons, numberOfInputsPerNeuron, neurons)
end

function create_network(layerSizes)
    numberOfInputs = first(layerSizes)
    numberOfLayers = length(layerSizes)
    layers = Vector{Layer}(undef, numberOfLayers)
    layers[1] = create_layer(numberOfInputs, 0)
    for i = 2:numberOfLayers
        layers[i] = create_layer(layerSizes[i], layerSizes[i-1])
    end
    NeuralNetwork(layerSizes, numberOfLayers, numberOfInputs, last(layerSizes), layers)
end

#====================
NeuralNetwork functions
====================#

function setWeights!(NN::NeuralNetwork, weights)
    iterator = 1
    for i = 2:NN.numberOfLayers
        for j = 1:NN.layers[i].numberOfNeurons
            for k = 1:NN.layers[i].neurons[j].numberOfInputs
                NN.layers[i].neurons[j].weights[k] = weights[iterator]
                iterator += 1
            end
        end
    end
end

function setBiases!(NN::NeuralNetwork, biases)
    iterator = 1
    for i = 2:NN.numberOfLayers
        for j = 1:NN.layers[i].numberOfNeurons
            NN.layers[i].neurons[j].bias = biases[iterator]
            iterator += 1
        end
    end
end

function getNumberOfWeights(NN::NeuralNetwork)
    count = 0
    for i = 2:NN.numberOfLayers
        count += NN.layerSizes[i] * NN.layerSizes[i-1]
    end
    count
end

function getNumberOfBiases(NN::NeuralNetwork)
    count = 0
    for i = 2:NN.numberOfLayers
        count += NN.layerSizes[i]
    end
    count
end

function update(NN::NeuralNetwork, inputs)

    outputs = Vector{Float64}(undef, 1)

    for i = 2:NN.numberOfLayers
        if i > 2
            inputs = outputs
        end

        numberOfNeuronsInLayer = NN.layers[i].numberOfNeurons
        outputs = Vector{Float64}(undef, numberOfNeuronsInLayer)

        for j = 1:numberOfNeuronsInLayer
            nettoInput = 0

            numberOfInputs = NN.layers[i].neurons[j].numberOfInputs

            for k = 1:numberOfInputs
                nettoInput += NN.layers[i].neurons[j].weights[k] * inputs[k]
            end

            nettoInput += NN.layers[i].neurons[j].bias

            outputs[j] = sigmoid(nettoInput)
        end
    end

    outputs
end


#====================
Helper functions
====================#


sigmoid(nettoInput) = 1.0 / ( 1.0 + exp(-nettoInput))

random_uniform(min, max) =  rand(min:1e-8:max)

random_uniform(min, max, n) = rand(min:1e-8:max, 1, n)