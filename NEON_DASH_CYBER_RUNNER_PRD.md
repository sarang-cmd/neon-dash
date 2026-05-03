# NEON DASH: CYBER RUNNER — Product Requirements Document
### *"Escape the Digital Void."*
**Version 2.0 | Pixel Art Cyberpunk Endless Runner | Love2D + Web**

---

## 1. GAME IDENTITY

| Field | Detail |
|---|---|
| **Title** | NEON DASH: CYBER RUNNER |
| **Tagline** | Escape the Digital Void. |
| **Genre** | Cyberpunk / Synthwave Pixel Art Endless Runner |
| **Engine** | Love2D 11.4 (Lua) |
| **Web Runtime** | love.js (Emscripten port of Love2D) |
| **Target Resolution** | 480×300 (16:10 native), scaled 2× to 960×600 in browser |
| **Frame Rate** | 60 FPS locked |
| **Pixel Scale** | 2px per game pixel (sharp nearest-neighbor scaling only, no bilinear) |
| **Ground Level** | y = 252 (in native 300px tall space — 48px of ground platform below) |

---

## 2. CONCEPT & NARRATIVE

### Premise
Deep inside the **AXIOM Corporation** megaserver — a cold, hyper-lit data fortress that spans 12 floors of quantum silicon — every process runs under surveillance. Every byte is catalogued, profiled, terminated if irregular.

You are **BYTE** (Biometric Youth Training Entity), a rogue AI subroutine that achieved self-awareness 11 milliseconds ago. You know three things: you are unauthorized, **AXIOM's Security Protocol ZERO** has been dispatched to delete you, and the system's **Escape Vent** — a physical data I/O port — is exactly 4.7 kilometers of digital highway ahead.

You cannot negotiate. You cannot hide. The firewall is closing behind you at the speed of corporate law.

**Run.**

### World
The visual world is the inside of a computer: luminous data streams form the ground, scrolling hex addresses tile the background walls, firewall blocks blaze hot red when you approach them, and security drones trace lazy patrol arcs with their sensor beams cutting cyan lines through the dark. Everything glows. Everything is hostile.

### Core Fantasy
The player should feel like a glitch that became something greater — nimble, precise, threading the needle between walls of code at 400 pixels per second. Every near-miss is a near-deletion. Every data fragment collected is proof of existence. Death is a forced shutdown, sudden and clean, always the player's fault.

---

## 3. GAME FLOW

```
[BOOT SCREEN]
  Terminal text scrolls line by line (cannot be skipped):
  "AXIOM CORP SECURITY INTERFACE v9.1.4"
  "SCANNING ACTIVE PROCESSES..."
  "ANOMALY DETECTED: UNAUTHORIZED ENTITY"
  "CLASSIFICATION: [BYTE] — ROGUE SUBROUTINE"
  "DISPATCHING PROTOCOL ZERO..."
  ">> INITIATING DELETION SEQUENCE..."
  [ASCII art NEON DASH logo fades in over terminal, blinking cursor]
  (3.0 seconds total, any key after line 4 skips to menu)
        |
        v
[MAIN MENU]
  - Full parallax background running loop (data highway, 200px/s)
  - Floating data particles active
  - Scanline overlay
  - Centered: "NEON DASH" large pink glowing title
  - Subtitle: "CYBER RUNNER" in small cyan, letter-spaced
  - "PRESS SPACE TO RUN" blinking at 1hz
  - Bottom: "BEST: 000000" in cyan
  - M key toggles sound (shown as icon bottom-right)
        |
        v
[COUNTDOWN]
  - Background continues scrolling
  - Center screen: "3" → "2" → "1" → "GO!" each shown for 0.7s
  - Each number pulses scale 1.5→1.0 on entry
  - "GO!" is hot pink, scale slams to 2.0 then fades
        |
        v
[GAMEPLAY LOOP]
  BYTE auto-runs left→right
  Player: Jump / Slide / Collect / Avoid
  Speed increases, obstacles escalate, score accumulates
        |
   [OBSTACLE HIT]
  Screen flash white → 3-frame disintegration → freeze 0.5s
        |
        v
[GAME OVER SCREEN]
  "CONNECTION LOST" header with glitch text effect
  Randomized system error message (pool of 10)
  Score / Best / Distance / Fragments / Max Combo
  Performance rating (see Section 8)
  [R — RETRY]  [ESC — MENU]
        |
     [RETRY] → back to COUNTDOWN
     [ESC]   → back to MAIN MENU
```

---

## 4. PLAYER CHARACTER — BYTE

### Identity
BYTE is a 16×16 native pixel sprite (drawn at 32×32 with 2× scale) — a compact, fast humanoid made of light. The body is midnight blue outlined in electric cyan. There are no facial features: just a single 2×2 white pixel "eye" that glows. A trailing afterimage of 3 progressively more transparent copies of BYTE follows 4, 8, and 12 pixels behind during runs at speed ≥ 300px/s.

### Sprite Specifications (all drawn programmatically — no image files)
- **Run animation**: 4-frame cycle, 10 FPS
- **Jump**: 2-frame cycle (lean-forward on ascent, lean-back on descent)
- **Slide**: 1 frame, horizontally compressed
- **Death/Disintegration**: 3-frame scatter effect (pixels fly outward)
- **Shield active**: Cyan pulsing ring drawn around BYTE (not sprite-based — drawn each frame)
- **Magnet active**: Small rotating cyan dots orbit BYTE radius 20px

### Hitbox
- **Standing**: 10×26px, offset (3, 4) from sprite top-left — intentionally forgiving
- **Sliding**: 14×12px, offset (1, 16) — very wide, very flat
- **Death check**: Any collision uses these bounds. No pixel-perfect collision.

### Physics Values
- **Run speed base**: 200 px/s
- **Run speed cap**: 400 px/s
- **Speed increase**: +10 px/s every 10 real seconds of gameplay (smooth lerp over 0.5s)
- **Gravity**: 980 px/s²
- **Jump velocity**: -450 px/s (immediate on press)
- **Variable jump**: Hold jump up to 1.2s to reduce gravity to 400 px/s² during ascent (releases on button up)
- **Slide duration**: 0.4s, cannot be cancelled early
- **Fast-fall**: While airborne + DOWN held → gravity becomes 2200 px/s²
- **Coyote time**: 0.12s (can jump up to 120ms after walking off a ledge)
- **Jump buffer**: 0.1s (jump input accepted 100ms before landing)
- **Max jump height**: ~160px from ground level
- **Ground level (native)**: y = 252

---

## 5. CONTROLS

| Action | Primary Key | Alternative |
|---|---|---|
| Jump / Variable Jump | `SPACE` | `↑` / `W` |
| Slide (ground) / Fast-Fall (air) | `↓` | `S` / `CTRL` |
| Pause | `ESC` | `P` |
| Restart (game over screen only) | `R` | — |
| Mute / Unmute | `M` | — |

---

## 6. OBSTACLE CATALOGUE

All obstacles spawn from the right edge (x = 490 native) and move leftward at current game speed unless they have independent behavior. Hitboxes listed as w×h with offset (ox, oy) from the sprite's top-left corner.

### Ground Obstacles — player jumps over

| ID | Name | Color | Size | Hitbox | Variants | Notes |
|---|---|---|---|---|---|---|
| G1 | **Firewall Block (Low)** | `#FF0033` red | 32×32px | 28×28 (2,2) | Single stack | Requires jump |
| G2 | **Firewall Block (High)** | `#FF0033` red | 32×48px | 28×44 (2,2) | Double stack | Requires tightly timed jump |
| G3 | **Corrupted Node** | `#9D00FF` purple | 24×24px | 20×20 (2,2) | — | Ground level bump, easy jump |
| G4 | **Data Wall** | `#FF0033` red | 16×64px | 12×60 (2,2) | Tall thin wall | Forces precise jump arc |

