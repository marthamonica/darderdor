extends Node

class_name Inventory

@export var power_ups : Dictionary = {}

func add_item(powerUpName : String):
	if (power_ups.has(powerUpName)):
		power_ups[powerUpName] += 1
	else:
		power_ups[powerUpName] = 1
	
	# temp for debug to see what's in inventory
	print_debug(power_ups)
