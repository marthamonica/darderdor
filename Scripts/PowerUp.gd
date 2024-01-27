extends Node2D

class_name PowerUp

@export var display_name : String
@export var additional_bomb_count : int
@export var additional_bomb_reach : int
@export var additional_player_speed : int

func detonate():
	destroy()

func destroy():
	queue_free()
