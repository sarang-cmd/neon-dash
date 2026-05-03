local Player = {}

function Player.new()
    local self = {
        x = 130,
        y = 252,
        w = 32,
        h = 32,
        vx = 0,
        vy = 0,
        
        hitbox_ox = 3,
        hitbox_oy = 4,
        hitbox_w = 10,
        hitbox_h = 26,
        
        state = "run",
        animation_frame = 0,
        animation_timer = 0,
        
        gravity = 980,
        jump_velocity = -450,
        variable_jump_gravity = 400,
        base_gravity = 980,
        slide_gravity = 2200,
        
        jump_pressed = false,
        slide_pressed = false,
        
        is_jumping = false,
        is_sliding = false,
        slide_timer = 0,
        slide_duration = 0.4,
        
        coyote_timer = 0,
        coyote_time = 0.12,
        jump_buffer = 0.1,
        jump_buffer_timer = 0,
        
        is_dead = false,
        death_timer = 0,
        
        -- Power-ups
        shield_active = false,
        shield_timer = 0,
        magnet_active = false,
        magnet_timer = 0,
        slow_mo_active = false,
        slow_mo_timer = 0,
        double_points_active = false,
        double_points_timer = 0,
        
        ground_level = 252,
        speed = 200,
    }
    return self
end

function Player:update(dt, game_speed)
    if self.is_dead then
        self.death_timer = self.death_timer + dt
        return
    end
    
    self.speed = game_speed
    self.x = self.x + self.speed * dt
    
    -- Handle sliding
    if self.is_sliding then
        self.slide_timer = self.slide_timer + dt
        if self.slide_timer >= self.slide_duration then
            self.is_sliding = false
            self.slide_timer = 0
        end
        
        self.hitbox_ox = 1
        self.hitbox_oy = 16
        self.hitbox_w = 14
        self.hitbox_h = 12
    elseif self.is_jumping then
        self.hitbox_ox = 3
        self.hitbox_oy = 4
        self.hitbox_w = 10
        self.hitbox_h = 26
    else
        self.hitbox_ox = 3
        self.hitbox_oy = 4
        self.hitbox_w = 10
        self.hitbox_h = 26
    end
    
    -- Gravity and vertical motion
    if self.y < self.ground_level then
        -- If holding jump and in ascent, use reduced gravity
        if self.jump_pressed and self.vy < 0 then
            self.gravity = self.variable_jump_gravity
        else
            self.gravity = self.base_gravity
        end
        
        -- Handle fast-fall (DOWN key while in air)
        if self.slide_pressed and self.vy >= 0 then
            self.gravity = self.slide_gravity
        end
        
        self.vy = self.vy + self.gravity * dt
        self.is_jumping = true
    else
        self.y = self.ground_level
        self.vy = 0
        self.is_jumping = false
        self.coyote_timer = self.coyote_time
    end
    
    self.coyote_timer = self.coyote_timer - dt
    self.jump_buffer_timer = self.jump_buffer_timer - dt
    
    -- Jump logic
    if self.jump_pressed and not self.is_sliding then
        if self.coyote_timer > 0 or self.jump_buffer_timer > 0 then
            self.vy = self.jump_velocity
            self.is_jumping = true
            self.coyote_timer = 0
            self.jump_buffer_timer = 0
        end
    end
    
    -- Update position
    self.y = self.y + self.vy * dt
    if self.y > self.ground_level then
        self.y = self.ground_level
    end
    
    -- Animation
    self:update_animation(dt)
    
    -- Power-ups
    if self.shield_active then
        self.shield_timer = self.shield_timer + dt
        if self.shield_timer >= 5 then
            self.shield_active = false
            self.shield_timer = 0
        end
    end
    
    if self.magnet_active then
        self.magnet_timer = self.magnet_timer + dt
        if self.magnet_timer >= 8 then
            self.magnet_active = false
            self.magnet_timer = 0
        end
    end
    
    if self.slow_mo_active then
        self.slow_mo_timer = self.slow_mo_timer + dt
        if self.slow_mo_timer >= 3 then
            self.slow_mo_active = false
            self.slow_mo_timer = 0
        end
    end
    
    if self.double_points_active then
        self.double_points_timer = self.double_points_timer + dt
        if self.double_points_timer >= 10 then
            self.double_points_active = false
            self.double_points_timer = 0
        end
    end
    
    self.jump_pressed = false
    self.slide_pressed = false
