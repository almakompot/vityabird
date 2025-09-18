extends CharacterBody2D
class_name PatrolGuard

@export var heat_damage: float = 1.5
@export var destroy_on_hit: bool = true
@export var defeat_reason: String = "Caught by guard"
@export var patrol_speed: float = 120.0
@export var patrol_distance: float = 160.0
@export var start_direction: int = 1

var _origin: Vector2
var _direction: int = 1

func _ready() -> void:
    add_to_group("hazard")
    _origin = global_position
    _direction = 1 if start_direction >= 0 else -1
    set_physics_process(patrol_speed > 0.0)

func _physics_process(delta: float) -> void:
    if patrol_speed <= 0.0:
        velocity = Vector2.ZERO
        return
    velocity.x = patrol_speed * _direction
    velocity.y = 0.0
    move_and_slide()
    var offset := global_position.x - _origin.x
    if abs(offset) >= patrol_distance:
        _direction *= -1
        var clamped := clamp(offset, -patrol_distance, patrol_distance)
        global_position.x = _origin.x + clamped

func get_heat_damage() -> float:
    return heat_damage

func should_destroy_on_hit() -> bool:
    return destroy_on_hit

func get_defeat_reason() -> String:
    return defeat_reason

func on_player_blocked(_player: RunnerPlayer, _world: RunnerWorld) -> void:
    if destroy_on_hit:
        queue_free()

func on_player_damaged(_player: RunnerPlayer, _world: RunnerWorld) -> void:
    if destroy_on_hit:
        queue_free()
