extends Node2D

signal hovered
signal hovered_off

var position_in_hand : Vector2
var card_slot_card_is_in
var card_type: String
var attack: int
var health: int
var defeated: bool = false

func _ready() -> void:
	get_parent().connect_card_signal(self)

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)
