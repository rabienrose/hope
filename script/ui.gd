extends Control

@export var enemy_count: Label
@export var player_count: Label
@export var die_count: Label

var game
var die_num=0



func update_enemy_count():
	var count=0
	for group in game.char_groups:
		count += game.char_groups[group].size()
	enemy_count.text = str(count)

func update_player_count():
	player_count.text = str(game.char_groups[-1].size())

func update_add_die():
	die_num=die_num+1
	die_count.text = str(die_num)
