extends Node2D
class_name RunnerWorld

@export var player_path: NodePath
@export var camera_path: NodePath
@export var segment_spawner_path: NodePath
@export var powerup_manager_path: NodePath
@export var powerup_pickup_scene: PackedScene
@export var coin_pickup_scene: PackedScene
@export var coin_value: float = 1.0
@export var coin_spawn_variance: float = 12.0
@export var camera_lead: float = 320.0
@export var camera_height_offset: float = 120.0
@export var camera_smoothing: float = 6.0
@export var speed_ramp_interval: float = 9.0
@export var speed_ramp_amount: float = 18.0

var coin_bank: float = 0.0
var chase_heat: float = 0.0

var _player: RunnerPlayer
var _camera: Camera2D
var _segment_spawner: SegmentSpawner
var _powerup_manager: PowerUpManager
var _speed_timer: float = 0.0
var _motorcade_active: bool = false
var _base_heat_ramp: float = 0.0
var _heat_multiplier: float = 1.0
var _heat_modifier_time: float = 0.0
var _heat_decay_bonus: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    if player_path != NodePath(""):
        _player = get_node(player_path)
    if camera_path != NodePath(""):
        _camera = get_node(camera_path)
    if segment_spawner_path != NodePath(""):
        _segment_spawner = get_node(segment_spawner_path)
    if powerup_manager_path != NodePath(""):
        _powerup_manager = get_node(powerup_manager_path)
        if _powerup_manager:
            if _player:
                _powerup_manager.set_player(_player)
            _powerup_manager.set_world(self)
    _speed_timer = speed_ramp_interval
    if _segment_spawner:
        _base_heat_ramp = _segment_spawner.heat_ramp_rate
        if _player:
            _segment_spawner.set_player(_player)
            _segment_spawner.player_path = _player.get_path()
        _segment_spawner.segment_spawned.connect(Callable(self, "_on_segment_spawned"))
    _rng.randomize()

func _process(delta: float) -> void:
    if _player:
        _update_camera(delta)
        _update_speed(delta)
    if _segment_spawner:
        chase_heat = _segment_spawner.heat_level
    _update_heat_modifier(delta)

func add_currency(amount: float) -> void:
    coin_bank += amount

func drain_currency(amount: float) -> void:
    coin_bank = max(0.0, coin_bank - amount)

func summon_motorcade(_duration: float) -> void:
    _motorcade_active = true

func dismiss_motorcade() -> void:
    _motorcade_active = false

func apply_heat_modifier(multiplier: float, duration: float, decay_bonus: float = 0.0) -> void:
    _heat_multiplier = multiplier
    _heat_modifier_time = duration
    _heat_decay_bonus = decay_bonus
    if _segment_spawner:
        _segment_spawner.heat_ramp_rate = _base_heat_ramp * multiplier

func _update_camera(delta: float) -> void:
    if not _camera or not _player:
        return
    var target := Vector2(_player.global_position.x + camera_lead, _player.global_position.y - camera_height_offset)
    var weight := clamp(delta * camera_smoothing, 0.0, 1.0)
    _camera.global_position = _camera.global_position.lerp(target, weight)

func _update_speed(delta: float) -> void:
    if not _player:
        return
    _speed_timer -= delta
    if _speed_timer <= 0.0:
        _player.run_speed += speed_ramp_amount
        _speed_timer = speed_ramp_interval

func _update_heat_modifier(delta: float) -> void:
    if _heat_modifier_time <= 0.0:
        return
    _heat_modifier_time -= delta
    if _heat_modifier_time <= 0.0:
        _heat_multiplier = 1.0
        if _segment_spawner:
            _segment_spawner.heat_ramp_rate = _base_heat_ramp
            _segment_spawner.heat_level = clamp(_segment_spawner.heat_level + _heat_decay_bonus, 0.0, _segment_spawner.max_heat)
        _heat_decay_bonus = 0.0

func _on_segment_spawned(segment: Node, tileset: EnvironmentTileset) -> void:
    if segment == null or not segment is SegmentChunk:
        return
    var chunk := segment as SegmentChunk
    _spawn_coins_for_segment(segment, chunk)
    _spawn_powerup_for_segment(segment, chunk, tileset)

func _spawn_coins_for_segment(segment: Node, chunk: SegmentChunk) -> void:
    if coin_pickup_scene == null:
        return
    var markers := chunk.get_spawn_markers("coins")
    if markers.is_empty():
        return
    for marker: Marker2D in markers:
        var coin_instance := coin_pickup_scene.instantiate()
        if coin_instance == null:
            continue
        segment.add_child(coin_instance)
        var coin := coin_instance as Coin
        if coin:
            coin.set_world(self)
            coin.value = coin_value
        var offset := Vector2.ZERO
        if coin_spawn_variance > 0.0:
            offset = Vector2(
                _rng.randf_range(-coin_spawn_variance, coin_spawn_variance),
                _rng.randf_range(-coin_spawn_variance, coin_spawn_variance) * 0.5
            )
        coin_instance.position = marker.position + offset

func _spawn_powerup_for_segment(segment: Node, chunk: SegmentChunk, tileset: EnvironmentTileset) -> void:
    if powerup_pickup_scene == null or _powerup_manager == null:
        return
    var markers := chunk.get_spawn_markers("powerups")
    if markers.is_empty():
        return
    var marker: Marker2D = markers[_rng.randi_range(0, markers.size() - 1)]
    var pickup: PowerUpPickup = powerup_pickup_scene.instantiate()
    if pickup == null:
        return
    segment.add_child(pickup)
    pickup.position = marker.position
    pickup.assign_manager(_powerup_manager)
    pickup.powerup_id = _select_powerup_for_tileset(tileset)

func _select_powerup_for_tileset(tileset: EnvironmentTileset) -> StringName:
    if tileset and tileset.powerup_bias.size() > 0:
        var index := _rng.randi_range(0, tileset.powerup_bias.size() - 1)
        return StringName(tileset.powerup_bias[index])
    if _powerup_manager:
        var pool: Array[StringName] = []
        for powerup in _powerup_manager.available_powerups:
            if powerup:
                pool.append(powerup.id)
        if pool.size() > 0:
            var idx := _rng.randi_range(0, pool.size() - 1)
            return pool[idx]
    return &"public_works_jetpack"
