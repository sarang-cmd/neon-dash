local ObstacleTypes = require("game.entities.obstacle_types")
local Collectible = require("game.entities.collectible")

local Spawner = {}

function Spawner.new()
    local self = {
        obstacles = {},
        collectibles = {},
        
        spawn_timer = 0,
        last_gap = 600,
        spawn_distance = 0,
        
        core_timer = 0,
        core_spawn_distance = 2000 + love.math.random() * 1000,
        
        last_obstacle_x = 500,
    }
    
    return self
end

function Spawner:update(dt, difficulty, distance, player)
    self.spawn_distance = self.spawn_distance + distance * dt
    
    -- Spawn obstacles
    local gap = difficulty:get_random_gap()
    if self.spawn_distance >= self.last_gap + gap then
        local obstacle_type = difficulty:get_random_obstacle()
        local new_obstacle = ObstacleTypes.spawn_obstacle(obstacle_type, 490, 252)
        
        if new_obstacle then
            if new_obstacle.type then
                -- Single obstacle
                table.insert(self.obstacles, new_obstacle)
            else
                -- Combo obstacle with sub-obstacles
                for _, sub in pairs(new_obstacle) do
                    if sub.type then
                        table.insert(self.obstacles, sub)
                    end
                end
            end
        end
        
        self.spawn_distance = 0
        self.last_gap = gap
    end
    
    -- Spawn power cores
    self.core_timer = self.core_timer + distance * dt
    if self.core_timer >= self.core_spawn_distance then
        local px = player.x
        if px + 200 < 490 then
            local core = Collectible.new("core", 490, 200)
            core.powerup_type = self:_choose_powerup()
            table.insert(self.collectibles, core)
        end
        self.core_timer = 0
        self.core_spawn_distance = 2000 + love.math.random() * 1000
    end
    
    -- Spawn data fragments in groups
    local spawn_odds = 0.4
    if love.math.random() < spawn_odds * dt then
        local group_size = 3 + love.math.random(0, 2)
        local base_x = 490
        local base_y = 80 + love.math.random() * 60
        
        for i = 1, group_size do
            local frag = Collectible.new("fragment", base_x + i * 24, base_y)
            table.insert(self.collectibles, frag)
        end
    end
    
    -- Update all entities
    for _, obs in ipairs(self.obstacles) do
        if obs.type then
            obs:update(dt, distance)
        else
            if obs.g1 then obs.g1:update(dt, distance) end
            if obs.g2 then obs.g2:update(dt, distance) end
            if obs.g4 then obs.g4:update(dt, distance) end
            if obs.a1 then obs.a1:update(dt, distance) end
            if obs.a2 then obs.a2:update(dt, distance) end
            if obs.a3 then obs.a3:update(dt, distance) end
            if obs.f1 then obs.f1:update(dt, distance) end
            if obs.f2 then obs.f2:update(dt, distance) end
        end
    end
    
    for _, coll in ipairs(self.collectibles) do
        coll:update(dt, distance, player.magnet_active, player.x, player.y)
    end
    
    -- Remove offscreen entities
    local i = 1
    while i <= #self.obstacles do
        if self.obstacles[i].x < -50 then
            table.remove(self.obstacles, i)
        else
            i = i + 1
        end
    end
    
    i = 1
    while i <= #self.collectibles do
        if self.collectibles[i].x < -50 then
            table.remove(self.collectibles, i)
        else
            i = i + 1
        end
    end
end

function Spawner:_choose_powerup()
    local roll = love.math.random()
    if roll < 0.2 then
        return "shield"
    elseif roll < 0.4 then
        return "slow_mo"
    elseif roll < 0.65 then
        return "magnet"
    else
        return "double_points"
    end
end

function Spawner:clear()
    self.obstacles = {}
    self.collectibles = {}
end

return Spawner
