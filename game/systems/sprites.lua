local Sprites = {}

-- Helper to draw pixel at native scale
local function pixel(x, y, r, g, b, a)
    a = a or 1.0
    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("fill", x, y, 1, 1)
end

-- Helper to draw line of pixels
local function rect(x, y, w, h, r, g, b, a)
    a = a or 1.0
    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("fill", x, y, w, h)
end

-- Helper to draw outline rectangle
local function outline(x, y, w, h, r, g, b, a)
    a = a or 1.0
    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("line", x, y, w, h)
end

-- Color palette
local COLORS = {
    bg_deep = {0.039, 0.039, 0.18},      -- #0A0A2E
    bg_mid = {0.051, 0.051, 0.239},     -- #0D0D3D
    grid = {0.102, 0.102, 0.306, 0.15}, -- #1A1A4E
    cyan = {0, 1, 1},                    -- #00FFFF
    pink = {1, 0, 1},                    -- #FF00FF
    purple = {0.616, 0, 1},              -- #9D00FF
    orange = {1, 0.4, 0},                -- #FF6600
    red = {1, 0, 0.2},                   -- #FF0033
    gold = {1, 0.8, 0},                  -- #FFCC00
    white = {1, 1, 1},                   -- #FFFFFF
    dark_gray = {0.118, 0.118, 0.239},   -- #1E1E3E
}

function Sprites.load()
    Sprites.player = {}
    Sprites.obstacles = {}
    Sprites.collectibles = {}
    
    -- Player sprites
    Sprites.player.run = {}
    Sprites.player.jump = {}
    Sprites.player.slide = nil
    Sprites.player.death = {}
    
    for i = 1, 4 do
        Sprites.player.run[i] = love.graphics.newCanvas(16, 16)
        love.graphics.setCanvas(Sprites.player.run[i])
        love.graphics.clear(0, 0, 0, 0)
        Sprites:_draw_player_run(i)
        love.graphics.setCanvas()
    end
    
    for i = 1, 2 do
        Sprites.player.jump[i] = love.graphics.newCanvas(16, 16)
        love.graphics.setCanvas(Sprites.player.jump[i])
        love.graphics.clear(0, 0, 0, 0)
        Sprites:_draw_player_jump(i)
        love.graphics.setCanvas()
    end
    
    Sprites.player.slide = love.graphics.newCanvas(16, 16)
    love.graphics.setCanvas(Sprites.player.slide)
    love.graphics.clear(0, 0, 0, 0)
    Sprites:_draw_player_slide()
    love.graphics.setCanvas()
    
    for i = 1, 3 do
        Sprites.player.death[i] = love.graphics.newCanvas(16, 16)
        love.graphics.setCanvas(Sprites.player.death[i])
        love.graphics.clear(0, 0, 0, 0)
        Sprites:_draw_player_death(i)
        love.graphics.setCanvas()
    end
    
    -- Obstacle sprites
    Sprites.obstacles.firewall_low = love.graphics.newCanvas(32, 32)
    love.graphics.setCanvas(Sprites.obstacles.firewall_low)
    love.graphics.clear(0, 0, 0, 0)
    Sprites:_draw_firewall_low()
    love.graphics.setCanvas()
    
    Sprites.obstacles.firewall_high = love.graphics.newCanvas(32, 48)
    love.graphics.setCanvas(Sprites.obstacles.firewall_high)
    love.graphics.clear(0, 0, 0, 0)
    Sprites:_draw_firewall_high()
    love.graphics.setCanvas()
    
    Sprites.obstacles.corrupted_node = love.graphics.newCanvas(24, 24)
    love.graphics.setCanvas(Sprites.obstacles.corrupted_node)
    love.graphics.clear(0, 0, 0, 0)
    Sprites:_draw_corrupted_node()
    love.graphics.setCanvas()
    
    Sprites.obstacles.data_wall = love.graphics.newCanvas(16, 64)
    love.graphics.setCanvas(Sprites.obstacles.data_wall)
    love.graphics.clear(0, 0, 0, 0)
    Sprites:_draw_data_wall()
    love.graphics.setCanvas()
    
    -- Collectible sprites
    Sprites.collectibles.data_fragment = {}
    for i = 1, 8 do
        Sprites.collectibles.data_fragment[i] = love.graphics.newCanvas(12, 12)
        love.graphics.setCanvas(Sprites.collectibles.data_fragment[i])
        love.graphics.clear(0, 0, 0, 0)
        Sprites:_draw_data_fragment(i)
        love.graphics.setCanvas()
    end
    
    Sprites.collectibles.power_core = {}
    for i = 1, 8 do
        Sprites.collectibles.power_core[i] = love.graphics.newCanvas(16, 16)
        love.graphics.setCanvas(Sprites.collectibles.power_core[i])
        love.graphics.clear(0, 0, 0, 0)
        Sprites:_draw_power_core(i)
        love.graphics.setCanvas()
    end
    
    love.graphics.setCanvas()
end

