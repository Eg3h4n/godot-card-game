extends Node2D

@export var is_player: bool = true
var cards: Array = []

## Called to initialize deck with card data and ownership flag
func initialize(deck_data: Array, player_owned: bool):
	cards = deck_data.duplicate()
	is_player = player_owned
	shuffle()

## Shuffle the deck
func shuffle():
	cards.shuffle()

## Draw a single card from the top of the deck
func draw_card():
	if cards.is_empty():
		return null
	return cards.pop_front()

## Draw multiple cards at once
func draw_multiple(count: int) -> Array:
	var drawn = []
	for i in range(count):
		if cards.is_empty():
			break
		drawn.append(cards.pop_front())
	return drawn

## Add card back into deck (e.g., reshuffle scenario)
func add_card(card_data):
	cards.append(card_data)

## Get remaining card count
func get_remaining_count() -> int:
	return cards.size()
