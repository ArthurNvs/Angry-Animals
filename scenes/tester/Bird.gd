extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _pro_cess(_delta):
	pass


func _on_input_event(_viewport, event, _shape_idx):
	if event.button_mask == 1:
		position = get_global_mouse_position()
