# Godot Prototype Plan – Core Feel Vertical Slice

This document describes the moment-to-moment gameplay prototype required to validate tone, pacing, and mechanics for the "Endless Escape" vertical slice.

## Prototype Goals
1. **Establish Cartoon Chase Momentum** – Responsive run/jump/slide loop with comedic FX hooks.
2. **Demonstrate Escalating Pressure** – Simple heat meter that spawns additional pursuers.
3. **Inject Satirical Flavor** – Contextual barks, UI callouts, and prop gags triggered by player actions.

## Scene Structure
```
MainScene (Node2D)
├── World (Node2D)
│   ├── ParallaxBackground (ParallaxBackground)
│   │   ├── LayerSky (ParallaxLayer -> Sprite2D)
│   │   └── LayerCity (ParallaxLayer -> Sprite2D)
│   ├── Ground (StaticBody2D + CollisionShape2D)
│   ├── ObstacleSpawner (Node)
│   ├── PickupSpawner (Node)
│   ├── PursuitDirector (Node)
│   └── Vic (CharacterBody2D)
│       ├── AnimatedSprite2D
│       └── DustTrail (GPUParticles2D)
├── UI (CanvasLayer)
│   ├── HeatMeter (TextureProgressBar)
│   ├── PromptLabel (RichTextLabel)
│   ├── PowerupTimer (Label)
│   └── CaptionFeed (VBoxContainer)
└── AudioBus (Node)
    ├── Music (AudioStreamPlayer)
    └── SFX (AudioStreamPlayer2D)
```

## Implementation Steps
1. **Character Controller**
   - Add `Vic` as `CharacterBody2D` with capsule collider and `AnimatedSprite2D` states (`run`, `jump`, `slide`, `jetpack`).
   - Configure gravity (1800 px/s²), run speed (320 px/s), jump impulse (600 px/s), slide duration (0.4 s).
   - Hook input actions: `ui_accept` (jump), `slide` (swipe/down arrow), `powerup` (tap & hold).

2. **Lane Management**
   - Use invisible markers to lock the player to ground plane while allowing vertical arcs.
   - Add `CoyoteTimer` to permit jump input within 0.1s after leaving ground for forgiving controls.

3. **Obstacle & Pickup Systems**
   - `ObstacleSpawner` instantiates pre-authored scenes (e.g., `CaviarTray.tscn`, `Limousine.tscn`) every 1.5–3 seconds based on heat level.
   - `PickupSpawner` emits `SpinTape` and `ConsultancyCoin` nodes using weighted randomness; align them with safe lanes.
   - Add `Area2D` triggers on obstacles/pickups to play VO quips when first encountered.

4. **Heat Meter & Pursuit Director**
   - Heat increases by +1 per second and +5 per obstacle hit; decreases by -10 when picking up `SpinTape`.
   - At thresholds (25/50/75) the `PursuitDirector` spawns drones, limos, and helicopter spotlight overlays respectively.
   - Each spawn triggers a bark from Agent Hilda via `CaptionFeed` (scrolling headline UI).

5. **Tone Delivery**
   - Implement `CaptionFeed` as a queue of two-line jokes pulled from JSON to ensure repeatable style testing.
   - Trigger dust trails and money particle effects during slides and power-up activation.
   - Sync protest chants to beat markers in `Music` player (use `AudioStreamPlayback` callbacks).

6. **Camera & Parallax**
   - Parent `Camera2D` to `Vic` with dampening (0.1) and custom screen shake on obstacle impacts.
   - Parallax background uses 3 speeds (sky 0.2x, city 0.5x, foreground signage 0.8x) for depth.

7. **Moment-to-Moment Loop**
   - Tutorial prompts appear via `PromptLabel` with timers that fade out once the player performs each action.
   - After 90 seconds, enable procedural segment randomization using a queue of chunk scenes.

## Sample GDScript – Vic Controller
```gdscript
extends CharacterBody2D

@export var run_speed: float = 320.0
@export var jump_velocity: float = -600.0
@export var slide_duration: float = 0.4
@export var gravity: float = 1800.0

var _slide_timer := 0.0
var _coyote_timer := 0.0
var _is_sliding := false

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
    else:
        velocity.y = max(velocity.y, 0.0)
        _coyote_timer = min(_coyote_timer + delta, 0.1)

    velocity.x = run_speed

    _handle_jump(delta)
    _handle_slide(delta)

    move_and_slide()
    _update_animation()

func _handle_jump(delta: float) -> void:
    if Input.is_action_just_pressed("ui_accept") and (_coyote_timer > 0.0 or is_on_floor()):
        velocity.y = jump_velocity
        _coyote_timer = 0.0
        $AnimatedSprite2D.play("jump")
        get_tree().call_group("vo", "play_quip", "jump")
    elif is_on_floor():
        _coyote_timer = 0.1

func _handle_slide(delta: float) -> void:
    if Input.is_action_just_pressed("slide") and is_on_floor() and not _is_sliding:
        _is_sliding = true
        _slide_timer = slide_duration
        $AnimatedSprite2D.play("slide")
        $CollisionShape2D.scale.y = 0.6
        get_tree().call_group("sfx", "emit_slide")
    if _is_sliding:
        _slide_timer -= delta
        if _slide_timer <= 0.0:
            _is_sliding = false
            $CollisionShape2D.scale.y = 1.0
            $AnimatedSprite2D.play("run")

func _update_animation() -> void:
    if is_on_floor() and not _is_sliding:
        $AnimatedSprite2D.play("run")
```

## Satirical Feedback Hooks
- **VO Manager:** Autoload singleton (`VoDirector.gd`) that sequences narrator, Hilda, and protest chants; ensures quip cooldown (min 6s between lines).
- **Headline Pop-ups:** On major events (heat thresholds, crashes), spawn floating UI cards with tabloid-style headlines to reinforce tone.
- **Dynamic Music Stems:** Blend in brass stabs when heat > 50; reduce percussion when player activates megaphone power-up.

## Prototype Milestones
1. **Day 1–2:** Build scene skeleton, movement controller, placeholder sprites.
2. **Day 3–4:** Implement spawners, heat logic, UI prompts.
3. **Day 5:** Layer satire systems (VO, captions), tighten juice (particles, screen shake).
4. **Day 6:** Playtest for readability, adjust pacing, capture vertical slice footage.
