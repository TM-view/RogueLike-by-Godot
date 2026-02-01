extends Control

@onready var player = $".."
@onready var slime = $"../../slime"
@onready var text1 = $Select1/TextEdit
@onready var text2 = $Select2/TextEdit
@onready var text3 = $Select3/TextEdit
@onready var button1 = $Select1/Button
@onready var button2 = $Select2/Button
@onready var button3 = $Select3/Button
@onready var button4 = $Select1/Button2
@onready var button5 = $Select2/Button2
@onready var button6 = $Select3/Button2
@onready var pic1 = $Select1/TextureRect
@onready var pic2 = $Select2/TextureRect
@onready var pic3 = $Select3/TextureRect
@onready var heart = get_tree().root.get_node_or_null("world/Player/Heart")

const max_char = 18
const skill_name = ["Fury","Accelerate","Slender","Celerity","Endurance","Recovery","Catholic"," Sanguinary"]
const skill_description = ["    Little enchances \n       attack power","    Slash cooldown \n          reduced",
"   Your sword is a \n        little longer","  Run a little faster","Little more Health",
"   Wound recovery \n             faster", "   Empower sword\n make attack wider","     Your bloodlust\n          increases"]
var skill_index = [0,1,2,3,4,5,6,7]
const skill_pic = [18,20,25,35,12,24,33,30] 
var random_skill = []
var as_max = false
var hr_max = false
var as_flag = 0
var hr_flag = 0
const skill_pic_paths = {
	18: preload("res://Arts/Other/skill_icon/Icon18.png"),
	20: preload("res://Arts/Other/skill_icon/Icon20.png"),
	25: preload("res://Arts/Other/skill_icon/Icon25.png"),
	35: preload("res://Arts/Other/skill_icon/Icon35.png"),
	12: preload("res://Arts/Other/skill_icon/Icon12.png"),
	24: preload("res://Arts/Other/skill_icon/Icon24.png"),
	33: preload("res://Arts/Other/skill_icon/Icon33.png"),
	30: preload("res://Arts/Other/skill_icon/Icon30.png"),
}
var addon_index = [0,1,2,3,4,5,6,7,8]
const addon_pic = [1,2,38,39,26,21,46,22,24] 
const addon_name = ["ExpGain","LessLevelUp","I AM Atomic","HotBlood","HolySoul","Armor","WindWalk","HawkEye","Blessing"]
const addon_description = ["         Get More\n        Experience","    Less Experience\n         to level up",
						"    I AM ATOMIC !!!","   Rise Attack 50%\n  Down Health 50%","   Rise Health 50%\n  Down Attack 50%",
						"   Reduce Damage\n             Taken"," Can Walk Through\n         Obstacles",
						"       Your view is\n            further","   All your wounds\n         are healed"]
var random_addon = []
const addon_pic_paths = {
	1: preload("res://Arts/Other/skill_icon/Icon1.png"),
	2: preload("res://Arts/Other/skill_icon/Icon2.png"),
	38: preload("res://Arts/Other/skill_icon/Icon38.png"),
	39: preload("res://Arts/Other/skill_icon/Icon39.png"),
	26: preload("res://Arts/Other/skill_icon/Icon26.png"),
	21: preload("res://Arts/Other/skill_icon/Icon21.png"),
	46: preload("res://Arts/Other/skill_icon/Icon46.png"),
	22: preload("res://Arts/Other/skill_icon/Icon22.png"),
	24: preload("res://Arts/Other/skill_icon/Icon24.png")
}

func _ready() :
	button1.pressed.connect(func(): select_choice(0))
	button2.pressed.connect(func(): select_choice(1))
	button3.pressed.connect(func(): select_choice(2))
	button4.pressed.connect(func(): select_box_choice(0))
	button5.pressed.connect(func(): select_box_choice(1))
	button6.pressed.connect(func(): select_box_choice(2))
	
