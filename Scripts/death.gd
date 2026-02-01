extends Control

@onready var player = $".."
@onready var button1 = $Panel/TextEdit/Button
@onready var button2 = $Panel/TextEdit2/Button
@onready var time = $"../Main_UI"
@onready var con = $"../Main_UI/Con"
@onready var stop = $"../Main_UI/Stop"
@onready var tutorial = $"../Main_UI/Tutorial"
@onready var level_up = $"../Level_Up"
@onready var slime = $"../../slime"
@onready var spawner = $"../../Spawner"
@onready var sp_timer = $"../../Spawner/Timer"
@onready var end = $"../END"
var new_spawner

func _ready() :
	if not Engine.is_editor_hint():
		button1.pressed.connect(func(): select_choice(0))
		button2.pressed.connect(func(): select_choice(1))

func select_choice(index):
	$"../click-sound".play()
	if index == 0 :
		$"../chill".play()
		player.game_start = true
	sp_timer.one_shot = false
	sp_timer.autostart = false
	sp_timer.start()
	player.skill_level = [0,0,0,0,0,0,0,0]
	player.level = 0
	player.experience = 0
	player.health = 8
	player.current_dir = "down"
	player.alive = true
	player.game_pause = false
	player.can_attack = true
	player.dis_exp = 0
	player.dis_hp_inc_atk = 0
	player.dis_atk_inc_hp = 0
	player.reduce_dmg = 0
	player.invis = 0
	player.inc_camera = 0
	slime.multi_exp = 0
	level_up.as_max = false
	level_up.hr_max = false
	level_up.as_flag = 0
	level_up.hr_flag = 0
	level_up.skill_index = [0,1,2,3,4,5,6,7]
	level_up.random_skill = []
	level_up.addon_index = [0,1,2,3,4,5,6,7,8]
	level_up.random_addon = []
	spawner.amount_slime = 0
	spawner.amount_mini = 0
	spawner.amount_boss = 0
	spawner.spawn_timer = [0,0,0]
	spawner.count_normal = 0
	spawner.count_mini = 0
	spawner.count_boss = 0
	spawner.count_box = 0
	$TextEdit.visible = false
	$"../heart-sound".stop()
	clear_slime()
	player.position = Vector2(1280,1112)
	$".".visible = false
	time.minute = 0
	time.sec = 0
	stop.visible = true
	con.visible = false
	tutorial.visible = true
	end.visible = false
	player.update_stat()
	if index == 1:
		$"../Start".visible = true
		$"../Start/starter".stream.loop = true
		$"../Start/starter".play()
		player.game_start = false
		player.game_pause = true

func clear_slime():
	for child in $"../../Spawner".get_children() :
		if child.name != "Timer" :
			child.queue_free()
