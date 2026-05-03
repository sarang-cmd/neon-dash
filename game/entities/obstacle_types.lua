local Obstacle = require("game.entities.obstacle")

local ObstacleTypes = {}

-- Ground obstacles
function ObstacleTypes.create_firewall_low(x, y)
    return Obstacle.new("g1", x, y, {
        w = 32, h = 32,
        hitbox_ox = 2, hitbox_oy = 2,
        hitbox_w = 28, hitbox_h = 28,
        color = {1, 0, 0.2},
        frames = 1,
    })
end

function ObstacleTypes.create_firewall_high(x, y)
    return Obstacle.new("g2", x, y, {
        w = 32, h = 48,
        hitbox_ox = 2, hitbox_oy = 2,
        hitbox_w = 28, hitbox_h = 44,
        color = {1, 0, 0.2},
        frames = 1,
    })
end

function ObstacleTypes.create_corrupted_node(x, y)
    return Obstacle.new("g3", x, y, {
        w = 24, h = 24,
        hitbox_ox = 2, hitbox_oy = 2,
        hitbox_w = 20, hitbox_h = 20,
        color = {0.616, 0, 1},
        frames = 1,
    })
end

function ObstacleTypes.create_data_wall(x, y)
    return Obstacle.new("g4", x, y, {
        w = 16, h = 64,
        hitbox_ox = 2, hitbox_oy = 2,
        hitbox_w = 12, hitbox_h = 60,
        color = {1, 0, 0.2},
        frames = 1,
    })
end

-- Air obstacles
function ObstacleTypes.create_laser_gate(x, y)
    return Obstacle.new("a1", x, y, {
        w = 8, h = 200,
        hitbox_ox = 0, hitbox_oy = 0,
        hitbox_w = 8, hitbox_h = 200,
        color = {1, 0.4, 0},
        frames = 1,
        sweep_position = 0,
        sweep_direction = 1,
    })
end

function ObstacleTypes.create_security_drone(x, y)
    return Obstacle.new("a2", x, y, {
        w = 32, h = 16,
        hitbox_ox = 2, hitbox_oy = 2,
        hitbox_w = 28, hitbox_h = 12,
        color = {1, 0.4, 0},
        frames = 2,
    })
end

function ObstacleTypes.create_firewall_beam(x, y)
    return Obstacle.new("a3", x, y, {
        w = 960, h = 6,
        hitbox_ox = 0, hitbox_oy = 0,
        hitbox_w = 960, hitbox_h = 6,
        color = {1, 0, 0.2},
        frames = 1,
    })
end

-- Floating obstacles
function ObstacleTypes.create_data_mine(x, y)
    return Obstacle.new("f1", x, y, {
        w = 24, h = 24,
        hitbox_ox = 3, hitbox_oy = 3,
        hitbox_w = 18, hitbox_h = 18,
        color = {0.616, 0, 1},
        frames = 8,
    })
end

function ObstacleTypes.create_viral_cluster(x, y)
    local cluster = Obstacle.new("f2", x, y, {
        w = 72, h = 24,
        hitbox_ox = 0, hitbox_oy = 0,
        hitbox_w = 72, hitbox_h = 24,
        color = {1, 0, 1},
        frames = 8,
    })
    cluster.sub_obstacles = {
        {x = 0, y = 0},
        {x = 20, y = -8},
        {x = 40, y = 0},
    }
    return cluster
end

-- Combo obstacles
function ObstacleTypes.create_combo_g1_a1(x, y)
    local combo = {}
    combo.g1 = ObstacleTypes.create_firewall_low(x, y + 20)
    combo.a1 = ObstacleTypes.create_laser_gate(x + 20, y)
    combo.type = "c1"
    return combo
end

function ObstacleTypes.create_combo_f1_g1(x, y)
    local combo = {}
    combo.f1 = ObstacleTypes.create_data_mine(x, y)
    combo.g1 = ObstacleTypes.create_firewall_low(x + 30, y + 50)
    combo.type = "c2"
    return combo
end

function ObstacleTypes.create_combo_a2_a3(x, y)
    local combo = {}
    combo.a2 = ObstacleTypes.create_security_drone(x, y)
    combo.a3 = ObstacleTypes.create_firewall_beam(x, y + 20)
    combo.type = "c3"
    return combo
end

function ObstacleTypes.create_combo_f2_g2(x, y)
    local combo = {}
    combo.f2 = ObstacleTypes.create_viral_cluster(x, y)
    combo.g2 = ObstacleTypes.create_firewall_high(x + 40, y + 60)
    combo.type = "c4"
    return combo
end

function ObstacleTypes.create_combo_g4_f1(x, y)
    local combo = {}
    combo.g4 = ObstacleTypes.create_data_wall(x, y + 30)
    combo.f1 = ObstacleTypes.create_data_mine(x + 30, y)
    combo.type = "c5"
    return combo
end

function ObstacleTypes.spawn_obstacle(obstacle_type, x, y)
    if obstacle_type == "g1" then
        return ObstacleTypes.create_firewall_low(x, y)
    elseif obstacle_type == "g2" then
        return ObstacleTypes.create_firewall_high(x, y)
    elseif obstacle_type == "g3" then
        return ObstacleTypes.create_corrupted_node(x, y)
    elseif obstacle_type == "g4" then
        return ObstacleTypes.create_data_wall(x, y)
    elseif obstacle_type == "a1" then
        return ObstacleTypes.create_laser_gate(x, y - 100)
    elseif obstacle_type == "a2" then
        return ObstacleTypes.create_security_drone(x, y - 40)
    elseif obstacle_type == "a3" then
        return ObstacleTypes.create_firewall_beam(x, y - 50)
    elseif obstacle_type == "f1" then
        return ObstacleTypes.create_data_mine(x, y - 80)
    elseif obstacle_type == "f2" then
        return ObstacleTypes.create_viral_cluster(x, y - 80)
    elseif obstacle_type == "c1" then
        return ObstacleTypes.create_combo_g1_a1(x, y - 80)
    elseif obstacle_type == "c2" then
        return ObstacleTypes.create_combo_f1_g1(x, y - 80)
    elseif obstacle_type == "c3" then
        return ObstacleTypes.create_combo_a2_a3(x, y - 80)
    elseif obstacle_type == "c4" then
        return ObstacleTypes.create_combo_f2_g2(x, y - 80)
    elseif obstacle_type == "c5" then
        return ObstacleTypes.create_combo_g4_f1(x, y - 80)
    end
    return nil
end

return ObstacleTypes
