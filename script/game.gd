extends Node


var test_node
var char_groups={}
@export var char_scn_res: PackedScene
@export var char_root: Node2D
@export var cam: Camera2D
@export var map: Node2D
var next_avi_group_id = 0

func cam_2_world(pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * pos
	# return (cam.position+pos-Vector2(1000,600))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var pos = cam_2_world(event.position)
		set_group_mov_target(-1, pos)

func set_group_mov_target(group_id: int, pos: Vector2) -> void:
	for char in char_groups[group_id]:
		char.set_mov_target(pos)

func find_nearest_enemy(char):
	if char.is_enemy==false:
		for group in char_groups:
			if group == -1:
				continue
			var b_group_far = false
			for c in char_groups[group]:
				if c.hp<=0:
					continue
				var d = c.position.distance_to(char.position)
				if d>500:
					b_group_far=true
					break
				if d < Global.atk_dist:
					return c
			if b_group_far:
				continue
	else:
		for c in char_groups[-1]:
			var d = c.position.distance_to(char.position)
			if d < Global.atk_dist:
				return c
	return null

func remove_char(char):
	for group in char_groups:
		if char in char_groups[group]:
			char_groups[group].erase(char)
			char.queue_free()
	

func _ready():
	
	Global.map_w=map.get_map_width()
	Global.map_h=map.get_map_height()
	cam.limit_right=Global.map_w
	cam.limit_bottom=Global.map_h
	
	for i in range(5):
		var group_center= Vector2(Global.rng.randf_range(300, Global.map_w-300), Global.rng.randf_range(300, Global.map_h-300))
		var member_count=Global.rng.randi_range(1, 8)
		var group_id=next_avi_group_id
		next_avi_group_id+=1
		char_groups[group_id]=[]
		var agent_list = []
		for j in range(member_count):
			var char=char_scn_res.instantiate()
			char_groups[group_id].append(char)
			var rand_offset= Vector2(Global.rng.randf_range(-50, 50), Global.rng.randf_range(-50, 50))
			char.setup(true, group_id, group_center+rand_offset, self)
			char_root.add_child(char)
			agent_list.append(char.agent)
		for char in char_groups[group_id]:
			char.set_group_member(agent_list)
	
	var agent_list = []
	var group_center=cam.position
	char_groups[-1]=[]
	for i in range(4):
		var char=char_scn_res.instantiate()
		char_groups[-1].append(char)
		var rand_offset= Vector2(Global.rng.randf_range(-50, 50), Global.rng.randf_range(-50, 50))
		char.setup(false, -1, group_center+rand_offset, self)
		char_root.add_child(char)
		agent_list.append(char.agent)
	for char in char_groups[-1]:
		char.set_group_member(agent_list)

func _process(delta):
	var group_center=Vector2(0, 0)
	for char in char_groups[-1]:
		group_center+=char.position
	group_center/=char_groups[-1].size()
	cam.position=group_center
		
