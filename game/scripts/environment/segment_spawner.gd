extends Node2D
class_name SegmentSpawner

signal segment_spawned(segment: Node, tileset: EnvironmentTileset)
signal segment_recycled(segment: Node, tileset: EnvironmentTileset)

@export var player_path: NodePath
@export var tilesets: Array[EnvironmentTileset] = []
@export var segments_ahead: int = 4
@export var recycle_margin: float = 640.0
@export var heat_ramp_rate: float = 0.012
@export var max_heat: float = 3.0

var heat_level: float = 0.0

var _player: Node2D
var _rng := RandomNumberGenerator.new()
var _active_segments: Array[Dictionary] = []
var _next_spawn_x: float = 0.0

func _ready() -> void:
    if player_path != NodePath(""):
        _player = get_node(player_path)
    _rng.randomize()
    while _active_segments.size() < segments_ahead:
        _spawn_next_segment()

func _process(delta: float) -> void:
    if _player:
        _maybe_spawn_segments()
        _recycle_old_segments()
    heat_level = clamp(heat_level + heat_ramp_rate * delta, 0.0, max_heat)

func _maybe_spawn_segments() -> void:
    var target_x := _player.global_position.x + 1600.0
    while _next_spawn_x < target_x:
        if not _spawn_next_segment():
            break

func _spawn_next_segment() -> bool:
    var tileset := _select_tileset()
    if tileset == null:
        return false
    var packed := tileset.pick_random_segment(_rng)
    if packed == null:
        return false
    var instance := packed.instantiate()
    if not instance:
        return false
    add_child(instance)
    if instance is Node2D:
        instance.position.x = _next_spawn_x
    _active_segments.append({"node": instance, "tileset": tileset})
    var length := 960.0
    if instance is SegmentChunk:
        length = instance.segment_length
    _next_spawn_x += length
    instance.set_meta("environment_tileset", tileset.id)
    segment_spawned.emit(instance, tileset)
    return true

func _recycle_old_segments() -> void:
    if _player == null:
        return
    var recycle_x := _player.global_position.x - recycle_margin
    while _active_segments.size() > 0:
        var entry := _active_segments[0]
        var first: Node = entry.get("node")
        var tileset: EnvironmentTileset = entry.get("tileset")
        if first == null or not first is Node2D:
            _active_segments.pop_front()
            continue
        if first.global_position.x + 1280.0 >= recycle_x:
            break
        _active_segments.pop_front()
        first.queue_free()
        segment_recycled.emit(first, tileset)

func _select_tileset() -> EnvironmentTileset:
    var available: Array[EnvironmentTileset] = []
    var total_weight := 0.0
    for tileset in tilesets:
        if tileset == null:
            continue
        if tileset.contains_heat(heat_level):
            available.append(tileset)
            total_weight += max(tileset.weight, 0.001)
    if available.is_empty():
        available = tilesets.duplicate()
        total_weight = 0.0
        for tileset in available:
            total_weight += max(tileset.weight, 0.001)
    if available.is_empty():
        return null
    var pick := _rng.randf_range(0.0, total_weight)
    var accumulator := 0.0
    for tileset in available:
        accumulator += max(tileset.weight, 0.001)
        if pick <= accumulator:
            return tileset
    return available[-1]

func set_player(player: Node2D) -> void:
    _player = player
