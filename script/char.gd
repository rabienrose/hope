extends CharacterBody2D

@export var anim_player: AnimationPlayer
@export var body: Node2D
@export var collishion: CollisionShape2D
var agent := await GSAICharacterBody2DAgent.new(self)
var target := GSAIAgentLocation.new()
var arrive := GSAIArrive.new(agent, target)
var _accel := GSAITargetAcceleration.new()

var separation: GSAISeparation
var cohesion: GSAICohesion
var proximity: GSAIInfiniteProximity
var blend := GSAIBlend.new(agent)


@export var max_hp=20
var hp=max_hp
@export var attack=10
var is_enemy=true
var ai_status="idle"
var group_id
var atk_target=null

var ai_time_step=1
var atk_time_step=0

var game

func set_mov_target(pos: Vector2) -> void:
	target.position = GSAIUtils.to_vector3(pos)
	# if ai_status!="atk":
	ai_status="move"
	anim_player.play("move")

func set_group_member(agents):
	proximity = GSAIInfiniteProximity.new(agent, agents)
	separation = GSAISeparation.new(agent, proximity)
	separation.decay_coefficient=60000
	cohesion = GSAICohesion.new(agent, proximity)
	blend.add(separation, 10)
	blend.add(cohesion, 0.1)
	blend.add(arrive, 1)

func setup(_is_enemy, _group_id, init_pos, _game) -> void:
	game=_game
	group_id=_group_id
	hp=max_hp
	agent.linear_speed_max = Global.max_spd
	agent.linear_acceleration_max = Global.max_acc
	agent.linear_drag_percentage = 0.1
	arrive.deceleration_radius = 210
	arrive.arrival_tolerance = 70
	is_enemy=_is_enemy
	position=init_pos
	agent.position = GSAIUtils.to_vector3(init_pos)
	target.position = GSAIUtils.to_vector3(init_pos)

func _ready():
	anim_player.play("idle")
	if is_enemy:
		modulate = Color(0.5, 0.5, 1)

func do_damage(atk):
	if hp-atk>0:
		hp=hp-atk
	else:
		hp=0
		if is_enemy:
			collishion.disabled=true
			anim_player.play("die")
		else:
			game.remove_char(self)
		proximity.agents.erase(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if hp<=0:
		return
	if ai_status=="move":
		blend.calculate_steering(_accel)
		
		if (agent.linear_velocity.x > 0):
			body.scale.x = -1
		elif (agent.linear_velocity.x < 0):
			body.scale.x = 1
		agent._apply_steering(_accel, delta)
		ai_time_step=ai_time_step+delta
		if ai_time_step<0.2:
			return
		ai_time_step=0
		var enemy = game.find_nearest_enemy(self)
		if enemy!=null:
			var delta_x=enemy.position.x-position.x
			if delta_x<0:
				body.scale.x = 1
			else:
				body.scale.x = -1
			atk_target=enemy
			ai_status="atk"
			anim_player.play("atk")
		var to_target = target.position - agent.position
		var distance = to_target.length()
		if distance<arrive.arrival_tolerance:
			ai_status="idle"
			anim_player.play("idle")
	
	elif ai_status=="atk":
		if atk_time_step>Global.atk_period:
			atk_time_step=0
			if atk_target!=null:
				if is_instance_valid(atk_target)==false:
					atk_target=null
					ai_status="move"
					anim_player.play("move")
					return
				else:
					if atk_target.hp<=0 or atk_target.is_enemy==false:
						atk_target=null
						ai_status="move"
						anim_player.play("move")
						return
				var d = position.distance_to(atk_target.position)
				if d>Global.atk_dist:
					atk_target=null
					ai_status="move"
					anim_player.play("move")
				else:
					atk_target.do_damage(attack)
			else:
				ai_status="move"
				anim_player.play("move")
		atk_time_step=atk_time_step+delta

	

	
