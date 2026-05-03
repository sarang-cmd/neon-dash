local GameplayState = {}

local Player = require("game.entities.player")
local Spawner = require("game.systems.spawner")
local Difficulty = require("game.systems.difficulty")
local Scoring = require("game.systems.scoring")
local Parallax = require("game.systems.parallax")
local Particles = require("game.systems.particles")
local Collision = require("game.systems.collision")
local HUD = require("game.ui.hud")
local Effects = require("game.ui.effects")

function GameplayState.new()
    local self = {
        player = nil,
        spawner = nil,
        difficulty = nil,
        scoring = nil,
        parallax = nil,
        particles = nil,
        hud = nil,
        effects = nil,
        
        paused = false,
        pause_time = 0,
    }
    return self
end

function GameplayState:enter()
    self.player = Player.new()
    self.spawner = Spawner.new()
    self.difficulty = Difficulty.new()
    self.scoring = Scoring.new()
    self.parallax = Parallax.new()
    self.particles = Particles.new()
    self.hud = HUD.new()
    self.effects = Effects.new()
    self.paused = false
end

function GameplayState:exit()
end

function GameplayState:update(dt)
    if self.paused then
        self.pause_time = self.pause_time + dt
        return
    end
    
    -- Apply slow-mo if active
    local speed_multiplier = 1.0
    if self.player.slow_mo_active then
        speed_multiplier = 0.5
        dt = dt * speed_multiplier
    end
    
    -- Update systems
    self.difficulty:update(dt, self.scoring.score)
    self.player:update(dt, self.difficulty.current_speed)
    self.spawner:update(dt, self.difficulty, self.difficulty.current_speed, self.player)
    self.parallax:update(dt, self.difficulty.current_speed)
    self.particles:update(dt)
    self.effects:update(dt)
    
    -- Collision detection
    local collision_results = {
        fragment_collected = false,
        core_collected = false,
        near_miss = false,
        death = false,
    }
    
    -- Obstacle collisions
    for _, obs in ipairs(self.spawner.obstacles) do
        if obs.type then
            if Collision.aabb(self.player, obs) then
                if not self.player.shield_active then
                    collision_results.death = true
                    self.player:die()
                    self.effects:screen_shake(8, 0.35)
                    self.effects:white_flash(0.1)
                else
                    self.player.shield_active = false
                    self.particles:spawn_burst(self.player.x + 16, self.player.y + 16, 10, 0, 1, 1, 3, 80, 150, false)
                end
            elseif Collision.near_miss(self.player, obs) then
                collision_results.near_miss = true
            end
        else
            -- Combo obstacle
            for key, sub in pairs(obs) do
                if sub.type and Collision.aabb(self.player, sub) then
                    if not self.player.shield_active then
                        collision_results.death = true
                        self.player:die()
                        self.effects:screen_shake(8, 0.35)
                        self.effects:white_flash(0.1)
                    else
                        self.player.shield_active = false
                        self.particles:spawn_burst(self.player.x + 16, self.player.y + 16, 10, 0, 1, 1, 3, 80, 150, false)
                    end
                elseif sub.type and Collision.near_miss(self.player, sub) then
                    collision_results.near_miss = true
                end
            end
        end
    end
    
    -- Collectible collisions
    local i = 1
    while i <= #self.spawner.collectibles do
        local coll = self.spawner.collectibles[i]
        if Collision.aabb(self.player, coll) then
            if coll.type == "fragment" then
                collision_results.fragment_collected = true
                self.particles:spawn_burst(coll.x + 12, coll.y + 12, 6, 0, 1, 1, 2, 60, 140, false)
            elseif coll.type == "core" then
                collision_results.core_collected = true
                self.particles:spawn_spiral(coll.x + 16, coll.y + 16, 14, 1, 0.8, 0)
                self.effects:white_flash(0.1)
                if coll.powerup_type then
                    if coll.powerup_type == "shield" then
                        self.player:apply_powerup("shield")
                        self.scoring.score_multiplier = 1.0
                    elseif coll.powerup_type == "magnet" then
                        self.player:apply_powerup("magnet")
                        self.scoring.score_multiplier = 1.0
                    elseif coll.powerup_type == "slow_mo" then
                        self.player:apply_powerup("slow_mo")
                        self.scoring.score_multiplier = 1.0
                    elseif coll.powerup_type == "double_points" then
                        self.player:apply_powerup("double_points")
                        self.scoring.score_multiplier = 2.0
                    end
                end
            end
            table.remove(self.spawner.collectibles, i)
        else
            i = i + 1
        end
    end
    
    -- Update scoring
    self.scoring:update(dt, self.difficulty.current_speed, collision_results, self.scoring.score_multiplier)
    
    -- Check if player died
    if self.player.is_dead and self.player.death_timer >= 0.8 then
        local new_record = self.scoring:save_highscore()
        return "gameover"
    end
end

function GameplayState:draw(sprites)
    love.graphics.push()
    local shake_x, shake_y = self.effects:get_shake_offset()
    love.graphics.translate(shake_x, shake_y)
    
    self.parallax:draw()
    
    -- Draw obstacles
    for _, obs in ipairs(self.spawner.obstacles) do
        if obs.type then
            obs:draw(sprites)
        else
            for key, sub in pairs(obs) do
                if sub.type then
                    sub:draw(sprites)
                end
            end
        end
    end
    
    -- Draw collectibles
    for _, coll in ipairs(self.spawner.collectibles) do
        coll:draw(sprites)
    end
    
    -- Draw player
    self.player:draw(sprites)
    
    -- Draw particles
    self.particles:draw()
    
    love.graphics.pop()
    
    -- Draw HUD
    self.hud:draw(
        self.scoring.score,
        self.scoring.highscore,
        self.difficulty.distance,
        self.difficulty.current_speed,
        self.scoring.consecutive_fragments,
        (self.player.shield_active and "shield" or
         self.player.magnet_active and "magnet" or
         self.player.slow_mo_active and "slow_mo" or
         self.player.double_points_active and "double_points" or nil),
        (self.player.shield_active and self.player.shield_timer or
         self.player.magnet_active and self.player.magnet_timer or
         self.player.slow_mo_active and self.player.slow_mo_timer or
         self.player.double_points_active and self.player.double_points_timer or 0),
        5,
        self.difficulty
    )
    
    -- Draw scoring toasts
    if self.scoring.milestone_toasts then
        for i, toast in ipairs(self.scoring.milestone_toasts) do
            local alpha = 1.0 - (toast.timer / 1.5)
            love.graphics.setColor(toast.color[1], toast.color[2], toast.color[3], alpha)
            local text = toast.text .. " +200"
            local width = 50
            love.graphics.print(text, 480 - width / 2, 250 + i * 40)
        end
    end
    
    -- Screen effects
    self.effects:draw_scanlines()
    self.effects:draw_vignette()
    self.effects:draw_flash()
    self.effects:draw_speed_lines(self.difficulty.current_speed)
    
    -- Pause overlay
    if self.paused then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, 960, 600)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("PAUSED", 400, 250)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print("P/ESC - RESUME", 400, 300)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function GameplayState:keypressed(key)
    if key == "space" or key == "up" or key == "w" then
        self.player:jump()
    elseif key == "down" or key == "s" or key == "lctrl" then
        self.player:slide()
    elseif key == "p" or key == "escape" then
        self.paused = not self.paused
    end
end

function GameplayState:focus(focus)
    if not focus then
        self.paused = true
    end
end

return GameplayState
