extends CharacterBody2D

#health
@export var max_health = 10
var current_health = max_health
var minorheal = 2

#progress and casting loading
@onready var health_bar: ProgressBar = $CanvasLayer/UI/healthbar/bar
@onready var casttext: Label = $CanvasLayer/UI/castlayout/casttext
@onready var tooltiplabel: Label = $CanvasLayer/UI/spelllayout/spelllist
var tooltipstr = ""
@onready var raycast = $blinkraycast

#states
enum State {IDLE, MOVE, CAST, BLINKING, DAMAGED, DIE}
var curstate = State.IDLE
var state_time = 0.0

#movement handling
var speed = 5
var lastmovedir: Vector2 = Vector2.ZERO
var lastdir: Vector2 = Vector2.ZERO
var blink_duration = 0.25
const BLINK_DUR = 0.25
var blink_speed = 1200


#cast handling
var castdir = Vector2()
var is_blinking = false
var is_aegised = false

#state handling vars
var casting = false
var damaged = false
var invulnerable = false
var blinking = false

#collectible spell saves
var canblink = false
var canaegis = false
var canunlock = false

#spell names/loads
var fireballscene = preload("res://fireball.tscn")

#game over
var game_over_scene = preload("res://gameover.tscn")


func _ready():
	health_bar.max_value = max_health
	health_bar.value = current_health
	$AnimatedSprite2D.play("idleDown")
	tooltipupdate()
	
func _input(event):
	if event.is_action_pressed("cast"):
		switch_to(State.CAST)
	if event.is_action_pressed("a"):
		casttext.text = casttext.text + "a"
	if event.is_action_pressed("b"):
		casttext.text = casttext.text + "b"
	if event.is_action_pressed("c"):
		casttext.text = casttext.text + "c"
	if event.is_action_pressed("d"):
		casttext.text = casttext.text + "d"
	if event.is_action_pressed("e"):
		casttext.text = casttext.text + "e"
	if event.is_action_pressed("f"):
		casttext.text = casttext.text + "f"
	if event.is_action_pressed("g"):
		casttext.text = casttext.text + "g"
	if event.is_action_pressed("h"):
		casttext.text = casttext.text + "h"
	if event.is_action_pressed("i"):
		casttext.text = casttext.text + "i"
	if event.is_action_pressed("j"):
		casttext.text = casttext.text + "j"
	if event.is_action_pressed("k"):
		casttext.text = casttext.text + "k"	
	if event.is_action_pressed("l"):
		casttext.text = casttext.text + "l"
	if event.is_action_pressed("m"):
		casttext.text = casttext.text + "m"
	if event.is_action_pressed("n"):
		casttext.text = casttext.text + "n"
	if event.is_action_pressed("o"):
		casttext.text = casttext.text + "o"
	if event.is_action_pressed("p"):
		casttext.text = casttext.text + "p"
	if event.is_action_pressed("q"):
		casttext.text = casttext.text + "q"
	if event.is_action_pressed("r"):
		casttext.text = casttext.text + "r"
	if event.is_action_pressed("s"):
		casttext.text = casttext.text + "s"
	if event.is_action_pressed("t"):
		casttext.text = casttext.text + "t"
	if event.is_action_pressed("u"):
		casttext.text = casttext.text + "u"
	if event.is_action_pressed("v"):
		casttext.text = casttext.text + "v"
	if event.is_action_pressed("w"):
		casttext.text = casttext.text + "w"
	if event.is_action_pressed("x"):
		casttext.text = casttext.text + "x"
	if event.is_action_pressed("y"):
		casttext.text = casttext.text + "y"
	if event.is_action_pressed("z"):
		casttext.text = casttext.text + "z"
	if event.is_action_pressed("ui_select"):
		casttext.text = casttext.text + " "
	if event.is_action_pressed("'"):
		casttext.text = casttext.text + "'"
	if event.is_action_pressed(","):
		casttext.text = casttext.text + ","
	if event.is_action_pressed("ui_text_backspace"):
		var text = casttext.text
		text = text.left(text.length() - 1)
		casttext.text = text
	
