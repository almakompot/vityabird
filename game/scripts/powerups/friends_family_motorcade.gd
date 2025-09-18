extends PowerUp
class_name FriendsFamilyMotorcade

@export var shield_strength: int = 3
@export var drain_rate: float = 15.0

var _timer: float = 0.0
var _active: bool = false

func activate(player: RunnerPlayer, world: Node) -> void:
    _timer = duration
    _active = true
    player.add_shield(shield_strength)
    if world.has_method("summon_motorcade"):
        world.summon_motorcade(duration, drain_rate)

func update(delta: float, player: RunnerPlayer, world: Node) -> void:
    if not _active:
        return
    _timer -= delta
    if world.has_method("drain_currency"):
        world.drain_currency(drain_rate * delta)

func deactivate(player: RunnerPlayer, world: Node) -> void:
    if not _active:
        return
    _active = false
    player.clear_shield(false)
    if world.has_method("dismiss_motorcade"):
        world.dismiss_motorcade()
