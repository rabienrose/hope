extends Node


var test_node
var char_groups={}
@export var char_root: Node2D
@export var cam: Camera2D
@export var map: Node2D
@export var ui: CanvasLayer
var next_avi_group_id = 0
var cur_level=[]
var level_colors=[]
var update_step=0

var battle_time=0
var group_attacked={}

var w_pressed=false
var a_pressed=false
var s_pressed=false
var d_pressed=false
var mouse_pressed=false
var mouse_pos=Vector2(0,0)
func cam_2_world(pos: Vector2) -> Vector2:
	
	return get_viewport().get_canvas_transform().affine_inverse() * pos
	# return (cam.position+pos-Vector2(1000,600))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			mouse_pressed=true
		else:
			mouse_pressed=false
	if event is InputEventMouseMotion:
		mouse_pos=event.position
	#use wasd to control
	if event is InputEventKey:	
		if event.keycode==87 or event.keycode==65 or event.keycode==83 or event.keycode==68:
			if event.pressed==true:	
				if event.keycode==87: #w
					w_pressed=true
				elif event.keycode==65: #a
					a_pressed=true
				elif event.keycode==83: #s
					s_pressed=true
				elif event.keycode==68: #d
					d_pressed=true
			else:
				if event.keycode==87: #w
					w_pressed=false
				elif event.keycode==65: #a
					a_pressed=false
				elif event.keycode==83: #s
					s_pressed=false
				elif event.keycode==68: #d
					d_pressed=false

func set_group_dir(pos: Vector2):
	for char in char_groups[-1]:
		char.update_move_dir(pos)

func cancel_group_dir():
	for char in char_groups[-1]:
		char.cancel_move()

func set_group_mov_target(group_id: int, pos: Vector2) -> void:
	for char in char_groups[group_id]:
		if char.hp<=0:
			continue
		char.set_mov_target(pos)

func find_nearest_enemy(char, atk_range, mode):
	var min_dist=9999
	var min_char=null
	var all_chars=[]
	if char.is_enemy==false:
		for group in char_groups:
			if group == -1:
				continue
			var b_group_far = false
			for c in char_groups[group]:
				if is_instance_valid(c)==false:
					continue
				if c.hp<=0:
					continue
				var d = c.position.distance_to(char.position)
				if d < Global.atk_dist*atk_range:
					if mode=="any":
						return c
					elif mode=="best":
						if d<min_dist:
							min_dist=d
							min_char=c
					elif mode=="all":
						all_chars.append(c)
	else:
		for c in char_groups[-1]:
			if is_instance_valid(c)==false:
				continue
			if c.hp<=0:
				continue
			var d = c.position.distance_to(char.position)
			if d < Global.atk_dist*atk_range:
				if mode=="any":
					return c
				elif mode=="best":
					if d<min_dist:
						min_dist=d
						min_char=c
				elif mode=="all":
					all_chars.append(c)
	if mode=="any":
		return null
	elif mode=="best":
		return min_char
	elif mode=="all":
		return all_chars

func remove_char(char):
	for group in char_groups:
		if char in char_groups[group]:
			char_groups[group].erase(char)
			char.queue_free()
	if char.is_enemy==false:
		ui.update_add_die()
		ui.update_player_count()

func _ready():
	for i in range(Global.level_data.size()):
		cur_level.append(-1)
		level_colors.append(i*30)
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
		char.setup(false, -1, group_center+rand_offset, self, Color.WHITE)
		char_root.add_child(char)
		agent_list.append(char.agent)
	for char in char_groups[-1]:
		char.set_group_member(agent_list)
	ui.update_player_count()
	for i in range(Global.max_group):
		proces_level(i)

func check_level_over():
	var all_done=true
	for i in Global.level_data.size():
		if cur_level[i]<Global.level_data[i].size():
			all_done=false
	return all_done

func proces_level(level_id):
	if cur_level[level_id]==Global.level_data[level_id].size()-1:
		var next_empty_level=-1
		for i in range(cur_level.size()):
			if cur_level[i]==-1:
				next_empty_level=i
				break
		level_id=next_empty_level
	if level_id==-1:
		var min_level=-1
		for i in range(cur_level.size()):
			if cur_level[i]<Global.level_data[i].size()-1:
				min_level=i
				break
		level_id=min_level
		if level_id==-1:
			return
	cur_level[level_id]=cur_level[level_id]+1
	var dat=Global.level_data[level_id][cur_level[level_id]]	
	ui.update_count_down()
	var group_center= Vector2(Global.rng.randf_range(300, Global.map_w-300), Global.rng.randf_range(600, Global.map_h-600))
	var char_list=[]
	var group_id=next_avi_group_id
	group_attacked[group_id]=0
	next_avi_group_id+=1
	char_groups[group_id]=[]
	var agent_list = []
	var group_color=Color.from_hsv(level_colors[level_id]/360.0, 0.5, 1.0) 
	for char_name in dat:
		for i in range(dat[char_name]):
			var char_scn_res=load("res://chars/"+char_name+".tscn")
			var char=char_scn_res.instantiate()
			char_groups[group_id].append(char)
			var rand_offset= Vector2(Global.rng.randf_range(-50, 50), Global.rng.randf_range(-50, 50))
			char.setup(true, group_id, group_center+rand_offset, self, group_color)
			char.level_id=level_id
			char_root.add_child(char)
			agent_list.append(char.agent)
	for char in char_groups[group_id]:
		char.set_group_member(agent_list)
	ui.update_enemy_count()

func _process(delta):
	update_step=update_step+delta
	battle_time=battle_time+delta
	if update_step>0.2:
		var move_dir=Vector2(0,0)
		if mouse_pressed:
			var x = mouse_pos.x-get_window().size.x/2.0
			var y = mouse_pos.y-get_window().size.y/2.0
			move_dir=Vector2(x, y)
			move_dir=move_dir.normalized()
		else:
			if w_pressed:
				move_dir.y-=1
			if a_pressed:
				move_dir.x-=1
			if s_pressed:
				move_dir.y+=1
			if d_pressed:
				move_dir.x+=1
		if move_dir!=Vector2(0,0):
			set_group_dir(move_dir)
		else:
			cancel_group_dir()
		ui.update_fps()
		update_step=0
		if char_groups[-1].size()>0:
			var group_center=Vector2(0, 0)
			for char in char_groups[-1]:
				group_center+=char.position
			group_center/=char_groups[-1].size()
			cam.position=group_center
		
