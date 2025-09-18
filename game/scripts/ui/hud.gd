extends CanvasLayer
class_name RunnerHUD

@export var distance_pixels_per_unit: float = 32.0
@export var show_decimal_distance: bool = false

@onready var _currency_label: Label = %CurrencyLabel
@onready var _distance_label: Label = %DistanceLabel
@onready var _motorcade_label: Label = %MotorcadeLabel

var _world: RunnerWorld
var _currency_base_modulate := Color(1, 1, 1, 1)
var _distance_base_modulate := Color(1, 1, 1, 1)
var _motorcade_base_modulate := Color(1, 1, 1, 1)

func _ready() -> void:
    if _currency_label:
        _currency_base_modulate = _currency_label.modulate
    if _distance_label:
        _distance_base_modulate = _distance_label.modulate
    if _motorcade_label:
        _motorcade_base_modulate = _motorcade_label.modulate
        _motorcade_label.visible = false
    _refresh_currency(0.0)
    _refresh_distance(0.0)

func set_world(world: RunnerWorld) -> void:
    if _world == world:
        return
    _disconnect_world()
    _world = world
    _connect_world()
    if _world:
        _refresh_currency(_world.coin_bank)
        _refresh_distance(_world.distance_traveled)
        _update_motorcade_display(_world.is_motorcade_active(), _world.get_motorcade_drain_rate())

func _disconnect_world() -> void:
    if _world == null:
        return
    if _world.is_connected("currency_changed", Callable(self, "_on_currency_changed")):
        _world.disconnect("currency_changed", Callable(self, "_on_currency_changed"))
    if _world.is_connected("currency_collected", Callable(self, "_on_currency_collected")):
        _world.disconnect("currency_collected", Callable(self, "_on_currency_collected"))
    if _world.is_connected("currency_drained", Callable(self, "_on_currency_drained")):
        _world.disconnect("currency_drained", Callable(self, "_on_currency_drained"))
    if _world.is_connected("distance_changed", Callable(self, "_on_distance_changed")):
        _world.disconnect("distance_changed", Callable(self, "_on_distance_changed"))
    if _world.is_connected("motorcade_state_changed", Callable(self, "_on_motorcade_state_changed")):
        _world.disconnect("motorcade_state_changed", Callable(self, "_on_motorcade_state_changed"))

func _connect_world() -> void:
    if _world == null:
        return
    _world.currency_changed.connect(_on_currency_changed)
    _world.currency_collected.connect(_on_currency_collected)
    _world.currency_drained.connect(_on_currency_drained)
    _world.distance_changed.connect(_on_distance_changed)
    _world.motorcade_state_changed.connect(_on_motorcade_state_changed)

func _on_currency_changed(total: float) -> void:
    _refresh_currency(total)

func _on_currency_collected(amount: float) -> void:
    _flash_label(_currency_label, Color(0.8, 1.0, 0.6))

func _on_currency_drained(amount: float) -> void:
    _flash_label(_currency_label, Color(1.0, 0.6, 0.6))
    if _motorcade_label and _motorcade_label.visible:
        _flash_label(_motorcade_label, Color(1.0, 0.7, 0.4))

func _on_distance_changed(distance: float) -> void:
    _refresh_distance(distance)

func _on_motorcade_state_changed(active: bool, drain_rate: float) -> void:
    _update_motorcade_display(active, drain_rate)

func _refresh_currency(total: float) -> void:
    if not _currency_label:
        return
    var rounded := int(round(total))
    _currency_label.text = "Coin Bank: %d" % rounded

func _refresh_distance(distance: float) -> void:
    if not _distance_label:
        return
    var units := distance
    if distance_pixels_per_unit > 0.0:
        units = distance / distance_pixels_per_unit
    if show_decimal_distance:
        _distance_label.text = "Distance: %.1f m" % units
    else:
        _distance_label.text = "Distance: %d m" % int(units)

func _update_motorcade_display(active: bool, drain_rate: float) -> void:
    if not _motorcade_label:
        return
    if active:
        _motorcade_label.visible = true
        if drain_rate > 0.0:
            _motorcade_label.text = "Motorcade Upkeep: -%.1f/s" % drain_rate
        else:
            _motorcade_label.text = "Motorcade Escort Active"
    else:
        _motorcade_label.visible = false
        _motorcade_label.text = ""
        _motorcade_label.modulate = _motorcade_base_modulate

func _flash_label(label: CanvasItem, highlight_color: Color) -> void:
    if label == null:
        return
    var base_color := Color(1, 1, 1, 1)
    if label == _currency_label:
        base_color = _currency_base_modulate
    elif label == _distance_label:
        base_color = _distance_base_modulate
    elif label == _motorcade_label:
        base_color = _motorcade_base_modulate
    label.modulate = highlight_color
    var tween := create_tween()
    tween.tween_property(label, "modulate", base_color, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
