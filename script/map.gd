extends Node
class_name MapCus

@export var BG: TextureRect

	
func get_map_width():
	return BG.custom_minimum_size.x

func get_map_height():
	return BG.custom_minimum_size.y

func _ready():
	pass

		
