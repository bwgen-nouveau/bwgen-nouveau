extends Control

var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().
var phase_left = 0.0
var phase_right = 0.0
var paused = true
var selectedEntry : SequenceEntry
var selectedEntryIndex = 0

class SequenceEntry:
	var timeDurationSec: int
	var isTransition: bool
	var newBaseFreq: float
	var newTargetFreq: float
	
var Sequence = {}

func _fill_audio_buffer():
	if not paused:
		var basefreq = $"%BaseFreq".value
		var targetfreq = $"%TargetFreq".value
		var increment_right = (basefreq + targetfreq) / 44100
		var increment_left = basefreq / 44100
		var to_fill = playback.get_frames_available()
		while to_fill > 0:
			playback.push_frame(Vector2(sin(phase_left * TAU),sin(phase_right * TAU))) # Audio frames are stereo.
			#playback.push_frame(Vector2.ONE*sin(phase_left * TAU))
			phase_right = fmod(phase_right + increment_right, 1.0)
			phase_left = fmod(phase_left + increment_left, 1.0)
			to_fill -= 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TabContainer.current_tab = 0
	$"%BaseFreq".value = 130.81
	_clear_sequence()
	$AudioStreamPlayer.stream.mix_rate = 44100
	playback = $AudioStreamPlayer.get_stream_playback()
	_fill_audio_buffer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_fill_audio_buffer()

func _on_button_pressed() -> void:
	paused = not paused
	if paused:
		$"%PlayPauseButton".text = "Begin Entrainment"
	else:
		$"%PlayPauseButton".text = "Pause Entrainment"


func _on_item_list_item_selected(index: int) -> void:
	if index == 0:
		$"%DeleteStep".disabled = true
	else:
		$"%DeleteStep".disabled = false
	selectedEntry = Sequence.get(index)
	selectedEntryIndex = index
	$"%EditStep".disabled = false

func _on_item_list_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	pass # Replace with function body.

func _clear_sequence() -> void:
	Sequence = {}
	$"%ItemList".clear()
	var StartEntry= SequenceEntry.new()
	StartEntry.isTransition = false
	StartEntry.newBaseFreq = $"%BaseFreq".value
	StartEntry.newTargetFreq = $"%TargetFreq".value
	_add_to_sequence(StartEntry)
	selectedEntry = null
	selectedEntryIndex = -1
	$"%EditStep".disabled = true
	
func _add_to_sequence(entry: SequenceEntry) -> void:
	print(Sequence)
	_update_sequence(len(Sequence), entry)
	print(Sequence)
	$"%ItemList".add_item(_entry_as_text(entry))
	
func _entry_as_text(entry) -> String:
	if entry.isTransition:
		return "Transition for "+Time.get_time_string_from_unix_time(entry.timeDurationSec)+" to next step"
	else:
		return "Base frequency "+str(entry.newBaseFreq)+"hz/"+str(entry.newTargetFreq)+"hz - duration "+Time.get_time_string_from_unix_time(entry.timeDurationSec)
	
func _update_sequence(id: int, entry: SequenceEntry) -> void:
	Sequence.get_or_add(id, entry)
	$"%ItemList".set_item_text(id, _entry_as_text(entry))
	
func _on_clear_sequence_pressed() -> void:
	_clear_sequence()
	pass # Replace with function body.


func _on_add_step_pressed() -> void:
	$"%Properties".show()


func _on_edit_step_pressed() -> void:
	$"%Properties".setup_edit(selectedEntry.timeDurationSec,selectedEntry.isTransition,selectedEntry.newBaseFreq,selectedEntry.newTargetFreq)
	$"%Properties".show()

func _on_process_btn_pressed() -> void:
	OS.alert("This feature is not yet ready")


func _on_properties_step_added() -> void:
	var NewEntry= SequenceEntry.new()
	print("In step_added")
	if $"%Properties".is_finished:
		if $"%Properties".is_transition:
			NewEntry.isTransition = true
			NewEntry.timeDurationSec = $"%Properties".duration
		else:
			NewEntry.isTransition = false
			NewEntry.newBaseFreq = $"%Properties".basefreq
			NewEntry.newTargetFreq = $"%Properties".targetfreq
			NewEntry.timeDurationSec = $"%Properties".duration
		print("adding")
		_add_to_sequence(NewEntry)
		print("added")
		selectedEntry = NewEntry
		selectedEntryIndex = len(Sequence)
	
	$"%Properties".hide()

func _on_properties_close_no_save() -> void:
	$"%Properties".hide()

func _on_properties_step_saved() -> void:
	var NewEntry= SequenceEntry.new()
	if $"%Properties".is_finished:
		if $"%Properties".is_transition:
			NewEntry.isTransition = true
			NewEntry.timeDurationSec = $"%Properties".duration
		else:
			NewEntry.isTransition = false
			NewEntry.newBaseFreq = $"%Properties".basefreq
			NewEntry.newTargetFreq = $"%Properties".targetfreq
			NewEntry.timeDurationSec = $"%Properties".duration
			print("Updating "+str(selectedEntryIndex)+" to "+str(NewEntry))
		_update_sequence(selectedEntryIndex,NewEntry)
	
	$"%Properties".hide()
