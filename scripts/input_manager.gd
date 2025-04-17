extends Node2D

@onready var card_manager: Node2D = $"../CardManager"
@onready var deck: Node2D = $"../Deck"

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4

signal left_mouse_button_clicked
signal left_mouse_button_released

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# raycast checking
			left_mouse_button_clicked.emit()
			raycast_at_cursor()
		else:
			left_mouse_button_released.emit()
				

func raycast_at_cursor():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			# card clicked
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager.card_clicked(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			# deck clicked
			deck.draw_card()
