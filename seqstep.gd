extends Control

signal step_added
signal step_saved
signal close_no_save

@export var is_transition: bool = true
@export var is_finished: bool = false
@export var basefreq: float = 0
@export var targetfreq: float = 0
@export var duration: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_seq_type_btn_transition_pressed() -> void:
	$"%Transition".show()
	$"%NewBaseFreq".hide()
	$"%NewTargetFreq".hide()
	is_finished = true
	is_transition = true
	$Panel/VBoxContainer/AddButton.disabled = false
	$Panel/VBoxContainer/SaveButton.disabled = false
	
func _on_seq_type_btn_freq_pressed() -> void:
	$"%Transition".hide()
	$"%NewBaseFreq".show()
	$"%NewTargetFreq".show()
	is_finished = true
	is_transition = false
	$Panel/VBoxContainer/AddButton.disabled = false
	$Panel/VBoxContainer/SaveButton.disabled = false

func _on_button_pressed() -> void:
	_reset_to_blank()
	emit_signal("close_no_save")
	
func _validate() -> bool:
	var dur = Time.get_unix_time_from_datetime_string("1970-01-01 "+$"%Duration".text)
	if dur <= 0 : 
		OS.alert("Time must be more than 00:00")
		return false
	else:
		duration = dur
		basefreq = $Panel/VBoxContainer/NewBaseFreq/TextEdit2.value
		targetfreq = $Panel/VBoxContainer/NewTargetFreq/TextEdit2.value
		return true

func _on_add_button_pressed() -> void:
	if _validate():
		emit_signal("step_added")
		_reset_to_blank()

func _on_save_button_pressed() -> void:
	if _validate():
		emit_signal("step_saved")
		_reset_to_blank()
	
func _reset_to_blank() -> void:
	is_finished = false
	$"%Duration".text = '00:00:00'
	$"%Transition".hide()
	$"%NewBaseFreq".hide()
	$"%NewTargetFreq".hide()
	$Panel/VBoxContainer/AddButton.disabled = true
	$Panel/VBoxContainer/AddButton.show()
	$Panel/VBoxContainer/SaveButton.disabled = true
	$Panel/VBoxContainer/SaveButton.hide()
	
func setup_edit(duration: int,transition:bool,basefreq:float,targetfreq:float) -> void:
	$"%Duration".text = Time.get_datetime_string_from_unix_time(duration).get_slice("T",1)
	if transition:
		$"%Transition".show()
		$"%NewBaseFreq".hide()
		$"%NewTargetFreq".hide()
		is_transition = true
	else:
		$"%Transition".hide()
		$"%NewBaseFreq".show()
		$"%NewTargetFreq".show()
		is_transition = false
	is_finished = true
	$Panel/VBoxContainer/NewBaseFreq/TextEdit2.value = basefreq
	$Panel/VBoxContainer/NewTargetFreq/TextEdit2.value = targetfreq
	$Panel/VBoxContainer/SaveButton.disabled = false
	$Panel/VBoxContainer/SaveButton.show()
	$Panel/VBoxContainer/AddButton.hide()
