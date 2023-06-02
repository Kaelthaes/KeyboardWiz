extends CharacterBody2D
enum State {FLIGHT,EXPLODE}
@export var explosion_damage: int = 150
@onready var animation: AnimatedSprite2D = $img
var dir = Vector2()
var speed = 1000
var curstate = State.FLIGHT

func _ready():
	animation.play("flight")
	self.scale = Vector2(1,1)
	
func _physics_process(delta):
	if dir == Vector2(1,0):
		rotation_degrees=0
	elif dir == Vector2(-1,0):
		rotation_degrees=180
	elif dir == Vector2(0,1):
		rotation_degrees=90
	elif dir == Vector2(0,-1):
		rotation_degrees=270
	move_and_collide(dir * speed * delta)

func switch_to(new_state: State):
	curstate=new_state
	if new_state == State.EXPLODE:
		speed = 0
		animation.play("explosion")
		self.scale = Vector2(3,3)
		animation.offset.x = 2
		animation.offset.y = 8
		$Area2D/flight.queue_free()
		
func _on_area_2d_body_entered(body):
	if curstate == State.FLIGHT:
		switch_to(State.EXPLODE)
	if curstate == State.EXPLODE:
		if body.has_method("take_damage"):
			body.take_damage(explosion_damage)
		


func _on_img_animation_finished():
	if curstate == State.EXPLODE:
		queue_free()
