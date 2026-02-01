extends CharacterBody2D

@onready var max_level = $Level_Up
@onready var stop_con = $Main_UI
@onready var stop = $Main_UI/Stop
@onready var tutorial = $Main_UI/Tutorial
@onready var hurt_box = $Hurt_Area
@onready var sword_wave = $Area_Hit/Sword_wave
@onready var sp_timer = $"../Spawner/Timer"
@onready var py_timer = $Timer

var skill_level : Array = [0,0,20,0,0,0,0,0] :
	get : return skill_level
	set(value) :
		skill_level = value
		update_stat()
var speed : int 
var attack : int 
var attack_speed : float 
var attack_range : float
var attack_width : float
var life_steal : float
var max_health : int 
var health : int = 8 :
	get : return health
	set(value) :
		if value <= max_health :
			health = value
		else :
			health = max_health
		$Heart.create_heart()
var regen_cooldown : int
var time_regen : int
var level : int
var max_experience : float
var experience : float :
	get : return experience
	set(value) : 
		experience = value
		level_up()
		persent_exp()
var current_dir = "down"
var alive : bool = true :
	get : return alive
	set(value) :
		alive = value
		if !alive :
			player_die()
var game_pause : bool = true :
	get : return game_pause
	set(value) :
		game_pause = value
		if !game_pause :
			sp_timer.start()
			py_timer.start()
		if game_pause :
			sp_timer.stop()
			py_timer.stop()
		if game_pause == true and alive and game_start :
			anim_pause()
var game_start : bool = false :
	get : return game_start
	set(value) :
		game_start = value
		if game_start :
			sp_timer.start()
			py_timer.start()
		else :
			sp_timer.stop()
			py_timer.stop()
var can_attack = true
var can_flag = true
var balance_speed : int
var attack_skew = false
var direct_skew = 0
var dis_exp = 0
var dis_hp_inc_atk = 0
var dis_atk_inc_hp = 0
var reduce_dmg = 0
var invis = 0
var inc_camera = 0
var wave_change = true

func _ready() :
	update_stat()
	hurt_box.area_entered.connect(hit_area)
	
func _physics_process(_delta):
	if !game_pause :
		player_movement()
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and game_start and alive:
		if event.keycode == KEY_ESCAPE :
			enter_pause()
			
func update_stat():
	speed = 100 + skill_level[3] * 10
	balance_speed = 30 + skill_level[3]
	attack = (10 + skill_level[0] * 5) * (1 + (0.5 * dis_hp_inc_atk) - (0.5 * dis_atk_inc_hp))
	attack_speed = 0.6 - skill_level[1] * 0.03
	attack_range = 1 + skill_level[2] * 2 
	attack_width = 1 + skill_level[6] * 2
	life_steal = skill_level[7] * 1.5
	max_health = (8 + level + skill_level[4] * 2) * (1 + (0.5 * dis_atk_inc_hp) - (0.5 * dis_hp_inc_atk))
	regen_cooldown = 15 - skill_level[5]
	max_experience = ((level + 1) * 2.5) - (dis_exp * 5)
	if skill_level[1] == 20:
		max_level.as_max = true
	if skill_level[5] == 14:
		max_level.hr_max = true
	if invis == 1 :
		$".".collision_mask = 1 << 1
	if inc_camera == 1 :
		$Camera2D.zoom = Vector2(2,2)
			
