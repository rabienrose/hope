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
	
	for group_id in game.char_groups:
		var has_idle_char = false
		var all_die=true
		for char in game.char_groups[group_id]:
			if char.is_enemy and char.ai_status == "idle":
				has_idle_char=true
			if char.is_enemy and char.hp>0:
				all_die=false
		if group_id!=-1 and all_die:
			var agents=game.char_groups[-1][0].proximity.agents
			for char in game.char_groups[group_id]:
				char.group_id=-1
				char.hp=char.max_hp
				char.is_enemy=false
				char.collishion.disabled=false
				char.ai_status="idle"
				char.anim_player.play("idle")
				char.proximity.agents=agents
				char.modulate = Color(1, 1, 1)
				agents.append(char.agent)
				game.char_groups[-1].append(char)
			game.char_groups.erase(group_id)
		if has_idle_char:
			var group_center = Vector2(Global.rng.randf_range(300, Global.map_w-300), Global.rng.randf_range(300, Global.map_h-300))
			game.set_group_mov_target(group_id, group_center)
