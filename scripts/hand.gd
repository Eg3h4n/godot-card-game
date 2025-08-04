extends Node2D

@export var is_player: bool = true
@export var card_move_speed: float = 0.1
@export var hand_y_position: float = 955
@export var is_reversed: bool = false

const CARD_WIDTH = 160
var held_cards: Array = []
var center_screen_x

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2

##  Signal-driven update (for GameManager.hand_updated)
func update_hand_ui(cards: Array):
	# Clear existing cards
	for c in held_cards:
		if is_instance_valid(c) and c.get_parent() == self:
			remove_child(c)
	held_cards.clear()

	# Add cards from data
	for card_data in cards:
		var card_scene = preload("res://scenes/partial/card.tscn").instantiate()
		if "set_card_data" in card_scene and is_player:
			card_scene.set_card_data(card_data) # Only show details for player
		elif not is_player:
			card_scene.modulate.a = 0.0 # Hidden opponent cards
		held_cards.append(card_scene)
		add_child(card_scene)
		# ✅ FIX: Register cards for dragging
		if is_player:
			InputManager.register_card(card_scene)
			print("DEBUG: Hand.gd registered card ->", card_data.get("name"))

	update_hand_positions(card_move_speed)

## Add a single card manually (optional)
func add_card(card: Node2D, speed: float = 0.1):
	if not card:
		return
	held_cards.insert(0, card)
	add_child(card)
	update_hand_positions(speed)

## Remove a card manually
func remove_card(card: Node2D):
	if card in held_cards:
		held_cards.erase(card)
		if is_instance_valid(card) and card.get_parent() == self:
			remove_child(card)
	update_hand_positions(card_move_speed)

## Arrange card positions visually
func update_hand_positions(speed: float):
	for i in range(held_cards.size()):
		var new_position = Vector2(calculate_card_position(i), hand_y_position)
		var card = held_cards[i]
		card.position_in_hand = new_position
		animate_card_to_position(card, new_position, speed)

## Calculate card X position (mirrored for opponent if needed)
func calculate_card_position(index: int):
	var x_offset = (held_cards.size() - 1) * CARD_WIDTH
	if is_reversed:
		return center_screen_x - index * CARD_WIDTH + x_offset / 2
	else:
		return center_screen_x + index * CARD_WIDTH - x_offset / 2

## Animate card movement
func animate_card_to_position(card, new_position: Vector2, speed: float):
	if not is_instance_valid(card):
		return
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

## Get cards
func get_cards() -> Array:
	return held_cards

## Get card count
func get_count() -> int:
	return held_cards.size()
