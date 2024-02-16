extends CanvasLayer

@export var enemy_count: Label
@export var player_count: Label
@export var die_count: Label
@export var count_done: Label
@export var fps: Label
@export var win_count: Label
@export var win_count_wnd: Control

var game
var die_num=0

func update_enemy_count():
	var count=0
	for group in game.char_groups:
		if group == -1:
			continue
		count += game.char_groups[group].size()
	enemy_count.text = str(count)

func update_player_count():
	player_count.text = str(game.char_groups[-1].size())

func update_add_die():
	die_num=die_num+1
	die_count.text = str(die_num)

func update_count_down():
	var total_pass_level=0
	for num in game.cur_level:
		total_pass_level=total_pass_level+num+1
	count_done.text = str(total_pass_level)+"/"+str(Global.total_level_count)

func update_fps():
	fps.text = "FPS: "+str(Engine.get_frames_per_second())

func _on_to_main_button_down():
	get_tree().change_scene_to_file("res://main.tscn")

func show_win_count(count):
	if win_count_wnd.visible==true:
		return
	win_count_wnd.visible = true
	win_count.text = "剩余部队： "+str(count)

func _on_restart_button_down():
	get_tree().change_scene_to_file("res://main.tscn")
