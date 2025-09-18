extends CharacterBody2D
class_name RunnerPlayer

signal slide_started
signal slide_ended
signal jetpack_started
signal jetpack_ended
signal shield_broken

@export var run_speed: float = 420.0
@export var acceleration: float = 30.0
@export var jump_velocity: float = -620.0
@export var gravity: float = 1800.0
@export var max_fall_speed: float = 1400.0
@export var slide_duration: float = 0.45
@export var jetpack_hover_speed: float = -120.0
@export var jetpack_duration: float = 3.5

var current_speed: float = 0.0
var _slide_timer: float = 0.0
var _jetpack_timer: float = 0.0
var _is_sliding: bool = false
var _is_jetpacking: bool = false
var _shield_health: int = 0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _base_shape := collision_shape.shape.duplicate(true) if collision_shape.shape else null
@onready var _slide_shape := _make_slide_shape()
@onready var _base_collision_offset: Vector2 = collision_shape.position

func _ready() -> void:
    current_speed = run_speed

func _physics_process(delta: float) -> void:
    _apply_horizontal_acceleration(delta)
    if _is_jetpacking:
        _update_jetpack(delta)
    else:
        _apply_gravity(delta)
        _handle_jump_input()
        _handle_slide_input(delta)
    move_and_slide()

func _apply_horizontal_acceleration(delta: float) -> void:
    current_speed = move_toward(current_speed, run_speed, acceleration * delta)
    velocity.x = current_speed

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y = clamp(velocity.y + gravity * delta, -INF, max_fall_speed)
    elif velocity.y > 0.0:
        velocity.y = 0.0

func _handle_jump_input() -> void:
    if Input.is_action_just_pressed("runner_jump") and is_on_floor():
        velocity.y = jump_velocity

func _handle_slide_input(delta: float) -> void:
    if Input.is_action_just_pressed("runner_slide") and is_on_floor() and not _is_sliding:
        _begin_slide()
    if _is_sliding:
        _slide_timer -= delta
        if _slide_timer <= 0.0 or not Input.is_action_pressed("runner_slide"):
            _end_slide()

func _begin_slide() -> void:
    _is_sliding = true
    _slide_timer = slide_duration
    if _slide_shape and _base_shape:
        collision_shape.shape = _slide_shape
        collision_shape.position = _base_collision_offset + Vector2(0, (_base_shape.size.y - _slide_shape.size.y) * 0.5)
    slide_started.emit()

func _end_slide() -> void:
    _is_sliding = false
    if _base_shape:
        collision_shape.shape = _base_shape
        collision_shape.position = _base_collision_offset
    slide_ended.emit()

func start_jetpack(duration: float = jetpack_duration) -> void:
    _is_jetpacking = true
    _jetpack_timer = duration
    velocity.y = jetpack_hover_speed
    jetpack_started.emit()

func end_jetpack() -> void:
    if not _is_jetpacking:
        return
    _is_jetpacking = false
    jetpack_ended.emit()

func _update_jetpack(delta: float) -> void:
    velocity.y = move_toward(velocity.y, jetpack_hover_speed, 600.0 * delta)
    _jetpack_timer -= delta
    if _jetpack_timer <= 0.0:
        end_jetpack()

func apply_speed_multiplier(multiplier: float, duration: float) -> void:
    run_speed *= multiplier
    await get_tree().create_timer(duration).timeout
    run_speed /= multiplier

func add_shield(strength: int) -> void:
    _shield_health = max(_shield_health, strength)

func consume_shield_hit() -> bool:
    if _shield_health <= 0:
        return false
    _shield_health -= 1
    if _shield_health == 0:
        shield_broken.emit()
    return true

func set_run_speed(target_speed: float) -> void:
    run_speed = target_speed

func has_shield() -> bool:
    return _shield_health > 0

func clear_shield(emit_signal: bool = true) -> void:
    if _shield_health <= 0:
        return
    _shield_health = 0
    if emit_signal:
        shield_broken.emit()

func _make_slide_shape() -> RectangleShape2D:
    if _base_shape == null:
        return RectangleShape2D.new()
    var slide_shape := RectangleShape2D.new()
    slide_shape.size = Vector2(_base_shape.size.x, _base_shape.size.y * 0.6)
    return slide_shape
