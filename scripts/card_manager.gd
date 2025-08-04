extends Node2D

@export var card_scene: PackedScene
@export var hand_container: Node2D

# Internal state
var player_id: Variant
var hand_cards: Array = []

const CARD_SPACING: float = 120.0
const HAND_Y_OFFSET: float = 0.0
const MAX_HAND_WIDTH: float = 600.0

# ------------------------------------------------------------
# Setup
# ------------------------------------------------------------
func initialize_for_player(id: Variant):
	player_id = id
	print("CardManager: initialized for player:", id)
	_refresh_hand_from_gamemanager()

# ------------------------------------------------------------
# Drawing cards
# ------------------------------------------------------------
func draw_card():
	if not GameManager.players.has(player_id):
		return
	
	var deck = GameManager.players[player_id].deck
	if deck.is_empty():
		print("CardManager: No cards left to draw")
		return
		
	var card_data = deck.pop_front()
	GameManager.players[player_id].hand.append(card_data)
	
	_spawn_card_in_hand(card_data)
	_arrange_hand()

func _refresh_hand_from_gamemanager():
	# Clear current hand visuals
	for card in hand_cards:
		if is_instance_valid(card):
			card.queue_free()
	hand_cards.clear()
	
	if not GameManager.players.has(player_id):
		return
		
	var player_hand = GameManager.players[player_id].hand
	for data in player_hand:
		_spawn_card_in_hand(data)
		
	_arrange_hand()

# ------------------------------------------------------------
# Card spawning
# ------------------------------------------------------------
func _spawn_card_in_hand(card_data: Dictionary):
	print("DEBUG: _spawn_card_in_hand called for:", card_data.get("name"))
	if not card_scene:
		push_error("CardManager: card_scene not assigned")
		return
		
	var new_card = card_scene.instantiate()
	hand_container.add_child(new_card)
	new_card.set_card_data(card_data)
	
	hand_cards.append(new_card)
	InputManager.register_card(new_card)
	

# ------------------------------------------------------------
# Card removal
# ------------------------------------------------------------
func remove_card(card_node: Node):
	if hand_cards.has(card_node):
		hand_cards.erase(card_node)
	if is_instance_valid(card_node):
		card_node.queue_free()
	_arrange_hand()

# ------------------------------------------------------------
# Arrange cards visually
# ------------------------------------------------------------
func _arrange_hand():
	var count = hand_cards.size()
	if count == 0:
		return
		
	# Calculate spacing
	var spacing = min(CARD_SPACING, MAX_HAND_WIDTH / max(1, count))
	
	var start_x = -(count - 1) * spacing / 2
	for i in range(count):
		var card = hand_cards[i]
		if is_instance_valid(card):
			var target_pos = Vector2(start_x + i * spacing, HAND_Y_OFFSET)
			card.position = target_pos
