extends Area2D
class_name Coin

signal collected(amount: float)

@export var value: float = 1.0
@export var spin_speed_degrees: float = 180.0

var _world: RunnerWorld

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    rotation += deg_to_rad(spin_speed_degrees) * delta

func set_world(world: RunnerWorld) -> void:
    _world = world

func _on_body_entered(body: Node) -> void:
    if not body is RunnerPlayer:
        return
    if _world:
        _world.add_currency(value)
    collected.emit(value)
    queue_free()