func switch_to(new_state: State):
	if casting or damaged:
		return
	curstate = new_state
	state_time = 0.0
	
	if new_state == State.IDLE:
		if lastmovedir.x > 0:
			$AnimatedSprite2D.play("idle")
			$AnimatedSprite2D.flip_h = false
		elif lastmovedir.x < 0:
			$AnimatedSprite2D.play("idle")
			$AnimatedSprite2D.flip_h = true
		elif lastmovedir.y > 0:
			$AnimatedSprite2D.play("idleDown")
			$AnimatedSprite2D.flip_h = false
		elif lastmovedir.y < 0:
			$AnimatedSprite2D.play("idleUp")
			$AnimatedSprite2D.flip_h = false 
	elif new_state == State.CAST:
		casting = true
		if lastmovedir.x > 0:
			$AnimatedSprite2D.play("cast")
			$AnimatedSprite2D.flip_h = false
			castdir = Vector2(1,0)
		elif lastmovedir.x < 0:
			$AnimatedSprite2D.play("cast")
			$AnimatedSprite2D.flip_h = true
			castdir = Vector2(-1,0)
		elif lastmovedir.y > 0:
			$AnimatedSprite2D.play("castDown")
			$AnimatedSprite2D.flip_h = false
			castdir = Vector2(0,1)
		elif lastmovedir.y < 0:
			$AnimatedSprite2D.play("castUp")
			$AnimatedSprite2D.flip_h = false 
			castdir = Vector2(0,-1)
		spell_check()
	elif new_state == State.MOVE:
		update_movement_animation()
	elif new_state == State.DAMAGED:
		$AnimatedSprite2D.play("damaged")
		damaged = true
	elif new_state == State.DIE:
		$AnimatedSprite2D.play("die")
		
	

func spell_check():
	#possible spells
	if casttext.text == "fire":
		launch_fireball(castdir)
	elif casttext.text == "blink" and canblink:
		blink()
	elif casttext.text == "aegis of ages":
		aegis()
	elif casttext.text == "lay on hands":
		heal()
		#do the move
		#possibly raycast to point and return if it's not allowed?
		
		
	#reset
	casttext.text = ""


func update_movement_animation():
	if curstate == State.MOVE:
		if lastmovedir.x > 0:
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = false
		elif lastmovedir.x < 0:
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = true
		elif lastmovedir.y > 0:
			$AnimatedSprite2D.play("walkDown")
			$AnimatedSprite2D.flip_h = false
		elif lastmovedir.y < 0:
			$AnimatedSprite2D.play("walkUp")
			$AnimatedSprite2D.flip_h = false

func _physics_process(delta):
	var dir = Vector2.ZERO
	
	#cast is first in priority
	if Input.is_action_just_pressed("cast"):
		switch_to(State.CAST)
		# walking
	if Input.is_action_pressed("ui_up"):
		dir.y = -1
		switch_to(State.MOVE)
	elif Input.is_action_pressed("ui_down"):
		dir.y = 1	
		switch_to(State.MOVE)
	elif Input.is_action_pressed("ui_left"):
		dir.x = -1	
		switch_to(State.MOVE)
	elif Input.is_action_pressed("ui_right"):
		dir.x = 1
		switch_to(State.MOVE)
	else:
		switch_to(State.IDLE)

	move_and_collide(dir * speed)	
	lastdir = dir	
	if dir.length() > 0:
		lastmovedir = dir
	
	# Keep track of how long we spent in the current state so far
	state_time += delta

func _on_animated_sprite_2d_animation_finished():
	if curstate == State.CAST:
		casting = false
		switch_to(State.IDLE)
	if curstate == State.DAMAGED:
		damaged = false
		if current_health <= 0:
			switch_to(State.DIE)
		else:
			switch_to(State.IDLE)
	if curstate == State.DIE:
		game_over()
		queue_free()
		
func take_damage(damage: int):
	if !invulnerable:
		if is_aegised:
			is_aegised = false
		else:
			current_health -= damage
			health_bar.value = current_health
			switch_to(State.DAMAGED)

