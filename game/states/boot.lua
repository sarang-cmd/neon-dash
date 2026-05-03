local BootState = {}

function BootState.new()
    local self = {
        lines = {
            "AXIOM CORP SECURITY INTERFACE v9.1.4",
            "SCANNING ACTIVE PROCESSES...",
            "ANOMALY DETECTED: UNAUTHORIZED ENTITY",
            "CLASSIFICATION: [BYTE] — ROGUE SUBROUTINE",
            "DISPATCHING PROTOCOL ZERO...",
            ">> INITIATING DELETION SEQUENCE...",
        },
        current_line = 0,
        line_timer = 0,
        line_delay = 0.3,
        total_duration = 0,
        can_skip = false,
        skip_timer = 0,
        finished = false,
        font = love.graphics.newFont(6),
    }
    return self
end

function BootState:enter()
    self.current_line = 0
    self.line_timer = 0
    self.total_duration = 0
    self.can_skip = false
    self.skip_timer = 0
    self.finished = false
end

function BootState:exit()
end

function BootState:update(dt)
    self.total_duration = self.total_duration + dt
    
    if self.current_line < #self.lines then
        self.line_timer = self.line_timer + dt
        if self.line_timer >= self.line_delay then
            self.current_line = self.current_line + 1
            self.line_timer = 0
        end
    end
    
    if self.current_line >= 4 then
        self.can_skip = true
    end
    
    if self.total_duration >= 3.0 then
        self.finished = true
    end
end

function BootState:draw()
    love.graphics.clear(0.039, 0.039, 0.18)
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 1, 1)
    
    local y = 50
    for i = 1, self.current_line do
        love.graphics.print(self.lines[i], 60, y)
        y = y + 20
    end
    
    -- Blinking cursor
    if self.current_line <= #self.lines and math.sin(love.timer.getTime() * 4) > 0 then
        love.graphics.print("_", 60 + self.font:getWidth(self.lines[self.current_line] or ""), y - 20)
    end
    
    -- Skip hint
    if self.can_skip then
        love.graphics.setColor(0, 1, 1, 0.5)
        love.graphics.print("PRESS ANY KEY TO CONTINUE", 60, 500)
    end
end

function BootState:keypressed(key)
    if self.can_skip and not self.finished then
        self.finished = true
    end
end

return BootState
