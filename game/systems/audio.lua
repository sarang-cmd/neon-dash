local Audio = {}

function Audio.new()
    local self = {
        muted = false,
        sources = {},
        music = nil,
        music_pitch = 1.0,
    }
    return self
end

function Audio:play_sfx(name)
    if self.muted then return end
    -- Stub: Sound effects would be loaded here
    -- For now, all effects are silent stubs
end

function Audio:play_music(name)
    if self.muted then return end
    -- Background music would be loaded and looped here
end

function Audio:stop_music()
    if self.music then
        self.music:stop()
        self.music = nil
    end
end

function Audio:set_music_pitch(factor)
    self.music_pitch = factor
    if self.music then
        self.music:setPitch(factor)
    end
end

function Audio:toggle_mute()
    self.muted = not self.muted
    if self.muted and self.music then
        self.music:stop()
    elseif not self.muted and self.music then
        self.music:play()
    end
end

function Audio:update(dt)
    -- Music state updates would go here
end

return Audio
