extends Node

const CARDS = { # [attack, health, sprite, card type, ability text, ability script]
	"Knight" : [2, 3, "res://assets/Knigt.png", "Monster", null, null],
	"Archer" : [1, 1, "res://assets/Archer.png", "Monster", "Deals 1 damage to opponent commander", "res://scripts/abilities/arrow_attack.gd"],
	"Demon" : [5, 7, "res://assets/Demon.png", "Monster", "Attacks twice", "res://scripts/abilities/attack_twice.gd"],
	"Tornado": [null, null, "res://assets/Tornado.png", "Magic", "Deal 1 damage to all opponent cards", "res://scripts/abilities/tornado.gd"]
}
