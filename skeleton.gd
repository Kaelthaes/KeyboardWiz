class_name skeleton extends Enemy

enum State {WALK_LEFT, WALK_RIGHT, WALK_UP, WALK_DOWN, DAMAGED, DYING, DEAD}
const WALKING_STATES = [State.WALK_LEFT, State.WALK_RIGHT, State.WALK_UP, State.WALK_DOWN]
var curstate = State.WALK_LEFT
var state_time = 0.0
var movevector = Vector2()
var lastdir = State.WALK_LEFT

var max_health = 100
var current_health = max_health
@onready var health_bar: ProgressBar = $healthbar/bar

func _ready():
	health_bar.max_value = max_health
	health_bar.value = max_health
	switch_to(State.WALK_LEFT)

func _physics_process(delta):
	state_time += delta
	var collide
	
	if curstate in WALKING_STATES:
		if state_time >= 4.0: 
			switch_to(WALKING_STATES[randi_range(0,3)])
			state_time = 0
		if curstate == State.WALK_LEFT:
			collide = move_and_collide(Vector2(-80,0)*delta)
			lastdir = State.WALK_LEFT
		elif curstate == State.WALK_RIGHT:
			collide = move_and_collide(Vector2(80,0)*delta)
			lastdir = State.WALK_RIGHT
		elif curstate == State.WALK_UP:
			collide = move_and_collide(Vector2(0,-80)*delta)
			lastdir = State.WALK_UP
		elif curstate == State.WALK_DOWN:
			collide = move_and_collide(Vector2(0,80)*delta)
			lastdir = State.WALK_DOWN
		if collide:
			switch_to(WALKING_STATES[randi_range(0,3)])

func switch_to(new_state: State):
	if curstate == State.DYING and new_state != State.DEAD:
		return
	if new_state == lastdir and new_state in WALKING_STATES:
		switch_to(WALKING_STATES[randi_range(0,3)])
	curstate = new_state
	
	if new_state == State.WALK_LEFT:
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.play("walkLeft")
		$AnimatedSprite2D.flip_h = true
	elif new_state == State.WALK_RIGHT:
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.play("walkRight")
		$AnimatedSprite2D.flip_h = false
	elif new_state == State.WALK_RIGHT:
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.play("walkUp")
		$AnimatedSprite2D.flip_h = false
	elif new_state == State.WALK_RIGHT:
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.play("walkDown")
		$AnimatedSprite2D.flip_h = false
	elif new_state == State.DAMAGED:
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.play("damaged")
	elif new_state == State.DYING:
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.play("dying")
	elif new_state == State.DEAD:
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	if curstate == State.DAMAGED:
		if current_health <= 0:
			switch_to(State.DYING)
		else:
			switch_to(lastdir)
	elif curstate == State.DYING:
		switch_to(State.DEAD)
		
func take_damage(damage: int):
	current_health -= damage
	health_bar.value = current_health
	switch_to(State.DAMAGED)

