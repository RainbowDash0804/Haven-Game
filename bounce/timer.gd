extends Label
@onready var label = $"."
@onready var timer = $Timer
var level = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(timeranout)
	pass # Replace with function body.
func timeranout() -> void:
	get_tree().change_scene_to_file("res://death.tscn")
	if Input.is_action_just_pressed("ui_accept"):
		print(get_tree())
		match level:
			0:
				get_tree().change_scene_to_file("res://world.tscn")
			1:
				get_tree().change_scene_to_file("res://level2.tscn")
		print(timer.start())

func time_left_to_live():
	var timeLeft = timer.time_left
	var minute = floor(timeLeft / 60)
	var second = int(timeLeft) % 60
	return [minute, second]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "%02d:%02d" % time_left_to_live()
	
