extends Node2D
class_name RunnerWorld

signal currency_changed(total: float)
signal currency_collected(amount: float)
signal currency_drained(amount: float)
signal distance_changed(distance: float)
signal motorcade_state_changed(active: bool, drain_rate: float)
signal run_ended(distance: float, coins: float, heat: float, reason: String)

@export var player_path: NodePath
@export var camera_path: NodePath
@export var segment_spawner_path: NodePath
@export var powerup_manager_path: NodePath
@export var hud_path: NodePath
@export var powerup_pickup_scene: PackedScene
@export var coin_pickup_scene: PackedScene
@export var coin_value: float = 1.0
@export var coin_spawn_variance: float = 12.0
@export var obstacle_scenes: Array[PackedScene] = []
@export var enemy_scenes: Array[PackedScene] = []
@export var obstacle_spawn_chance: float = 0.75
@export var enemy_spawn_chance: float = 0.6
@export var camera_lead: float = 320.0
@export var camera_height_offset: float = 120.0
@export var camera_smoothing: float = 6.0
@export var speed_ramp_interval: float = 9.0
@export var speed_ramp_amount: float = 18.0

var coin_bank: float = 0.0
var chase_heat: float = 0.0
var distance_traveled: float = 0.0

var _player: RunnerPlayer = null
var _camera: Camera2D = null
var _segment_spawner: SegmentSpawner = null
var _powerup_manager: PowerUpManager = null
var _hud: RunnerHUD = null
var _speed_timer: float = 0.0
var _motorcade_active: bool = false
var _motorcade_drain_rate: float = 0.0
var _base_heat_ramp: float = 0.0
var _heat_multiplier: float = 1.0
var _heat_modifier_time: float = 0.0
var _heat_decay_bonus: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _last_player_x: float = 0.0
var _run_active: bool = true
var _max_heat: float = 0.0

func _ready() -> void:
    _run_active = true
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
    if hud_path != NodePath(""):
        _hud = get_node(hud_path)
        if _hud:
            _hud.set_world(self)
    _speed_timer = speed_ramp_interval
    if _segment_spawner:
        _base_heat_ramp = _segment_spawner.heat_ramp_rate
        _max_heat = _segment_spawner.max_heat
        if _player:
            _segment_spawner.set_player(_player)
            _segment_spawner.player_path = _player.get_path()
        _segment_spawner.segment_spawned.connect(Callable(self, "_on_segment_spawned"))
    _rng.randomize()
    if _player:
        _last_player_x = _player.global_position.x
        _player.hazard_blocked.connect(_on_player_hazard_blocked)
        _player.hazard_damaged.connect(_on_player_hazard_damaged)
    currency_changed.emit(coin_bank)
    distance_changed.emit(distance_traveled)
    motorcade_state_changed.emit(_motorcade_active, _motorcade_drain_rate)

func _process(delta: float) -> void:
    if not _run_active:
        return
    if _player:
        _update_camera(delta)
        _update_speed(delta)
        _update_distance()
    if _segment_spawner:
        chase_heat = _segment_spawner.heat_level
    _update_heat_modifier(delta)

func add_currency(amount: float) -> void:
    if amount == 0.0:
        return
    coin_bank += amount
    currency_changed.emit(coin_bank)
    currency_collected.emit(amount)

func drain_currency(amount: float) -> void:
    if amount <= 0.0:
        return
    var previous: float = coin_bank
    coin_bank = max(0.0, coin_bank - amount)
    var drained: float = previous - coin_bank
    if drained <= 0.0:
        return
    currency_changed.emit(coin_bank)
    currency_drained.emit(drained)

func summon_motorcade(_duration: float, drain_rate: float = 0.0) -> void:
    _motorcade_active = true
    _motorcade_drain_rate = drain_rate
    motorcade_state_changed.emit(true, _motorcade_drain_rate)

func dismiss_motorcade() -> void:
    _motorcade_active = false
    _motorcade_drain_rate = 0.0
    motorcade_state_changed.emit(false, _motorcade_drain_rate)

func is_motorcade_active() -> bool:
    return _motorcade_active

func get_motorcade_drain_rate() -> float:
    return _motorcade_drain_rate

func apply_heat_modifier(multiplier: float, duration: float, decay_bonus: float = 0.0) -> void:
    _heat_multiplier = multiplier
    _heat_modifier_time = duration
    _heat_decay_bonus = decay_bonus
    if _segment_spawner:
        _segment_spawner.heat_ramp_rate = _base_heat_ramp * multiplier

func _update_camera(delta: float) -> void:
    if not _camera or not _player:
        return
    var target: Vector2 = Vector2(_player.global_position.x + camera_lead, _player.global_position.y - camera_height_offset)
    var weight: float = clamp(delta * camera_smoothing, 0.0, 1.0)
    _camera.global_position = _camera.global_position.lerp(target, weight)

func _update_speed(delta: float) -> void:
    if not _player:
        return
    _speed_timer -= delta
    if _speed_timer <= 0.0:
        _player.run_speed += speed_ramp_amount
        _speed_timer = speed_ramp_interval

func _update_distance() -> void:
    if not _player:
        return
    var current_x: float = _player.global_position.x
    if current_x > _last_player_x:
        distance_traveled += current_x - _last_player_x
        distance_changed.emit(distance_traveled)
    _last_player_x = current_x

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
    var chunk: SegmentChunk = segment as SegmentChunk
    _spawn_coins_for_segment(segment, chunk)
    _spawn_powerup_for_segment(segment, chunk, tileset)
    _spawn_obstacles_for_segment(segment, chunk)
    _spawn_enemies_for_segment(segment, chunk)

