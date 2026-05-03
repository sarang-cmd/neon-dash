local Obstacle = {}

function Obstacle.new(type, x, y, props)
    props = props or {}
    
    local self = {
        type = type,
        x = x,
        y = y,
        w = props.w or 32,
        h = props.h or 32,
        hitbox_ox = props.hitbox_ox or 2,
        hitbox_oy = props.hitbox_oy or 2,
        hitbox_w = props.hitbox_w or 28,
        hitbox_h = props.hitbox_h or 28,
        color = props.color or {1, 0, 0},
        vx = props.vx or 0,
        vy = props.vy or 0,
        animation_frame = 0,
        animation_timer = 0,
        _props = props,
    }
    
    return self
end

function Obstacle:update(dt, game_speed)
    -- Base movement is left (negative vx by default)
    self.vx = -game_speed
    self.x = self.x + self.vx * dt
    
    -- Type-specific updates
    if self.type == "f1" or self.type == "f2" or self.type:sub(1,1) == "F" then
        self:_update_floating(dt)
    elseif self.type == "a2" then
        self:_update_drone(dt, game_speed)
    elseif self.type == "a1" then
        self:_update_laser(dt)
    end
    
    -- Animation
    self.animation_timer = self.animation_timer + dt
    local frame_duration = 1 / 12
    if self.animation_timer >= frame_duration then
        self.animation_frame = self.animation_frame + 1
        self.animation_timer = 0
        if self.animation_frame > (self._props.frames or 1) then
            self.animation_frame = 1
        end
    end
end

function Obstacle:_update_floating(dt)
    -- Sine wave motion for data mines and viral clusters
    local time = love.timer.getTime()
    local phase = (self.x / 480) * math.pi * 2
    local center_y = 180
    local amplitude = 40
    local frequency = 2
    self.y = center_y + math.sin(time * frequency * math.pi * 2 + phase) * amplitude
end

function Obstacle:_update_drone(dt, game_speed)
    self.vx = -(game_speed + 50)
    self.x = self.x + (50 * dt)
end

function Obstacle:_update_laser(dt)
    if self._props.sweep_position then
        self._props.sweep_direction = self._props.sweep_direction or 1
        self._props.sweep_position = self._props.sweep_position + (100 * dt * self._props.sweep_direction)
        
        if self._props.sweep_position <= 0 or self._props.sweep_position >= 80 then
            self._props.sweep_direction = -self._props.sweep_direction
        end
    end
end

function Obstacle:draw(sprites)
    if self.type == "g1" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.obstacles.firewall_low, self.x, self.y, 0, 2, 2)
    elseif self.type == "g2" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.obstacles.firewall_high, self.x, self.y, 0, 2, 2)
    elseif self.type == "g3" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.obstacles.corrupted_node, self.x, self.y, 0, 2, 2)
    elseif self.type == "g4" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.obstacles.data_wall, self.x, self.y, 0, 2, 2)
    elseif self.type == "a1" then
        -- Laser gate drawn dynamically
        love.graphics.setColor(1, 0.4, 0, 0.8)
        local sweep_y = (self._props.sweep_position or 0) * 2
        love.graphics.rectangle("fill", self.x * 2, sweep_y, 16, 20)
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", self.x * 2, sweep_y, 16, 4)
    elseif self.type == "a2" then
        -- Security drone
        love.graphics.setColor(1, 0.4, 0)
        love.graphics.rectangle("fill", self.x + 2, self.y + 3, 28, 10)
        love.graphics.setColor(0.8, 0.27, 0)
        love.graphics.rectangle("fill", self.x + 4, self.y + 5, 24, 6)
        
        -- Sensor beam
        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.rectangle("fill", self.x + 2, self.y + 16, 28, 4)
    elseif self.type == "a3" then
        -- Firewall beam
        love.graphics.setColor(1, 0, 0.2, 0.8)
        love.graphics.rectangle("fill", 0, self.y, 960, 12)
        love.graphics.setColor(1, 0.2, 0.4)
        love.graphics.rectangle("fill", 0, self.y + 4, 960, 4)
    elseif self.type == "f1" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.obstacles.corrupted_node, self.x, self.y, 0, 2, 2)
    elseif self.type == "f2" then
        -- Three mines in cluster
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.obstacles.corrupted_node, self.x, self.y, 0, 2, 2)
        love.graphics.draw(sprites.obstacles.corrupted_node, self.x + 40, self.y - 16, 0, 2, 2)
        love.graphics.draw(sprites.obstacles.corrupted_node, self.x + 80, self.y, 0, 2, 2)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

return Obstacle
