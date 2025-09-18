extends Node2D
class_name SegmentChunk

@export var segment_length: float = 960.0
@export var heat_band: Vector2 = Vector2(0.0, 1.0)
@export var tags: PackedStringArray = []

var spawn_markers: Dictionary[StringName, Array] = {}

func _ready() -> void:
    _cache_spawn_markers()

func _cache_spawn_markers() -> void:
    spawn_markers.clear()
    for child in get_children():
        if child is Marker2D:
            var group: StringName = &"default"
            if child.has_meta("spawn_group"):
                group = StringName(child.get_meta("spawn_group"))
            if not spawn_markers.has(group):
                spawn_markers[group] = [] as Array[Marker2D]
            var markers := spawn_markers[group] as Array[Marker2D]
            markers.append(child)

func get_spawn_markers(group: StringName = &"default") -> Array[Marker2D]:
    if not spawn_markers.has(group):
        return [] as Array[Marker2D]
    return spawn_markers[group] as Array[Marker2D]
