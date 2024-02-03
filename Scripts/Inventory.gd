extends Node

class_name Inventory

@export var power_ups : Dictionary = {}

func add_item(power_up_name : String):
	if (power_ups.has(power_up_name)):
		power_ups[power_up_name] += 1
	else:
		power_ups[power_up_name] = 1
	
	# temp for debug to see what's in inventory
	print_debug(power_ups)
	
func remove_all_item():
	power_ups.clear()
	
	print_debug("All power up removed")
