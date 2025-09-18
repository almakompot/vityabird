extends Area2D
class_name PowerUpPickup

signal collected(powerup_id: StringName)

@export var powerup_id: StringName = &"public_works_jetpack"
@export var auto_activate: bool = true
@export var sprite_color: Color = Color(0.984314, 0.815686, 0.290196, 1)

var _powerup_manager: PowerUpManager

func _ready() -> void:
    connect("body_entered", Callable(self, "_on_body_entered"))
    if has_node("Sprite2D"):
        var sprite: Sprite2D = get_node("Sprite2D")
        sprite.modulate = sprite_color

func _on_body_entered(body: Node) -> void:
    if not body is RunnerPlayer:
        return
    if _powerup_manager == null:
        _powerup_manager = _find_powerup_manager()
    if _powerup_manager:
        if auto_activate:
            _powerup_manager.grant_powerup(powerup_id)
            var powerup := _powerup_manager.get_powerup(powerup_id)
            if powerup:
                _powerup_manager.activate_powerup(powerup)
        else:
            _powerup_manager.grant_powerup(powerup_id)
    collected.emit(powerup_id)
    queue_free()

func assign_manager(manager: PowerUpManager) -> void:
    _powerup_manager = manager

func _find_powerup_manager() -> PowerUpManager:
    var node := get_parent()
    while node:
        if node is PowerUpManager:
            return node
        node = node.get_parent()
    return null
