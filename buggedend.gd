extends Control


func _on_audio_stream_player_1_finished():
	$Timer.start(10)

func _on_timer_timeout():
	$AudioStreamPlayer2.play(0.0)

func _on_audio_stream_player_2_finished():
	get_tree().quit()



