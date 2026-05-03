local Difficulty = {}

function Difficulty.new()
    local self = {
        distance = 0,
        elapsed_time = 0,
        base_speed = 200,
        current_speed = 200,
        target_speed = 200,
        speed_increment = 10,
        time_until_speed_increase = 10,
        gap_range = {500, 700},
        min_gap = 500,
        max_gap = 700,
        obstacle_pool = {"g1", "g3"},
        speed_notifications = {},
    }
    return self
end

local PHASE_SPEEDS = {
    {min=0, max=500, speed=200, gap={500,700}, pool={"g1","g3"}},
    {min=500, max=1000, speed=260, gap={420,580}, pool={"g1","g2","g3","a1"}},
    {min=1000, max=2000, speed=300, gap={360,500}, pool={"g1","g2","g3","a1","f1","a2"}},
    {min=2000, max=3500, speed=340, gap={280,420}, pool={"g1","g2","g3","g4","a1","a2","a3","f1","f2","c1","c2"}},
    {min=3500, max=5000, speed=380, gap={200,340}, pool={"g1","g2","g3","g4","a1","a2","a3","f1","f2","c1","c2","c3","c4"}},
    {min=5000, max=999999, speed=400, gap={160,280}, pool={"g1","g2","g3","g4","a1","a2","a3","f1","f2","c1","c2","c3","c4","c5"}},
}

function Difficulty:update(dt, score)
    self.distance = self.distance + self.current_speed * dt
    self.elapsed_time = self.elapsed_time + dt
    
    -- Find current phase based on score
    local phase = PHASE_SPEEDS[1]
    for _, p in ipairs(PHASE_SPEEDS) do
        if score >= p.min and score < p.max then
            phase = p
            break
        end
    end
    
    -- Lerp current speed toward target phase speed
    self.target_speed = phase.speed
    local diff = self.target_speed - self.current_speed
    if math.abs(diff) > 1 then
        self.current_speed = self.current_speed + diff * (dt / 2)
    else
        self.current_speed = self.target_speed
    end
    
    -- Check for speed increase every 10 seconds
    self.time_until_speed_increase = self.time_until_speed_increase - dt
    if self.time_until_speed_increase <= 0 then
        self.current_speed = self.current_speed + self.speed_increment
        self.time_until_speed_increase = 10
        table.insert(self.speed_notifications, {
            timer = 0,
            text = "SPEED UP"
        })
    end
    
    -- Cap speed
    self.current_speed = math.min(self.current_speed, 400)
    
    -- Update gap and pool
    self.gap_range = phase.gap
    self.min_gap = phase.gap[1]
    self.max_gap = phase.gap[2]
    self.obstacle_pool = phase.pool
    
    -- Update notifications
    local i = 1
    while i <= #self.speed_notifications do
        self.speed_notifications[i].timer = self.speed_notifications[i].timer + dt
        if self.speed_notifications[i].timer > 1.2 then
            table.remove(self.speed_notifications, i)
        else
            i = i + 1
        end
    end
end

function Difficulty:get_random_gap()
    return self.min_gap + love.math.random() * (self.max_gap - self.min_gap)
end

function Difficulty:get_random_obstacle()
    if #self.obstacle_pool == 0 then
        return "g1"
    end
    return self.obstacle_pool[love.math.random(1, #self.obstacle_pool)]
end

return Difficulty
