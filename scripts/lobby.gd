extends CanvasLayer

@export var host_button: Button
@export var join_button: Button

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

func _on_host_pressed():
	NetworkManager.host_game()
	print("Hosting game...")
	# Load game scene (e.g., board)
	get_tree().change_scene_to_file("res://scenes/game_setup.tscn")

func _on_join_pressed():
	var ip = "localhost"
	NetworkManager.join_game(ip)
	print("Joining game...")
	get_tree().change_scene_to_file("res://scenes/game_setup.tscn")
