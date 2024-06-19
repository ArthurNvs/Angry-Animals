extends RigidBody2D


# Creates a coordinate limit box
const DRAG_LIM_MAX: Vector2 = Vector2(0, 60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60, 0)
# Multiplier for bird's impulse
const IMPULSE_MULT: float = 16.0
const IMPULSE_MAX: float = 1200.0


enum ANIMAL_STATE { READY, DRAG, RELEASE }


var _state: ANIMAL_STATE = ANIMAL_STATE.READY
var _start: Vector2 = Vector2.ZERO # Animal start position
var _drag_start: Vector2 = Vector2.ZERO # Mouse drag start position
var _dragged_vector: Vector2 = Vector2.ZERO # Mouse drag final position
var _last_dragged_vector: Vector2 = Vector2.ZERO
var arrow_scale_x: float = 0.0
var last_collision_count: int = 0


@onready var label = $Label
@onready var arrow = $Arrow
@onready var stretch_sound = $StretchSound
@onready var launch_sound = $LaunchSound
@onready var kick_sound = $KickSound


# Called when the node enters the scene tree for the first time.
func _ready():
	_start = position
	arrow_scale_x = arrow.scale.x
	arrow.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update(delta)
	label.text = "%s" % ANIMAL_STATE.keys()[_state]
	label.text += " (%.1f, %.1f)" % [_dragged_vector.x, _dragged_vector.y]


func get_impulse() -> Vector2:
	return _dragged_vector * -1 * IMPULSE_MULT


func set_release() -> void:
	freeze = false
	arrow.hide()
	apply_central_impulse(get_impulse())
	launch_sound.play()
	SignalManager.on_attempt_made.emit()


func set_drag() -> void:
	_drag_start = get_global_mouse_position()
	arrow.show()


func _set_new_state(new_state: ANIMAL_STATE) -> void:
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		set_release()
	elif _state == ANIMAL_STATE.DRAG:
		set_drag()


func detect_release_bool() -> bool:
	if _state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag") == true:
			_set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false


func scale_arrow() -> void:
	var impulse_len = get_impulse().length()
	var percentage = impulse_len / IMPULSE_MAX
	arrow.scale.x = (arrow_scale_x * percentage) + arrow_scale_x
	arrow.rotation = (_start - position).angle()


func play_strech_sound() -> void:
	if (_last_dragged_vector - _dragged_vector).length() > 0:
		if stretch_sound.playing == false:
			stretch_sound.play()


func get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - _drag_start


func drag_in_limits() -> void:
	_last_dragged_vector = _dragged_vector
	# clampf limits the range of x and y to the constants
	_dragged_vector.x = clampf(_dragged_vector.x, DRAG_LIM_MIN.x, DRAG_LIM_MAX.x)
	_dragged_vector.y = clampf(_dragged_vector.y, DRAG_LIM_MIN.y, DRAG_LIM_MAX.y)
	position = _start + _dragged_vector


func update_drag() -> void:
	if detect_release_bool() == true:
		return
	
	var gmp = get_global_mouse_position()
	_dragged_vector = get_dragged_vector(gmp)
	play_strech_sound()
	drag_in_limits()
	scale_arrow()


func play_collision() -> void:
	if last_collision_count == 0 and get_contact_count() > 0 and kick_sound.playing == false:
		kick_sound.play()
	last_collision_count = get_contact_count()


func update_flight() -> void:
	play_collision()


func update(delta: float) -> void:
	match _state:
		ANIMAL_STATE.DRAG:
			update_drag()
		ANIMAL_STATE.RELEASE:
			update_flight()

func die() -> void:
	SignalManager.on_animal_died.emit()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	die()


func _on_input_event(viewport, event: InputEvent, shape_idx):
	if _state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		_set_new_state(ANIMAL_STATE.DRAG)


func _on_sleeping_state_changed():
	if sleeping == true:
		var cb = get_colliding_bodies()
		if cb.size() > 0:
			cb[0].die()
		call_deferred("die")
