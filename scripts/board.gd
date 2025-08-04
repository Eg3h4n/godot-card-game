extends Node2D

# -----------------------------
# Signals
# -----------------------------
signal request_end_turn

@export var player_field : Node2D
@export var opponent_field : Node2D
@export var end_turn_button: Button
@export var drag_canvas_layer: CanvasLayer

func _ready():
	print("Board: Initializing...")
	
	# Connect to GameManager signals
	GameManager.hand_updated.connect(_on_hand_updated)
	GameManager.card_played.connect(_on_card_played)
	GameManager.player_health_changed.connect(_on_player_health_changed)
	GameManager.turn_changed.connect(_on_turn_changed)
	InputManager.set_drag_layer(drag_canvas_layer)
	 # Connect button signal to emit request only
	if end_turn_button:
		end_turn_button.pressed.connect(_on_end_turn_pressed)

	# Assign Player field
	if player_field:
		player_field.player_id = _get_local_player_id()
		player_field.is_local_player = true
		print("Board: Player field set for", player_field.player_id)
	
	 # Assign Opponent field
	if opponent_field:
		opponent_field.player_id = _get_opponent_id()
		opponent_field.is_local_player = false
		print("Board: Opponent field set for", opponent_field.player_id)
	
	# ✅ Start first turn and auto-draw only when Board is ready
	GameManager.start_first_turn()
	## Start first turn automatically
	#if GameManager.players.size() > 0:
		#var first_player = GameManager.players.keys()[0]
		#GameManager.turn_changed.emit(first_player)
		

# -----------------------------
# Helper functions
# -----------------------------
func _get_local_player_id():
	if GameManager.mode == GameManager.GameMode.SINGLE_PLAYER:
		return "Player"
	return multiplayer.get_unique_id()

func _get_opponent_id():
	if GameManager.mode == GameManager.GameMode.SINGLE_PLAYER:
		return "AI"
	# Multiplayer: pick the other peer id
	for id in GameManager.players.keys():
		if id != multiplayer.get_unique_id():
			return id
	return "Unknown"

# --- SIGNAL HANDLERS ---

func _on_end_turn_pressed():
	print("Board: End turn pressed")
	emit_signal("request_end_turn")

func _on_turn_changed(current_player_id):
	print("Board: Turn changed ->", current_player_id)
	
	# Disable End Turn button if it's not the local player's turn
	var is_local_turn = (current_player_id == _get_local_player_id())
	if end_turn_button:
		end_turn_button.disabled = not is_local_turn
		
		
func _on_player_health_changed(player_id, new_health):
	print("Board: Health updated ->", player_id, "=", new_health)
	# TODO: Update health bar in UI
	
func _on_hand_updated(player_id, new_hand):
	print("Board: Hand updated for", player_id, "- Cards:", new_hand.size())
	# TODO: Update hand UI for the appropriate player
	if player_id == _get_local_player_id():
		if player_field and "update_hand_ui" in player_field:
			player_field.update_hand_ui(new_hand)
	else:
		if opponent_field and "update_hand_ui" in opponent_field:
			opponent_field.update_hand_ui(new_hand)
			
func _on_card_played(player_id, card_data, target_id):
	print("Board: Card played by", player_id, "-", card_data.name)
	# TODO: Animate card move, show effects on target
	if player_id == _get_local_player_id():
		if player_field and "animate_card_play" in player_field:
			player_field.animate_card_play(card_data, target_id)
	else:
		if opponent_field and "animate_card_play" in opponent_field:
			opponent_field.animate_card_play(card_data, target_id)
