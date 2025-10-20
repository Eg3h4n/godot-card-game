extends Node

const CARDS = { # [attack, health, sprite, card type, ability text, ability script]
	"Knight" : [2, 3, "res://assets/Knigt.png", "Monster", "", ""],
	"Archer" : [1, 1, "res://assets/Archer.png", "Monster", "Deals 1 damage to opponent commander", "res://scripts/abilities/arrow_attack.gd"],
	"Demon" : [5, 7, "res://assets/Demon.png", "Monster", "Attacks twice", "res://scripts/abilities/attack_twice.gd"],
	"Tornado": [0, 0, "res://assets/Tornado.png", "Magic", "Deal 1 damage to all opponent cards", "res://scripts/abilities/tornado.gd"]
}

func get_card_data(name: String, is_player: bool = true) -> Dictionary:
	var c = CARDS[name]
	return {
		"name": name,
		"attack": c[0],
		"health": c[1],
		"sprite_path": c[2],
		"type": c[3],
		"ability_text": c[4],
		"ability_script": c[5],
		"is_players_card": is_player
	}
