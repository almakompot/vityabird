extends PowerUp
class_name PublicWorksJetpack

@export var ascent_boost: float = -240.0
@export var hover_grace: float = 0.25

func activate(player: RunnerPlayer, _world: Node) -> void:
    player.start_jetpack(duration)

func update(delta: float, player: RunnerPlayer, _world: Node) -> void:
    if Input.is_action_pressed("runner_jump"):
        player.velocity.y = min(player.velocity.y, ascent_boost)

func deactivate(player: RunnerPlayer, _world: Node) -> void:
    player.end_jetpack()
