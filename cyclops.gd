class_name cyclops extends Enemy

enum State {IDLE, MOVE, ATTACK, DAMAGED, DIE}
var curstate = State.IDLE

var speed = 5  # The speed of the enemy
var player  # The player the enemy is chasing
var move_horizontally = true  # To alternate between horizontal and vertical movement
var active = false
var lastmovedir: Vector2 = Vector2.ZERO
var damage = 4
var statetime = 0.0

var max_health = 300
var current_health = max_health
@onready var health_bar: ProgressBar = $healthbar/bar

func _ready():
	player = get_node('/root/Floor1/Character')
	health_bar.max_value = max_health
	health_bar.value = max_health
	switch_to(State.IDLE)

func switch_to(new_state : State):
	curstate = new_state
	if new_state == State.IDLE:
		$AnimatedSprite2D.play("idle")
	if new_state == State.MOVE:
		$AnimatedSprite2D.play("walkDown")
	if new_state == State.DAMAGED:
		$AnimatedSprite2D.play("hitDown")
	if new_state == State.DIE:
		$AnimatedSprite2D.play("die")
	if new_state == State.ATTACK:
		var direction = player.global_position - global_position
		direction = direction.normalized()
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				direction = Vector2(1, 0)  # Right
				$AnimatedSprite2D.play("attackRight")
			else:
				direction = Vector2(-1, 0)  # Left
				$AnimatedSprite2D.play("attackLeft")
		else:
			if direction.y > 0:
				direction = Vector2(0, 1)  # Down
				$AnimatedSprite2D.play("attackDown")
			else:
				direction = Vector2(0, -1)  # Up
				$AnimatedSprite2D.play("attackUp")

#basically, if it gets within 2000 pixels of you, it activates and chases you until you die
func _physics_process(delta):
	statetime += delta
	var direction = player.global_position - global_position
	if curstate == State.IDLE:
		if direction.distance_to(Vector2(0,0)) < 500:
			switch_to(State.MOVE)	
	if curstate == State.MOVE:
		direction = direction.normalized()  # Normalize the direction
		if abs(direction.x) > 0.97 and abs(direction.x) < 1.03:
			move_horizontally = true
			statetime = 0
		elif abs(direction.y) > 0.97 and abs(direction.y) < 1.03:
			move_horizontally = false
			statetime = 0
		elif statetime > 1.5:
			move_horizontally = not move_horizontally
			statetime = 0
			
		if move_horizontally:
			if direction.x > 0:
				direction = Vector2(1, 0)  # Right
				$AnimatedSprite2D.play("walkRight")
			else:
				direction = Vector2(-1, 0)  # Left
				$AnimatedSprite2D.play("walkLeft")
		else:
			if direction.y > 0:
				direction = Vector2(0, 1)  # Down
				$AnimatedSprite2D.play("walkDown")
			else:
				direction = Vector2(0, -1)  # Up
				$AnimatedSprite2D.play("walkUp")
		lastmovedir = direction
		move_and_collide(direction * speed)

func _on_attackbox_body_entered(body):
	if body.name == "Character":
		body.take_damage(damage)
		switch_to(State.ATTACK)
		
func take_damage(damage: int):
	if curstate != State.DIE:
		current_health -= damage
		health_bar.value = current_health
		switch_to(State.DAMAGED)

func _on_animated_sprite_2d_animation_finished():
	if curstate == State.DAMAGED:
		if current_health <= 0:
			switch_to(State.DIE)
		else:
			switch_to(State.MOVE)
	if curstate == State.ATTACK:
		switch_to(State.MOVE)
	if curstate == State.DIE:
		queue_free()
