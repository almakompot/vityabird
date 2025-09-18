extends PowerUp
class_name NationalizedMediaMegaphone

@export var heat_multiplier: float = 0.35
@export var decay_bonus: float = -0.6

var _applied: bool = false

func activate(_player: RunnerPlayer, world: Node) -> void:
    _applied = true
    if world.has_method("apply_heat_modifier"):
        world.apply_heat_modifier(heat_multiplier, duration, decay_bonus)

func update(delta: float, _player: RunnerPlayer, world: Node) -> void:
    pass

func deactivate(_player: RunnerPlayer, _world: Node) -> void:
    _applied = false
