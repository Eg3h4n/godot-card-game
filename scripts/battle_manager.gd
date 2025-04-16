extends Node
@onready var end_turn_button: Button = $"../EndTurnButton"
@onready var opponent_deck: Node2D = $"../OpponentDeck"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var opponent_card_slots: Node2D = $"../OpponentCardSlots"
@onready var opponent_hand: Node2D = $"../OpponentHand"
@onready var deck: Node2D = $"../Deck"
@onready var card_manager: Node2D = $"../CardManager"

const CARD_IN_SLOT_SCALE: Vector2 = Vector2(0.6, 0.6)

var empty_monster_card_slots = []

func _ready() -> void:
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	print(empty_monster_card_slots.size())
	for i in opponent_card_slots.get_children().size():
		var slot = opponent_card_slots.get_child(i)
		if slot.card_slot_type == "Monster":
			empty_monster_card_slots.append(slot)
	print(empty_monster_card_slots.size())

func _on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	end_turn_button.visible = false
	
	await process_opponent_turn()
	
	end_turn_button.disabled = false
	end_turn_button.visible = true

func process_opponent_turn():
	opponent_deck.draw_card()
	
	# waiting 1 second
	battle_timer.start()
	await battle_timer.timeout
	
	# checks card slot if it can play a monster card
	if empty_monster_card_slots.size() <= 0:
		return
		
	battle_timer.start()
	await battle_timer.timeout
	
	#  plays card with highest attack
	if opponent_hand.opponent_hand.size() == 0:
		return
	var random_empty_monster_card_slot = empty_monster_card_slots[randi_range(0, empty_monster_card_slots.size() - 1)]
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	var card_with_highest_attack = opponent_hand.opponent_hand[0]
	for card in opponent_hand.opponent_hand:
		if card.attack > card_with_highest_attack.attack:
			card_with_highest_attack = card
			
	var pos_tween = get_tree().create_tween()
	pos_tween.tween_property(card_with_highest_attack, "position", random_empty_monster_card_slot.global_position, 0.2)
	var scale_tween = get_tree().create_tween()
	scale_tween.tween_property(card_with_highest_attack, "scale", CARD_IN_SLOT_SCALE, 0.2)
	card_with_highest_attack.get_node("AnimationPlayer").play("card_flip")
	opponent_hand.remove_card_from_hand(card_with_highest_attack)
	
	battle_timer.start()
	await battle_timer.timeout
	#end turn
	battle_timer.start()
	await battle_timer.timeout
	deck.reset_draw()
	card_manager.reset_played_monster()
	
