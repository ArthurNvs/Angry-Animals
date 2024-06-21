extends Control


const MAIN = preload("res://scenes/main/main.tscn")


@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var attempts_label = $MarginContainer/VBoxContainer/AttemptsLabel
@onready var game_sound = $GameSound
@onready var v_box_container_2 = $MarginContainer/VBoxContainer2


# Called when the node enters the scene tree for the first time.
func _ready():
	level_label.text = "LEVEL %s" % ScoreManager.get_level_selected()
	update_attempts(0)
	SignalManager.on_score_updated.connect(update_attempts)
	SignalManager.on_level_complete.connect(on_level_complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu") == true:
		get_tree().change_scene_to_packed(MAIN)


func update_attempts(attempts: int) -> void:
	attempts_label.text = "Attempts: %s" % attempts


func on_level_complete() -> void:
	v_box_container_2.show()
	game_sound.play()
