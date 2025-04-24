extends Node

const ABILITY_TRIGGER_EVENT = "after_attack"

var already_activated: bool = false

func trigger_ability(input_manager, battle_manager, card_with_ability, trigger_event):
	if trigger_event != ABILITY_TRIGGER_EVENT:
		return
	if already_activated:
		return
	if card_with_ability in battle_manager.player_cards_that_attacked_this_turn:
		battle_manager.player_cards_that_attacked_this_turn.erase(card_with_ability)
		already_activated = true

func end_turn_reset():
	already_activated = false
