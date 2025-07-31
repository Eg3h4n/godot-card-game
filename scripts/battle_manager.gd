extends Node

signal card_played(player_id, card_data, target_id)
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
func play_card(player_id: Variant, card_data: Dictionary, target_id: Variant = null):
	# Ensure it's this player's turn
	if player_id != _current_turn_player:
		print("BattleManager: Invalid action - not player's turn")
		return
		
	print("BattleManager: Player", player_id, "plays card:", card_data.name)
	
	# Apply card effect
	_apply_card_effect(player_id, card_data, target_id)
	
	# Remove card from player's hand
	var hand = GameManager.players[player_id].hand
	if card_data in hand:
		hand.erase(card_data)
	
	card_played.emit(player_id, card_data, target_id)

func _apply_card_effect(player_id: Variant, card_data: Dictionary, target_id: Variant):
	# Example effect: damage
	var damage = card_data.get("damage", 0)
	if target_id and GameManager.players.has(target_id):
		GameManager.change_health(target_id, -damage)
		attack_resolved.emit(player_id, target_id, damage)
		print("BattleManager: Applied", damage, "damage to", target_id)
	else:
		print("BattleManager: No valid target for", card_data.name)

# -----------------------------------------------------------
# Phase Management (Optional future expansion)
# -----------------------------------------------------------
func _on_phase_changed(new_phase):
	print("BattleManager: Phase changed to", new_phase)
	# Example: handle draw/main/battle phases here if you want multiple phases
