local Collectible = {}

function Collectible.new(type, x, y, props)
    props = props or {}
    
    local self = {
        type = type,
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        w = (type == "fragment" and 12 or 16),
        h = (type == "fragment" and 12 or 16),
        hitbox_ox = (type == "fragment" and 1 or 1),
        hitbox_oy = (type == "fragment" and 1 or 1),
        hitbox_w = (type == "fragment" and 10 or 14),
        hitbox_h = (type == "fragment" and 10 or 14),
        
        animation_frame = love.math.random(1, 8),
        animation_timer = 0,
        bob_offset = 0,
        bob_timer = 0,
        
        powerup_type = props.powerup_type or nil,
    }
    
    return self
end

function Collectible:update(dt, game_speed, magnet_active, player_x, player_y)
    self.vx = -game_speed
    self.x = self.x + self.vx * dt
    
    -- Bobbing animation
    self.bob_timer = self.bob_timer + dt
    self.bob_offset = math.sin(self.bob_timer * 1.5) * 3
    self.y = self.y + self.bob_offset * dt
    
    -- Frame animation
    self.animation_timer = self.animation_timer + dt
    local frame_duration = 1 / 12
    if self.animation_timer >= frame_duration then
        self.animation_frame = self.animation_frame + 1
        if self.animation_frame > 8 then
            self.animation_frame = 1
        end
        self.animation_timer = 0
    end
    
    -- Magnet pull
    if magnet_active then
        local dist_x = player_x - self.x
        local dist_y = player_y - self.y
        local dist = math.sqrt(dist_x * dist_x + dist_y * dist_y)
        
        if dist < 100 and dist > 0 then
            local pull_speed = 200
            self.vx = (dist_x / dist) * pull_speed
            self.vy = (dist_y / dist) * pull_speed
            self.x = self.x + self.vx * dt
            self.y = self.y + self.vy * dt
        end
    end
end

function Collectible:draw(sprites)
    if self.type == "fragment" then
        local frame = math.floor(self.animation_frame)
        if frame < 1 then frame = 1 end
        if frame > 8 then frame = 8 end
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.collectibles.data_fragment[frame], self.x, self.y, 0, 2, 2)
    elseif self.type == "core" then
        local frame = math.floor(self.animation_frame)
        if frame < 1 then frame = 1 end
        if frame > 8 then frame = 8 end
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprites.collectibles.power_core[frame], self.x, self.y, 0, 2, 2)
        
        -- Halo effect
        love.graphics.setColor(1, 0.8, 0, 0.5)
        love.graphics.circle("line", self.x + 16, self.y + 16, 20)
        love.graphics.setColor(1, 0.8, 0, 0.25)
        love.graphics.circle("line", self.x + 16, self.y + 16, 24)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

return Collectible
