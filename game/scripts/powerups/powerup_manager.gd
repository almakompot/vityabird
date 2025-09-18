extends Node
class_name PowerUpManager

signal powerup_activated(powerup: PowerUp)
signal powerup_finished(powerup: PowerUp)
signal powerup_ready(powerup: PowerUp)

@export var player_path: NodePath
@export var world_path: NodePath
@export var available_powerups: Array[PowerUp] = []
@export var randomize_queue: bool = true

var _player: RunnerPlayer = null
var _world: Node = null
var _active_powerup: PowerUp = null
var _active_timer: float = 0.0
var _cooldowns: Dictionary[StringName, float] = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _ready_state: Dictionary[StringName, bool] = {}

func _ready() -> void:
    if player_path != NodePath(""):
        _player = get_node(player_path)
    if world_path != NodePath(""):
        _world = get_node(world_path)
    _rng.randomize()
    for powerup in available_powerups:
        _cooldowns[powerup.id] = INF
        _ready_state[powerup.id] = false

func _process(delta: float) -> void:
    _update_cooldowns(delta)
    if _active_powerup:
        _active_timer -= delta
        if _player and _world:
            _active_powerup.update(delta, _player, _world)
        if _active_timer <= 0.0:
            _finish_active_powerup()
    else:
        if Input.is_action_just_pressed("runner_powerup"):
            trigger_random_powerup()

func trigger_random_powerup() -> bool:
    var ready: Array[PowerUp] = _get_ready_powerups()
    if ready.is_empty():
        return false
    var powerup: PowerUp = ready[0]
    if randomize_queue and ready.size() > 1:
        powerup = ready[_rng.randi_range(0, ready.size() - 1)]
    return activate_powerup(powerup)

func activate_powerup(powerup: PowerUp) -> bool:
    if _active_powerup:
        return false
    if _world == null:
        return false
    if not powerup.can_activate(_world):
        return false
    if _cooldowns.get(powerup.id, 0.0) > 0.0:
        return false
    if _player == null:
        return false
    _active_powerup = powerup
    _active_timer = powerup.duration
    _cooldowns[powerup.id] = powerup.cooldown
    _ready_state[powerup.id] = false
    _active_powerup.activate(_player, _world)
    powerup_activated.emit(powerup)
    return true

func _finish_active_powerup() -> void:
    if not _active_powerup:
        return
    _active_powerup.deactivate(_player, _world)
    powerup_finished.emit(_active_powerup)
    _active_powerup = null
    _active_timer = 0.0

func _get_ready_powerups() -> Array[PowerUp]:
    var ready: Array[PowerUp] = []
    for powerup in available_powerups:
        if powerup == null:
            continue
        if _cooldowns.get(powerup.id, 0.0) <= 0.0:
            ready.append(powerup)
    return ready

func _update_cooldowns(delta: float) -> void:
    for key in _cooldowns.keys():
        var id: StringName = key
        var previous_ready: bool = bool(_ready_state.get(id, false))
        _cooldowns[id] = max(_cooldowns[id] - delta, 0.0)
        var is_ready: bool = _cooldowns[id] <= 0.0
        _ready_state[id] = is_ready
        if is_ready and not previous_ready:
            var powerup: PowerUp = _find_powerup(id)
            if powerup:
                powerup_ready.emit(powerup)

func _find_powerup(id: StringName) -> PowerUp:
    for powerup in available_powerups:
        if powerup and powerup.id == id:
            return powerup
    return null

func set_player(player: RunnerPlayer) -> void:
    _player = player

func set_world(world: Node) -> void:
    _world = world

func grant_powerup(id: StringName) -> void:
    var powerup: PowerUp = _find_powerup(id)
    if not powerup:
        return
    _cooldowns[id] = 0.0
    _ready_state[id] = true
    powerup_ready.emit(powerup)

func get_powerup(id: StringName) -> PowerUp:
    return _find_powerup(id)
