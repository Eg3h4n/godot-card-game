extends CanvasLayer

@export var board_scene : PackedScene
@export var min_display_time: float = 1.0 # seconds to keep loading screen visible
@export var loading_text_label : RichTextLabel

var _match_ready := false

func _ready() -> void:
	print("GameSetup: Loading screen started")
	
	# Show loading message if you have a label
	if loading_text_label:
		loading_text_label.text = "Setting up match..."
	
	# Connect to game_started before starting match
	if not GameManager.game_started.is_connected(_on_game_started):
		GameManager.game_started.connect(_on_game_started, CONNECT_ONE_SHOT)
	
	_populate_test_decks()  # 🔹 Add test decks here
	
	# Now start match
	GameManager.start_match()

func _populate_test_decks():
	var test_deck_player = []
	var test_deck_ai = []
	
	# Fill deck with test cards
	for i in range(3):
		test_deck_player.append(CardDatabase.get_card_data("Knight"))
		test_deck_player.append(CardDatabase.get_card_data("Knight"))
		test_deck_player.append(CardDatabase.get_card_data("Archer"))
		test_deck_player.append(CardDatabase.get_card_data("Archer"))
		test_deck_player.append(CardDatabase.get_card_data("Tornado"))
		test_deck_player.append(CardDatabase.get_card_data("Tornado"))
		
	for i in range(3):
		test_deck_ai.append(CardDatabase.get_card_data("Demon", false))
		test_deck_ai.append(CardDatabase.get_card_data("Demon", false))
		test_deck_ai.append(CardDatabase.get_card_data("Archer", false))
		test_deck_ai.append(CardDatabase.get_card_data("Archer", false))
		test_deck_ai.append(CardDatabase.get_card_data("Tornado", false))
		test_deck_ai.append(CardDatabase.get_card_data("Tornado", false))
		
	# Store decks in GameManager
	GameManager.players["Player"] = {
		"health": 20,
		"deck": test_deck_player,
		"hand": []
	}
	GameManager.players["AI"] = {
		"health": 20,
		"deck": test_deck_ai,
		"hand": []
	}

func _on_game_started() -> void:
	print("GameSetup: Match setup completed")
	_match_ready = true
	_go_to_board()

func _go_to_board() -> void:
	 # Ensure the loading screen stays at least min_display_time visible
	await get_tree().create_timer(min_display_time).timeout
	if board_scene:
		print("GameSetup: Loading board scene...")
		get_tree().change_scene_to_packed(board_scene)
	else:
		push_error("Board scene not assigned in inspector!")
