class_name Card
extends Node2D

# ------------------------------------------------------------
# Signals for interaction
# ------------------------------------------------------------
signal picked(card_node)
signal dropped(card_node)
signal hovered(card_node)
signal hover_exited(card_node)

# ------------------------------------------------------------
# Exported Node References (drag in editor)
# ------------------------------------------------------------
@export var card_back_image: Sprite2D
@export var card_front_image: Sprite2D 
@export var label_name: RichTextLabel
@export var label_ability_text: RichTextLabel
@export var label_attack: RichTextLabel
@export var label_health: RichTextLabel

# ------------------------------------------------------------
# Core card data
# ------------------------------------------------------------
var card_data: Dictionary = {
	"name": "",
	"sprite_path": "",
	"attack": 0,
	"health": 0,
	"ability_script": "",
	"ability_text": "",
	"is_revealed": true   # replaced is_players_card for better multiplayer use
}

# Local state
var position_in_hand: Vector2
var card_slot: Node = null
var defeated: bool = false

# Dragging state
var is_dragging: bool = false
var drag_offset: Vector2

func _ready():
	_enable_mouse_input()
	_update_visuals()
	print("DEBUG: Card input ready:", $Area2D.input_pickable)

# Enable collision/mouse events
func _enable_mouse_input():
	if has_node("Area2D"):
		var area = $Area2D
		area.input_pickable = true
		print("DEBUG: Card ready:", name, "Pickable:", area.input_pickable)
		area.connect("input_event", Callable(self, "_input_event"))

# ------------------------------------------------------------
# Card data access
# ------------------------------------------------------------
func get_card_data() -> Dictionary:
	return card_data

func set_card_data(data: Dictionary):
	card_data = data
	_update_visuals()
	
# ------------------------------------------------------------
# Visual updates
# ------------------------------------------------------------
func _update_visuals():
	if label_name:
		label_name.text = str(card_data.get("name", ""))
	if label_attack:
		label_attack.text = str(card_data.get("attack", 0))
	if label_health:
		label_health.text = str(card_data.get("health", 0))
	if label_ability_text:
		label_ability_text.text = str(card_data.get("ability_text", ""))

	var sprite_path = card_data.get("sprite_path", "")
	if sprite_path != "":
		var tex = load(sprite_path)
		if tex:
			card_front_image.texture = tex

	var is_revealed = card_data.get("is_revealed", true)
	card_back_image.visible = not is_revealed
	card_front_image.visible = is_revealed

func set_revealed(state: bool):
	card_data["is_revealed"] = state
	_update_visuals()

# ------------------------------------------------------------
# Input events (click + drag)
# ------------------------------------------------------------
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print("Card: input_event detected on", card_data.get("name", "Unknown"), "pressed:", event.pressed)
		if event.pressed:
			is_dragging = true
			drag_offset = get_global_mouse_position() - global_position
			emit_signal("picked", self)
		else:
			is_dragging = false
			emit_signal("dropped", self)

# ------------------------------------------------------------
# Hover effects
# ------------------------------------------------------------
func _set_highlight(state: bool):
	if card_front_image:
		card_front_image.modulate = Color(1, 1, 0.8, 1) if state else Color(1, 1, 1, 1)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)
	_set_highlight(true)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hover_exited", self)
	_set_highlight(false)
