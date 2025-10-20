extends Node

# ------------------------------------------------------------
# Signals
# ------------------------------------------------------------
signal card_selected(card_node)
signal card_dropped_on_slot(card_node, target_slot)
signal card_play_attempt(player_id, card_data, target_id)

# ------------------------------------------------------------
# Dragging State
# ------------------------------------------------------------
var _dragging_card: Card = null
var _drag_start_pos: Vector2
var _drag_start_index: int = -1
var _dragging_original_parent: Node

# The local player's ID (used to enable/disable input)
var local_player_id: Variant

# Optional drag layer (set via inspector or scene path)
var _drag_layer: Node = null
var current_target_card_slot: CardSlot = null

# ------------------------------------------------------------
# Autoload Initialization
# ------------------------------------------------------------
func _ready():
	# Persistent autoload setup
	local_player_id = _get_local_player_id()
	
	# Connect to GameManager if it exists now or later
	if Engine.has_singleton("GameManager"):
		GameManager.turn_changed.connect(_on_turn_changed)
	else:
		print("InputManager: Waiting for GameManager...")
		
	
		
	print("InputManager: Autoload initialized for local player:", local_player_id)
	set_process(true)

func _on_update_current_target_card_slot(card_slot):
	if current_target_card_slot == card_slot:
		current_target_card_slot = null
		print("InputManager: target slot cleared:")
	else:
		current_target_card_slot = card_slot
		print("InputManager: target slot set as: ", card_slot.card_slot_id)

# ------------------------------------------------------------
# Called by board scenes on load
# ------------------------------------------------------------
func set_drag_layer(layer_node: Node):
	_drag_layer = layer_node
	print("InputManager: Drag layer set to", layer_node)
	
	var slots = get_tree().get_nodes_in_group("card_slots")
	for slot in slots:
		slot.update_target_card_slot.connect(_on_update_current_target_card_slot)

# ------------------------------------------------------------
# Register card signals dynamically
# ------------------------------------------------------------s
func register_card(card_node: Node):
	print("InputManager: registering card ->", card_node)
	if not card_node.is_connected("picked", _on_card_picked):
		card_node.connect("picked", _on_card_picked)
	if not card_node.is_connected("dropped", _on_card_dropped):
		card_node.connect("dropped", _on_card_dropped)
	
# ------------------------------------------------------------
# Process - update card position while dragging
# ------------------------------------------------------------
func _process(delta):
	if _dragging_card:
		#print("Dragging:", _dragging_card.name, "MousePos:", get_viewport().get_mouse_position())
		_dragging_card.global_position = get_viewport().get_mouse_position()
	
# ------------------------------------------------------------
# Card Picked
# ------------------------------------------------------------
func _on_card_picked(card_node):
	print("InputManager: _on_card_picked ->", card_node)
	if _dragging_card:
		return  # already dragging another card
	
	_dragging_card = card_node
	_drag_start_pos = card_node.global_position
	_dragging_original_parent = card_node.get_parent()
	_drag_start_index = card_node.get_index()
	
	var new_parent = _drag_layer if _drag_layer and is_instance_valid(_drag_layer) else get_tree().root
	print("Reparenting card to:", new_parent.name)

	if card_node.get_parent() != new_parent:
		if card_node.get_parent():
			card_node.get_parent().remove_child(card_node)
		new_parent.add_child(card_node)

	card_node.z_index = 100
	emit_signal("card_selected", card_node)

# ------------------------------------------------------------
# Card Dropped
# ------------------------------------------------------------
func _on_card_dropped(card_node):
	if not _dragging_card:
		return
	print("InputManager: _on_card_dropped ->", card_node)
	var target_slot = current_target_card_slot
	var card_data = card_node.get_card_data() if card_node.has_method("get_card_data") else card_node.card_data

	if target_slot and target_slot.has_method("can_accept_card") and target_slot.can_accept_card(card_data):
		target_slot.place_card(card_node)
		emit_signal("card_dropped_on_slot", card_node, target_slot)
		_play_card(card_node, target_slot)
	else:
		if _dragging_original_parent and is_instance_valid(_dragging_original_parent):
			if card_node.get_parent() != _dragging_original_parent:
				card_node.get_parent().remove_child(card_node)
				_dragging_original_parent.add_child(card_node)
			if _drag_start_index >= 0:
				_dragging_original_parent.move_child(card_node, clamp(_drag_start_index, 0, _dragging_original_parent.get_child_count() - 1))
			card_node.global_position = _drag_start_pos
	
	if card_node:
		card_node.z_index = 0

	_dragging_card = null
	_dragging_original_parent = null
	_drag_start_index = -1

# -----------------------------
# Slot detection
# -----------------------------
func _get_slot_under_mouse() -> Node:
	var mouse_pos = get_viewport().get_mouse_position()
	var slots = get_tree().get_nodes_in_group("card_slots")
	for slot in slots:
		if slot.has_method("get_global_rect"):
			if slot.get_global_rect().has_point(mouse_pos):
				return slot
		elif slot.has_node("CollisionShape2D"):
			var shape = slot.get_node("CollisionShape2D")
			var rect = Rect2(slot.global_position - shape.shape.extents, shape.shape.extents * 2)
			if rect.has_point(mouse_pos):
				return slot
	return null

# -----------------------------
# Notify BattleManager
# -----------------------------
func _play_card(card_node: Node, target_slot: Node):
	var player_id = "Player" if GameManager.mode == GameManager.GameMode.SINGLE_PLAYER else str(multiplayer.get_unique_id())
	var card_data = card_node.card_data if card_node.has_meta("card_data") else card_node.get("card_data")
	var target_id = target_slot.get("owner_id") if target_slot.has_meta("owner_id") else ""
	
	card_play_attempt.emit(player_id, card_data, target_id)
	
	var bm = get_tree().current_scene.get_node_or_null("BattleManager")
	if bm:
		bm.play_card_request(player_id, card_data, target_id)
		
# ------------------------------------------------------------
# Turn-locking behavior
# ------------------------------------------------------------
func _on_turn_changed(current_player_id):
	var can_interact = (current_player_id == local_player_id)
	set_process_input(can_interact)
	print("InputManager: Turn changed ->", current_player_id, "| Local input enabled:", can_interact)
	
func _get_local_player_id():
	if GameManager.mode == GameManager.GameMode.SINGLE_PLAYER:
		return "Player"
	return multiplayer.get_unique_id()
