extends Node

signal card_selected(card_node)
signal card_dropped_on_slot(card_node, target_slot)
signal card_play_attempt(player_id, card_data, target_id)

var _dragging_card: Node = null
var _drag_start_pos: Vector2
var _dragging_original_parent: Node

# The local player's ID (used to enable/disable input)
var local_player_id: Variant

func _ready():
	# Detect local player
	local_player_id = _get_local_player_id()
	# Listen for turn changes to toggle input availability
	GameManager.turn_changed.connect(_on_turn_changed)
	
	print("InputManager: Initialized for local player:", local_player_id)

# Connect signals from dynamically spawned cards
func register_card(card_node: Node):
	if not card_node.is_connected("picked", _on_card_picked):
		card_node.connect("picked", _on_card_picked)
	if not card_node.is_connected("dropped", _on_card_dropped):
		card_node.connect("dropped", _on_card_dropped)
	
# -----------------------------
# SIGNAL HANDLERS
# -----------------------------
func _on_card_picked(card_node):
	if _dragging_card: 
		return  # already dragging another card
		
	_dragging_card = card_node
	_drag_start_pos = card_node.global_position
	_dragging_original_parent = card_node.get_parent()
	
	# Move card to top layer for dragging
	get_tree().current_scene.add_child(card_node)
	card_node.global_position = get_viewport().get_mouse_position()
	
	emit_signal("card_selected", card_node)
	
func _on_card_dropped(card_node):
	if not _dragging_card:
		return
		
	# Find drop target under mouse
	var target_slot = _get_slot_under_mouse()
	var card_data = card_node.get_card_data() if card_node.has_method("get_card_data") else card_node.card_data
	if target_slot  and target_slot.has_method("can_accept_card") and target_slot.can_accept_card(card_data):
		target_slot.place_card(card_node)
		emit_signal("card_dropped_on_slot", card_node, target_slot)
		_play_card(card_node, target_slot)
	else:
		# Return card to original position
		if _dragging_original_parent:
			_dragging_original_parent.add_child(card_node)
		card_node.global_position = _drag_start_pos
		
	_dragging_card = null
	_dragging_original_parent = null

# -----------------------------
# Slot detection
# -----------------------------
func _get_slot_under_mouse() -> Node:
	var mouse_pos = get_viewport().get_mouse_position()
	var slots = get_tree().get_nodes_in_group("card_slots")
	for slot in slots:
		if slot.get_global_rect().has_point(mouse_pos):
			return slot
	return null

# -----------------------------
# Notify BattleManager
# -----------------------------
func _play_card(card_node: Node, target_slot: Node):
	var player_id = "Player" if GameManager.mode == GameManager.GameMode.SINGLE_PLAYER else multiplayer.get_unique_id()
	var card_data = card_node.card_data if card_node.has_variable("card_data") else card_node.get("card_data")
	var target_id = target_slot.get_meta("owner_id") if target_slot.has_meta("owner_id") else null
	
	emit_signal("card_play_attempt", player_id, card_data, target_id)
	
	var bm = get_tree().current_scene.get_node_or_null("BattleManager")
	if bm:
		bm.play_card(player_id, card_data, target_id)
		
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
