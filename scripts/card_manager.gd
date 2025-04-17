extends Node2D

@onready var player_hand: Node2D = $"../PlayerHand"
@onready var input_manager: Node2D = $"../InputManager"
@onready var battle_manager: Node = $"../BattleManager"

const COLLISION_MASK_CARD: int = 1
const COLLISION_MASK_CARD_SLOT: int = 2
const DEFAULT_CARD_SCALE: Vector2 = Vector2(0.8, 0.8)
const FOCUSED_CARD_SCALE: Vector2 = Vector2(0.85, 0.85)
const PLACED_CARD_SCALE: Vector2 = Vector2(0.6, 0.6)

var screen_size
var card_being_dragged
var is_hovering_on_card: bool
var played_monster_card_this_turn: bool = false
var selected_monster

func _ready() -> void:
	screen_size = get_viewport_rect().size
	input_manager.left_mouse_button_released.connect(on_left_click_released)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))

func on_left_click_released():
	if card_being_dragged:
		finish_drag()

#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			## raycast checking
			#var card = raycast_check_for_card()
			#if card:
				#start_drag(card)
		#else:
			#if card_being_dragged:
				#finish_drag()
				#
func raycast_check_for_card_slot():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func connect_card_signal(card):
	card.hovered.connect(on_hovered_over_card)
	card.hovered_off.connect(on_hovered_off_card)
	
func on_hovered_over_card(card):
	if card.card_slot_card_is_in:
		return
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if card.card_slot_card_is_in || card_being_dragged || card.defeated:
		return
		
	highlight_card(card, false)
	# checking if hovered off to another card directly
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = FOCUSED_CARD_SCALE
		card.z_index = 2
	else:
		card.scale = DEFAULT_CARD_SCALE
		card.z_index = 1

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

func start_drag(card: Node2D):
	card_being_dragged = card
	card.scale = DEFAULT_CARD_SCALE

func finish_drag():
	card_being_dragged.scale = FOCUSED_CARD_SCALE
	var card_slot_found: Node2D = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		if card_being_dragged.card_type == card_slot_found.card_slot_type:
			if !played_monster_card_this_turn:
				card_being_dragged.card_slot_card_is_in = card_slot_found;
				card_being_dragged.scale = PLACED_CARD_SCALE
				card_being_dragged.z_index = -1
				is_hovering_on_card = false
				player_hand.remove_card_from_hand(card_being_dragged)
				card_being_dragged.global_position = card_slot_found.global_position
				card_slot_found.card_in_slot = true
				card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
				battle_manager.player_cards_on_battlefield.append(card_being_dragged)
				card_being_dragged = null
				played_monster_card_this_turn = true
				return
	player_hand.add_card_to_hand(card_being_dragged, player_hand.card_move_speed)
	card_being_dragged = null
	
func card_clicked(card):
	if card.card_slot_card_is_in:
		if battle_manager.is_opponents_turn:
			return
		if card in battle_manager.player_cards_that_attacked_this_turn:
			return
		if battle_manager.opponent_cards_on_battlefield.size() == 0:
			battle_manager.attack_player(card, "Player")
			return
		else:
			select_card_for_battle(card)
		pass
	else:
		start_drag(card)
	
func reset_played_monster():
	played_monster_card_this_turn = false
	
func unselect_selected_monster():
	if selected_monster:
		selected_monster.position.y += 20
		selected_monster = null
	
func select_card_for_battle(card):
	if selected_monster:
		if selected_monster == card:
			unselect_selected_monster()
		else:
			selected_monster.position.y += 20
			selected_monster = card
			card.position.y -= 20
	else:
		selected_monster = card
		card.position.y -= 20
