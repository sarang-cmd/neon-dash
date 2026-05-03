local Parallax = {}

function Parallax.new()
    local self = {
        layers = {},
        scroll_x = {},
    }
    
    for i = 1, 5 do
        self.scroll_x[i] = 0
    end
    
    self.layers[1] = Parallax:_create_starfield()
    self.layers[2] = Parallax:_create_skyline()
    self.layers[3] = Parallax:_create_hex_grid()
    self.layers[4] = Parallax:_create_ground()
    self.layers[5] = Parallax:_create_particles()
    
    return self
end

function Parallax:_create_starfield()
    local canvas = love.graphics.newCanvas(480, 300)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.039, 0.039, 0.18)
    
    love.math.setRandomSeed(42)
    for i = 1, 80 do
        local x = love.math.random(0, 480)
        local y = love.math.random(0, 300)
        love.graphics.setColor(1, 1, 1)
        if i <= 5 then
            love.graphics.rectangle("fill", x, y, 2, 2)
        else
            love.graphics.rectangle("fill", x, y, 1, 1)
        end
    end
    
    love.graphics.setCanvas()
    return canvas
end

function Parallax:_create_skyline()
    local canvas = love.graphics.newCanvas(480, 200)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    
    love.math.setRandomSeed(123)
    local x = 0
    local building_count = 0
    while x < 480 do
        local w = 8 + love.math.random(0, 20)
        local h = 20 + love.math.random(0, 60)
        local y = 200 - h
        
        love.graphics.setColor(0.2, 0.15, 0.3)
        love.graphics.rectangle("fill", x, y, w, h)
        
        -- Windows
        if building_count % 3 == 0 then
            for wy = y + 4, y + h - 4, 8 do
                for wx = x + 2, x + w - 4, 6 do
                    if love.math.random() < 0.6 then
                        local c = love.math.random(1, 3)
                        if c == 1 then
                            love.graphics.setColor(0, 1, 1)
                        elseif c == 2 then
                            love.graphics.setColor(1, 0.7, 0)
                        else
                            love.graphics.setColor(1, 0, 1)
                        end
                        love.graphics.rectangle("fill", wx, wy, 2, 2)
                    end
                end
            end
        end
        
        x = x + w
        building_count = building_count + 1
    end
    
    love.graphics.setCanvas()
    return canvas
end

function Parallax:_create_hex_grid()
    local canvas = love.graphics.newCanvas(480, 300)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    
    love.graphics.setColor(0.102, 0.102, 0.306, 0.15)
    for x = 0, 480, 32 do
        love.graphics.rectangle("fill", x, 0, 1, 300)
    end
    for y = 0, 300, 32 do
        love.graphics.rectangle("fill", 0, y, 480, 1)
    end
    
    love.graphics.setCanvas()
    return canvas
end

function Parallax:_create_ground()
    local canvas = love.graphics.newCanvas(480, 48)
    love.graphics.setCanvas(canvas)
    
    love.graphics.setColor(0.118, 0.118, 0.239)
    love.graphics.rectangle("fill", 0, 0, 480, 48)
    
    love.graphics.setColor(0, 1, 1, 0.4)
    love.graphics.rectangle("fill", 0, 0, 480, 2)
    
    for x = 0, 480, 64 do
        love.graphics.setColor(0, 1, 1)
        love.graphics.rectangle("fill", x, 0, 1, 48)
    end
    
    for x = 0, 480, 128 do
        love.graphics.setColor(0, 1, 1)
        love.graphics.rectangle("fill", x, 0, 4, 4)
    end
    
    love.graphics.setCanvas()
    return canvas
end

function Parallax:_create_particles()
    local canvas = love.graphics.newCanvas(480, 300)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    
    love.math.setRandomSeed(999)
    Parallax.bg_particles = {}
    for i = 1, 30 do
        table.insert(Parallax.bg_particles, {
            x = love.math.random(0, 480),
            y = love.math.random(20, 200),
            speed = 0.7 + love.math.random() * 0.2,
            color = love.math.random(1, 3),
            opacity = 0.3 + love.math.random() * 0.4,
        })
    end
    
    love.graphics.setCanvas()
    return canvas
end

function Parallax:update(dt, game_speed)
    local speeds = {20, 40, 60, 100, 80}
    local widths = {480, 480, 480, 480, 480}
    
    for i = 1, 5 do
        self.scroll_x[i] = self.scroll_x[i] + (game_speed * speeds[i] / 200) * dt
        if self.scroll_x[i] >= widths[i] then
            self.scroll_x[i] = self.scroll_x[i] - widths[i]
        end
    end
end

function Parallax:draw()
    for i = 1, 5 do
        local tile_width = 480
        local y_offset = (i == 2) and 100 or (i == 4) and 252 or 0
        
        love.graphics.draw(self.layers[i], -self.scroll_x[i], y_offset)
        love.graphics.draw(self.layers[i], tile_width - self.scroll_x[i], y_offset)
    end
    
    if Parallax.bg_particles then
        for _, p in ipairs(Parallax.bg_particles) do
            love.graphics.setColor(
                (p.color == 1 and 0 or 1),
                (p.color == 1 and 1 or (p.color == 2 and 0.8 or 0)),
                (p.color == 3 and 1 or 1),
                p.opacity
            )
            love.graphics.rectangle("fill", math.floor((p.x - self.scroll_x[5] * 0.8) % 480), math.floor(p.y), 2, 2)
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

return Parallax
