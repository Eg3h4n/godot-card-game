extends CanvasLayer

@export var single_player_button: Button
@export var multi_player_button: Button
@export var quit_button: Button

@export var game_setup_scene : PackedScene
@export var lobby_scene : PackedScene

func _ready():
	single_player_button.pressed.connect(_on_single_player_pressed)
	multi_player_button.pressed.connect(_on_multi_player_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_single_player_pressed():
	print("Single Player Mode selected")
	GameManager.mode = GameManager.GameMode.SINGLE_PLAYER
	# Load Game Setup directly for single player
	get_tree().change_scene_to_packed(game_setup_scene)

func _on_multi_player_pressed():
	print("Multiplayer Mode selected")
	GameManager.mode = GameManager.GameMode.MULTIPLAYER
	# Go to lobby scene for host/join
	get_tree().change_scene_to_packed(lobby_scene)

func _on_quit_pressed():
	get_tree().quit()
