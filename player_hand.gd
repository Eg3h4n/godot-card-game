extends Node2D

@onready var card_manager: Node2D = $"../CardManager"

const CARD = preload("res://card.tscn")
const HAND_COUNT = 5
const CARD_WIDTH = 200
const HAND_Y_POSITION = 890

var player_hand = []
var center_screen_x

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	
	for i in range(HAND_COUNT):
		var new_card = CARD.instantiate()
		card_manager.add_child(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)
		
func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.position_in_hand)
	
func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.position_in_hand = new_position
		animate_card_to_position(card, new_position)
		
func calculate_card_position(index: int):
	var x_offset = (player_hand.size() - 1) * CARD_WIDTH
	var x_position = center_screen_x + index * CARD_WIDTH - x_offset / 2
	return x_position
	
func animate_card_to_position(card, new_position: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)
	
func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
