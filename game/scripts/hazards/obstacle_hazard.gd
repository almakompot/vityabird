extends StaticBody2D
class_name ObstacleHazard

@export var heat_damage: float = 1.0
@export var destroy_on_hit: bool = false
@export var defeat_reason: String = "Stumbled into barricade"

func _ready() -> void:
    add_to_group("hazard")

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
