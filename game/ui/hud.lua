local HUD = {}

function HUD.new()
    local self = {
        font_small = love.graphics.newFont(6),
        font_medium = love.graphics.newFont(8),
        toasts = {},
    }
    return self
end

function HUD:draw(score, best, distance, speed, combo_count, active_powerup, powerup_timer, powerup_max, difficulty)
    love.graphics.setFont(self.font_medium)
    
    -- Score (top-left)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SCORE: " .. string.format("%06d", score), 10, 10)
    
    -- Distance (below score)
    love.graphics.setFont(self.font_small)
    love.graphics.print("DIST: " .. string.format("%04d", math.floor(distance / 100)) .. "M", 10, 26)
    
    -- Best score (top-right)
    love.graphics.setFont(self.font_medium)
    love.graphics.setColor(1, 0, 1)
    love.graphics.print("BEST: " .. string.format("%06d", best), 850, 10)
    
    -- Speed bar (bottom-left)
    love.graphics.setFont(self.font_small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SPD", 10, 570)
    
    local speed_fill = (speed - 200) / 200
    speed_fill = math.max(0, math.min(1, speed_fill))
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 50, 573, 80, 8)
    love.graphics.setColor(0, 1, 1)
    love.graphics.rectangle("fill", 50, 573, 80 * speed_fill, 8)
    
    -- Power-up indicator (bottom-right)
    if active_powerup then
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 850, 560, 16, 16)
        
        local bar_fill = powerup_timer / powerup_max
        local bar_color = {0, 1, 1}
        if active_powerup == "shield" then
            bar_color = {0, 1, 1}
        elseif active_powerup == "slow_mo" then
            bar_color = {0.616, 0, 1}
        elseif active_powerup == "magnet" then
            bar_color = {1, 0, 1}
        elseif active_powerup == "double_points" then
            bar_color = {1, 0.8, 0}
        end
        
        local blink = (powerup_timer < 2 and math.sin(love.timer.getTime() * 8) > 0) and 0.5 or 1.0
        love.graphics.setColor(bar_color[1], bar_color[2], bar_color[3], blink)
        love.graphics.rectangle("fill", 880, 568, 64 * bar_fill, 8)
    end
    
    -- Combo indicator (top-center)
    if combo_count >= 5 then
        local combo_tier = "LINKED"
        local combo_color = {0, 1, 1}
        if combo_count >= 15 then
            combo_tier = "OVERCLOCKED"
            combo_color = {1, 0.8, 0}
        elseif combo_count >= 10 then
            combo_tier = "SYNCED"
            combo_color = {1, 0, 1}
        end
        
        local scale = math.sin(love.timer.getTime() * 3) * 0.1 + 1.0
        love.graphics.setFont(self.font_small)
        love.graphics.setColor(combo_color[1], combo_color[2], combo_color[3])
        
        local text = combo_tier .. " x" .. combo_count
        local width = self.font_small:getWidth(text)
        love.graphics.push()
        love.graphics.translate(480 - width / 2, 30)
        love.graphics.scale(scale)
        love.graphics.print(text, 0, 0)
        love.graphics.pop()
    end
    
    -- Draw toasts
    love.graphics.setFont(self.font_medium)
    for i, toast in ipairs(difficulty.speed_notifications) do
        local alpha = 1.0 - (toast.timer / 1.2)
        love.graphics.setColor(1, 0.2, 1, alpha)
        local offset_x = 100 - (toast.timer / 1.2) * 50
        love.graphics.print(toast.text, 700 + offset_x, 100 + i * 30)
    end
    
    for i, toast in ipairs(scoring and scoring.milestone_toasts or {}) do
        local alpha = 1.0 - (toast.timer / 1.5)
        love.graphics.setColor(toast.color[1], toast.color[2], toast.color[3], alpha)
        local text = toast.text .. " +200"
        local width = self.font_medium:getWidth(text)
        love.graphics.print(text, 480 - width / 2, 250 + i * 40)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont())
end

return HUD
