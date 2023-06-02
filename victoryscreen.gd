extends Control


func _on_audio_stream_player_finished():
	$Timer.start(10)

func _on_timer_timeout():
	get_tree().quit()
