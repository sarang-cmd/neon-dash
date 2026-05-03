local Particles = {}

function Particles.new()
    local self = {
        particles = {},
        pool_size = 0,
        max_pool = 300,
    }
    return self
end

function Particles:spawn_burst(x, y, count, r, g, b, size, min_speed, max_speed, gravity_affected)
    gravity_affected = gravity_affected or false
    size = size or 2
    min_speed = min_speed or 60
    max_speed = max_speed or 140
    
    for i = 1, count do
        if self.pool_size < self.max_pool then
            local angle = (math.pi * 2 / count) * i + (love.math.random() - 0.5) * 0.3
            local speed = min_speed + (max_speed - min_speed) * love.math.random()
            
            local particle = {
                x = x,
                y = y,
                vx = math.cos(angle) * speed,
                vy = math.sin(angle) * speed,
                life = 1.0,
                max_life = (gravity_affected and 0.8 or 0.4),
                r = r,
                g = g,
                b = b,
                size = size,
                gravity = (gravity_affected and 300 or 0),
            }
            table.insert(self.particles, particle)
            self.pool_size = self.pool_size + 1
        end
    end
end

function Particles:spawn_spiral(x, y, count, r, g, b)
    for i = 1, count do
        if self.pool_size < self.max_pool then
            local angle = (math.pi * 2 / count) * i
            local speed = 80
            
            local particle = {
                x = x,
                y = y,
                vx = math.cos(angle) * speed,
                vy = math.sin(angle) * speed,
                life = 1.0,
                max_life = 0.7,
                r = r,
                g = g,
                b = b,
                size = 3,
                gravity = 0,
            }
            table.insert(self.particles, particle)
            self.pool_size = self.pool_size + 1
        end
    end
end

function Particles:update(dt)
    local i = 1
    while i <= #self.particles do
        local p = self.particles[i]
        
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + p.gravity * dt
        p.life = p.life - (dt / p.max_life)
        
        if p.life <= 0 then
            table.remove(self.particles, i)
            self.pool_size = self.pool_size - 1
        else
            i = i + 1
        end
    end
end

function Particles:draw()
    for _, p in ipairs(self.particles) do
        love.graphics.setColor(p.r, p.g, p.b, p.life)
        love.graphics.rectangle("fill", math.floor(p.x), math.floor(p.y), p.size, p.size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Particles:clear()
    self.particles = {}
    self.pool_size = 0
end

return Particles
