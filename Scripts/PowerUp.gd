extends Node2D

class_name PowerUp

@export var display_name : String

func destroy():
	queue_free()
