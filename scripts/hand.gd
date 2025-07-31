extends Node2D

@export var is_player: bool = true
var held_cards: Array = []

## Add a card to the hand
func add_card(card: Node2D):
	if not card: 
		return
	held_cards.append(card)
	add_child(card)
	_arrange_cards()

## Remove a card from hand
func remove_card(card: Node2D):
	if held_cards.has(card):
		held_cards.erase(card)
		if card.get_parent() == self:
			remove_child(card)
	_arrange_cards()

## Arrange card positions visually
func _arrange_cards():
	var spacing = 100
	var start_x = -(held_cards.size() - 1) * spacing / 2
	for i in range(held_cards.size()):
		var card = held_cards[i]
		card.position = Vector2(start_x + i * spacing, 0)
		
		# Hide opponent's cards if they shouldn't be visible
		if not is_player:
			card.modulate.a = 0.0 # fully hidden
		else:
			card.modulate.a = 1.0

## Get all cards
func get_cards() -> Array:
	return held_cards

## Get card count
func get_count() -> int:
	return held_cards.size()
