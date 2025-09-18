extends Resource
class_name EnvironmentTileset

@export var id: StringName = &"default"
@export var display_name: String = "Unnamed Tileset"
@export var description: String = ""
@export var heat_threshold: Vector2 = Vector2(0.0, 1.0)
@export var weight: float = 1.0
@export var segments: Array[PackedScene] = []
@export var powerup_bias: PackedStringArray = []

func pick_random_segment(rng: RandomNumberGenerator) -> PackedScene:
    if segments.is_empty():
        return null
    var index: int = rng.randi_range(0, segments.size() - 1)
    return segments[index]

func contains_heat(heat: float) -> bool:
    return heat >= heat_threshold.x and heat <= heat_threshold.y
