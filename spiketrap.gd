extends Node2D
var damage = 3
enum State {SIT, STAB}
var curstate = State.SIT
var active = false
func _ready():
	$AnimatedSprite2D.play("sit")
	
func _on_hurtbox_body_entered(body):
	if body.has_method("take_damage"):
		if active:
			if body.name == "Character":
				body.take_damage(damage)
			else:
				body.take_damage = 50


func _on_animated_sprite_2d_animation_finished():
	if curstate == State.SIT:
		$AnimatedSprite2D.play("stab")
		active = true
		curstate = State.STAB
		if $hurtbox.has_overlapping_bodies():
			for body in $hurtbox.get_overlapping_bodies():
				if body.has_method("take_damage"):
					if body.name == "Character":
						body.take_damage(damage)
					else:
						body.take_damage = 50
		
	elif curstate == State.STAB:
		$AnimatedSprite2D.play("sit")
		active = false
		curstate = State.SIT
		
		