func player_movement():
	if alive :
		if can_attack :
			can_attack = false
			var anim = $AnimatedSprite2D
			var move = "front_attack"
			if skill_level[2] >= 8 :
				$Area_Hit/Sword_wave.visible = true
			$Area_Hit/Hit_Box.set_deferred("disabled",false)
			$"sword-sound".play()
			if current_dir == "right":
				move = "side_attack"
			elif current_dir == "left":
				anim.flip_h = true
				move = "side_attack"
			elif current_dir == "down":
				move = "front_attack"
			elif current_dir == "up":
				move = "back_attack"
			anim.play(move)
			anim.frame = 1
			await get_tree().create_timer(0.2).timeout
			$Area_Hit/Sword_wave.visible = false
			$Area_Hit/Hit_Box.set_deferred("disabled",true)
			if skill_level[1] != 20 :
				if skill_level[1] > 9 :
					await get_tree().create_timer(0.6 - (skill_level[1] - 9) * 0.05).timeout
				else :
					await get_tree().create_timer(1.5 - skill_level[1] * 0.1).timeout
				await get_tree().create_timer(attack_speed).timeout 
			can_attack = true
		elif Input.is_key_pressed(KEY_W) and Input.is_key_pressed(KEY_A):
			current_dir = "left"
			attack_skew = true
			direct_skew = 1
			play_anim(1)
			velocity.x = -speed + balance_speed
			velocity.y = -speed + balance_speed
		elif Input.is_key_pressed(KEY_W) and Input.is_key_pressed(KEY_D):
			current_dir = "right"
			attack_skew = true
			direct_skew = 1
			play_anim(1)
			velocity.x = speed - balance_speed
			velocity.y = -speed + balance_speed
		elif Input.is_key_pressed(KEY_S) and Input.is_key_pressed(KEY_D):
			current_dir = "right"
			attack_skew = true
			direct_skew = 2
			play_anim(1)
			velocity.x = speed - balance_speed
			velocity.y = speed - balance_speed
		elif Input.is_key_pressed(KEY_S) and Input.is_key_pressed(KEY_A):
			current_dir = "left"
			attack_skew = true
			direct_skew = 2
			play_anim(1)
			velocity.x = -speed + balance_speed
			velocity.y = speed - balance_speed
		elif Input.is_key_pressed(KEY_D):
			current_dir = "right"
			attack_skew = false
			direct_skew = 0
			play_anim(1)
			velocity.x = speed
			velocity.y = 0
		elif Input.is_key_pressed(KEY_A):
			current_dir = "left"
			attack_skew = false
			direct_skew = 0
			play_anim(1)
			velocity.x = -speed
			velocity.y = 0
		elif Input.is_key_pressed(KEY_S):
			current_dir = "down"
			attack_skew = false
			direct_skew = 0
			play_anim(1)
			velocity.y = speed
			velocity.x = 0
		elif Input.is_key_pressed(KEY_W):
			current_dir = "up"
			attack_skew = false
			direct_skew = 0
			play_anim(1)
			velocity.y = -speed
			velocity.x = 0
		else:
			if health > 0 :
				play_anim(0)
				velocity.x = 0
				velocity.y = 0
				$Area_Hit/Hit_Box.set_deferred("disabled",true)
			else :
				alive = false
			attack_skew = false
	move_and_slide() 

func player_die() :
	$chill.stop()
	$Hurt_Box.set_deferred("disabled",true)
	$"death-sound".play()
	$"..".modulate = Color.from_rgba8(255,255,255)
	game_pause = true
	for i in range(3) :
		$AnimatedSprite2D.play("death")
		$AnimatedSprite2D.frame = i
		await get_tree().create_timer(0.2).timeout 
	await get_tree().create_timer(0.3).timeout 
	$Death.visible = true
	$Death/TextEdit.visible = true
	$"heart-sound".stop()
	stop.visible = false
	tutorial.visible = false
	
func play_sound() :
	if !game_pause :
		if health < max_health / 3 :
			$chill.stop()
			$"heart-sound".play()
			$"..".modulate = Color.from_rgba8(255,100,120)
		else :
			$chill.play()
			$"..".modulate = Color.from_rgba8(255,255,255)
			$"heart-sound".stop()
	else :
		$"heart-sound".stop()
		
