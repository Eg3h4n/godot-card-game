class_name CardSlot

extends Node2D

var card_in_slot = false
var card_slot_type = "Monster"

func _ready() -> void:
	pass

func activate_card_slot_collision():
	get_node("Area2D/CollisionShape2D").disabled = false
