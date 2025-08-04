extends Node2D

@export var player_id: String    # Can be "Player", "AI", or peer_id
@export var is_local_player: bool = true
@export var discard_pile: Node2D
@export var hand: Node2D
@export var card_slots: Node2D
@export var deck_count_label: RichTextLabel
@export var health_label: RichTextLabel
@export var card_manager: Node
@export var deck: Node2D

func _ready():
	# Assign owner_id to all slots
	for slot in get_tree().get_nodes_in_group("card_slots"):
		if is_ancestor_of(slot):
			slot.owner_id = player_id
	# Connect to GameManager updates
	if not GameManager.game_started.is_connected(_on_game_started):
		GameManager.game_started.connect(_on_game_started)
	if not GameManager.hand_updated.is_connected(_on_hand_updated):
		GameManager.hand_updated.connect(_on_hand_updated)
	if not GameManager.deck_updated.is_connected(_update_deck_count):
		GameManager.deck_updated.connect(_update_deck_count)
	if not GameManager.player_health_changed.is_connected(_on_player_health_changed):
		GameManager.player_health_changed.connect(_on_player_health_changed)
	
	# (Future) Connect other signals for hand/deck changes
	
	# Initialize immediately if GameManager already has data
	if GameManager.players.has(player_id):
		_initialize_from_gamemanager()
		
	
# ------------------------------------------------------------
# Initialization
# ------------------------------------------------------------
func _on_game_started():
	if GameManager.players.has(player_id):
		_initialize_from_gamemanager()

func _initialize_from_gamemanager():
	if GameManager.players.has(player_id):
		var data = GameManager.players[player_id]
		# Health
		health_label.text = str(data.health)
		# Deck count
		_update_deck_count(player_id, data.deck.size())
		# Hand UI
		if hand and "update_hand_ui" in hand:
			hand.update_hand_ui(data.hand)
		deck.initialize(data.deck, is_local_player)

# ------------------------------------------------------------
# Health & Deck UI Updates
# ------------------------------------------------------------
func _on_player_health_changed(id, new_health):
	if id == player_id:
		health_label.text = str(new_health)

func _on_hand_updated(id, new_hand):
	if id == player_id and hand:
		if "update_hand_ui" in hand:
			hand.update_hand_ui(new_hand)

func _update_deck_count(playerid, count: int):
	if deck_count_label:
		deck_count_label.text = str(count)

# ------------------------------------------------------------
# Card Drawing (Triggered by external systems like Board/BattleManager)
# ------------------------------------------------------------
func request_draw_card():
	# Only trigger GameManager to handle card logic
	if GameManager.players.has(player_id):
		GameManager.draw_card(player_id)
		print("Field: draw_card request for", player_id)
