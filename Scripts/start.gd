extends Control

@onready var player = $".."
@onready var button1 = $menu/Button1
@onready var button2 = $menu/Button2
@onready var button3 = $menu/Button3
@onready var x_button = $"../setting/TextureRect/Button"
@onready var q_button = $"../Main_UI/Tutorial/Button"
@onready var x2_button = $"../Main_UI/Tu_Panel/x/Button"
@onready var setting = $"../setting"
@onready var l_s = $"../setting/SpinBox"
@onready var tittle = $Title
@onready var menu = $menu
@onready var con = $"../Main_UI/Con"
@onready var stop = $"../Main_UI/Stop"
@onready var tutorial = $"../Main_UI/Tu_Panel"
@onready var tu_icon = $"../Main_UI/Tutorial"

var level_sound : int

func _ready() :
	l_s.value = 100
	l_s.connect("value_changed", Callable(self, "_on_spin_box_value_changed"))
	if not Engine.is_editor_hint():
		button1.pressed.connect(func(): select_choice(0))
		button2.pressed.connect(func(): select_choice(1))
		button3.pressed.connect(func(): select_choice(2))
		q_button.pressed.connect(func(): select_choice(7))
		x2_button.pressed.connect(func(): select_choice(8))
		x_button.pressed.connect(func(): select_choice(9))

func _on_spin_box_value_changed(value):
	level_sound = value
	var real_level_sound = level_sound / 5 - 10
	$starter.volume_db = real_level_sound
	$"../sword-sound".volume_db = real_level_sound
	$"../chill".volume_db = real_level_sound
	$"../death-sound".volume_db = real_level_sound
	$"../taken-sound".volume_db = real_level_sound
	$"../click-sound".volume_db = real_level_sound
	$"../recovery-sound".volume_db = real_level_sound
	$"../heart-sound".volume_db = real_level_sound
	$"../level-up".volume_db = real_level_sound
	$"../../slime/slime-taken".volume_db = real_level_sound
	$"../../slime/slime-death".volume_db = real_level_sound
	
func select_choice(index):
	$"../click-sound".play()
	if index == 0 :
		$starter.stop()
		await get_tree().create_timer(0.2).timeout 
		player.game_pause = false
		$".".visible = false
		tu_icon.visible = true
		player.game_start = true
		await get_tree().create_timer(1).timeout
		$"../chill".play()
	elif index == 1 :
		tittle.visible = false
		menu.visible = false
		setting.visible = true
		player.game_pause = true
	elif index == 2 :
		get_tree().quit()
	elif index == 7 :
		player.game_pause = true
		tutorial.visible = true
		con.visible = false
		stop.visible = false
		$"../chill".stop()
		player.play_sound()
	elif index == 8 :
		player.game_pause = false
		tutorial.visible = false
		con.visible = false
		stop.visible = true
		$"../chill".play()
		player.play_sound()
	else :
		tittle.visible = true
		menu.visible = true
		setting.visible = false
