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
	$MarginContainer/tooltiplabel.text = "Blink Unlocked - Use the button in the top right to view it."
	$Timer.start()

func _on_timer_timeout():
	$MarginContainer/tooltiplabel.text = ""
	queue_free()