func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	var box = $Area_Hit/Hit_Box
	
	if dir == "right":
		if direct_skew != 0 :
			box.scale.x = 3 + 0.5 * attack_width
			box.scale.y = 3 + 0.5 * attack_range
			box.position.x = 10 + attack_range / 1.6
			if attack_skew and direct_skew == 1:
				box.position.y = -2 - attack_range / 1.7
				box.rotation_degrees = 45
				if skill_level[2] >= 8 :
					anim_sword_wave("RT")
			elif attack_skew and direct_skew == 2:
				box.position.y = 21 + attack_range / 1.6
				box.rotation_degrees = -45
				if skill_level[2] >= 8 :
					anim_sword_wave("RD")
		else:
			box.scale.x = 3 + 0.5 * attack_range 
			box.scale.y = 3 + 0.5 * attack_width
			box.position.x = 12 + attack_range / 1.13
			box.position.y = 10
			box.rotation_degrees = 0
			if skill_level[2] >= 8 :
				anim_sword_wave("R")
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	elif dir == "left":
		if direct_skew != 0 :
			box.scale.x = 3 + 0.5 * attack_width
			box.scale.y = 3 + 0.5 * attack_range
			box.position.x = -9 - attack_range / 1.9
			if attack_skew and direct_skew == 1:
				box.position.y = -2 - attack_range / 2
				box.rotation_degrees = -45
				if skill_level[2] >= 8 :
					anim_sword_wave("LT")
			elif attack_skew and direct_skew == 2:
				box.position.y = 21 + attack_range / 2
				box.rotation_degrees = 45
				if skill_level[2] >= 8 :
					anim_sword_wave("LD")
		else:
			box.scale.x = 3 + 0.5 * attack_range
			box.scale.y = 3 + 0.5 * attack_width
			box.position.x = -10.5 - attack_range / 1.1
			box.position.y = 10
			box.rotation_degrees = 0
			if skill_level[2] >= 8 :
				anim_sword_wave("L")
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	elif dir == "down":
		box.scale.x = 3 + 0.5 * attack_width
		box.scale.y = 3 + 0.5 * attack_range
		box.position.x = 1
		box.position.y = 21 + attack_range / 1.3
		anim.flip_h = false
		box.rotation_degrees = 0
		if skill_level[2] >= 8 :
			anim_sword_wave("D")
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
	elif dir == "up":
		box.scale.x = 3 + 0.5 * attack_width
		box.scale.y = 3 + 0.5 * attack_range
		box.position.x = 1
		box.position.y = -2.5 - attack_range / 1.3
		anim.flip_h = false
		box.rotation_degrees = 0
		if skill_level[2] >= 8 :
			anim_sword_wave("T")
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("back_idle")
	
func hit_area(area: Area2D) :
	if area.name == "Border_Area" :
		if position.x >= 2320 :
			position.x = 2318
		elif position.y >= 2040 :
			position.y = 2036
		elif position.x <= 269 :
			position.x = 275
		elif position.y <= 159 :
			position.y = 165
		taken_damage(1)
	elif "Open" in area.name :
		area.get_parent().queue_free()
		await get_tree().create_timer(0.2).timeout
		$Level_Up/Select1.visible = false
		$Level_Up/Select2.visible = false
		$Level_Up/Select3.visible = false
		$Level_Up/Select1/Button.visible = false
		$Level_Up/Select2/Button.visible = false
		$Level_Up/Select3/Button.visible = false
		$Level_Up.visible = true
		game_pause = true
		await get_tree().create_timer(0.2).timeout
		play_anim(0)
		$Level_Up/Select1.visible = true
		$Level_Up/Select2.visible = true
		$Level_Up/Select3.visible = true
		$Level_Up/Select1/Button2.visible = true
		$Level_Up/Select2/Button2.visible = true
		$Level_Up/Select3/Button2.visible = true
		$".".z_index = -1
		$Level_Up.create_select_box()

