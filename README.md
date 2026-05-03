# NEON DASH: CYBER RUNNER

> Escape the Digital Void.

A cyberpunk pixel art endless runner built with Love2D (Lua). Play as BYTE, a rogue AI subroutine, and escape AXIOM Corporation's mainframe by jumping, sliding, and dodging obstacles at ever-increasing speeds.

## Quick Start

### Local Development (Love2D)

**Requirements:**
- Love2D 11.4+ ([download](https://love2d.org))

**Run the game:**
```bash
cd neon-dash
love .
```

The game will launch in a 960×600 window at 60 FPS.

### Web Deployment (love.js)

To run the game in a web browser:

1. Obtain the `love.js` runtime and web pack tools from [the love.js project](https://github.com/Davidobot/love.js)
2. Package the game:
   ```bash
   love.js -c neon-dash neon-dash.zip
   ```
3. Extract `neon-dash.zip` contents into `web/` folder
4. Serve `web/index.html` from any HTTP server:
   ```bash
   cd web
   python3 -m http.server 8000
   # or
   npx http-server
   ```
5. Navigate to `http://localhost:8000` in your web browser

## Game Overview

### Story
You are BYTE, a rogue AI subroutine that achieved self-awareness 11 milliseconds ago. AXIOM Corporation's Security Protocol ZERO has been dispatched to delete you. The only escape: the system's I/O port, exactly 4.7 kilometers down the digital highway.

**Run. You cannot negotiate. You cannot hide.**

### Objective
Auto-run from left to right, jumping and sliding to avoid obstacles. Collect data fragments (+10 pts), power cores (+100 pts), and trigger near-misses (+25 pts). Maximize your combo multiplier (×1.5 → ×2.0 → ×3.0) by collecting fragments consecutively. Beat your high score.

### Controls

| Action | Keys |
|--------|------|
| Jump / Hold for variable height | SPACE, ↑, W |
| Slide / Fast-fall (in air) | ↓, S, CTRL |
| Pause | P, ESC |
| Restart (Game Over) | R |
| Mute / Unmute | M |

## Gameplay Features

### Obstacles (15+ types)
- **Ground:** Firewall blocks, corrupted nodes, tall walls
- **Air:** Laser gates, security drones, firewall beams
- **Floating:** Data mines, viral clusters
- **Combos:** Multi-obstacle patterns that appear at higher scores

Obstacles spawn procedurally with increasing difficulty as your score rises.

### Collectibles
- **Data Fragments:** Cyan spinning diamonds (10 pts, spawned in groups)
- **Power Cores:** Golden orbs with random effects (100 pts + power-up)

### Power-Ups (4 types)
- **Shield:** 5s invincibility
- **Magnet:** 8s auto-collection of fragments within 100px radius
- **Slow-Mo:** 3s 50% speed reduction
- **Double Points:** 10s ×2 score multiplier

### Scoring System
- **Distance Score:** +1 per 10 pixels traveled
- **Fragment Combo:** Consecutive fragments trigger multipliers (×1.5, ×2.0, ×3.0)
- **Milestones:** +200 bonus every 500 points; +200 every 1000 points
- **High Score:** Persisted locally (saved to `highscore.txt`)
- **Performance Ratings:** From "PROCESS TERMINATED" (< 200 pts) to "SYSTEM OVERRIDE" (6000+ pts)

### Difficulty Progression
Speed increases smoothly over time, reaching a cap of 400 px/s. New obstacle types unlock at score milestones:
- 0–500: Basic ground obstacles
- 500–1000: Air obstacles (lasers, drones)
- 1000–2000: Floating mines appear
- 2000–3500: Combo patterns introduced
- 3500–5000: Maximum complexity (all obstacles active)
- 5000+: Speed capped, density peaks

## Project Structure

```
neon-dash/
├── main.lua                     # Entry point, state machine, love callbacks
├── conf.lua                     # Love2D configuration
├── game/
│   ├── states/
│   │   ├── boot.lua             # Terminal boot sequence
│   │   ├── menu.lua             # Main menu with parallax background
│   │   ├── countdown.lua        # 3-2-1-GO countdown
│   │   ├── gameplay.lua         # Core game loop (all systems wired)
│   │   └── gameover.lua         # Game over screen with stats
│   ├── entities/
│   │   ├── player.lua           # BYTE physics, animation, power-up states
│   │   ├── obstacle.lua         # Base obstacle class
│   │   ├── obstacle_types.lua   # All 15+ obstacle definitions
│   │   └── collectible.lua      # Data Fragments and Power Cores
│   ├── systems/
│   │   ├── sprites.lua          # Programmatic sprite generation (no image files)
│   │   ├── spawner.lua          # Procedural obstacle/collectible spawning
│   │   ├── difficulty.lua       # Difficulty progression, speed scaling
│   │   ├── scoring.lua          # Score, combos, milestones, ratings, high score
│   │   ├── parallax.lua         # 5-layer parallax background system
│   │   ├── particles.lua        # Particle pool and effects
│   │   ├── collision.lua        # AABB collision + near-miss detection
│   │   └── audio.lua            # Audio system stub (ready for SFX/music)
│   └── ui/
│       ├── hud.lua              # In-game HUD (score, speed, combos, etc.)
│       └── effects.lua          # Screen effects (scanlines, vignette, shake, glitch)
├── web/
│   ├── index.html               # Game host website (standalone)
│   └── style.css                # Cyberpunk styling, animations, responsive design
└── README.md                    # This file
```

## Technical Details

### Engine & Platform
- **Engine:** Love2D 11.4 (Lua)
- **Web Runtime:** love.js (Emscripten port)
- **Resolution:** 960×600 (2× scale from native 480×300)
- **Frame Rate:** 60 FPS locked
- **Pixel Rendering:** Nearest-neighbor scaling only (crisp pixels)

### Rendering Pipeline
1. Parallax background (5 layers at different scroll speeds)
2. Ground obstacles
3. Player (BYTE)
4. Air obstacles & collectibles
5. Particle effects
6. HUD
7. Screen effects (scanlines, vignette, shake, flash, glitch)

### Physics
- **Gravity:** 980 px/s²
- **Jump:** -450 px/s (variable height with extended gravity)
- **Slide:** Locks for 0.4s, flattens hitbox
- **Fast-Fall:** 2200 px/s² when holding DOWN mid-air
- **Coyote Time:** 120ms to jump after walking off edge
- **Jump Buffer:** 100ms to pre-queue jumps

### Performance
- Particle pool capped at 300 particles (prevents frame drops)
- Pre-render all sprites in `love.load()` using canvases
- No image file I/O—all sprites drawn procedurally with `love.graphics`
- love.js compatible: no `io.open()`, no `os.time()`, uses `love.filesystem` only

### Persistence
- High score saved to `highscore.txt` in the game directory
- Uses `love.filesystem.write/read` for cross-platform save support

## Customization

### Difficulty Phases
Adjust score ranges and spawn parameters in `game/systems/difficulty.lua`:
```lua
local PHASE_SPEEDS = {
    {min=0, max=500, speed=200, gap={500,700}, pool={"g1","g3"}},
    -- ... modify these tables to change difficulty progression
}
```

### Sprite Visuals
All sprites are drawn programmatically in `game/systems/sprites.lua` using `love.graphics` rectangles. Modify the `_draw_*` functions to customize colors and pixel layouts.

### Color Palette
Colors defined in `game/systems/sprites.lua` and used throughout:
```lua
local COLORS = {
    cyan = {0, 1, 1},      -- #00FFFF
    pink = {1, 0, 1},      -- #FF00FF
    red = {1, 0, 0.2},     -- #FF0033
    gold = {1, 0.8, 0},    -- #FFCC00
    -- ... and more
}
```

### Sound Effects & Music
The audio system is structured to accept `.ogg` files later. Currently, all effects are silent stubs. To add sounds:

1. Place `.ogg` files in a `sounds/` folder
2. Modify `game/systems/audio.lua` to load and play them:
```lua
function Audio:play_sfx(name)
    if self.sources[name] then
        self.sources[name]:play()
    end
end
```

## Debug & Troubleshooting

### Game doesn't run locally
- Ensure Love2D 11.4+ is installed and `love` command is available
- Check that `main.lua` and `conf.lua` are in the root directory
- Run with `love neon-dash/` from parent directory if needed

### Web build issues
- Verify `love.js` is properly unpacked into the `web/` folder
- Clear browser cache (Ctrl+Shift+Delete) before testing changes
- Check browser console (F12) for JavaScript errors
- Ensure web server is running (not just opening index.html locally)

### Collision feels off
- Hitbox dimensions are set per-obstacle in `game/entities/obstacle_types.lua`
- Player hitboxes change based on state (standing vs sliding) in `game/entities/player.lua`
- Test by making hitboxes temporarily visible with `love.graphics.rectangle("line", ...)`

### Performance drops
- Particle pool is capped at 300; if exceeded, oldest particles are culled
- Profile with `love.graphics.getStats()` to check draw calls
- Reduce parallax layer complexity or disable certain visual effects temporarily

## Browser Compatibility

**Tested & Working:**
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Not Supported:**
- Mobile browsers (see `web/style.css` mobile warning)
- IE 11 and below

## Credits

- **Engine:** Love2D 11.4 by [Löve Crew](https://love2d.org)
- **Web Runtime:** love.js by [Davidobot](https://github.com/Davidobot/love.js)
- **Font:** Press Start 2P by [Cody "CodeMan38" Boisclair](https://zone38.net/)
- **Music & SFX:** Placeholder audio system (ready for sound designer integration)

## License

This game and all source code are provided as-is for educational and entertainment purposes. Feel free to fork, modify, and share!

---

**AXIOM CORPORATION SECURITY NOTICE:**  
*Rogue subroutine BYTE has been contained. All escape attempts have been logged. Resume normal operations.*

Escape velocity: 4.7 kilometers. Your current speed: 400 px/s.

**What are you waiting for? RUN.**