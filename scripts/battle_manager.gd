extends Node

signal attack_resolved(attacker_id, target_id, damage)

@export var turn_duration: float = 30.0  # Optional: timer per turn

var _timer: Timer
var _current_turn_player: Variant

func _ready():
	# Listen for turn changes
	GameManager.turn_changed.connect(_on_turn_changed)
	GameManager.phase_changed.connect(_on_phase_changed)
	
	# Create a turn timer if not already in scene
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_turn_timeout)
	
	print("BattleManager: Ready and connected.")

# -----------------------------------------------------------
# Turn Flow
# -----------------------------------------------------------
func _on_turn_changed(player_id):
	_current_turn_player = player_id
	print("BattleManager: Turn started for", player_id)
	
	# Restart turn timer
	_timer.start(turn_duration)

func _on_turn_timeout():
	print("BattleManager: Turn timeout for", _current_turn_player)
	_end_turn()
	
func _end_turn():
	GameManager.next_turn()

# -----------------------------------------------------------
# Card Play Logic
# -----------------------------------------------------------
func play_card_request(player_id: String, card_data: Dictionary, target_id: String = ""):
	GameManager.play_card(player_id, card_data, target_id)

# -----------------------------------------------------------
# Phase Management (Optional future expansion)
# -----------------------------------------------------------
func _on_phase_changed(new_phase):
	print("BattleManager: Phase changed to", new_phase)
	# Example: handle draw/main/battle phases here if you want multiple phases
