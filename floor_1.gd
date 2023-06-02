extends Node2D
var victoryscene = preload("res://victoryscreen.tscn")
var endscene = preload("res://buggedend.tscn")

func _on_outofbounds_body_entered(body):
	var end = endscene.instantiate()
	add_child(end)
	$outofbounds.queue_free()
	end.visible = true


func _on_victorytrigger_body_entered(body):
	$Character/box.queue_free()
	$Character/collectbox.queue_free()
	$Character/CanvasLayer/UI.visible = false
	$Character/CanvasLayer/victoryscreen.visible = true
	$Character/CanvasLayer/victoryscreen/AudioStreamPlayer.play()
	
