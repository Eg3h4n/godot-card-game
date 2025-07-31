extends Node2D

@export var player_field : Node2D
@export var opponent_field : Node2D
@export var end_turn_button: Button

func _ready():
	print("Board: Initializing...")
	
	# Connect to GameManager signals
	GameManager.turn_changed.connect(_on_turn_changed)
	GameManager.player_health_changed.connect(_on_player_health_changed)
	
	# Assign Player field
	if player_field:
		player_field.player_id = _get_local_player_id()
		player_field.is_local_player = true
		print("Board: Player field set for", player_field.player_id)
	
	 # Assign Opponent field
	if opponent_field:
		opponent_field.player_id = _get_opponent_id()
		opponent_field.is_local_player = false
		#opponent_field.flip_layout()  # Mirror opponent field layout
		print("Board: Opponent field set for", opponent_field.player_id)
	# Set up End Turn button
	if end_turn_button:
		end_turn_button.pressed.connect(_on_end_turn_pressed)
		
	# Start first turn automatically
	if GameManager.players.size() > 0:
		var first_player = GameManager.players.keys()[0]
		GameManager.turn_changed.emit(first_player)
		

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
	GameManager.next_turn()

func _on_turn_changed(current_player_id):
	print("Board: Turn changed ->", current_player_id)
	
	# Disable End Turn button if it's not the local player's turn
	var is_local_turn = (current_player_id == _get_local_player_id())
	if end_turn_button:
		end_turn_button.disabled = not is_local_turn
		
	# If it's AI's turn, start AI action
	if GameManager.mode == GameManager.GameMode.SINGLE_PLAYER and current_player_id == "AI":
		_start_ai_turn()
		
func _on_player_health_changed(player_id, new_health):
	# Optional: extra reactions like animations or effects
	pass

# --- BASIC AI TURN (placeholder) ---

func _start_ai_turn():
	print("Board: AI thinking...")
	# Delay AI turn for realism
	await get_tree().create_timer(1.5).timeout
	# AI action: just ends turn for now
	print("Board: AI ends turn")
	GameManager.next_turn()
