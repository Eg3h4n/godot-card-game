extends Node

# -----------------------------
# Signals
# -----------------------------
signal game_started
signal phase_changed(new_phase)
signal player_health_changed(player_id, new_health)
signal turn_changed(current_player_id)
signal game_reset

signal card_played(player_id, card_data, target_id)
signal hand_updated(player_id, new_hand)
signal deck_updated(player_id, deck_count)

# -----------------------------
# Enums
# -----------------------------
enum GamePhase {SETUP, DRAW, MAIN, BATTLE, END}
enum GameMode {SINGLE_PLAYER, MULTIPLAYER}

# -----------------------------
# Variables
# -----------------------------
var current_phase : GamePhase = GamePhase.SETUP
var mode: GameMode = GameMode.SINGLE_PLAYER
# Dictionary storing all players and their data
var players : Dictionary = {}  # {peer_id: {health: int, deck: [], hand: []}}
var current_turn: int = 0

# --- MATCH CONTROL ---
func reset_game() -> void:
	players.clear()
	current_phase = GamePhase.SETUP
	current_turn = 0
	game_reset.emit()
	print("GameManager: Game reset.")

func register_player(player_id, starting_health: int = 20, deck: Array = []):
	if not players.has(player_id):
		players[player_id] = {
			"health": starting_health,
			"deck": deck.duplicate(true) if deck.size() > 0 else [],
			"hand": []
		}
		player_health_changed.emit(player_id, starting_health)
		deck_updated.emit(player_id, players[player_id].deck.size())
		print("GameManager: Registered player ->", player_id, "Deck size:", deck.size())

func start_match(starting_health: int = 20) -> void:
	match mode:
		GameMode.SINGLE_PLAYER:
			if not players.has("Player"):
				register_player("Player", starting_health)
			if not players.has("AI"):
				register_player("AI", starting_health)
		GameMode.MULTIPLAYER:
			if not players.has(multiplayer.get_unique_id()):
				register_player(multiplayer.get_unique_id(), starting_health)
			if multiplayer.is_server():
				for peer_id in multiplayer.get_peers():
					if not players.has(peer_id):
						register_player(peer_id, starting_health)
	game_started.emit()
	print("GameManager: Match started in mode:", mode)
	change_phase(GamePhase.DRAW)
	
	

# -----------------------------
# Health Management
# -----------------------------
func set_health(player_id, value: int) -> void:
	if players.has(player_id):
		players[player_id].health = value
		player_health_changed.emit(player_id, value)
		print("GameManager: Player", player_id, "health set to", value)

func change_health(player_id, delta: int) -> void:
	if players.has(player_id):
		var new_health = players[player_id].health + delta
		set_health(player_id, new_health)

# -----------------------------
# Card Play Management
# -----------------------------
func start_first_turn(starting_hand_size := 3):
	if players.size() == 0:
		return
	current_turn = 0
	var keys = players.keys()
	print("GameManager: First turn ->", keys[current_turn])
	turn_changed.emit(keys[current_turn])
	
	# ✅ Auto-draw starting cards for all players
	for id in players.keys():
		for i in range(starting_hand_size):
			draw_card(id)

func draw_card(player_id):	
	if players[player_id].deck.is_empty():
		return
	var card_data = players[player_id].deck.pop_front()
	players[player_id].hand.append(card_data)
	hand_updated.emit(player_id, players[player_id].hand)
	deck_updated.emit(player_id, players[player_id].deck.size())
	print("GameManager: Player", player_id, "drew card", card_data.name)

func play_card(player_id: String, card_data: Dictionary, target_id: String = ""):
	if not players.has(player_id):
		push_warning("Invalid player")
		return
		
	# Validate turn
	var current_player_id = players.keys()[current_turn]
	if player_id != current_player_id:
		push_warning("Not player's turn")
		return
	
	# Validate card in hand
	var hand = players[player_id].hand
	if not card_data in hand:
		push_warning("Card not in hand")
		return
	
	# Apply effect (simple damage for now)
	if target_id != "" and players.has(target_id):
		var dmg = card_data.get("damage", 0)
		change_health(target_id, -dmg)
	
	# Remove from hand
	hand.erase(card_data)
	
	# Notify listeners
	hand_updated.emit(player_id, hand)
	card_played.emit(player_id, card_data, target_id)
	
	print("GameManager: Player", player_id, "played", card_data.name)

# --- TURN MANAGEMENT ---
func next_turn():
	var keys = players.keys()
	if keys.is_empty():
		return
	current_turn = (current_turn + 1) % keys.size()
	turn_changed.emit(keys[current_turn])
	print("GameManager: Turn changed ->", keys[current_turn])
	
	# Handle AI turn here
	if mode == GameMode.SINGLE_PLAYER and keys[current_turn] == "AI":
		await _handle_ai_turn()

	
# --- PHASE MANAGEMENT ---
func change_phase(phase: GamePhase):
	current_phase = phase
	phase_changed.emit(phase)
	print("GameManager: Phase changed ->", phase)

# -----------------------------
# AI Logic
# -----------------------------
func _handle_ai_turn():
	print("GameManager: AI thinking...")
	await get_tree().create_timer(1.5).timeout
	print("GameManager: AI ends turn")
	next_turn()
