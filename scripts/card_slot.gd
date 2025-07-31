#class_name CardSlot
#
#extends Node2D
#
#var card_in_slot = false
#var card_slot_type = "Monster"
#
#func _ready() -> void:
	#print("card slots here")
	#pass
#
#func activate_card_slot_collision():
	#get_node("Area2D/CollisionShape2D").disabled = false
class_name CardSlot
extends Node2D

@export var card_slot_type: String = "Monster" # "Monster" or "Magic"
@export var owner_id: String = ""             # Player or AI ID

var card_in_slot: bool = false
var collider: CollisionShape2D

func _ready() -> void:
	if owner_id == "Player":
		collider = $Area2D/CollisionShape2D
	# Ensure the slot is active by default
	if collider:
		collider.disabled = false

# ------------------------------------------------------------
# Determines if a card can be dropped here
# ------------------------------------------------------------
func can_accept_card(card_data: Dictionary) -> bool:
	# 1) Slot must be empty
	if card_in_slot:
		return false
		
	# 2) Card type must match slot type
	if card_data.get("type", "") != card_slot_type:
		return false
		
	# 3) Owner ID check (optional, for multiplayer)
	if owner_id != "" and card_data.get("owner_id", owner_id) != owner_id:
		return false
		
	return true

# ------------------------------------------------------------
# Called when a card is placed successfully
# ------------------------------------------------------------
func place_card(card_node: Node):
	card_in_slot = true
	add_child(card_node)
	card_node.position = Vector2.ZERO
	print("Card placed in", card_slot_type, "slot owned by", owner_id)

# ------------------------------------------------------------
# Free the slot when card is removed/destroyed
# ------------------------------------------------------------
func clear_slot():
	card_in_slot = false

# ------------------------------------------------------------
# Optionally allow external activation of collision
# ------------------------------------------------------------
func activate_card_slot_collision():
	if collider:
		collider.disabled = false
