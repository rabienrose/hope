extends CharacterBody2D

@export var anim_player: AnimationPlayer
@export var body: Node2D
@export var collishion: CollisionShape2D
@export var char_name=""
@export var die_fx: PackedScene
@export var hp_bar: TextureProgressBar
var agent := await GSAICharacterBody2DAgent.new(self)
var target := GSAIAgentLocation.new()
var arrive := GSAIArrive.new(agent, target)
var _accel := GSAITargetAcceleration.new()


var separation: GSAISeparation
var cohesion: GSAICohesion
var proximity: GSAIInfiniteProximity
var blend := GSAIBlend.new(agent)



var max_hp=20
var hp=max_hp
var attack=10
var atk_range=1
var is_enemy=true
var ai_status="idle"
var group_id
var atk_target=null

var ai_time_step=1
var atk_time_step=0

var game
var in_hit_effect=false
var hit_effect_delay=0
var die_fx_obj=null
var only_apperance=false
var last_tar_time=0

func switch_anim(anim_name):
	anim_player.play("RESET")
	anim_player.queue(anim_name)

func set_mov_target(pos: Vector2) -> void:
	target.position = GSAIUtils.to_vector3(pos)
	# if ai_status!="atk":
	ai_status="move"
	switch_anim("move")
	last_tar_time=game.battle_time

func set_group_member(agents):
	proximity = GSAIInfiniteProximity.new(agent, agents)
	separation = GSAISeparation.new(agent, proximity)
	separation.decay_coefficient=60000
	cohesion = GSAICohesion.new(agent, proximity)
	blend.add(separation, Global.char_data[char_name]["sep"])
	# blend.add(cohesion, 0.1)
	blend.add(arrive, 1)

func setup(_is_enemy, _group_id, init_pos, _game) -> void:
	var info=Global.char_data[char_name]
	max_hp=info["hp"]
	if char_name=="cat":
		hp=10
	else:
		hp=max_hp
	attack=info["atk"]
	atk_range=info["range"]
	is_enemy=_is_enemy
	game=_game
	group_id=_group_id
	agent.linear_speed_max = Global.max_spd*info["spd"]
	agent.linear_acceleration_max = Global.max_acc*info["spd"]
	if is_enemy==false:
		agent.linear_speed_max = agent.linear_speed_max*Global.player_spd_rate
		agent.linear_acceleration_max = agent.linear_acceleration_max*Global.player_spd_rate
	agent.linear_drag_percentage = 0.1
	arrive.deceleration_radius = 210
	arrive.arrival_tolerance = 70
	
	position=init_pos
	agent.position = GSAIUtils.to_vector3(init_pos)
	target.position = GSAIUtils.to_vector3(init_pos)

func _ready():
	anim_player.play("RESET")
	if is_enemy:
		modulate = game.group_color[group_id]

func play_die_fx():
	die_fx_obj =die_fx.instantiate()
	die_fx_obj.position=position
	get_parent().add_child(die_fx_obj)
	die_fx_obj.get_node("AnimationPlayer").animation_finished.connect(test_cb)
	die_fx_obj.get_node("AnimationPlayer").play("play")

func test_cb(a_name):
	if die_fx_obj!=null and is_instance_valid(die_fx_obj):
		die_fx_obj.queue_free()

func do_damage(atk, attacker):
	if hp<=0:
		return
	body.modulate=Color(1, 0.7, 0.7, 1)
	in_hit_effect=true
	if hp-atk>0:
		hp=hp-atk
		if Global.char_data[char_name]["assist"]:
			if is_enemy:
				if game.group_attacked[group_id]==0:
					game.set_group_mov_target(group_id, attacker.position)
				game.group_attacked[group_id]=game.battle_time
	else:
		hp=0
		play_die_fx()
		if is_enemy:
			collishion.disabled=true
			switch_anim("die")
		else:
			game.remove_char(self)
		proximity.agents.erase(agent)

func shot(dir):
	pass

func heal(tar):
	if tar.hp>0 and tar.hp<tar.max_hp:
		tar.hp=tar.hp+attack
		if tar.hp>tar.max_hp:
			tar.hp=tar.max_hp
		tar.body.modulate=Color(0.7, 0.7, 1.0, 1)
		tar.in_hit_effect=true

func find_heal_tar():
	var group_members=game.char_groups[group_id]
	var min_hp=9999
	var min_hp_char=null
	for char in group_members:
		if char.hp<min_hp and char.hp>0:
			min_hp=char.hp
			min_hp_char=char
	if min_hp_char!=null and min_hp_char.hp<min_hp_char.max_hp and min_hp_char.position.distance_to(position)<Global.atk_dist*atk_range:
		return min_hp_char
	else:
		return null
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if only_apperance:
		return
	hit_effect_delay=hit_effect_delay+delta
	if hit_effect_delay>0.5:
		hit_effect_delay=0
		if in_hit_effect:
			in_hit_effect=false
			body.modulate=Color(1, 1, 1, 1)
	if hp<=0:
		return
	if ai_status=="move":
		blend.calculate_steering(_accel)
		if (agent.linear_velocity.x > 0):
			body.scale.x = -1
		elif (agent.linear_velocity.x < 0):
			body.scale.x = 1
		agent._apply_steering(_accel, delta)
		var to_target = target.position - agent.position
		var distance = to_target.length()
		if distance<arrive.arrival_tolerance or game.battle_time-last_tar_time>10:
			ai_status="idle"
			anim_player.play("RESET")
	if ai_status=="move" or ai_status=="idle":
		ai_time_step=ai_time_step+delta
		if ai_time_step<0.2:
			return
		ai_time_step=0
		var enemy
		if char_name=="ghost":
			enemy=find_heal_tar()
		else:
			enemy = game.find_nearest_enemy(self, atk_range)
		if enemy!=null:
			var delta_x=enemy.position.x-position.x
			if delta_x<0:
				body.scale.x = 1
			else:
				body.scale.x = -1
			atk_target=enemy
			ai_status="atk"
			switch_anim("attack")
	elif ai_status=="atk":
		if atk_time_step>Global.atk_period:
			atk_time_step=0
			if atk_target!=null:
				if is_instance_valid(atk_target)==false:
					atk_target=null
					ai_status="move"
					switch_anim("move")
					return
				else:
					if atk_target.hp<=0:
						atk_target=null
						ai_status="move"
						switch_anim("move")
						return
					if char_name!="ghost" and atk_target.is_enemy==is_enemy or char_name=="ghost" and atk_target.is_enemy!=is_enemy:
						atk_target=null
						ai_status="move"
						switch_anim("move")
						return
				var d = position.distance_to(atk_target.position)
				if d>Global.atk_dist*atk_range:
					atk_target=null
					ai_status="move"
					switch_anim("move")
				else:
					
					if char_name=="ghost":
						if atk_target.hp<atk_target.max_hp:
							heal(atk_target)
						else:
							atk_target=null
							ai_status="move"
							switch_anim("move")
					elif char_name=="fish":
						var dir=atk_target.position-position
						dir=dir.normalized()
						shot(dir)
					else:
						atk_target.do_damage(attack, self)
			else:
				ai_status="move"
				switch_anim("move")
		atk_time_step=atk_time_step+delta

	

	
