extends Node2D

@onready var card_manager: Node2D = $"../CardManager"
@export var card_move_speed: float = 0.1
const CARD_WIDTH = 160
const HAND_Y_POSITION = -30

var opponent_hand = []
var center_screen_x

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2

func add_card_to_hand(card, speed):
	if card not in opponent_hand:
		opponent_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.position_in_hand, speed)
	
func update_hand_positions(speed: float):
	for i in range(opponent_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = opponent_hand[i]
		card.position_in_hand = new_position
		animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(index: int):
	var x_offset = (opponent_hand.size() - 1) * CARD_WIDTH
	var x_position = center_screen_x - index * CARD_WIDTH + x_offset / 2
	return x_position
	
func animate_card_to_position(card, new_position: Vector2, speed: float):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	
func remove_card_from_hand(card):
	if card in opponent_hand:
		opponent_hand.erase(card)
		update_hand_positions(card_move_speed)
