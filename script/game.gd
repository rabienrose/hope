extends Node


var test_node
var char_groups={}
@export var char_root: Node2D
@export var cam: Camera2D
@export var map: Node2D
@export var ui: CanvasLayer
var next_avi_group_id = 0
var next_level=0
var update_step=0

var battle_time=0
var group_color={}
var group_attacked={}
func cam_2_world(pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * pos
	# return (cam.position+pos-Vector2(1000,600))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var pos = cam_2_world(event.position)
		set_group_mov_target(-1, pos)

func set_group_mov_target(group_id: int, pos: Vector2) -> void:
	for char in char_groups[group_id]:
		if char.hp<=0:
			continue
		char.set_mov_target(pos)

func find_nearest_enemy(char, atk_range):
	if char.is_enemy==false:
		for group in char_groups:
			if group == -1:
				continue
			var b_group_far = false
			for c in char_groups[group]:
				if c.hp<=0:
					continue
				var d = c.position.distance_to(char.position)
				if d < Global.atk_dist*atk_range:
					return c
	else:
		for c in char_groups[-1]:
			if c.hp<=0:
				continue
			var d = c.position.distance_to(char.position)
			if d < Global.atk_dist*atk_range:
				return c
	return null

func remove_char(char):
	for group in char_groups:
		if char in char_groups[group]:
			char_groups[group].erase(char)
			char.queue_free()
	if char.is_enemy==false:
		ui.update_add_die()
		ui.update_player_count()

func _ready():
	Global.map_w=map.get_map_width()
	Global.map_h=map.get_map_height()
	ui.game=self
	cam.limit_right=Global.map_w
	cam.limit_bottom=Global.map_h
	var agent_list = []
	var group_center=cam.position
	char_groups[-1]=[]
	var char_scn_res=load("res://chars/cat.tscn")
	for i in range(Global.player_init_count):
		var char=char_scn_res.instantiate()
		char_groups[-1].append(char)
		var rand_offset= Vector2(Global.rng.randf_range(-150, 150), Global.rng.randf_range(-150, 150))
		char.setup(false, -1, group_center+rand_offset, self)
		char_root.add_child(char)
		agent_list.append(char.agent)
	for char in char_groups[-1]:
		char.set_group_member(agent_list)
	ui.update_player_count()


func proces_level():
	var level_ind=0
	if next_level>=Global.level_data.size():
		return
	var dat=Global.level_data[next_level]
	if dat["time"]<battle_time:
		next_level+=1
		var group_center= Vector2(Global.rng.randf_range(300, Global.map_w-300), Global.rng.randf_range(600, Global.map_h-600))
		var char_list=[]
		var group_id=next_avi_group_id
		group_color[group_id]=Color.from_hsv(dat["color"]/360.0, 0.5, 1)
		group_attacked[group_id]=0
		next_avi_group_id+=1
		char_groups[group_id]=[]
		var agent_list = []
		for char_name in dat["group"]:
			for i in range(dat["group"][char_name]):
				var char_scn_res=load("res://chars/"+char_name+".tscn")
				var char=char_scn_res.instantiate()
				char_groups[group_id].append(char)
				var rand_offset= Vector2(Global.rng.randf_range(-50, 50), Global.rng.randf_range(-50, 50))
				char.setup(true, group_id, group_center+rand_offset, self)
				char_root.add_child(char)
				agent_list.append(char.agent)
		for char in char_groups[group_id]:
			char.set_group_member(agent_list)
		ui.update_enemy_count()

func _process(delta):
	update_step=update_step+1
	if update_step>0.1:
		ui.update_fps()
		update_step=0
		ui.update_count_down()
		battle_time=battle_time+delta
		proces_level()
		if char_groups[-1].size()>0:
			var group_center=Vector2(0, 0)
			for char in char_groups[-1]:
				group_center+=char.position
			group_center/=char_groups[-1].size()
			cam.position=group_center
		