func _spawn_coins_for_segment(segment: Node, chunk: SegmentChunk) -> void:
    if coin_pickup_scene == null:
        return
    var markers: Array[Marker2D] = chunk.get_spawn_markers("coins")
    if markers.is_empty():
        return
    for marker: Marker2D in markers:
        var coin_instance: Node2D = coin_pickup_scene.instantiate() as Node2D
        if coin_instance == null:
            continue
        segment.add_child(coin_instance)
        var coin: Coin = coin_instance as Coin
        if coin:
            coin.set_world(self)
            coin.value = coin_value
        var offset: Vector2 = Vector2.ZERO
        if coin_spawn_variance > 0.0:
            offset = Vector2(
                _rng.randf_range(-coin_spawn_variance, coin_spawn_variance),
                _rng.randf_range(-coin_spawn_variance, coin_spawn_variance) * 0.5
            )
        coin_instance.position = marker.position + offset

func _spawn_powerup_for_segment(segment: Node, chunk: SegmentChunk, tileset: EnvironmentTileset) -> void:
    if powerup_pickup_scene == null or _powerup_manager == null:
        return
    var markers: Array[Marker2D] = chunk.get_spawn_markers("powerups")
    if markers.is_empty():
        return
    var marker: Marker2D = markers[_rng.randi_range(0, markers.size() - 1)]
    var pickup: PowerUpPickup = powerup_pickup_scene.instantiate() as PowerUpPickup
    if pickup == null:
        return
    segment.add_child(pickup)
    pickup.position = marker.position
    pickup.assign_manager(_powerup_manager)
    pickup.powerup_id = _select_powerup_for_tileset(tileset)

func _select_powerup_for_tileset(tileset: EnvironmentTileset) -> StringName:
    if tileset and tileset.powerup_bias.size() > 0:
        var index: int = _rng.randi_range(0, tileset.powerup_bias.size() - 1)
        return StringName(tileset.powerup_bias[index])
    if _powerup_manager:
        var pool: Array[StringName] = []
        for powerup in _powerup_manager.available_powerups:
            if powerup:
                pool.append(powerup.id)
        if pool.size() > 0:
            var idx: int = _rng.randi_range(0, pool.size() - 1)
            return pool[idx]
    return &"public_works_jetpack"

func _spawn_obstacles_for_segment(segment: Node, chunk: SegmentChunk) -> void:
    _spawn_hazards_for_segment(segment, chunk, &"obstacles", obstacle_scenes, obstacle_spawn_chance)

func _spawn_enemies_for_segment(segment: Node, chunk: SegmentChunk) -> void:
    _spawn_hazards_for_segment(segment, chunk, &"enemies", enemy_scenes, enemy_spawn_chance)

func _spawn_hazards_for_segment(segment: Node, chunk: SegmentChunk, group: StringName, scenes: Array[PackedScene], spawn_chance: float) -> void:
    if scenes.is_empty():
        return
    var markers: Array[Marker2D] = chunk.get_spawn_markers(group)
    if markers.is_empty():
        return
    for marker: Marker2D in markers:
        if spawn_chance < 1.0 and _rng.randf() > spawn_chance:
            continue
        var scene: PackedScene = scenes[_rng.randi_range(0, scenes.size() - 1)]
        if scene == null:
            continue
        var instance: Node = scene.instantiate()
        if instance == null:
            continue
        segment.add_child(instance)
        if instance is Node2D:
            instance.position = marker.position

func apply_heat_penalty(amount: float) -> float:
    if amount <= 0.0:
        return chase_heat
    if _segment_spawner:
        _segment_spawner.heat_level = clamp(_segment_spawner.heat_level + amount, 0.0, _segment_spawner.max_heat)
        chase_heat = _segment_spawner.heat_level
    else:
        var cap: float = _max_heat if _max_heat > 0.0 else chase_heat + amount
        chase_heat = clamp(chase_heat + amount, 0.0, cap)
    return chase_heat

func end_run(reason: String = "Apprehended") -> void:
    if not _run_active:
        return
    _run_active = false
    if _player:
        _player.end_jetpack()
        _player.set_controls_enabled(false)
    if _segment_spawner:
        _segment_spawner.set_process(false)
    if _powerup_manager:
        _powerup_manager.set_process(false)
    run_ended.emit(distance_traveled, coin_bank, chase_heat, reason)

func _on_player_hazard_blocked(hazard: Node) -> void:
    if hazard and hazard.has_method("on_player_blocked"):
        hazard.on_player_blocked(_player, self)

func _on_player_hazard_damaged(hazard: Node) -> void:
    var heat_damage: float = 1.0
    var reason: String = "Apprehended"
    if hazard:
        if hazard.has_method("get_heat_damage"):
            heat_damage = float(hazard.get_heat_damage())
        if hazard.has_method("get_defeat_reason"):
            reason = str(hazard.get_defeat_reason())
    var new_heat: float = apply_heat_penalty(heat_damage)
    if hazard and hazard.has_method("on_player_damaged"):
        hazard.on_player_damaged(_player, self)
    var limit: float = _segment_spawner.max_heat if _segment_spawner else (_max_heat if _max_heat > 0.0 else new_heat)
    if new_heat >= limit:
        end_run(reason)