function Sprites:_draw_player_run(frame)
    local navy = COLORS.bg_mid
    local cyan = COLORS.cyan
    local white = COLORS.white
    
    -- Body
    rect(5, 5, 6, 10, navy[1], navy[2], navy[3])
    outline(5, 5, 6, 10, cyan[1], cyan[2], cyan[3])
    
    -- Head
    rect(6, 1, 4, 4, navy[1], navy[2], navy[3])
    outline(6, 1, 4, 4, cyan[1], cyan[2], cyan[3])
    
    -- Eye
    pixel(7, 2, white[1], white[2], white[3])
    pixel(8, 2, white[1], white[2], white[3])
    pixel(7, 3, white[1], white[2], white[3])
    pixel(8, 3, white[1], white[2], white[3])
    
    -- Legs alternate
    if frame == 1 or frame == 3 then
        rect(6, 15, 2, 4, cyan[1], cyan[2], cyan[3])
        rect(9, 13, 2, 4, cyan[1], cyan[2], cyan[3])
    else
        rect(6, 13, 2, 4, cyan[1], cyan[2], cyan[3])
        rect(9, 15, 2, 4, cyan[1], cyan[2], cyan[3])
    end
    
    -- Arm
    if frame == 1 or frame == 4 then
        rect(11, 6, 1, 3, cyan[1], cyan[2], cyan[3])
    else
        rect(3, 6, 1, 3, cyan[1], cyan[2], cyan[3])
    end
end

function Sprites:_draw_player_jump(frame)
    local navy = COLORS.bg_mid
    local cyan = COLORS.cyan
    local white = COLORS.white
    
    local x_offset = (frame == 1) and 1 or -1
    
    -- Body (offset for lean)
    rect(5 + x_offset, 5, 6, 10, navy[1], navy[2], navy[3])
    outline(5 + x_offset, 5, 6, 10, cyan[1], cyan[2], cyan[3])
    
    -- Head
    rect(6 + x_offset, 1, 4, 4, navy[1], navy[2], navy[3])
    outline(6 + x_offset, 1, 4, 4, cyan[1], cyan[2], cyan[3])
    
    -- Eye
    pixel(7 + x_offset, 2, white[1], white[2], white[3])
    pixel(8 + x_offset, 2, white[1], white[2], white[3])
    pixel(7 + x_offset, 3, white[1], white[2], white[3])
    pixel(8 + x_offset, 3, white[1], white[2], white[3])
    
    -- Legs together
    rect(7 + x_offset, 14, 2, 2, cyan[1], cyan[2], cyan[3])
    rect(10 + x_offset, 14, 2, 2, cyan[1], cyan[2], cyan[3])
    
    -- Arms
    if frame == 1 then
        rect(12 + x_offset, 4, 1, 3, cyan[1], cyan[2], cyan[3])
    else
        rect(3 + x_offset, 4, 1, 3, cyan[1], cyan[2], cyan[3])
    end
end

function Sprites:_draw_player_slide()
    local navy = COLORS.bg_mid
    local cyan = COLORS.cyan
    local white = COLORS.white
    
    -- Flattened body
    rect(3, 10, 10, 6, navy[1], navy[2], navy[3])
    outline(3, 10, 10, 6, cyan[1], cyan[2], cyan[3])
    
    -- Head moved right
    rect(10, 9, 4, 4, navy[1], navy[2], navy[3])
    outline(10, 9, 4, 4, cyan[1], cyan[2], cyan[3])
    
    -- Eye
    pixel(12, 10, white[1], white[2], white[3])
    pixel(13, 10, white[1], white[2], white[3])
    pixel(12, 11, white[1], white[2], white[3])
    pixel(13, 11, white[1], white[2], white[3])
end

function Sprites:_draw_player_death(frame)
    local cyan = COLORS.cyan
    local white = COLORS.white
    
    if frame == 1 then
        -- Mostly intact, some pixels flying
        rect(5, 5, 6, 10, 0.05, 0.05, 0.2)
        outline(5, 5, 6, 10, cyan[1], cyan[2], cyan[3], 0.8)
        
        pixel(2, 1, cyan[1], cyan[2], cyan[3])
        pixel(14, 1, cyan[1], cyan[2], cyan[3])
        pixel(2, 14, cyan[1], cyan[2], cyan[3])
        pixel(14, 14, cyan[1], cyan[2], cyan[3])
    elseif frame == 2 then
        -- Half gone
        for x = 5, 7 do
            for y = 5, 12 do
                if love.math.random() > 0.5 then
                    pixel(x, y, cyan[1], cyan[2], cyan[3])
                end
            end
        end
    else
        -- Mostly gone, just a few pixels
        pixel(4, 4, white[1], white[2], white[3])
        pixel(8, 8, cyan[1], cyan[2], cyan[3])
        pixel(12, 5, white[1], white[2], white[3])
    end
end

