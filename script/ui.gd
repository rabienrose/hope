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
	if game.next_level>=Global.level_data.size():
		count_done.text = "0"
		return
	var time = Global.level_data[game.next_level]["time"]-game.battle_time
	if time < 0:
		time = 0
	time = ceil(time)
	count_done.text = str(game.next_level)+": "+str(time)

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
