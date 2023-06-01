extends CharacterBody2D
#load character for access
var character = preload("res://character.gd")
@onready var animation = $AnimationPlayer.get_animation('rise')
var collected = false

func collect():
	if !collected:
		$AnimationPlayer.play("rise")
		collected = true

func _on_animation_player_animation_finished(anim_name):
	$MarginContainer/tooltiplabel.text = "You have now unlocked the spell 'Blink'
	Type 'blink' to cast it, and teleport in the direction you're facing!"
	$Timer.start()

func _on_timer_timeout():
	$MarginContainer/tooltiplabel.text = ""
	queue_free()
