extends Control

@onready var game_label = $spelllayout/spelllist
@onready var game_button = $toolbutton

func _ready():
	game_label.visible = false

func _on_toolbutton_button_down():
	game_label.show()


func _on_toolbutton_button_up():
	game_label.hide()
