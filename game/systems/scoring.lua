local Scoring = {}

function Scoring.new()
    local self = {
        score = 0,
        highscore = 0,
        distance = 0,
        fragments = 0,
        max_combo = 0,
        current_combo = 0,
        consecutive_fragments = 0,
        near_miss_count = 0,
        score_multiplier = 1.0,
        combo_multiplier = 1.0,
        last_distance_score = 0,
        last_score_check = 0,
        milestone_toasts = {},
    }
    
    -- Load highscore
    local ok, data = pcall(function() return love.filesystem.read("highscore.txt") end)
    if ok and data then
        self.highscore = tonumber(data) or 0
    end
    
    return self
end

function Scoring:update(dt, distance, collision_results, speed_multiplier)
    speed_multiplier = speed_multiplier or 1.0
    self.distance = distance
    
    -- Distance score: +1 per 10 pixels
    local distance_score = math.floor(distance / 10) - math.floor(self.last_distance_score / 10)
    if distance_score > 0 then
        self.score = self.score + distance_score
    end
    self.last_distance_score = distance
    
    -- Process collisions
    if collision_results then
        if collision_results.fragment_collected then
            self.fragments = self.fragments + 1
            self.consecutive_fragments = self.consecutive_fragments + 1
            
            -- Calculate combo multiplier
            if self.consecutive_fragments >= 15 then
                self.combo_multiplier = 3.0
            elseif self.consecutive_fragments >= 10 then
                self.combo_multiplier = 2.0
            elseif self.consecutive_fragments >= 5 then
                self.combo_multiplier = 1.5
            else
                self.combo_multiplier = 1.0
            end
            
            local frag_score = math.floor(10 * self.score_multiplier * self.combo_multiplier)
            self.score = self.score + frag_score
        end
        
        if collision_results.core_collected then
            local core_score = math.floor(100 * self.score_multiplier)
            self.score = self.score + core_score
            self.consecutive_fragments = 0
        end
        
        if collision_results.near_miss then
            self.near_miss_count = self.near_miss_count + 1
            self.score = self.score + 25
        end
        
        if collision_results.death then
            self.consecutive_fragments = 0
        end
    end
    
    -- Update max combo
    self.current_combo = self.consecutive_fragments
    self.max_combo = math.max(self.max_combo, self.current_combo)
    
    -- Milestone checks
    local current_milestone_500 = math.floor(self.score / 500)
    local last_milestone_500 = math.floor(self.last_score_check / 500)
    
    if current_milestone_500 > last_milestone_500 and (current_milestone_500 * 500) % 500 == 0 then
        self.score = self.score + 200
        table.insert(self.milestone_toasts, {
            timer = 0,
            text = "CHECKPOINT",
            color = {0, 1, 1}
        })
    end
    
    if math.floor(self.score / 1000) > math.floor(self.last_score_check / 1000) then
        table.insert(self.milestone_toasts, {
            timer = 0,
            text = "LEVEL UP",
            color = {1, 0.2, 1}
        })
    end
    
    self.last_score_check = self.score
    
    -- Update milestone toasts
    local i = 1
    while i <= #self.milestone_toasts do
        self.milestone_toasts[i].timer = self.milestone_toasts[i].timer + dt
        if self.milestone_toasts[i].timer > 1.5 then
            table.remove(self.milestone_toasts, i)
        else
            i = i + 1
        end
    end
end

function Scoring:get_performance_rating()
    if self.score < 200 then
        return "PROCESS TERMINATED", {0.5, 0.5, 0.5}
    elseif self.score < 600 then
        return "SUBROUTINE FAILED", {1, 0.2, 0.2}
    elseif self.score < 1500 then
        return "PACKET DELIVERED", {1, 0.4, 0}
    elseif self.score < 3000 then
        return "FIREWALL BREACHED", {0, 1, 1}
    elseif self.score < 6000 then
        return "ESCAPE ACHIEVED", {1, 0, 1}
    else
        return "SYSTEM OVERRIDE", {1, 0.8, 0}
    end
end

function Scoring:save_highscore()
    if self.score > self.highscore then
        self.highscore = self.score
        pcall(function()
            love.filesystem.write("highscore.txt", tostring(self.highscore))
        end)
        return true
    end
    return false
end

return Scoring