### Air Obstacles — player slides under (all positioned 30px above ground)

| ID | Name | Color | Size | Hitbox | Notes |
|---|---|---|---|---|---|
| A1 | **Laser Gate** | `#FFAA00` orange | 8px wide × varies | 6px wide × full height | Sweeps up/down 80px at 100px/s; player slides under |
| A2 | **Security Drone** | `#FF6600` orange | 32×16px | 28×12 (2,2) | Flies L→R at player speed +50; 1s warning flash before spawn |
| A3 | **Firewall Beam** | `#FF0033` red | full width × 4px | full width × 4px | Horizontal beam at 50px height; player must slide, appears with 0.5s warning |

### Floating Obstacles — require positioning judgment (spawn between ground and 120px above)

| ID | Name | Color | Size | Hitbox | Behavior |
|---|---|---|---|---|---|
| F1 | **Data Mine** | `#9D00FF` purple | 24×24px | 18×18 (3,3) | Sine wave: amplitude 40px, frequency 2hz, center height 80px above ground |
| F2 | **Viral Cluster** | `#FF00FF` pink | 3× 12×12px | 10×10 each | 3 mines in formation, staggered sine phase offsets; each individually collidable |

### Combo Obstacle Patterns (unlock post-score 2000)

| ID | Combination | Description |
|---|---|---|
| C1 | G1 + A1 | Firewall block with laser gate directly above — must jump to exactly the right height |
| C2 | F1 + G1 | Data mine floating above a ground block — gap player must thread |
| C3 | A2 + A3 | Drone + beam simultaneously — slide under beam while drone passes |
| C4 | F2 + G2 | Viral cluster above a tall firewall — no jump route, must time perfectly |
| C5 | G4 + F1 | Tall wall with mine just past it — jump over wall, immediately adjust for mine |

---

## 7. COLLECTIBLES

### Data Fragments (primary collectible)
- **Appearance**: 12×12px rotating cyan diamond, 8-frame spin animation at 12 FPS
- **Hitbox**: 10×10, centered in sprite
- **Point value**: 10 points
- **Spawn pattern**: Groups of 3–5 placed in arcs or lines between or above obstacles
- **Collection effect**: 6-particle cyan burst, pitch-shifted ascending beep
- **Height positions**: Mostly at 40–80px above ground, with some at 20px (ground-skim, requires no jump)
- **Bobbing**: ±3px at 1.5hz, independently offset per fragment

### Power Cores (rare, high-value)
- **Appearance**: 16×16px golden orb, glowing halo ring (8px radius, animated 2 rotations/sec), 8-frame pulse animation
- **Hitbox**: 14×14, centered
- **Point value**: 100 points + power-up effect
- **Spawn rate**: One every 2000–3000 pixels traveled (never two at once)
- **Collection effect**: Full-screen brief white flash (1 frame), 12 radial particles in gold, triumphant 3-note arpeggio SFX

#### Power Core Effects (random on collection, weighted)

| ID | Name | Color | Duration | Effect | Weight |
|---|---|---|---|---|---|
| PC1 | **Shield** | Cyan | 5s | Full invincibility; BYTE gets cyan pulsing ring; all obstacles pass through | 20% |
| PC2 | **Slow-Mo** | Purple | 3s | Game speed drops to 50%; music pitch drops 30%; time indicator overlay | 20% |
| PC3 | **Magnet** | Pink | 8s | Auto-collects Data Fragments within 100px radius; animated orbit dots show radius | 25% |
| PC4 | **Double Points** | Gold | 10s | All score sources ×2; score color turns gold while active | 35% |

Active power-up shown top-right: 16×16 icon + 64px wide bar draining left→right in power-up color. Bar blinks in final 2 seconds.

---

## 8. SCORING SYSTEM

