extends Node2D
@onready var card_manager: Node2D = $"../CardManager"
@onready var opponent_hand: Node2D = $"../OpponentHand"
@onready var deck_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var deck_sprite_2d: Sprite2D = $Sprite2D
@onready var deck_rich_text_label: RichTextLabel = $RichTextLabel

@export var hand_count: int = 5
@export var card_draw_speed: float = 0.2
@export var starting_hand_size: int = 5

const OPPONENT_CARD = preload("res://scenes/opponent_card.tscn")

var opponent_deck = ["Knight", "Archer", "Demon", "Knight", "Knight", "Archer", "Demon", "Knight"]

func _ready() -> void:
	opponent_deck.shuffle()
	deck_rich_text_label.text = str(opponent_deck.size())
	
	for i in range(starting_hand_size):
		draw_card()

func draw_card():
	if opponent_deck.size() <= 0:
		return
		
	var card_drawn_name = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)
	
	if opponent_deck.size() <= 0:
		deck_sprite_2d.visible = false
		deck_rich_text_label.visible = false
		return
	
	deck_rich_text_label.text = str(opponent_deck.size())
	var new_card = OPPONENT_CARD.instantiate()
	new_card.attack = str(CardDatabase.CARDS[card_drawn_name][0])
	new_card.get_node("Attack").text = str(CardDatabase.CARDS[card_drawn_name][0])
	new_card.get_node("Health").text = str(CardDatabase.CARDS[card_drawn_name][1])
	new_card.get_node("CardImage").texture = load(CardDatabase.CARDS[card_drawn_name][2])
	new_card.card_type= CardDatabase.CARDS[card_drawn_name][3]
	card_manager.add_child(new_card)
	new_card.name = "Card"
	opponent_hand.add_card_to_hand(new_card, card_draw_speed)
