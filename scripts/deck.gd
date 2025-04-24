extends Node2D
@onready var card_manager: Node2D = $"../CardManager"
@onready var player_hand: Node2D = $"../PlayerHand"
@onready var deck_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var deck_sprite_2d: Sprite2D = $Sprite2D
@onready var deck_rich_text_label: RichTextLabel = $RichTextLabel

@export var hand_count: int = 5
@export var card_draw_speed: float = 0.2
@export var starting_hand_size: int = 5

const CARD = preload("res://scenes/card.tscn")

var player_deck = ["Knight", "Archer", "Tornado", "Knight", "Tornado", "Archer", "Demon", "Knight"]
var drawn_card_this_turn: bool = false

func _ready() -> void:
	player_deck.shuffle()
	deck_rich_text_label.text = str(player_deck.size())
	
	for i in range(starting_hand_size):
		draw_card()
		drawn_card_this_turn = false # to bypass the check in draw card func
	drawn_card_this_turn = true # to prevent drawing in first turn

func draw_card():
	if drawn_card_this_turn:
		return
		
	drawn_card_this_turn = true
		
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() <= 0:
		deck_collision_shape_2d.disabled = true
		deck_sprite_2d.visible = false
		deck_rich_text_label.visible = false
	
	deck_rich_text_label.text = str(player_deck.size())
	var new_card = CARD.instantiate()
	new_card.card_type = CardDatabase.CARDS[card_drawn_name][3]
	if new_card.card_type == "Monster":
		new_card.attack = CardDatabase.CARDS[card_drawn_name][0]
		new_card.get_node("Attack").text = str(new_card.attack)
		new_card.health = CardDatabase.CARDS[card_drawn_name][1]
		new_card.get_node("Health").text = str(new_card.health)
	else:
		new_card.get_node("Attack").visible = false
		new_card.get_node("Health").visible = false
	var new_card_ability_script_path = CardDatabase.CARDS[card_drawn_name][5]
	if new_card_ability_script_path:
		new_card.get_node("Ability").text =  CardDatabase.CARDS[card_drawn_name][4]
		new_card.ability_script = load(new_card_ability_script_path).new()
	else:
		new_card.get_node("Ability").visible = false
	new_card.get_node("CardImage").texture = load(CardDatabase.CARDS[card_drawn_name][2])
	card_manager.add_child(new_card)
	new_card.name = "Card"
	player_hand.add_card_to_hand(new_card, card_draw_speed)
	new_card.get_node("AnimationPlayer").play("card_flip")

func reset_draw():
	drawn_card_this_turn = false
