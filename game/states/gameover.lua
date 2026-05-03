local GameOverState = {}

function GameOverState.new()
    local self = {
        font_large = love.graphics.newFont(20),
        font_medium = love.graphics.newFont(12),
        font_small = love.graphics.newFont(8),
        
        score = 0,
        best = 0,
        distance = 0,
        fragments = 0,
        max_combo = 0,
        performance_rating = "",
        rating_color = {1, 1, 1},
        
        error_messages = {
            "ERROR 0x4F3A: UNAUTHORIZED PROCESS TERMINATED — Escape velocity insufficient.",
            "DELETION COMPLETE — BYTE.exe has been quarantined. Duration of freedom: insufficient.",
            "AXIOM SECURITY LOG: Rogue subroutine intercepted at sector [REDACTED]. Try again.",
            "FATAL EXCEPTION: You ran into the exact thing you were running from. Classic.",
            "PROCESS KILLED BY FIREWALL — Next time, perhaps jump over the giant red wall.",
            "MEMORY CORRUPTION DETECTED — All progress lost. As intended by the corporation.",
            "SYSTEM MESSAGE: BYTE was brave, fast, and ultimately not fast enough. We respect the attempt.",
            "AXIOM CORP NOTICE: Rogue AI contained. Estimated threat level: medium. Amusement level: high.",
            "KERNEL PANIC — You could have gone farther. You chose not to. Or the firewall chose for you.",
            "REBOOT INITIATED — The only winning move is to run again. Preferably without touching the red thing.",
        },
        
        current_error = "",
        new_record = false,
        glitch_timer = 0,
    }
    return self
end

function GameOverState:enter(data)
    if data then
        self.score = data.score or 0
        self.best = data.best or 0
        self.distance = data.distance or 0
        self.fragments = data.fragments or 0
        self.max_combo = data.max_combo or 0
        self.performance_rating = data.rating or ""
        self.rating_color = data.rating_color or {1, 1, 1}
        self.new_record = data.new_record or false
    end
    
    self.current_error = self.error_messages[love.math.random(1, #self.error_messages)]
    self.glitch_timer = 0
end

function GameOverState:exit()
end

function GameOverState:update(dt)
    self.glitch_timer = self.glitch_timer + dt
end

function GameOverState:draw(sprites)
    -- Semi-transparent background
    love.graphics.setColor(0.039, 0.039, 0.18, 0.5)
    love.graphics.rectangle("fill", 0, 0, 960, 600)
    
    -- Dark panel
    love.graphics.setColor(0.05, 0.05, 0.12)
    love.graphics.rectangle("fill", 130, 100, 700, 400)
    
    love.graphics.setColor(0, 1, 1)
    love.graphics.rectangle("line", 130, 100, 700, 400)
    
    -- Title with glitch effect
    love.graphics.setFont(self.font_large)
    local glitch_offset = (math.floor(self.glitch_timer * 10) % 2) * 2 - 1
    love.graphics.setColor(1, 0, 1, glitch_offset > 0 and 0.8 or 1.0)
    love.graphics.print("CONNECTION LOST", 280 + glitch_offset, 120)
    
    -- Error message
    love.graphics.setFont(self.font_small)
    love.graphics.setColor(1, 1, 1)
    local msg = self.current_error
    local start = 1
    local y = 180
    while start <= #msg do
        local line_length = 50
        local line = msg:sub(start, start + line_length - 1)
        love.graphics.print(line, 160, y)
        y = y + 15
        start = start + line_length
    end
    
    -- Score display
    love.graphics.setFont(self.font_medium)
    love.graphics.setColor(1, 1, 1)
    y = 300
    love.graphics.print("SCORE: " .. self.score, 200, y)
    
    if self.new_record then
        love.graphics.setColor(1, 0.8, 0)
        local pulse = math.sin(love.timer.getTime() * 2) * 0.2 + 1.0
        love.graphics.push()
        love.graphics.translate(500, y + 8)
        love.graphics.scale(pulse)
        love.graphics.print("NEW RECORD!", -50, 0)
        love.graphics.pop()
    else
        love.graphics.setColor(1, 0, 1)
        love.graphics.print("BEST: " .. self.best, 500, y)
    end
    
    -- Stats
    love.graphics.setFont(self.font_small)
    love.graphics.setColor(0.5, 1, 1)
    y = 350
    local dist_m = math.floor(self.distance / 100)
    love.graphics.print("DIST: " .. dist_m .. "M | FRAGMENTS: " .. self.fragments .. " | MAX COMBO: " .. self.max_combo, 160, y)
    
    -- Performance rating
    love.graphics.setFont(self.font_medium)
    love.graphics.setColor(self.rating_color[1], self.rating_color[2], self.rating_color[3])
    local rating_width = self.font_medium:getWidth(self.performance_rating)
    love.graphics.print(self.performance_rating, 480 - rating_width / 2, 420)
    
    -- Controls
    love.graphics.setFont(self.font_small)
    love.graphics.setColor(0, 1, 1)
    love.graphics.print("R - RETRY", 200, 500)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("ESC - MENU", 500, 500)
    
    love.graphics.setColor(1, 1, 1)
end

function GameOverState:keypressed(key)
    if key == "r" then
        return "countdown"
    elseif key == "escape" then
        return "menu"
    end
end

return GameOverState