func launch_fireball(launchdir):
	var fireballspell = fireballscene.instantiate()
	fireballspell.position = position
	fireballspell.dir = launchdir
	get_parent().add_child(fireballspell)
	
func blink():
	invulnerable = true
	is_blinking = true
	raycast.enabled = true
	var blink_distance = blink_speed * BLINK_DUR
	if lastmovedir.x > 0:
		$AnimatedSprite2D.play("blinkRight")
		$AnimatedSprite2D.flip_h = false
		raycast.target_position = Vector2(blink_distance, 0)  # Blink right
	elif lastmovedir.x < 0:
		$AnimatedSprite2D.play("blinkLeft")
		$AnimatedSprite2D.flip_h = false
		raycast.target_position = Vector2(-blink_distance, 0)  # Blink left
	elif lastmovedir.y > 0:
		$AnimatedSprite2D.play("blinkDown")
		$AnimatedSprite2D.flip_h = false
		raycast.target_position = Vector2(0, blink_distance)  # Blink down
	elif lastmovedir.y < 0:
		$AnimatedSprite2D.play("blinkUp")
		$AnimatedSprite2D.flip_h = false
		raycast.target_position = Vector2(0, -blink_distance)  # Blink 
	raycast.force_raycast_update() #this is needed to handle a bug
	var blink_destination = raycast.get_collision_point() if raycast.is_colliding() else global_position + raycast.target_position
	var actual_distance = blink_destination.distance_to(global_position)
	var distance_percentage = actual_distance / blink_distance
	blink_duration = BLINK_DUR * distance_percentage
	var blink_tween = create_tween()  # Instantiate a new Tween node
	blink_tween.tween_property(self, "position", blink_destination, blink_duration)
	blink_tween.set_trans(Tween.TRANS_QUART)
	blink_tween.finished.connect(_on_blink_tween_completed)
	blink_tween.play()
func _on_blink_tween_completed():
	invulnerable = false
	is_blinking = false
	raycast.enabled = false

func heal():
	print("healed")
	current_health += minorheal
	health_bar.value = current_health
	

func aegis():
	is_aegised=true
	print(is_aegised)

func unlock():
	pass
	
func game_over():
	var game_over_instance = game_over_scene.instantiate()
	get_tree().root.add_child(game_over_instance)

func _on_collectbox_body_entered(body):
	if body.has_method("collect"):
		body.collect()
		if body.name == 'blinkscroll':
			canblink = true
		if body.name == 'aegisscroll':
			canaegis = true
		tooltipupdate()
		
func tooltipupdate():
	tooltipstr = ""
	
	tooltipstr += "How to play:
		Type out your spell, then use TAB or ENTER keys to cast spells. Find your way out!\n\n"
	
	tooltipstr += "Attack Spells:\n"
	tooltipstr += "Fireball:
		Casting text: 'fire'
		A basic attack spell that hurls a fireball in the direction your facing.\n"
	
	
	#utilities
	tooltipstr += "\nUtility Spells:\n"
	#shield
	if canaegis:
		tooltipstr += "\tAegis:
			Casting text: 'aegis of ages'
			A spell that cloaks you in a golden shield, blocking any hit once before breaking.\n"
	else:
		tooltipstr += "Aegis:
			??????\n"
	#blink
	if canblink:
		tooltipstr += "\tBlink:
			Casting text: 'blink'
			A spell that warps you forward a short distance, ignoring obstacles and enemies in the way.\n"
	else:
		tooltipstr += "Blink:
			??????\n"
	#heal
	tooltipstr += "\tMinor Heal:
		Casting text: 'lay on hands'
		A spell that eases your injures by calling the light of life into your body.\n"
	#unlock
	if canunlock:
		tooltipstr += "\tUnlock Door:
			Casting text: 'unlock'
			A spell capable of unlocking any non-magical door.\n"
	else:
		tooltipstr += "Unlock:
			??????\n"
	
	tooltiplabel.text = tooltipstr
	
	
	
	
