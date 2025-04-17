extends Node
@onready var end_turn_button: Button = $"../EndTurnButton"
@onready var opponent_deck: Node2D = $"../OpponentDeck"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var opponent_card_slots: Node2D = $"../OpponentCardSlots"
@onready var opponent_hand: Node2D = $"../OpponentHand"
@onready var deck: Node2D = $"../Deck"
@onready var card_manager: Node2D = $"../CardManager"
@onready var player_health: RichTextLabel = $"../PlayerHealth"
@onready var opponent_health: RichTextLabel = $"../OpponentHealth"
@onready var player_discard_pile: Node2D = $"../PlayerDiscardPile"
@onready var opponent_discard_pile: Node2D = $"../OpponentDiscardPile"

const CARD_IN_SLOT_SCALE: Vector2 = Vector2(0.6, 0.6)
const BATTLE_POS_OFFSET = 25
@export var INITIAL_HEALTH: int

var empty_monster_card_slots = []
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []
var player_cards_that_attacked_this_turn = []
var player_health_amount: int
var opponent_health_amount: int
var is_opponents_turn: bool = false
var player_is_attacking: bool = false


func _ready() -> void:
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	print(empty_monster_card_slots.size())
	for i in opponent_card_slots.get_children().size():
		var slot = opponent_card_slots.get_child(i)
		if slot.card_slot_type == "Monster":
			empty_monster_card_slots.append(slot)
	print(empty_monster_card_slots.size())
	
	player_health_amount = INITIAL_HEALTH
	player_health.text = str(player_health_amount)
	opponent_health_amount = INITIAL_HEALTH
	opponent_health.text = str(opponent_health_amount)
	
func _on_end_turn_button_pressed() -> void:
	is_opponents_turn = true
	end_turn_button.disabled = true
	end_turn_button.visible = false
	
	card_manager.unselect_selected_monster()
	player_cards_that_attacked_this_turn = []
	
	await process_opponent_turn()
	
	end_turn_button.disabled = false
	end_turn_button.visible = true
	deck.reset_draw()
	card_manager.reset_played_monster()
	is_opponents_turn = false

func process_opponent_turn():
	opponent_deck.draw_card()
	
	# waiting 1 second
	await wait_for_seconds(1)
	
	# checks card slot if it can play a monster card
	if empty_monster_card_slots.size() != 0:
		await try_play_card_with_highest_attack() #  plays card with highest attack
		
	# try attacking
	if opponent_cards_on_battlefield.size() > 0:
		var available_cards_to_attack = opponent_cards_on_battlefield.duplicate()
		for card in available_cards_to_attack:
			if player_cards_on_battlefield.size() == 0: # will attack player
				await attack_player(card, "Opponent")
			else:
				var card_to_attack = player_cards_on_battlefield.pick_random()
				await attack_card(card, card_to_attack, "Opponent")
	
	#end turn
	await wait_for_seconds(1)
	
	

func try_play_card_with_highest_attack():
	if opponent_hand.opponent_hand.size() == 0:
		return
	var random_empty_monster_card_slot = empty_monster_card_slots.pick_random()
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	var card_with_highest_attack = opponent_hand.opponent_hand[0]
	for card in opponent_hand.opponent_hand:
		if card.attack > card_with_highest_attack.attack:
			card_with_highest_attack = card
	
	tween_animation(card_with_highest_attack, "position", random_empty_monster_card_slot.global_position, 0.2)
	tween_animation(card_with_highest_attack, "scale", CARD_IN_SLOT_SCALE, 0.2)

	card_with_highest_attack.get_node("AnimationPlayer").play("card_flip")
	
	opponent_hand.remove_card_from_hand(card_with_highest_attack)
	card_with_highest_attack.card_slot_card_is_in = random_empty_monster_card_slot
	opponent_cards_on_battlefield.append(card_with_highest_attack)
	
	await wait_for_seconds(1)

func attack_player(attacking_card, attacking_side):
	var new_pos_y
	if attacking_side == "Opponent":
		new_pos_y = 1080
	else:
		player_is_attacking = true
		new_pos_y = 0
		player_cards_that_attacked_this_turn.append(attacking_card)
	attacking_card.z_index = 5
	
	var new_pos: Vector2 = Vector2(attacking_card.position.x, new_pos_y)
	tween_animation(attacking_card, "position", new_pos, 0.2)
	
	await wait_for_seconds(0.25)
	
	if attacking_side == "Opponent":
		player_health_amount -= attacking_card.attack
		player_health.text = str(player_health_amount)
	else:
		opponent_health_amount -= attacking_card.attack
		opponent_health.text = str(opponent_health_amount)
		
	tween_animation(attacking_card, "position", attacking_card.card_slot_card_is_in.global_position, 0.2)
	
	attacking_card.z_index = 0
	await wait_for_seconds(1)
	
	if attacking_side == "Player":
		player_is_attacking = false
	
func attack_card(attacking_card, defending_card, attacking_side):
	if attacking_side == "Player":
		player_is_attacking = true
		card_manager.selected_monster = null
		player_cards_that_attacked_this_turn.append(attacking_card)
	attacking_card.z_index = 5
	var new_pos: Vector2 = Vector2(defending_card.global_position.x, defending_card.global_position.y + BATTLE_POS_OFFSET)
	
	tween_animation(attacking_card, "position", new_pos, 0.2)
	await wait_for_seconds(0.25)
	tween_animation(attacking_card, "position", attacking_card.card_slot_card_is_in.global_position, 0.2)
	
	defending_card.health -= attacking_card.attack
	defending_card.get_node("Health").text = str(defending_card.health)
	
	attacking_card.health -= defending_card.attack
	attacking_card.get_node("Health").text = str(attacking_card.health)
	
	await wait_for_seconds(1)
	attacking_card.z_index = 0
	
	var card_was_destroyed = false
	if attacking_card.health <= 0:
		await destroy_card(attacking_card, attacking_side)
		card_was_destroyed = true
	if defending_card.health <= 0:
		await destroy_card(defending_card, "Player" if attacking_side == "Opponent" else "Player" )
		card_was_destroyed = true
	
	if card_was_destroyed:
		await wait_for_seconds(1)
		
	if attacking_side == "Player":
		player_is_attacking = false

func destroy_card(card, card_owner):
	var new_pos
	if card_owner == "Player" && card in player_cards_on_battlefield:
		card.defeated = true
		card.get_node("Area2D/CollisionShape2D").disabled = true
		new_pos = player_discard_pile.position
		if card in player_cards_on_battlefield:
			player_cards_on_battlefield.erase(card)
		card.card_slot_card_is_in.activate_card_slot_collision()
	else:
		new_pos = opponent_discard_pile.position
		if card in opponent_cards_on_battlefield:
			opponent_cards_on_battlefield.erase(card)
		
	card.card_slot_card_is_in.card_in_slot = false
	card.card_slot_card_is_in = null
	# move card to discard pile
	tween_animation(card, "position", new_pos, 0.2)
	await wait_for_seconds(0.25)
	
	# remove card from arrays such as player_cards_on_battlefield
func opponent_card_selected(defending_card):
	var attacking_card = card_manager.selected_monster
	if attacking_card and defending_card in opponent_cards_on_battlefield and !player_is_attacking:
		attack_card(attacking_card, defending_card, "Player")
		card_manager.selected_monster = null

func tween_animation(object, property:String, tween_value, duration:float):
	var tween = get_tree().create_tween()
	tween.tween_property(object, property, tween_value, duration)

func wait_for_seconds(wait_time):
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout
