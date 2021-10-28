using Luxor
#====================
Structs
====================#

Base.@kwdef mutable struct PIPE
    x::Int64 = 0
    y::Int64 = 0
    width::Int64 = 100
    height::Int64 = 0
    PIPE_SPEED::Int64 = 3
end

Base.@kwdef struct Pipes
    top::PIPE
    bottom::PIPE
end

Base.@kwdef struct PipesParams
    PIPE_GAP::Int64 = 130
end

#====================
Create functions
====================#

function reset(height::Int64, width::Int64)
    params = PipesParams()
    pipe_gap_y = rand(200:(height-200))
    htop = pipe_gap_y - params.PIPE_GAP / 2
    hbottom = height - params.PIPE_GAP - htop
    top = PIPE(; x=width, height=htop)
    bottom = PIPE(; x=width, y=top.height + params.PIPE_GAP, height=hbottom)
    Pipes(top=top, bottom=bottom)
end

#====================
Update functions
====================#
    
function update!(pipe::Pipes)
    pipe.top.x += -pipe.top.PIPE_SPEED
    pipe.bottom.x += - pipe.bottom.PIPE_SPEED
end

#====================
Draw functions
====================#

draw(pipe::PIPE) = rect(Point(pipe.x, pipe.y), pipe.width, pipe.height, :fill)

function draw(pipe::Pipes) 
    draw(pipe.top)
    draw(pipe.bottom)
end