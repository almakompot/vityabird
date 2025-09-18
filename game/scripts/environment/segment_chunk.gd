extends Node2D
class_name SegmentChunk

@export var segment_length: float = 960.0
@export var heat_band: Vector2 = Vector2(0.0, 1.0)
@export var tags: PackedStringArray = []

var spawn_markers := {}

func _ready() -> void:
    _cache_spawn_markers()

func _cache_spawn_markers() -> void:
    spawn_markers.clear()
    for child in get_children():
        if child is Marker2D:
            var group := child.get_meta("spawn_group") if child.has_meta("spawn_group") else "default"
            if not spawn_markers.has(group):
                spawn_markers[group] = []
            spawn_markers[group].append(child)

func get_spawn_markers(group: StringName = &"default") -> Array:
    if not spawn_markers.has(group):
        return []
    return spawn_markers[group]
