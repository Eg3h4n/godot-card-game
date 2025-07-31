#extends Node2D
#
#signal hovered
#signal hovered_off
#
#signal picked(card_node)
#signal dropped(card_node)
#
#
#var position_in_hand : Vector2
#var card_slot_card_is_in
#var card_type: String
#var attack: int
#var health: int
#var defeated: bool = false
#var ability_script
#var is_players_card: bool = true
#
#func _input_event(viewport, event, shape_idx):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if event.pressed:
				#emit_signal("picked", self)
			#else:
				#emit_signal("dropped", self)
#
#
#func _ready() -> void:
	#get_parent().connect_card_signal(self)
#
#func _on_area_2d_mouse_entered() -> void:
	#hovered.emit(self)
#
#
#func _on_area_2d_mouse_exited() -> void:
	#hovered_off.emit(self)
extends Node2D

# Signals for drag & drop handling
signal picked(card_node)
signal dropped(card_node)
signal hovered(card_node)
signal hover_exited(card_node)

# Core card data
@export var card_name: String = ""
@export var attack: int = 0
@export var health: int = 0
@export var ability_script: String = ""
@export var is_players_card: bool = true

# Store full data for easy access
var card_data: Dictionary

# Local state
var position_in_hand: Vector2
var card_slot: Node = null
var defeated: bool = false

# Visual references
@onready var sprite: Sprite2D = $Sprite
@onready var label_name: Label = $Name
@onready var label_attack: Label = $Stats/Attack
@onready var label_health: Label = $Stats/Health

func _ready():
	# Build data dictionary
	card_data = {
		"name": card_name,
		"attack": attack,
		"health": health,
		"ability_script": ability_script,
		"is_players_card": is_players_card
	}
	_update_visuals()

# ------------------------------------------------------------
# Mouse interaction
# ------------------------------------------------------------
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("picked", self)
			else:
				emit_signal("dropped", self)

func _on_mouse_entered():
	emit_signal("hovered", self)
	_set_highlight(true)

func _on_mouse_exited():
	emit_signal("hover_exited", self)
	_set_highlight(false)

# ------------------------------------------------------------
# Visual updates
# ------------------------------------------------------------
func _update_visuals():
	if label_name:
		label_name.text = card_name
	if label_attack:
		label_attack.text = str(attack)
	if label_health:
		label_health.text = str(health)

func _set_highlight(state: bool):
	if sprite:
		sprite.modulate = Color(1, 1, 0.8, 1) if state else Color(1, 1, 1, 1)

# ------------------------------------------------------------
# Card data access
# ------------------------------------------------------------
func get_card_data() -> Dictionary:
	return card_data

func set_card_data(data: Dictionary):
	card_name = data.get("name", "")
	attack = data.get("attack", 0)
	health = data.get("health", 0)
	ability_script = data.get("ability_script", "")
	is_players_card = data.get("is_players_card", true)
	card_data = data
	_update_visuals()
