local Effects = {}

function Effects.new()
    local self = {
        shake_amount = 0,
        shake_timer = 0,
        shake_duration = 0,
        
        flash_timer = 0,
        flash_duration = 0,
        
        speed_line_timer = 0,
    }
    return self
end

function Effects:screen_shake(intensity, duration)
    self.shake_amount = intensity
    self.shake_timer = 0
    self.shake_duration = duration
end

function Effects:white_flash(duration)
    self.flash_timer = duration
    self.flash_duration = duration
end

function Effects:update(dt)
    if self.shake_timer < self.shake_duration then
        self.shake_timer = self.shake_timer + dt
    end
    
    if self.flash_timer > 0 then
        self.flash_timer = self.flash_timer - dt
    end
    
    self.speed_line_timer = self.speed_line_timer + dt
end

function Effects:get_shake_offset()
    if self.shake_timer >= self.shake_duration then
        return 0, 0
    end
    
    local decay = (self.shake_duration - self.shake_timer) / self.shake_duration
    return (love.math.random() - 0.5) * self.shake_amount * decay,
           (love.math.random() - 0.5) * self.shake_amount * decay
end

function Effects:draw_scanlines()
    love.graphics.setColor(0, 0, 0, 0.18)
    for y = 0, 600, 2 do
        love.graphics.rectangle("fill", 0, y, 960, 1)
    end
end

function Effects:draw_vignette()
    local gradient_depth = 60
    local step = 1 / gradient_depth
    
    for i = 1, gradient_depth do
        local alpha = (1 - (i / gradient_depth)) * 0.2
        love.graphics.setColor(0.039, 0.039, 0.18, alpha)
        
        -- Top
        love.graphics.rectangle("fill", 0, i - 1, 960, 1)
        -- Bottom
        love.graphics.rectangle("fill", 0, 600 - i, 960, 1)
        -- Left
        love.graphics.rectangle("fill", i - 1, 0, 1, 600)
        -- Right
        love.graphics.rectangle("fill", 960 - i, 0, 1, 600)
    end
end

function Effects:draw_flash()
    if self.flash_timer > 0 then
        local alpha = self.flash_timer / self.flash_duration
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.rectangle("fill", 0, 0, 960, 600)
    end
end

function Effects:draw_speed_lines(speed)
    if speed >= 350 then
        love.graphics.setColor(1, 1, 1, 0.35)
        for i = 1, 12 do
            local y = love.math.random(0, 450)
            local length = 40 + love.math.random(0, 80)
            local offset = (self.speed_line_timer * speed * 1.5) % 960
            love.graphics.rectangle("fill", 960 - offset, y, 1, length)
        end
    end
end

function Effects:draw_glitch(canvas)
    local band_count = 3
    for i = 1, band_count do
        local band_y = love.math.random(50, 450)
        local band_height = 4 + love.math.random(0, 12)
        local x_offset = (love.math.random() - 0.5) * 16
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(canvas, x_offset, band_y, 0, 1, 1,
                          0, band_y)
        
        love.graphics.setColor(1, 0, 0.2, 0.4)
        love.graphics.draw(canvas, x_offset + 2, band_y, 0, 1, 1,
                          0, band_y)
        
        love.graphics.setColor(0, 1, 1, 0.4)
        love.graphics.draw(canvas, x_offset - 2, band_y, 0, 1, 1,
                          0, band_y)
    end
end

return Effects
