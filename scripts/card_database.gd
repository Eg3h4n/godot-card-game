extends Node

const CARDS = { # [attack, health, sprite, card type, ability text, ability script]
	"Knight" : [2, 3, "res://assets/Knigt.png", "Monster", null, null],
	"Archer" : [1, 1, "res://assets/Archer.png", "Monster", null, null],
	"Demon" : [5, 7, "res://assets/Demon.png", "Monster", null, null],
	"Tornado": [null, null, "res://assets/Tornado.png", "Magic", "Deal 1 damage to all opponent cards", "res://scripts/abilities/tornado.gd"]
}