func create_select() :
	if as_flag == 0 :
		if as_max :
			as_flag = 1
			skill_index.erase(1)
	if hr_flag == 0 :
		if hr_max :
			hr_flag = 1
			skill_index.erase(5)
	
	skill_index.shuffle()
	random_skill = skill_index.slice(0,3)
	for i in range(3) :
		var lvl 
		if random_skill[i] == 1 and player.skill_level[random_skill[i]] == 19 :
			lvl = " MAX"
		elif random_skill[i] == 5 and player.skill_level[random_skill[i]] == 13 :
			lvl = " MAX"
		else :
			lvl = str(player.skill_level[random_skill[i]])
		var name_of_skill = skill_name[random_skill[i]] + " Lv" + lvl
		var index_pic = skill_pic_paths.get(skill_pic[random_skill[i]], null)
		var descrip = text_center(name_of_skill) + " ".repeat(8) + "description\n" + skill_description[random_skill[i]]
		if i == 0:
			text1.text = descrip
			pic1.texture = index_pic
		elif i == 1:
			text2.text = descrip
			pic2.texture = index_pic
		else:
			text3.text = descrip
			pic3.texture = index_pic
			
func select_choice(index) :
	$"../click-sound".play()
	player.skill_level[random_skill[index]] += 1
	if random_skill[index] == 4 :
		player.health += 2
	await get_tree().create_timer(0.2).timeout  
	player.game_pause = false
	$".".visible = false
	player.z_index = 0
	player.health += 1
	$"../recovery-sound".play()
	player.play_sound()
	$".."/Heart.create_heart()
	
func text_center(text):
	var space = (max_char - text.length())
	return " ".repeat(space) + text + "\n"

func create_select_box() :
	if player.dis_hp_inc_atk == 1 :
		addon_index.erase(3)
	if player.dis_atk_inc_hp == 1 :
		addon_index.erase(4)
	if player.invis == 1 :
		addon_index.erase(6)
	if player.inc_camera == 1 :
		addon_index.erase(7)
		
	addon_index.shuffle()
	random_addon = addon_index.slice(0,3)
	for i in range(3) :
		var name_of_addon
		if random_addon[i] == 0 :
			name_of_addon = addon_name[random_addon[i]] + " Lv" + str(slime.multi_exp)
		elif random_addon[i] == 1 :
			name_of_addon = addon_name[random_addon[i]] + " Lv" + str(player.dis_exp)
		elif random_addon[i] == 2 or random_addon[i] == 8:
			name_of_addon = addon_name[random_addon[i]]
		elif random_addon[i] == 3 or random_addon[i] == 4 or random_addon[i] == 6 or random_addon[i] == 7:
			name_of_addon = addon_name[random_addon[i]] + " Lv MAX"
		elif random_addon[i] == 5 :
			name_of_addon = addon_name[random_addon[i]] + " Lv " + str(player.reduce_dmg)
			
		var box_index_pic = addon_pic_paths.get(addon_pic[random_addon[i]], null)
		var descrip = text_center(name_of_addon) + " ".repeat(8) + "description\n" + addon_description[random_addon[i]]
		if i == 0:
			text1.text = descrip
			pic1.texture = box_index_pic
		elif i == 1:
			text2.text = descrip
			pic2.texture = box_index_pic
		else:
			text3.text = descrip
			pic3.texture = box_index_pic

func select_box_choice(index) :
	$"../click-sound".play()
	await get_tree().create_timer(0.2).timeout 
	if random_addon[index] == 0 :
		slime.multi_exp += 1
	elif random_addon[index] == 1 :
		player.dis_exp += 1
	elif random_addon[index] == 2 :
		slime.boombastic()
	elif random_addon[index] == 3 :
		player.dis_hp_inc_atk += 1
		$"../taken-sound".play()
		$".."/Heart.create_heart()
	elif random_addon[index] == 4 :
		player.dis_atk_inc_hp += 1
		player.health += player.health / 2
		$"../recovery-sound".play()
		$".."/Heart.create_heart()
	elif random_addon[index] == 5 :
		player.reduce_dmg += 1
	elif random_addon[index] == 6 :
		player.invis += 1
	elif random_addon[index] == 7 :
		player.inc_camera += 1
	elif random_addon[index] == 8 :
		player.health += player.max_health - player.health 
		$"../recovery-sound".play()
		$".."/Heart.create_heart()
	player.game_pause = false
	$".".visible = false
	player.play_sound()
	player.z_index = 0
	player.update_stat()
