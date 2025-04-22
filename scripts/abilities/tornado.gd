extends Node

@export var tornado_damage: int = 1

func trigger_ability(input_manager, battle_manager, card_with_ability):
	input_manager.input_disabled = true
	battle_manager.toggle_end_turn_button(false)
	
	await battle_manager.wait_for_seconds(1)
	var cards_to_destroy = []
	
	for card in battle_manager.opponent_cards_on_battlefield:
		card.health -= tornado_damage
		card.get_node("Health").text = str(card.health)
		if card.health <= 0:
			cards_to_destroy.append(card)
	await battle_manager.wait_for_seconds(1)
	if cards_to_destroy.size() > 0:
		for card in cards_to_destroy:
			battle_manager.destroy_card(card, "Opponent")
			
	battle_manager.destroy_card(card_with_ability, "Player")
	await battle_manager.wait_for_seconds(1)
	battle_manager.toggle_end_turn_button(true)
	input_manager.input_disabled = false