end

function Player:update_animation(dt)
    self.animation_timer = self.animation_timer + dt
    
    if self.is_dead then
        local frame_time = 1 / 10
        if self.animation_timer >= frame_time then
            self.animation_frame = self.animation_frame + 1
            self.animation_timer = 0
            if self.animation_frame > 3 then
                self.animation_frame = 3
            end
        end
    elseif self.is_sliding then
        self.animation_frame = 1
    elseif self.is_jumping then
        local frame_time = 1 / 10
        if self.animation_timer >= frame_time then
            self.animation_frame = self.animation_frame + 1
            self.animation_timer = 0
            if self.animation_frame > 2 then
                self.animation_frame = 2
            end
        end
    else
        local frame_time = 1 / 10
        if self.animation_timer >= frame_time then
            self.animation_frame = self.animation_frame + 1
            self.animation_timer = 0
            if self.animation_frame > 4 then
                self.animation_frame = 1
            end
        end
    end
end

function Player:draw(sprites)
    if self.is_dead then
        local sprite = sprites.player.death[math.min(self.animation_frame, 3)]
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, self.x, self.y, 0, 2, 2)
    elseif self.is_sliding then
        local sprite = sprites.player.slide
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, self.x, self.y, 0, 2, 2)
    elseif self.is_jumping then
        local frame = math.min(self.animation_frame, 2)
        local sprite = sprites.player.jump[frame]
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, self.x, self.y, 0, 2, 2)
    else
        local frame = math.max(1, math.min(self.animation_frame, 4))
        local sprite = sprites.player.run[frame]
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, self.x, self.y, 0, 2, 2)
    end
    
    -- Draw power-up effects
    if self.shield_active then
        local pulse = math.sin(love.timer.getTime() * 3) * 0.2 + 0.8
        love.graphics.setColor(0, 1, 1, pulse * 0.6)
        love.graphics.circle("line", self.x + 16, self.y + 16, 36)
    end
    
    if self.magnet_active then
        local t = love.timer.getTime() * 2
        for i = 1, 4 do
            local angle = (math.pi * 2 / 4) * i + t
            local mx = self.x + 16 + math.cos(angle) * 40
            local my = self.y + 16 + math.sin(angle) * 40
            love.graphics.setColor(0, 1, 1)
            love.graphics.rectangle("fill", mx, my, 2, 2)
        end
    end
    
    -- Trail effect at high speed
    if self.speed >= 300 and not self.is_dead then
        for i = 1, 3 do
            local trail_x = self.x - (i * 8)
            local alpha = (1 - i / 4)
            love.graphics.setColor(1, 1, 1, alpha * 0.5)
            if self.is_jumping then
                local frame = math.min(self.animation_frame, 2)
                love.graphics.draw(sprites.player.jump[frame], trail_x, self.y, 0, 2, 2)
            else
                local frame = math.max(1, math.min(self.animation_frame, 4))
                love.graphics.draw(sprites.player.run[frame], trail_x, self.y, 0, 2, 2)
            end
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Player:jump()
    self.jump_pressed = true
    self.jump_buffer_timer = self.jump_buffer
end

function Player:slide()
    if not self.is_jumping and not self.is_sliding then
        self.is_sliding = true
        self.slide_timer = 0
    elseif self.is_jumping then
        self.slide_pressed = true
    end
end

function Player:die()
    self.is_dead = true
    self.death_timer = 0
end

function Player:apply_powerup(powerup_type)
    if powerup_type == "shield" then
        self.shield_active = true
        self.shield_timer = 0
    elseif powerup_type == "magnet" then
        self.magnet_active = true
        self.magnet_timer = 0
    elseif powerup_type == "slow_mo" then
        self.slow_mo_active = true
        self.slow_mo_timer = 0
    elseif powerup_type == "double_points" then
        self.double_points_active = true
        self.double_points_timer = 0
    end
end

return Player
