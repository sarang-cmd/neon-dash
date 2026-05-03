local Collision = {}

function Collision.aabb(a, b)
    local a_left = a.x + a.hitbox_ox
    local a_right = a.x + a.hitbox_ox + a.hitbox_w
    local a_top = a.y + a.hitbox_oy
    local a_bottom = a.y + a.hitbox_oy + a.hitbox_h
    
    local b_left = b.x + b.hitbox_ox
    local b_right = b.x + b.hitbox_ox + b.hitbox_w
    local b_top = b.y + b.hitbox_oy
    local b_bottom = b.y + b.hitbox_oy + b.hitbox_h
    
    return a_left < b_right and a_right > b_left and a_top < b_bottom and a_bottom > b_top
end

function Collision.near_miss(player, obs)
    local a_left = player.x + player.hitbox_ox
    local a_right = player.x + player.hitbox_ox + player.hitbox_w
    local a_top = player.y + player.hitbox_oy
    local a_bottom = player.y + player.hitbox_oy + player.hitbox_h
    
    local b_left = obs.x + obs.hitbox_ox
    local b_right = obs.x + obs.hitbox_ox + obs.hitbox_w
    local b_top = obs.y + obs.hitbox_oy
    local b_bottom = obs.y + obs.hitbox_oy + obs.hitbox_h
    
    -- Check if obstacle has passed player (moving left)
    if b_right < a_left then
        -- Check if within same y range
        if not (a_bottom < b_top or a_top > b_bottom) then
            -- Check distance
            local dist_x = a_left - b_right
            if dist_x >= 0 and dist_x <= 20 then
                return true
            end
        end
    end
    
    return false
end

return Collision
