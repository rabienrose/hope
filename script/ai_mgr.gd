extends Node

@export var game: Node2D


var cul_time=0

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cul_time=cul_time+delta
	if cul_time>1:
		cul_time=0
	else:
		return
	if game.char_groups[-1].size()==0:
		get_tree().change_scene_to_file("res://main.tscn")
	var enemy_num=0
	for group_id in game.char_groups:
		if group_id!=-1:
			enemy_num+=game.char_groups[group_id].size()
	if enemy_num==0:
		game.ui.show_win_count(game.char_groups[-1].size())
	for group_id in game.char_groups:
		var has_idle_char = false
		var all_die=true
		for char in game.char_groups[group_id]:
			if char.is_enemy and char.ai_status == "idle":
				has_idle_char=true
			if char.is_enemy and char.hp>0:
				all_die=false
		if group_id!=-1 and game.char_groups[group_id].size()>0 and all_die:
			var agents=game.char_groups[-1][0].proximity.agents
			var char_level_id=-1
			for char in game.char_groups[group_id]:
				char_level_id=char.level_id
				char.agent.linear_speed_max = char.agent.linear_speed_max*Global.player_spd_rate
				char.agent.linear_acceleration_max = char.agent.linear_acceleration_max*Global.player_spd_rate
				char.group_id=-1
				char.hp=char.max_hp
				char.is_enemy=false
				char.collishion.disabled=false
				char.ai_status="idle"
				char.anim_player.play("RESET")
				char.proximity.agents=agents
				char.modulate = Color(1, 1, 1)
				agents.append(char.agent)
				game.char_groups[-1].append(char)
			game.char_groups[group_id]=[]
			game.ui.update_enemy_count()
			game.ui.update_player_count()
			game.cam.add_trauma(1)
			game.proces_level(char_level_id)

		if has_idle_char and game.group_attacked[group_id]==0:
			var group_center = Vector2(Global.rng.randf_range(300, Global.map_w-300), Global.rng.randf_range(300, Global.map_h-300))
			game.set_group_mov_target(group_id, group_center)
	
	for group_id in game.group_attacked:
		var attacked_time=game.group_attacked[group_id]
		if attacked_time>0 and game.battle_time-attacked_time>=3:
			game.group_attacked[group_id]=0
			for char in game.char_groups[group_id]:
				if char.hp<=0:
					continue
				char.ai_status="idle"
				char.anim_player.play("RESET")
