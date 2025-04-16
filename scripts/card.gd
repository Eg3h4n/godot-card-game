extends Node2D

signal hovered
signal hovered_off

var position_in_hand : Vector2
var card_is_in_card_slot : bool
var card_type: String

func _ready() -> void:
	get_parent().connect_card_signal(self)

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)
	print("hovering enter")


func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)
	print("hovering exit")
