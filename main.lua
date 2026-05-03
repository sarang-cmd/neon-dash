local Sprites = require("game.systems.sprites")

local BootState = require("game.states.boot")
local MenuState = require("game.states.menu")
local CountdownState = require("game.states.countdown")
local GameplayState = require("game.states.gameplay")
local GameOverState = require("game.states.gameover")

local states = {}
local current_state = nil
local state_name = "boot"

function love.load()
    -- Seed random
    love.math.setRandomSeed(love.timer.getTime() * 1000000)
    
    -- Load all sprites
    Sprites.load()
    
    -- Initialize states
    states.boot = BootState.new()
    states.menu = MenuState.new()
    states.countdown = CountdownState.new()
    states.gameplay = GameplayState.new()
    states.gameover = GameOverState.new()
    
    -- Start in boot state
    current_state = states.boot
    current_state:enter()
end

function love.update(dt)
    if current_state then
        local next_state = current_state:update(dt)
        
        if next_state then
            current_state:exit()
            state_name = next_state
            current_state = states[next_state]
            
            if current_state then
                current_state:enter()
            end
        end
    end
end

function love.draw()
    if state_name == "boot" or state_name == "menu" or state_name == "countdown" or state_name == "gameover" then
        current_state:draw()
    else
        current_state:draw(Sprites)
    end
end

function love.keypressed(key)
    if current_state and current_state.keypressed then
        local next_state = current_state:keypressed(key)
        
        if next_state then
            current_state:exit()
            state_name = next_state
            current_state = states[next_state]
            
            if current_state then
                if next_state == "gameover" then
                    -- Pass data to gameover state
                    local gameplay = states.gameplay
                    current_state:enter({
                        score = gameplay.scoring.score,
                        best = gameplay.scoring.highscore,
                        distance = gameplay.difficulty.distance,
                        fragments = gameplay.scoring.fragments,
                        max_combo = gameplay.scoring.max_combo,
                        rating = gameplay.scoring:get_performance_rating(),
                        rating_color = select(2, gameplay.scoring:get_performance_rating()) or {1, 1, 1},
                        new_record = gameplay.scoring.score > gameplay.scoring.highscore,
                    })
                else
                    current_state:enter()
                end
            end
        end
    end
    
    if key == "m" then
        -- Toggle mute (would be implemented in audio system)
    end
end

function love.focus(focus)
    if current_state and current_state.focus then
        current_state:focus(focus)
    end
end

function love.quit()
    return false
end