function Sprites:_draw_firewall_low()
    local dark_red = {0.2, 0, 0.05}
    local red = COLORS.red
    local dark_red2 = {0.8, 0, 0.15}
    local light_red = {1, 0.2, 0.33}
    
    -- Main fill
    rect(0, 0, 32, 32, dark_red[1], dark_red[2], dark_red[3])
    
    -- Bright face
    rect(2, 2, 28, 28, red[1], red[2], red[3])
    
    -- Darker inner
    rect(4, 6, 24, 20, dark_red2[1], dark_red2[2], dark_red2[3])
    
    -- Top highlight
    rect(2, 2, 28, 2, light_red[1], light_red[2], light_red[3])
    
    -- Warning texture diagonal lines
    for i = 0, 6 do
        pixel(2 + i * 6, 4 + (i % 2) * 6, red[1], red[2], red[3])
    end
    
    -- Border
    outline(0, 0, 32, 32, red[1], red[2], red[3])
end

function Sprites:_draw_firewall_high()
    local dark_red = {0.2, 0, 0.05}
    local red = COLORS.red
    local dark_red2 = {0.8, 0, 0.15}
    local light_red = {1, 0.2, 0.33}
    
    rect(0, 0, 32, 48, dark_red[1], dark_red[2], dark_red[3])
    rect(2, 2, 28, 44, red[1], red[2], red[3])
    rect(4, 6, 24, 36, dark_red2[1], dark_red2[2], dark_red2[3])
    rect(2, 2, 28, 2, light_red[1], light_red[2], light_red[3])
    
    for i = 0, 6 do
        pixel(2 + i * 6, 4 + (i % 2) * 6, red[1], red[2], red[3])
        pixel(2 + i * 6, 20 + (i % 2) * 6, red[1], red[2], red[3])
    end
    
    outline(0, 0, 32, 48, red[1], red[2], red[3])
    pixel(0, 32, red[1], red[2], red[3])
    pixel(31, 32, red[1], red[2], red[3])
end

function Sprites:_draw_corrupted_node()
    local purple = COLORS.purple
    local pink = COLORS.pink
    local dark_purple = {0.1, 0, 0.2}
    
    rect(2, 2, 20, 20, purple[1], purple[2], purple[3])
    rect(6, 6, 12, 12, dark_purple[1], dark_purple[2], dark_purple[3])
    
    pixel(2, 2, pink[1], pink[2], pink[3])
    pixel(20, 2, pink[1], pink[2], pink[3])
    pixel(2, 20, pink[1], pink[2], pink[3])
    pixel(20, 20, pink[1], pink[2], pink[3])
    
    outline(2, 2, 20, 20, purple[1], purple[2], purple[3])
end

function Sprites:_draw_data_wall()
    local dark_red = {0.2, 0, 0.05}
    local red = COLORS.red
    local pink_light = {1, 0.2, 0.33}
    local dark_red2 = {0.8, 0, 0.15}
    
    rect(0, 0, 16, 64, dark_red[1], dark_red[2], dark_red[3])
    rect(2, 2, 12, 60, red[1], red[2], red[3])
    
    outline(2, 0, 1, 64, pink_light[1], pink_light[2], pink_light[3])
    outline(13, 0, 1, 64, pink_light[1], pink_light[2], pink_light[3])
    
    for y = 10, 50, 20 do
        rect(2, y, 12, 2, dark_red2[1], dark_red2[2], dark_red2[3])
    end
end

function Sprites:_draw_data_fragment(frame)
    local cyan = COLORS.cyan
    local white = COLORS.white
    
    -- Diamond shape with squish effect per frame for rotation simulation
    local rows = {
        {2, 1}, {2, 2}, {3, 2}, {4, 2}, {5, 2},
        {3, 3}, {4, 3},
        {2, 4}, {3, 4}, {4, 4}, {5, 4},
        {3, 5}, {4, 5},
        {2, 6}, {3, 6}, {4, 6}, {5, 6},
        {3, 7}, {4, 7},
        {2, 8}, {3, 8}, {4, 8}, {5, 8}
    }
    
    for _, coord in ipairs(rows) do
        local x, y = coord[1], coord[2]
        if (x == 5 or x == 2) and (y == 2 or y == 6 or y == 8) then
            pixel(x, y, white[1], white[2], white[3])
        else
            pixel(x, y, cyan[1], cyan[2], cyan[3])
        end
    end
end

function Sprites:_draw_power_core(frame)
    local gold = COLORS.gold
    local white = COLORS.white
    local orange = COLORS.orange
    
    local pulse = 3 + math.floor(frame / 2)
    
    rect(2, 2, 12, 12, gold[1], gold[2], gold[3])
    rect(4, 4, pulse * 2, pulse * 2, white[1], white[2], white[3])
    
    pixel(1, 1, orange[1], orange[2], orange[3])
    pixel(13, 1, orange[1], orange[2], orange[3])
    pixel(1, 13, orange[1], orange[2], orange[3])
    pixel(13, 13, orange[1], orange[2], orange[3])
    
    outline(2, 2, 12, 12, gold[1], gold[2], gold[3], 0.7)
end

return Sprites
