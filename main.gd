extends Control

var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().
var phase_left = 0.0
var phase_right = 0.0
var paused = true

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
	_clear_sequence()
	$AudioStreamPlayer.stream.mix_rate = 44100
	playback = $AudioStreamPlayer.get_stream_playback()
	_fill_audio_buffer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	pass # Replace with function body.


func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	pass # Replace with function body.

func _clear_sequence() -> void:
	$"%ItemList".clear()
	$"%ItemList".add_item("Start at "+str($"%BaseFreq".value)+"Hz/"+str($"%TargetFreq".value)+"Hz",null,true)
	
func _on_clear_sequence_pressed() -> void:
	_clear_sequence()
	pass # Replace with function body.
