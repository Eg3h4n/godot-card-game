extends Node

signal game_started
signal phase_changed(new_phase)
signal player_health_changed(player_id, new_health)
signal turn_changed(current_player_id)
signal game_reset

enum GamePhase {SETUP, DRAW, MAIN, BATTLE, END}
enum GameMode {SINGLE_PLAYER, MULTIPLAYER}

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

func start_match(starting_health: int = 20) -> void:
	#reset_game()
	
	match mode:
		GameMode.SINGLE_PLAYER:
			register_player("Player", starting_health)
			register_player("AI", starting_health)
		GameMode.MULTIPLAYER:
			register_player(multiplayer.get_unique_id(), starting_health)
			if multiplayer.is_server():
				for peer_id in multiplayer.get_peers():
					register_player(peer_id, starting_health)
					
	game_started.emit()
	print("GameManager: Match started in mode:", mode)
	change_phase(GamePhase.DRAW)
	
# --- PLAYER MANAGEMENT ---
func register_player(player_id, starting_health: int = 20):
	if not players.has(player_id):
		players[player_id] = {
			"health": starting_health,
			"deck": [],
			"hand": []
		}
		player_health_changed.emit(player_id, starting_health)
		print("GameManager: Registered player ->", player_id)

func set_health(player_id, value: int) -> void:
	if players.has(player_id):
		players[player_id].health = value
		player_health_changed.emit(player_id, value)
		print("GameManager: Player", player_id, "health set to", value)

func change_health(player_id, delta: int) -> void:
	if players.has(player_id):
		var new_health = players[player_id].health + delta
		set_health(player_id, new_health)
		
# --- TURN MANAGEMENT ---
func next_turn():
	var keys = players.keys()
	if keys.is_empty():
		return
	current_turn = (current_turn + 1) % keys.size()
	turn_changed.emit(keys[current_turn])
	print("GameManager: Turn changed ->", keys[current_turn])
	
# --- PHASE MANAGEMENT ---
func change_phase(phase: GamePhase):
	current_phase = phase
	phase_changed.emit(phase)
	print("GameManager: Phase changed ->", phase)
