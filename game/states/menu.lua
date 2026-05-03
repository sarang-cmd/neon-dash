local MenuState = {}

function MenuState.new()
    local self = {
        parallax = nil,
        font_large = love.graphics.newFont(16),
        font_medium = love.graphics.newFont(12),
        font_small = love.graphics.newFont(6),
        best_score = 0,
    }
    return self
end

function MenuState:enter()
    if not self.parallax then
        local Parallax = require("game.systems.parallax")
        self.parallax = Parallax.new()
    end
end

function MenuState:exit()
end

function MenuState:update(dt)
    self.parallax:update(dt, 200)
end

function MenuState:draw()
    self.parallax:draw()
    
    love.graphics.setColor(0.039, 0.039, 0.18)
    love.graphics.rectangle("fill", 0, 0, 960, 600)
    
    self.parallax:draw()
    
    -- Title with glow
    love.graphics.setFont(self.font_large)
    love.graphics.setColor(0, 1, 1, 0.3)
    love.graphics.print("NEON DASH", 360, 148)
    love.graphics.print("NEON DASH", 362, 148)
    love.graphics.setColor(1, 0, 1)
    love.graphics.print("NEON DASH", 360, 150)
    
    -- Subtitle
    love.graphics.setFont(self.font_medium)
    love.graphics.setColor(0, 1, 1)
    love.graphics.print("CYBER RUNNER", 370, 200)
    
    -- Play hint
    love.graphics.setFont(self.font_small)
    local blink = math.sin(love.timer.getTime() * 2) > 0 and 1.0 or 0.5
    love.graphics.setColor(1, 1, 1, blink)
    love.graphics.print("PRESS SPACE TO RUN", 380, 300)
    
    -- Best score
    love.graphics.setColor(0, 1, 1)
    love.graphics.print("BEST: " .. string.format("%06d", self.best_score), 350, 400)
    
    -- Mute hint
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("M - MUTE", 850, 550)
    
    love.graphics.setColor(1, 1, 1)
end

function MenuState:keypressed(key)
    if key == "space" then
        return "countdown"
    end
end

return MenuState