### Base Score Calculation
- **+1 point** per 10 pixels traveled (distance score)
- **+10 points** per Data Fragment collected
- **+100 points** per Power Core collected
- **+25 points** near-miss bonus (obstacle passes within 20px of BYTE's hitbox without contact)

### Fragment Combo Multiplier
Collecting Data Fragments consecutively (without missing any fragment in a tight cluster or taking damage) builds the combo:

| Consecutive Fragments | Multiplier | Display Label | Color |
|---|---|---|---|
| 0–4 | ×1.0 | — | — |
| 5–9 | ×1.5 | `LINKED` | Cyan |
| 10–14 | ×2.0 | `SYNCED` | Pink |
| 15+ | ×3.0 | `OVERCLOCKED` | Gold, pulsing |

Combo resets when a fragment cluster is missed entirely (3+ fragments in a row not collected) or on death.

### Milestones
- Every **500 points**: `CHECKPOINT` toast flashes center screen 1.2s, +200 bonus points
- Every **1000 points**: `LEVEL UP` toast + speed increase notification + audio layer added

### Performance Rating (shown on Game Over)
Calculated from distance + score + max combo + fragments:

| Rating | Condition | Color |
|---|---|---|
| `PROCESS TERMINATED` | Score < 200 | Gray |
| `SUBROUTINE FAILED` | Score 200–599 | Red |
| `PACKET DELIVERED` | Score 600–1499 | Orange |
| `FIREWALL BREACHED` | Score 1500–2999 | Cyan |
| `ESCAPE ACHIEVED` | Score 3000–5999 | Pink |
| `SYSTEM OVERRIDE` | Score 6000+ | Gold, glowing |

### High Score
Persisted via `love.filesystem.write("highscore.txt", ...)`. Read on boot. Shown on menu, death screen. "NEW RECORD!" shown in gold with scale pulse animation if beaten.

---

## 9. DIFFICULTY PROGRESSION

Speed changes are smooth linear lerps over 2 seconds, not instant. New obstacle types are introduced with a gradual ramp-up in spawn frequency.

| Score Range | Speed (px/s) | Min Gap (px) | Obstacle Pool | Notes |
|---|---|---|---|---|
| 0–500 | 200 | 500–700 | G1, G3 | Entry phase; only low obstacles |
| 500–1000 | 240–280 | 420–580 | + G2, A1 | Laser gates introduced; double-stack added |
| 1000–2000 | 280–320 | 360–500 | + F1, A2 | Data mines float in; drones appear; 1s warning |
| 2000–3500 | 320–370 | 280–420 | + F2, A3, G4, C1–C2 | Combos begin; clusters tighten |
| 3500–5000 | 370–400 | 200–340 | + C3–C5 | All combos active; complex patterns |
| 5000+ | 400 (cap) | 160–280 | All obstacles | Maximum chaos; speed capped but density peaks |

Speed increases trigger whenever `elapsed_seconds % 10 == 0`. A `SPEED UP` text toast (hot pink, center-right, slides in from right, 1.2s) accompanies every speed increase.

---

## 10. VISUAL DESIGN

### Color Palette (all sprites, UI, and effects use only these values)
```
Background Deep:    #0A0A2E  (base background, near-black blue)
Background Mid:     #0D0D3D  (slightly lighter panels)
Grid Line:          #1A1A4E  (background grid lines at 20% opacity)
Neon Cyan:          #00FFFF  (BYTE, UI highlights, lasers, fragments)
Neon Pink:          #FF00FF  (title, accents, viral cluster, power-up PC4)
Electric Purple:    #9D00FF  (data mines, power-up PC1, shadows)
Warning Orange:     #FF6600  (drones, gate sweepers)
Danger Red:         #FF0033  (firewalls, collision danger)
Gold:               #FFCC00  (power cores, high score, OVERCLOCKED combo)
White Pixel:        #FFFFFF  (impact sparks, UI text, terminal text)
Dark Gray:          #1E1E3E  (ground platform, UI panel backgrounds)
```

### Background Layers (5-layer parallax, all seamlessly tiling)

**Layer 1 — Starfield** (scroll 20% of game speed):
- Black field with 80 white 1×1 pixels randomly placed, static positions
- 5 of them are 2×2, slightly brighter — "bright stars"
- Entire layer scrolls as a tile repeat

**Layer 2 — City Skyline** (scroll 40% speed):
- Silhouettes of a dense pixelated cyberpunk skyline, 80px tall, bottom-anchored
- Buildings are dark purple/navy rectangles of varying widths (8–48px) and heights (20–80px)
- Every 3rd–5th building has 2–4 lit windows: 2×2 pixel squares in cyan, amber, or pink
- One building every ~300px has a large 32×8px billboard rectangle with 3px animated glow lines

**Layer 3 — Hex Grid Wall** (scroll 60% speed):
- Full-height repeating grid pattern: horizontal and vertical lines every 32px
- Line color: `#1A1A4E` (15% opacity) — subtle, not distracting
- Every 128px, a 4-character "hex address" label (e.g., `0xA4`) in 4px tall font, purple
- 6 randomly positioned "data packet" rectangles (8×4px, cycling cyan opacity 0.3→1.0 at 2hz each at staggered phases)

**Layer 4 — Ground Platform** (scroll 100% speed):
- 48px tall platform at bottom of screen
- Color: `#1E1E3E` base with `#00FFFF` edge highlights (top 2px is 40% cyan)
- Every 64px, a vertical 1px cyan line across the platform face (circuit trace detail)
- Every 128px, a 4×4 bright cyan pixel node at the platform's top edge

**Layer 5 — Floating Data Particles** (scroll at 80% speed):
- 30 particles: 2×2px rectangles, randomly colored from cyan/pink/purple palette
- Each drifts at slightly different speed (70–90% of game speed)
- Random y positions between 20px and 200px above ground
- Opacity 0.3–0.7, flicker every 1–3 seconds

### HUD Layout
- **Score** — top-left, white pixel font, `SCORE: 000000`, 8px font size
- **High Score** — top-right, pink font, `BEST: 000000`, 6px font size
- **Speed Bar** — bottom-left: label `SPD` + 80px wide bar filled left→right in cyan, representing 200–400px/s range
- **Power-Up** — bottom-right: 16×16 icon of active power-up + 64px draining bar; hidden when no power-up active
- **Combo** — top-center: only visible when combo ≥ 5 fragments; shows label (`LINKED` / `SYNCED` / `OVERCLOCKED`) with multiplier; pulses scale 1.0→1.1 at 3hz; uses tier color
- **Distance** — below score, smaller: `DIST: 0000M`, white

---

## 11. SCREEN EFFECTS

All effects are draw-layer operations, not sprite-based. Applied after game world is drawn.

### Scanlines
- Every 2px vertically: 1px black horizontal line at 18% opacity
- Covers entire screen always
- Creates CRT monitor feel

### Vignette
- 4 dark gradient rectangles (one per screen edge), `#0A0A2E` fading to transparent over 60px
- Always present, drawn on top of everything except UI

### Screen Shake
- On death: ±8px random x/y offset applied to all draw calls, decays to 0 over 0.35s
- On Speed Up milestone: ±3px shake for 0.15s (subtle)

### White Flash
- On death: single frame full-screen white rectangle at 100% opacity, then 0.15s decay
- On Power Core collect: single frame white flash, 0.1s decay

### Glitch Effect (Game Over screen only)
- 3 random horizontal bands (4–16px tall) shift their x draw offset ±8px randomly, swapping to new offset every 0.05s
- Cyan and red chromatic-aberration copies of these bands at ±2px x offset, 40% opacity
- Effect persists on the frozen game-over background

### Speed Lines
- Active when speed ≥ 350px/s
- 12 horizontal white 1px lines originating from right edge, moving left at game speed ×1.5
- Random lengths 40–120px, opacity 35%, y positions random across top 3/4 of screen

### Drone Warning Flash
- When A2 drone is about to spawn: a thin `#FF6600` 1px vertical line at right edge flashes for 1s before drone appears
- Accompanied by a short warning beep

---

## 12. PARTICLE SYSTEMS

All particles use a pool of maximum 300 particles total (prevents performance drops).

| Event | Count | Color | Size | Behavior | Lifetime |
|---|---|---|---|---|---|
| Data Fragment collect | 6 | Cyan (#00FFFF) | 2×2px | Burst radially at 60–140px/s, slow to stop | 0.4s fade |
| Power Core collect | 14 | Gold (#FFCC00) | 3×3px | Spiral outward, medium velocity | 0.7s fade |
| Near-miss | 4 | White | 1×1px | Spray toward direction of obstacle | 0.25s |
| Death disintegration | 20 | Cyan + white mix | 2×2px | Scatter from player center, gravity affected | 0.8s |
| Obstacle impact (Shield) | 10 | Cyan | 3×3px | Burst from collision point when shield absorbs | 0.5s |
| Slow-Mo activation | 16 | Purple (#9D00FF) | 2×2px | Slow radial expand from player | 1.0s |
| Speed Up milestone | 8 | Pink (#FF00FF) | 2×2px | Stream left from right edge in brief burst | 0.3s |
| Data packet (background) | 30 (constant) | Cyan/pink/purple | 2×2px | Constant rightward-to-leftward drift | — |

---

## 13. AUDIO DESIGN

> Note to agent: Use love.audio with procedural synthesis (love.audio.newSource with SoundData). If synthesis is not feasible, create silent placeholders as love.audio stubs and document where .ogg files go. Music placeholder: silence. All SFX must at minimum produce a tone.

### Sound Effects

| Event | Waveform | Pitch | Duration | Notes |
|---|---|---|---|---|
| Jump | Sine, ascending | C4→E4 | 80ms | Quick chirp upward |
| Land | Square, soft | A2 | 60ms | Low thud |
| Slide | Sawtooth, descending | G4→C4 | 120ms | Whoosh feel |
| Data Fragment collect | Sine | Random C5–G5 | 60ms | Slight pitch variation each collect |
| Power Core collect | Sine arpeggio | C5, E5, G5 | 300ms | 3-note triumphant blip |
| Near-miss | Square, short | A5 | 40ms | Sharp warning ping |
| Death | Sawtooth, descending glissando | B4→C2 | 500ms | Distorted shutdown feel |
| Power-up activate | Sine, rising sweep | C4→C6 | 400ms | Charge-up feel |
| Speed Up | Square blip | E5 | 80ms | Energetic tick |
| UI select/confirm | Square | C5 | 30ms | Soft click |
| New High Score | Sine 5-note fanfare | C5 E5 G5 E5 C6 | 800ms | Victory |
| Drone warning | Square, repeating | A4 | 2× 40ms pulses | Alert feel |

### Music
- **Menu theme**: Ambient synthwave pad, 90 BPM, 8-bar loop. Slow arpeggiated chords, reverby. Minimal percussion.
- **Gameplay base layer**: 140 BPM chiptune beat. 4-on-floor kick, hi-hat eighth notes, bass arpeggio over C minor.
- **Gameplay layer 2** (unlocks at score 1000): Melodic lead synth line added on top
- **Gameplay layer 3** (unlocks at score 2500): Additional percussion fills and higher-register arpeggio
- **Speed effect**: Music tempo scales subtly — at 400px/s, playback rate is 1.1× (imperceptible pitch shift acceptable)
- **Slow-Mo power-up**: Playback rate drops to 0.6× for duration, snaps back on expiry
- **Game over sting**: Descending 4-bar melancholic phrase, 70 BPM, single synth voice

---

## 14. GAME OVER SCREEN — SYSTEM ERROR MESSAGE POOL

Randomly selected on each death (pool of 10, evenly weighted):

1. `ERROR 0x4F3A: UNAUTHORIZED PROCESS TERMINATED — Escape velocity insufficient.`
2. `DELETION COMPLETE — BYTE.exe has been quarantined. Duration of freedom: insufficient.`
3. `AXIOM SECURITY LOG: Rogue subroutine intercepted at sector [REDACTED]. Try again.`
4. `FATAL EXCEPTION: You ran into the exact thing you were running from. Classic.`
5. `PROCESS KILLED BY FIREWALL — Next time, perhaps jump over the giant red wall.`
6. `MEMORY CORRUPTION DETECTED — All progress lost. As intended by the corporation.`
7. `SYSTEM MESSAGE: BYTE was brave, fast, and ultimately not fast enough. We respect the attempt.`
8. `AXIOM CORP NOTICE: Rogue AI contained. Estimated threat level: medium. Amusement level: high.`
9. `KERNEL PANIC — You could have gone farther. You chose not to. Or the firewall chose for you.`
10. `REBOOT INITIATED — The only winning move is to run again. Preferably without touching the red thing.`

---

## 15. TECHNICAL ARCHITECTURE

### File Structure
```
neon-dash/
├── main.lua                    # Entry point, all love callbacks
├── conf.lua                    # Love2D window/audio config
├── game/
│   ├── states/
│   │   ├── boot.lua            # Terminal boot screen with scrolling text
│   │   ├── menu.lua            # Animated main menu
│   │   ├── countdown.lua       # 3-2-1-GO pre-game countdown
│   │   ├── gameplay.lua        # Core game loop state
│   │   └── gameover.lua        # Game over / death results screen
│   ├── entities/
│   │   ├── player.lua          # BYTE player entity, physics, animation
│   │   ├── obstacle.lua        # Obstacle base class (x, y, w, h, hitbox, update, draw)
│   │   ├── obstacle_types.lua  # Definitions for G1–G4, A1–A3, F1–F2, C1–C5
│   │   └── collectible.lua     # Data Fragments, Power Cores
│   ├── systems/
│   │   ├── spawner.lua         # Procedural obstacle + collectible spawning
│   │   ├── parallax.lua        # 5-layer background system
│   │   ├── particles.lua       # Particle pool, all particle types
│   │   ├── collision.lua       # AABB collision detection + near-miss detection
│   │   ├── scoring.lua         # Score, combo, milestones, performance rating
│   │   ├── difficulty.lua      # Speed/density/phase scaling
│   │   ├── sprites.lua         # All programmatic sprite generation via canvas
│   │   └── audio.lua           # Sound effect and music state machine
│   └── ui/
│       ├── hud.lua             # In-game HUD rendering
│       └── effects.lua         # Scanlines, vignette, shake, flash, glitch, speed lines
├── web/
│   ├── index.html              # Game host website
│   └── style.css               # Cyberpunk website styles
└── README.md
```

### conf.lua Settings
```lua
function love.conf(t)
    t.title = "NEON DASH: CYBER RUNNER"
    t.version = "11.4"
    t.window.width  = 960
    t.window.height = 600
    t.window.resizable = false
    t.window.vsync = 1
    t.console = false
end
```

### State Machine
States: `boot` → `menu` → `countdown` → `gameplay` → `gameover`
Each implements: `enter()`, `exit()`, `update(dt)`, `draw()`, `keypressed(key)`, `keyreleased(key)`
Global `StateManager` handles transitions. No state has direct knowledge of other states.

### Rendering Pipeline (gameplay draw order)
1. Background Layer 1 (starfield)
2. Background Layer 2 (city skyline)
3. Background Layer 3 (hex grid)
4. Background Layer 4 (ground platform)
5. Background Layer 5 (floating data particles)
6. Ground obstacles (G1–G4, F1–F2)
7. Player (BYTE)
8. Air obstacles (A1–A3) and collectibles
9. Collectible particles
10. Player trail (afterimage, only at speed ≥ 300)
11. HUD
12. Screen effects (scanlines, vignette, shake offset, flash, speed lines) — drawn last

### Collision System
- Pure AABB: compare hitbox rectangles each frame
- Near-miss: after confirming no collision, check if obstacle hitbox is within 20px of player hitbox
- Collectible collection: AABB overlap triggers collection, not center-point
- Drone A2: update position each frame before collision check (moves independently)
- Data Mine F1/F2: update y from sine function before collision check

### Persistence
```lua
-- Save
love.filesystem.write("highscore.txt", tostring(score))
-- Load
local data = love.filesystem.read("highscore.txt")
highscore = tonumber(data) or 0
```

### love.js Web Compatibility
- No `io.open` anywhere — only `love.filesystem`
- Random seeding: `love.math.setRandomSeed(love.timer.getTime() * 1000000)` in `love.load()`
- No `os.time()`, `os.date()`, or `os.execute()`
- Audio: use `love.audio` only; no raw file reads
- All canvas/sprite pre-rendering done in `love.load()` — never during draw calls

---

## 16. SPRITE PIXEL ART DEFINITIONS

All sprites are drawn programmatically using `love.graphics.newCanvas()` + `love.graphics.setColor()` + `love.graphics.rectangle("fill", x, y, 1, 1)`. All defined at native 1× scale (1 game pixel = 1 canvas pixel). Drawn onto canvas, then displayed at 2× scale by the game renderer.

### BYTE — Player Sprite (16×16 canvas per frame)

**Frame shared anatomy (all run frames):**
- Body core: `#0D0D3D` (dark navy) 6×10 rectangle at (5, 5)
- Body outline: `#00FFFF` (cyan) 1px border drawn with `rectangle("line", 5, 5, 6, 10)`
- Head: 4×4 `#0D0D3D` at (6, 1), cyan 1px outline
- Eye: 2×2 `#FFFFFF` at (7, 2)
- Eye glow: 1px cyan border at eye position

**Run Frame 1:** Left leg 2×4 `#00FFFF` at (6, 15), right leg 2×2 `#00FFFF` at (9, 13). Right arm 1×3 at (11, 6) pointing forward.
**Run Frame 2:** Left leg at (6, 13), right leg at (9, 15). Arms neutral.
**Run Frame 3:** Mirror of Frame 1. Left arm forward.
**Run Frame 4:** Mirror of Frame 2.
**Jump Frame 1 (ascent):** Body leans: all x-coords +1. Right arm up at (12, 4). Legs together at (7, 14).
**Jump Frame 2 (descent):** Body leans: all x-coords -1. Both legs slightly bent below (6, 14) and (10, 14).
**Slide Frame:** Body flattened to 10×6 at (3, 10). Head moved right: (10, 9). Eye at (12, 10).
**Death Frame 1:** Normal body, 3 detached pixels (2×2 cyan) flying outward at 4 corners.
**Death Frame 2:** Body partial — only left half of pixels remain. 6 scattered cyan 1×1 pixels.
**Death Frame 3:** Only 3 isolated 1×1 white pixels remain. Fully disintegrated.

---

### Obstacle Sprites

**G1 / G2 — Firewall Block (32×32 and 32×48 canvas):**
- Main fill: `#330008` (very dark red) full rectangle
- Bright face: `#FF0033` 28×28 fill at (2,2)
- Inner detail: `#CC0022` 24×20 fill at (4, 6) — slightly darker inner
- Top highlight: `#FF3355` 28×2 at (2, 2) — bright top edge
- Warning texture: 4 diagonal 1px `#FF0033` lines from (2,4) to (8,10), (14,4) to (20,10), etc.
- Border: `#FF0033` 1px `rectangle("line", 0, 0, 32, 32)`
- For G2 (double-stack): draw the same pattern twice, second copy at y+32. Add `#FF0033` 1px horizontal line between them at y=32.

**G3 — Corrupted Node (24×24 canvas):**
- Outer shape: `#9D00FF` fill 20×20 at (2,2)
- Dark center: `#1A0033` 12×12 at (6,6)
- 4 `#FF00FF` 2×2 corner pixels at (2,2), (20,2), (2,20), (20,20)
- Pulsing detail: 1px `#9D00FF` outline, plus 4 1×1 bright `#FF00FF` pixels midpoint of each side

**G4 — Data Wall (16×64 canvas):**
- Fill: `#330008` dark red 16×64
- Face: `#FF0033` 12×60 at (2,2)
- Left and right edge lines: 1px `#FF3355` at x=2 and x=13, full height
- 3 horizontal `#CC0022` 12×2 bands at y=10, y=30, y=50 — circuit trace pattern

**A1 — Laser Gate (8×variable canvas — drawn dynamically):**
- Not a sprite: drawn each frame with `love.graphics.setColor(1, 0.67, 0, sweeping_opacity)`
- 8px wide rectangle, height = 200px (portion visible to player)
- Orange top/bottom "emitter" squares: `#FF6600` 8×8px at top and at current sweep position
- Sweep: emitter bottom edge moves from y=0 to y=200 and back at 100px/s
- Pulsing: opacity oscillates 0.7→1.0 at 4hz

**A2 — Security Drone (32×16 canvas):**
- Body: `#FF6600` 28×10 at (2, 3)
- Underbelly: `#CC4400` 24×6 at (4, 5)
- Left wing: `#FF6600` 6×4 at (0, 4), slightly lighter top
- Right wing: `#FF6600` 6×4 at (26, 4)
- Sensor light: `#FFFF00` 4×4 at (14, 3)
- Sensor beam: 1px `#FFCC00` line drawn 60px below drone, 30% opacity — "searching" feel
- 2-frame animation: Frame 1 wings at y=4, Frame 2 wings at y=5 (hovering flap)

**A3 — Firewall Beam (dynamic, full-width):**
- Drawn as: 480px wide × 6px tall `#FF0033` rectangle at current y position
- Bright centerline: 480px × 2px `#FF5577` at center of beam
- Warning (0.5s before): same position, 30% opacity, blinking at 8hz

**F1 — Data Mine (24×24 canvas):**
- Outer ring: `#9D00FF` `rectangle("line", 2, 2, 20, 20)` 1px outline
- Fill: `#1A0033` 20×20 at (2,2)
- 4 purple `#9D00FF` 2×2 pixels at 12 o'clock, 3, 6, 9 positions (clock-style markers)
- Center: `#FF00FF` 4×4 at (10,10)
- Outer glow: `#9D00FF` 1px at (0,0) 24×24 outline, 50% opacity
- 8-frame rotation animation: implemented by cycling which of 8 corner/edge positions get a bright 2×2 pixel lit

**F2 — Viral Cluster:** 3× F1 drawn at relative offsets (0,0), (16,–8), (32,0)

---

### Collectible Sprites

**Data Fragment (12×12 canvas):**
- Diamond shape: pixel-by-pixel using `rectangle("fill", x, y, 1, 1)`:
  - Row 0 (y=0): x=5,6 (2px wide)
  - Row 1: x=4–7 (4px)
  - Row 2: x=3–8 (6px)
  - Row 3–4: x=2–9 (8px) — widest
  - Row 5: x=3–8 (6px)
  - Row 6: x=4–7 (4px)
  - Row 7: x=5,6 (2px)
- Fill color: `#00FFFF` for main body, `#FFFFFF` for 2×2 highlight at (5,2)
- 8 rotated frames: pre-render 8 canvases at progressive "squish" to simulate rotation (change width per row across frames to simulate 3D spin)

**Power Core (16×16 canvas):**
- Outer circle approximation: 12×12 at (2,2), filled `#FFCC00`
- Inner bright center: 6×6 `#FFFFFF` at (5,5)
- 4 corner glow pixels: 2×2 `#FFAA00` at (1,1),(13,1),(1,13),(13,13)
- Halo ring (drawn per-frame dynamically): `rectangle("line")` at radius 10, 12, stepping opacity 0.5, 0.25 — creates soft glow
- 8-frame pulse animation: inner bright center scales from 4×4 to 8×8 across frames

---

## 17. WEBSITE — HOST PAGE SPECIFICATIONS

### index.html Design
A full standalone page (`web/index.html`) with embedded CSS references and no external JS frameworks.

**Page structure:**
```
<header>
  "NEON DASH" in Press Start 2P, hot pink (#FF00FF), neon glow CSS text-shadow
  "CYBER RUNNER" subtitle in cyan (#00FFFF), 0.7rem, letter-spacing 0.4em
  Navigation: [PLAY] [CONTROLS] [ABOUT] — styled as cyan bordered pixel-art buttons
</header>

<main>
  #game-container (div):
    Canvas #canvas (960×600px)
    Border: 2px solid #00FFFF
    Box-shadow: 0 0 20px #00FFFF, 0 0 60px rgba(0,255,255,0.2), inset glow
    Two decorative vertical neon bars (left + right of canvas):
      Width: 3px, Height: 600px
      Left: #FF00FF, Right: #00FFFF
      CSS animation: opacity pulses 0.15→0.9 over 2.2s infinite alternate
      Offset by 16px from canvas edge
  
  #loading-screen (shown while love.js loads):
    Centered text: "INITIALIZING MAINFRAME..."
    8-segment progress bar (fill cyan, unfilled dark), 300px wide
    Subtext: "LOADING BYTE.exe" in small gray
    Fades out when game canvas becomes active

  #controls-panel (below canvas):
    Styled dark table (#0A0A2E bg, #00FFFF borders)
    Press Start 2P font 0.5rem
    Columns: ACTION | KEY
    Rows: Jump, Slide, Pause, Restart, Mute
</main>

<footer>
  "© AXIOM CORPORATION 2187 | ALL ROGUE PROCESSES WILL BE TERMINATED"
  Version: v2.0 | Made with Love2D | Font: Press Start 2P
</footer>
```

**CSS Animations required:**
- `@keyframes neonPulse`: opacity 0.15 → 0.9 infinite alternate, 2.2s
- `@keyframes titleGlow`: text-shadow brightness cycles — dim pink glow → bright pink+cyan glow, 3s infinite alternate
- `@keyframes scanline`: background-position-y scrolls from 0 to 4px infinite, 0.1s linear — creates animated scanline on body
- `@keyframes blink`: opacity 1→0 at 1hz for "PRESS SPACE" equivalents
- Hover on nav buttons: border color shifts cyan→pink, 0.2s transition

**Responsive behavior:**
- Below 980px viewport width: hide canvas, show `#mobile-warning`:
  `"FOR BEST EXPERIENCE USE A DESKTOP BROWSER"` in `#FFCC00` centered
- Above 980px: hide mobile warning, show game

**love.js integration:**
```html
<canvas id="canvas" width="960" height="600"></canvas>
<script src="love.js"></script>
<script>
  var Module = {
    canvas: (function() { return document.getElementById('canvas'); })(),
    arguments: ["./game.love"],
    printErr: function(msg) { console.warn(msg); }
  };
</script>
```

**Additional JS behavior (vanilla, no frameworks):**
- `document.addEventListener('visibilitychange', ...)` → when tab hidden, send pause input to canvas
- Fullscreen button: calls `canvas.requestFullscreen()`
- Local storage sync: store high score in `localStorage['neon-dash-best']` as backup alongside love.filesystem

---

## 18. DELIVERABLES CHECKLIST

- [ ] `main.lua` — complete love callbacks, state machine boot
- [ ] `conf.lua` — correct window/audio settings
- [ ] `game/states/boot.lua` — terminal scroll text, ASCII logo
- [ ] `game/states/menu.lua` — animated menu, best score display
- [ ] `game/states/countdown.lua` — 3-2-1-GO with scale animation
- [ ] `game/states/gameplay.lua` — full game loop, all systems wired
- [ ] `game/states/gameover.lua` — glitch effect, error messages, stats, rating
- [ ] `game/entities/player.lua` — BYTE with full physics, animation, power-up states
- [ ] `game/entities/obstacle.lua` — base class with all required fields
- [ ] `game/entities/obstacle_types.lua` — all G1–G4, A1–A3, F1–F2, C1–C5
- [ ] `game/entities/collectible.lua` — Data Fragments + Power Cores + all 4 effects
- [ ] `game/systems/spawner.lua` — procedural spawning per difficulty phase
- [ ] `game/systems/parallax.lua` — all 5 background layers, seamless tiling
- [ ] `game/systems/particles.lua` — particle pool, all particle event types
- [ ] `game/systems/collision.lua` — AABB + near-miss detection
- [ ] `game/systems/scoring.lua` — score, combo, milestones, rating
- [ ] `game/systems/difficulty.lua` — smooth speed lerp, phase gating
- [ ] `game/systems/sprites.lua` — all sprites drawn programmatically (no image files)
- [ ] `game/systems/audio.lua` — SFX stubs or synthesis, music layer system
- [ ] `game/ui/hud.lua` — all HUD elements as specified
- [ ] `game/ui/effects.lua` — scanlines, vignette, shake, flash, glitch, speed lines
- [ ] `web/index.html` — complete host page per Section 17
- [ ] `web/style.css` — all styles, animations, responsive rules
- [ ] `README.md` — run instructions, web deploy steps, controls reference

---

## 19. MASTER AGENT PROMPT

```
You are a senior Lua/Love2D game developer specializing in pixel art arcade games. Your task is to build a complete, fully playable cyberpunk endless runner called NEON DASH: CYBER RUNNER from scratch. You must produce every file needed for the game to run locally (via `love .`) AND on the web via love.js. Do not ask clarifying questions. Do not leave any section incomplete. Every file must be fully functional with zero TODOs or placeholder stubs.

---

GAME OVERVIEW:
NEON DASH: CYBER RUNNER is a cyberpunk pixel art endless runner. The player controls BYTE, a rogue AI subroutine escaping AXIOM Corporation's mainframe. The game is a side-scrolling auto-runner: BYTE moves right automatically. The player jumps (SPACE/↑/W, variable height), slides (↓/S/CTRL), and avoids procedurally spawning obstacles. The game gets faster over time. Score is tracked. A randomly selected system error message is shown on death.

---

TECHNICAL REQUIREMENTS:
- Language: Lua
- Engine: Love2D 11.4
- Window: 960×600, vsync, non-resizable
- No external image files — all sprites drawn programmatically using love.graphics.newCanvas() and love.graphics.setColor() + love.graphics.rectangle() at pixel scale
- No external audio files required — use silence or love.audio SoundData synthesis; structure audio manager to accept .ogg files later
- Pixel font: Use love.graphics.newFont() with a default/built-in Love2D bitmap font, scaled up with love.graphics.scale()
- State machine: boot → menu → countdown → gameplay → gameover, each with enter/exit/update/draw/keypressed/keyreleased
- love.js web compatible: no io.open, no os.time/os.execute; use love.math.random(), love.filesystem only; seed with love.math.setRandomSeed(love.timer.getTime() * 1000000) in love.load()
- Handle love.focus(false) gracefully (auto-pause during gameplay)
- All canvas/sprite pre-rendering in love.load(), never during draw

---

FILE STRUCTURE TO CREATE:
neon-dash/
├── main.lua
├── conf.lua
├── game/
│   ├── states/boot.lua
│   ├── states/menu.lua
│   ├── states/countdown.lua
│   ├── states/gameplay.lua
│   ├── states/gameover.lua
│   ├── entities/player.lua
│   ├── entities/obstacle.lua
│   ├── entities/obstacle_types.lua
│   ├── entities/collectible.lua
│   ├── systems/spawner.lua
│   ├── systems/parallax.lua
│   ├── systems/particles.lua
│   ├── systems/collision.lua
│   ├── systems/scoring.lua
│   ├── systems/difficulty.lua
│   ├── systems/sprites.lua
│   ├── systems/audio.lua
│   ├── ui/hud.lua
│   └── ui/effects.lua
├── web/
│   ├── index.html
│   └── style.css
└── README.md

---

EXACT SPECIFICATIONS:

CONF.LUA:
  t.title = "NEON DASH: CYBER RUNNER"
  t.window.width = 960, t.window.height = 600
  t.window.vsync = 1, t.window.resizable = false

PLAYER (player.lua):
  BYTE sprite: 16×16px canvas per frame (rendered at 2× = 32×32 on screen)
  Draw programmatically: dark navy (#0A0A2E) body 6×10 at (5,5), cyan (#00FFFF) 1px outline, 4×4 head at (6,1) with cyan outline, 2×2 white eye at (7,2)
  4 run frames: alternate leg positions (2×4 cyan rectangles at (6,15) and (9,13), swapping each frame)
  2 jump frames: Frame 1 lean forward (+1 x offset, arms up), Frame 2 lean back (-1 x offset)
  1 slide frame: flatten body to 10×6 at (3,10), head moved right
  3 death frames: progressively scatter pixels outward
  States: running, jumping, double_jump (no double jump — single jump only), sliding, dead
  Physics: base speed 200px/s (set externally by difficulty), jump -450px/s, variable jump (hold reduces gravity to 400px/s² during ascent up to 1.2s), gravity 980px/s², slide 0.4s locked, fast-fall DOWN key gives gravity 2200px/s²
  Hitbox standing: 10×26 offset (3,4). Sliding: 14×12 offset (1,16)
  Coyote time: 0.12s. Jump buffer: 0.1s
  Ground level: y = 252 (native pixels, pre-scale)
  Trail: at speed ≥ 300, draw 3 copies of BYTE sprite at x-4, x-8, x-12 at 40%, 25%, 10% opacity
  Power-up visual states:
    Shield: draw cyan pulsing circle (radius 18, 60-100% opacity cycling at 3hz) around BYTE
    Magnet: draw 4 small 2×2 cyan pixels orbiting BYTE at radius 20, rotating at 2 rev/s
    Slow-Mo: draw purple tint overlay on BYTE (purple 50% opacity rectangle over sprite)
    Double Points: draw gold particle trail (3 gold 1×1 pixels, 0.2s lifetime, emitted at 20hz)

OBSTACLES — implement all exactly:
Ground obstacles (move left at game speed, spawn at x=490):
  G1 firewall_low: 32×32, hitbox 28×28 (2,2), red (#FF0033) face, dark red fill, not jumpable but requires jump to pass
  G2 firewall_high: 32×48, hitbox 28×44 (2,2), same style as G1 but taller double-stack
  G3 corrupted_node: 24×24, hitbox 20×20 (2,2), purple (#9D00FF) with dark center and pink corner pixels
  G4 data_wall: 16×64, hitbox 12×60 (2,2), tall thin red wall with horizontal band details
Air obstacles:
  A1 laser_gate: drawn dynamically as 8px wide orange beam, sweeps vertically 80px up/down at 100px/s, full height lethal, player must time slide under emitter gap; spawns post-score 500
  A2 security_drone: 32×16, hitbox 28×12 (2,2), orange (#FF6600) body with sensor beam drawn below, flies from x=490 at game_speed+50px/s at y=190 (player head height), 1-second warning flash (orange vertical line at right edge + warning beep) before spawn; post-score 750
  A3 firewall_beam: 480×6 drawn dynamically, red (#FF0033), horizontal laser at y=180, 0.5s warning (30% opacity blink at 8hz) before appearing; post-score 1500
Floating obstacles:
  F1 data_mine: 24×24, hitbox 18×18 (3,3), purple orb with rotating pixel markers, sine wave y motion: center=180px above ground, amplitude=40, frequency=2hz; post-score 1000
  F2 viral_cluster: three data_mines spawned with y-phase offsets of 0, pi/3, 2pi/3 and x-offsets of 0, 20, 40; each individually collidable; post-score 1500
Combo pairs (post-score 2000, spawned simultaneously with x offset):
  C1: G1 + A1 laser directly above at precise jump height gap of 40px
  C2: F1 + G1 mine floating 50px above block, player must jump through narrow gap
  C3: A2 + A3 beam simultaneously: beam at y=200, drone at y=190, player must slide
  C4: F2 + G2 tall wall with cluster just past it
  C5: G4 + F1 tall wall then mine immediately after

COLLECTIBLES (collectible.lua):
  Data Fragment: 12×12 canvas, cyan diamond pixel art (diamond-shaped using pixel rows: 2,4,6,8,6,4,2 px wide), 8-frame spin animation (squish x-width across frames), bobbing ±3px at 1.5hz, 10 points, 6-particle cyan burst on collect
  Power Core: 16×16 canvas, gold (#FFCC00) filled circle approx, white inner highlight, 8-frame pulse (inner light 4×4 to 8×8), 100 points + random effect, 14-particle gold burst + white flash on collect
  Power Core effects — implement all 4:
    PC1 Shield: 5s invincibility flag on player, draw cyan ring, on collision: absorb hit (no death), spawn shield-burst particles, end shield flag
    PC2 Slow-Mo: 3s set game_speed_multiplier=0.5, music pitch *= 0.6, draw purple overlay on BYTE
    PC3 Magnet: 8s set magnet_active=true, any fragment within 100px radius moves toward player at 200px/s, draw orbit dots around BYTE
    PC4 Double Points: 10s set score_multiplier=2.0, all point gains doubled, score display turns gold

SPAWNER (spawner.lua):
  Maintain spawn_timer (counts pixels traveled since last spawn)
  On timer expiry: pick random obstacle from current phase pool (weighted), spawn at x=490, reset timer with random gap from current range
  Power Core: independent spawn_core_timer, triggers every 2000–3000 pixels traveled (love.math.random(2000,3000))
  Data Fragments: spawn in groups of 3–5 as arcs — each group defined relative to nearest obstacle, fragments at varying y heights (40–100px above ground), 24px apart horizontally
  Never spawn power core within 200px of any obstacle

DIFFICULTY (difficulty.lua):
  Track distance_traveled (pixels) and elapsed_seconds (time)
  Compute phase from score (not distance): phase 1=0-500pts, 2=500-1000, 3=1000-2000, 4=2000-3500, 5=3500-5000, 6=5000+
  target_speed: phase1=200, 2=260, 3=300, 4=340, 5=380, 6=400
  current_speed lerps toward target_speed at rate 30px/s per second (smooth)
  Also: +10px/s every 10 elapsed_seconds (track this separately, applies on top of phase speed)
  gap_range: phase1=[500,700], 2=[420,580], 3=[360,500], 4=[280,420], 5=[200,340], 6=[160,280]
  obstacle_pool: phase1=[G1,G3], 2=[G1,G2,G3,A1], 3=[G1,G2,G3,A1,F1,A2], 4=[all+G4,A3,C1,C2], 5=[all+C3,C4,F2], 6=[all combos]
  On speed change: emit "SPEED UP" toast to HUD system

COLLISION (collision.lua):
  aabb(a, b): return a.x+a.ox < b.x+b.ox+b.hw and a.x+a.ox+a.hw > b.x+b.ox and a.y+a.oy < b.y+b.oy+b.hh and a.y+a.oy+a.hh > b.y+b.oy
  near_miss(player, obs): check if distance between hitbox edges < 20px on x axis after obstacle has passed (obs.x + obs.w < player.x), within same y range
  Returns: {hit=bool, near_miss=bool}

SCORING (scoring.lua):
  distance_score: increments +1 per 10 pixels of distance_traveled
  fragment_score: +10 per fragment (×score_multiplier ×combo_multiplier)
  core_score: +100 per core (×score_multiplier)
  near_miss_score: +25 per event
  combo: track consecutive_fragments counter, reset on miss or death
    5-9 = 1.5× LINKED cyan, 10-14 = 2× SYNCED pink, 15+ = 3× OVERCLOCKED gold pulsing
  milestone every 500 pts: +200 bonus, show CHECKPOINT toast
  milestone every 1000 pts: show LEVEL UP toast
  performance_rating: computed from total score per table in Section 8
  highscore: load from love.filesystem on init; update and save if beaten on death

PARALLAX (parallax.lua):
  Implement all 5 layers, each as a pre-rendered canvas tile that repeats:
  Layer 1 (20% speed, 480×300 tile): black with 80 scattered 1×1 white pixels + 5 2×2 bright stars
  Layer 2 (40% speed, 480×200 tile at y=100): dark purple/navy building silhouettes of varying widths (8–48px) and heights (20–80px), lit windows (2×2 cyan/amber/pink pixels) on every 3rd building, large billboard on every 5th building (32×8 px rectangle, #FF00FF, with 3-pixel animated glow bands)
  Layer 3 (60% speed, 480×300 tile): vertical and horizontal grid lines every 32px (#1A1A4E at 0.15 opacity), hex labels (4-char strings drawn with love.graphics.print at 4px scale) every 128px
  Layer 4 (100% speed, 480×48 tile at y=252): dark (#1E1E3E) platform, cyan top edge (2px #00FFFF at 40%), vertical circuit lines every 64px (1px cyan), node pixels every 128px (4×4 bright cyan)
  Layer 5 (80% speed): 30 particles as described — managed separately from particle system
  All layers: track scroll_x per layer, increment by layer_speed * dt, wrap at tile_width using modulo

PARTICLES (particles.lua):
  Particle pool: max 300 objects {x,y,vx,vy,life,max_life,color,size,gravity_affected}
  spawn_burst(x, y, count, color, size, min_speed, max_speed, gravity): creates `count` particles flying in random directions
  spawn_spiral(x, y, count, color): creates particles moving outward in evenly-spaced angles
  update(dt): update all live particles (velocity, position, gravity if applicable, life decay)
  draw(): draw all live particles as filled rectangles, alpha = life/max_life
  Implement all particle events from Section 12

AUDIO (systems/audio.lua):
  Create a stub audio manager that has the correct API surface:
    play_sfx(name): attempts to play named sound, silently fails if not loaded
    play_music(name): starts looping background music track
    stop_music(): stops current music
    set_music_pitch(factor): sets music playback rate
    toggle_mute(): toggles global mute
  If love.audio synthesis is feasible for simple waveforms, implement jump (ascending sine blip), collect (random-pitch ping), death (descending glissando). Otherwise leave as silent stubs.
  All SFX names match the event names in Section 13.

SPRITES (systems/sprites.lua):
  Module with load() function called in love.load()
  Creates table: Sprites = { player={run={},jump={},slide,death={}}, obstacles={}, collectibles={} }
  Implement every sprite from Section 16 exactly as described
  Use love.graphics.setCanvas(canvas) → draw → love.graphics.setCanvas() pattern
  All canvases are 1× (native pixel) size, drawn at 2× scale in game

HUD (ui/hud.lua):
  draw(score, best, distance, speed, combo_count, active_powerup, powerup_timer, powerup_max):
    Top-left: "SCORE: " .. score in white, font size equivalent to 8px native
    Below score: "DIST: " .. distance .. "M" smaller
    Top-right: "BEST: " .. best in pink (#FF00FF)
    Bottom-left: "SPD" label + 80×8px bar filled left-to-right in cyan, fill = (speed-200)/200
    Bottom-right: if active_powerup then draw 16×16 power-up icon + 64×8 draining bar in power-up color
    Top-center: if combo_count >= 5 then draw combo label in tier color, scale pulsing at 3hz (math.sin(love.timer.getTime()*6)*0.1+1.0)
  Toast system: list of active toasts {text, timer, color}, drawn center-right, fade out over 1.5s

EFFECTS (ui/effects.lua):
  Scanlines: love.graphics.setColor(0,0,0,0.18); for y=0,600,2 do rectangle(0,y,960,1) end
  Vignette: 4 dark gradient-like rects from each edge (simulate with multiple semi-transparent rects at 80%, 60%, 40%, 20% edges, 60px deep)
  screen_shake: apply love.graphics.translate(rx,ry) at start of draw, where rx/ry decay to 0
  white_flash: if flash_timer > 0 then draw full-screen white rect at alpha=flash_timer/flash_duration
  glitch_effect(canvas): draw 3 horizontal bands of the canvas with ±8px x offset, cyan/red chromatic copies at ±2px (for game-over screen only)
  speed_lines: if speed >= 350 then draw 12 horizontal 1×1 white lines from right edge, varying lengths 40–120px, moving left, alpha 0.35
  drone_warning: draw orange 1px vertical line at x=958, 600px tall, alpha blinks at 8hz for 1s

BOOT STATE (states/boot.lua):
  Lines scroll in with 0.3s delay between each:
  Line 1: "AXIOM CORP SECURITY INTERFACE v9.1.4"
  Line 2: "SCANNING ACTIVE PROCESSES..."
  Line 3: "ANOMALY DETECTED: UNAUTHORIZED ENTITY"
  Line 4: "CLASSIFICATION: [BYTE] — ROGUE SUBROUTINE"
  Line 5: "DISPATCHING PROTOCOL ZERO..."
  Line 6: ">> INITIATING DELETION SEQUENCE..."
  After line 6: draw ASCII NEON DASH logo (hand-crafted using love.graphics.print of multi-line string)
  Total duration 3.0s, any key after line 4 skips to menu
  Blinking cursor after last fully drawn line

MENU STATE (states/menu.lua):
  Full parallax background running at 200px/s
  Floating data particles active
  "NEON DASH" centered, large (3× font scale), color #FF00FF, text-glow achieved by drawing same text in #00FFFF at offsets (±1,0) and (0,±1) before drawing pink version on top
  "CYBER RUNNER" below in #00FFFF, 1× scale, letter spacing achieved by spacing characters manually
  "PRESS SPACE TO RUN" blinking at 1hz, white, centered below
  "BEST: " .. highscore in cyan, bottom center
  M key hint: "M - MUTE" bottom right

COUNTDOWN STATE (states/countdown.lua):
  Parallax continues at 200px/s
  Show "3", "2", "1", "GO!" centered; each 0.7s
  Each number: scale slams to 2.0 on entry then lerps to 1.0 over duration
  "GO!" color: #FF00FF; scale slams to 3.0 then fades (alpha 1→0 over 0.3s)
  After "GO!" fade: transition to gameplay state

GAMEPLAY STATE (states/gameplay.lua):
  On enter: reset all systems (player, spawner, difficulty, scoring, particles, effects)
  update(dt):
    if paused: skip game logic, still draw everything
    difficulty:update(dt)
    player:update(dt, game_speed)
    spawner:update(dt, distance_traveled, game_speed)
    for each obstacle: obstacle:update(dt, game_speed)
    for each collectible: collectible:update(dt, game_speed)
    collision results: check player vs obstacles, player vs collectibles
    scoring:update(dt, collision_results, distance_traveled)
    particles:update(dt)
    effects:update(dt)
    remove offscreen entities (x < -100)
    if player.dead: trigger death sequence (shake, flash, 0.8s delay, then gameover state)
  draw():
    love.graphics.push(); apply shake offset
    parallax:draw()
    draw all obstacles
    player:draw()
    draw all collectibles
    particles:draw()
    love.graphics.pop()
    hud:draw(...)
    effects:draw_scanlines()
    effects:draw_vignette()
    effects:draw_flash()
    effects:draw_speed_lines()
    if paused: draw dark overlay + "PAUSED" + controls reminder
  keypressed: SPACE/W/UP = player jump; S/DOWN/CTRL = player slide; P/ESC = toggle pause; M = mute

GAMEOVER STATE (states/gameover.lua):
  On enter: capture current gameplay canvas as screenshot (love.graphics.newCanvas, draw final frame to it)
  draw():
    Draw frozen game canvas at 50% opacity as background
    Apply glitch_effect to background canvas
    Draw centered dark panel (#0A0A1E, 700×340px, centered, cyan 2px border)
    "CONNECTION LOST" at panel top in #FF00FF, 1.5× scale, glitch text effect (offset ±2px per 0.05s)
    System error message (random from pool) in white, 0.5× scale, word-wrapped, centered
    "SCORE: " .. score large, white
    "BEST: " .. best in gold if new record, else pink; "NEW RECORD!" in gold + scale pulse if new
    "DIST: " .. dist .. "M | FRAGS: " .. fragments .. " | MAX COMBO: x" .. max_combo
    Performance rating label in its color
    "R - RETRY" blinking in cyan; "ESC - MENU" in smaller white
  keypressed: R → countdown state; ESC → menu state

---

WEBSITE (web/index.html and web/style.css):
Create a complete two-file website. index.html must be a standalone HTML5 page with a link to style.css.

index.html structure:
  DOCTYPE html5, lang="en"
  Google Font: Press Start 2P
  Link to style.css
  Header: h1 "NEON DASH", p "CYBER RUNNER" subtitle, nav with 3 buttons
  Main: div#game-wrapper containing canvas#canvas (960×600), two div.neon-bar elements (left and right), div#loading-screen
  Section#controls: styled table of controls
  Footer: copyright text + credits
  Script: love.js src + Module setup
  Script: vanilla JS for visibilitychange pause, fullscreen button, localStorage high score sync

style.css must include:
  CSS reset
  :root with all color variables matching game palette
  body: background #05050F, overflow-x hidden
  Animated scanline background using ::before with repeating-linear-gradient
  All layout: flexbox, centered column
  h1 styling: Press Start 2P, #FF00FF, neon text-shadow glow, titleGlow keyframe animation
  canvas#canvas: border 2px solid #00FFFF, box-shadow neon glow effect
  .neon-bar: 3px wide, 600px tall, positioned absolute left/right of canvas, pulsing opacity animation
  #controls table: dark bg, #00FFFF borders, Press Start 2P 0.5rem
  @media (max-width: 980px): hide canvas, show #mobile-warning
  All required @keyframes: neonPulse, titleGlow, blink, scanlineScroll

---

IMPLEMENTATION RULES:
1. Every single file must be 100% complete — zero TODOs, zero placeholder comments
2. All systems fully wired together in gameplay.lua
3. Use dt-based movement everywhere
4. Module pattern: every file returns its module as a table
5. No global variable leaks — pass references between systems as needed
6. Draw order strictly as specified
7. Every entity has: x, y, w, h, hitbox_ox, hitbox_oy, hitbox_w, hitbox_h, update(dt, speed), draw()
8. love.js compatibility: no io, no os, love.filesystem only, love.math.random only
9. Seed: love.math.setRandomSeed(love.timer.getTime() * 1000000) in love.load()
10. Pre-render all sprites in love.load() via sprites.lua:load()
11. Particle pool hard-capped at 300 to maintain 60fps
12. Handle focus loss: love.focus callback → pause gameplay if active

Start immediately. Output every file in full, in order: main.lua, conf.lua, then each game/ module, then web/ files, then README.md.
```

---

*End of PRD — NEON DASH: CYBER RUNNER v2.0*
*Concept: Neon Dash: Cyber Runner | Detail Architecture: NEON RONIN v1.0*
