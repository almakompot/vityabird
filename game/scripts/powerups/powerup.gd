extends Resource
class_name PowerUp

@export var id: StringName = &"power_up"
@export var display_name: String = "Power Up"
@export var description: String = ""
@export var duration: float = 3.0
@export var cooldown: float = 8.0
@export var icon: Texture2D

func can_activate(_world: Node) -> bool:
    return true

func activate(_player: RunnerPlayer, _world: Node) -> void:
    pass

func update(_delta: float, _player: RunnerPlayer, _world: Node) -> void:
    pass

func deactivate(_player: RunnerPlayer, _world: Node) -> void:
    pass