func anim_sword_wave(move) :
	if move == "R" :
		sword_wave.scale.y = 1 + 0.17 * attack_width
		sword_wave.position.x = 15
		sword_wave.position.y = 12.5
		sword_wave.rotation_degrees = 0
		sword_wave.flip_h = false
		for i in range(skill_level[2] - 7) :
			sword_wave.position.x += 2
			await get_tree().create_timer(0.05).timeout
	elif move == "RT" :
		sword_wave.scale.x = 1 + 0.17 * attack_width
		sword_wave.position.x = 22
		sword_wave.position.y = -10
		sword_wave.rotation_degrees = -45
		sword_wave.flip_h = false
		for i in range(skill_level[2] - 7) :
			sword_wave.position.x += 1.5
			sword_wave.position.y -= 1.5
			await get_tree().create_timer(0.05).timeout
	elif move == "RD" :
		sword_wave.scale.x = 1 + 0.17 * attack_width
		sword_wave.position.x = 18
		sword_wave.position.y = 33	
		sword_wave.rotation_degrees = 45
		sword_wave.flip_h = false
		for i in range(skill_level[2] - 7) :
			sword_wave.position.x += 1.5
			sword_wave.position.y += 1.5
			await get_tree().create_timer(0.05).timeout
	elif move == "L" :
		sword_wave.scale.y = 1 + 0.17 * attack_width
		sword_wave.position.x = -26
		sword_wave.position.y = 12.5
		sword_wave.rotation_degrees = 0
		sword_wave.flip_h = true
		for i in range(skill_level[2] - 7) :
			sword_wave.position.x -= 2
			await get_tree().create_timer(0.05).timeout
	elif move == "LT" :
		sword_wave.scale.x = 1 + 0.17 * attack_width
		sword_wave.position.x = -20
		sword_wave.position.y = -1
		sword_wave.rotation_degrees = 45
		sword_wave.flip_h = true
		for i in range(skill_level[2] - 7) :
			sword_wave.position.x -= 1.5
			sword_wave.position.y -= 1.5
			await get_tree().create_timer(0.05).timeout
	elif move == "LD" :
		sword_wave.scale.x = 1 + 0.17 * attack_width
		sword_wave.position.x = -16
		sword_wave.position.y = 24.5
		sword_wave.rotation_degrees = -45
		sword_wave.flip_h = true
		for i in range(skill_level[2] - 7) :
			sword_wave.position.x -= 1.5
			sword_wave.position.y += 1.5
			await get_tree().create_timer(0.05).timeout
	elif move == "T" :
		sword_wave.scale.x = 1 + 0.17 * attack_width
		sword_wave.position.x = 4.2
		sword_wave.position.y = -8.5
		sword_wave.rotation_degrees = -90
		sword_wave.flip_h = false
		for i in range(skill_level[2] - 7) :
			sword_wave.position.y -= 2
			await get_tree().create_timer(0.05).timeout
	elif move == "D" :
		sword_wave.scale.x = 1 + 0.17 * attack_width
		sword_wave.position.x = -2.3
		sword_wave.position.y = 26
		sword_wave.rotation_degrees = -270
		sword_wave.flip_h = false
		for i in range(skill_level[2] - 7) :
			sword_wave.position.y += 2
			await get_tree().create_timer(0.05).timeout
				
func taken_damage(damage):
	var real_reduce = damage if damage - reduce_dmg < 0 else reduce_dmg
	health -= (damage - real_reduce)
	play_sound()
	$Heart.create_heart()
	$"taken-sound".play()
	$Hurt_Box.set_deferred("disabled",true)
	$AnimatedSprite2D.modulate = Color.from_rgba8(251,67,75)
	await get_tree().create_timer(0.4).timeout 
	$AnimatedSprite2D.modulate = Color.from_rgba8(255,255,255)
	$Hurt_Box.set_deferred("disabled",false)

func health_regen():
	time_regen += 1
	if time_regen == regen_cooldown:
		time_regen = 0
		health += 1
		$"recovery-sound".play()
		play_sound()
		$Heart.create_heart()

func level_up():
	if experience >= max_experience :
		experience -= max_experience
		level += 1
		await get_tree().create_timer(0.5).timeout
		$chill.stop()
		$"level-up".play()
		$Level_Up/UP.visible = true
		$Level_Up/Select1.visible = false
		$Level_Up/Select2.visible = false
		$Level_Up/Select3.visible = false
		$Level_Up/Select1/Button2.visible = false
		$Level_Up/Select2/Button2.visible = false
		$Level_Up/Select3/Button2.visible = false
		$Level_Up.visible = true
		game_pause = true
		await get_tree().create_timer(1.2).timeout
		play_anim(0)
		$Level_Up/UP.visible = false
		$Level_Up/Select1.visible = true
		$Level_Up/Select2.visible = true
		$Level_Up/Select3.visible = true
		$Level_Up/Select1/Button.visible = true
		$Level_Up/Select2/Button.visible = true
		$Level_Up/Select3/Button.visible = true
		$".".z_index = -1
		$Level_Up.create_select()

func anim_pause():
		var anim_name : String
		if current_dir == "right" :
			anim_name = "side_idle"
		elif current_dir == "left" :
			anim_name = "side_idle"
			$AnimatedSprite2D.flip_h = true
		elif current_dir == "down" :
			anim_name = "front_idle"
		elif current_dir == "up" :
			anim_name = "back_idle"
		$AnimatedSprite2D.play(anim_name)
		$AnimatedSprite2D.frame = 0

func enter_pause():
	if can_flag and !$Main_UI/Tu_Panel.visible:
		can_flag = false
		play_sound()
		if stop_con.flag == 1 :
			stop_con.select_choice(2)
		else :
			stop_con.select_choice(1)
		await get_tree().create_timer(0.2).timeout
		can_flag = true 

func persent_exp() :
	var persent : float
	persent = experience / max_experience * 100
	$Main_UI/EXP.text = " ".repeat(2) + "EXP " + "%.2f" % persent + "%"
