local CountdownState = {}

function CountdownState.new()
    local self = {
        parallax = nil,
        countdown_value = 3,
        timer = 0,
        phase = "count",
        font_huge = love.graphics.newFont(48),
        font_large = love.graphics.newFont(24),
    }
    return self
end

function CountdownState:enter()
    if not self.parallax then
        local Parallax = require("game.systems.parallax")
        self.parallax = Parallax.new()
    end
    self.countdown_value = 3
    self.timer = 0
    self.phase = "count"
end

function CountdownState:exit()
end

function CountdownState:update(dt)
    self.parallax:update(dt, 200)
    self.timer = self.timer + dt
    
    if self.phase == "count" then
        if self.timer >= 0.7 then
            self.countdown_value = self.countdown_value - 1
            self.timer = 0
            
            if self.countdown_value < 0 then
                self.phase = "go"
                self.countdown_value = 0
                self.timer = 0
            end
        end
    elseif self.phase == "go" then
        if self.timer >= 0.5 then
            return "gameplay"
        end
    end
end

function CountdownState:draw()
    self.parallax:draw()
    
    love.graphics.setColor(0.039, 0.039, 0.18, 0.7)
    love.graphics.rectangle("fill", 0, 0, 960, 600)
    
    if self.phase == "count" then
        local scale = 1.0 + (0.7 - self.timer) / 0.7 * 0.5
        
        love.graphics.setFont(self.font_huge)
        local text = tostring(math.max(1, self.countdown_value))
        local width = self.font_huge:getWidth(text)
        
        love.graphics.push()
        love.graphics.translate(480, 300)
        love.graphics.scale(scale)
        love.graphics.setColor(0, 1, 1)
        love.graphics.print(text, -width / 2, -24)
        love.graphics.pop()
    elseif self.phase == "go" then
        local alpha = 1.0 - (self.timer / 0.5)
        local scale = 2.0 + (self.timer / 0.5) * 0.5
        
        love.graphics.setFont(self.font_huge)
        local text = "GO!"
        local width = self.font_huge:getWidth(text)
        
        love.graphics.push()
        love.graphics.translate(480, 300)
        love.graphics.scale(scale)
        love.graphics.setColor(1, 0, 1, alpha)
        love.graphics.print(text, -width / 2, -24)
        love.graphics.pop()
    end
end

function CountdownState:keypressed(key)
end

return CountdownState
