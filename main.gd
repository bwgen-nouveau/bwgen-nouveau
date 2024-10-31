extends Control

var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().
var phase_left = 0.0
var phase_right = 0.0
var paused = true
var selectedEntry := preload("res://SequenceEntry.gd").new()
var selectedEntryIndex = 0
	
var Sequence : = {}
var currentSequenceSecond = 0
var startSequenceSecond = 0

func sequenceToBaseFreq(s: int) -> float:
	var secondsPast = 0
	var lastFreq = $"%BaseFreq".value
	for key in Sequence:
		print("Processing step "+str(key))
		if Sequence[key].newBaseFreq > 0:
			lastFreq = Sequence[key].newBaseFreq
		secondsPast += Sequence[key].timeDurationSec
		if secondsPast > s:
			# secondsPast is now beyond the correct block
			if Sequence[key].isTransition:
				print("Transitioning to new tone")
				var perSecond = (Sequence[key+1].newBaseFreq-lastFreq)/Sequence[key].timeDurationSec
				print("Hz/sec in step: "+str(perSecond))
				var secondsIn = s-(secondsPast - Sequence[key].timeDurationSec)
				return lastFreq + (secondsIn * perSecond)
			else:
				print("new tone direct")
				return lastFreq
	return 0.0

func sequenceToTargetFreq(s: int) -> float:
	var secondsPast = 0
	var lastFreq = $"%TargetFreq".value
	for key in Sequence:
		print("Processing step "+str(key))
		if Sequence[key].newTargetFreq > 0:
			lastFreq = Sequence[key].newTargetFreq
		secondsPast += Sequence[key].timeDurationSec
		if secondsPast > s:
			# secondsPast is now beyond the correct block
			if Sequence[key].isTransition:
				print("Transitioning to new difference")
				var perSecond = (Sequence[key+1].newTargetFreq-lastFreq)/Sequence[key].timeDurationSec
				print("Hz/sec in step: "+str(perSecond))
				var secondsIn = s-(secondsPast - Sequence[key].timeDurationSec)
				return lastFreq + (secondsIn * perSecond)
			else:
				print("new difference direct")
				return lastFreq
	return 0.0

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
	_update_sequence(len(Sequence), entry)
	$"%ItemList".add_item(_entry_as_text(entry))
	
func _entry_as_text(entry) -> String:
	if entry.isTransition:
		return "Transition for "+Time.get_time_string_from_unix_time(entry.timeDurationSec)+" to next step"
	else:
		return "Base frequency "+str(entry.newBaseFreq)+"hz/"+str(entry.newTargetFreq)+"hz - duration "+Time.get_time_string_from_unix_time(entry.timeDurationSec)

func _sort_sequence() -> void:
	var Sorted : Dictionary = {}
	var sortkey = 0
	for _key in Sequence:
		Sorted.get_or_add(sortkey,Sequence[sortkey])
		sortkey += 1
	Sequence = Sorted

func _update_sequence(id: int, entry: SequenceEntry) -> void:
	Sequence.erase(id)
	Sequence.get_or_add(id, entry)
	$"%ItemList".set_item_text(id, _entry_as_text(entry))
	_sort_sequence()
	
func _on_clear_sequence_pressed() -> void:
	_clear_sequence()
	pass # Replace with function body.

func _on_add_step_pressed() -> void:
	$"%Properties".show()

func _on_edit_step_pressed() -> void:
	$"%Properties".setup_edit(selectedEntry.timeDurationSec,selectedEntry.isTransition,selectedEntry.newBaseFreq,selectedEntry.newTargetFreq)
	$"%Properties".show()

func _on_process_btn_pressed() -> void:
	startSequenceSecond = Time.get_unix_time_from_system()
	if paused:
		_on_button_pressed()
	$Timer.start()

func _on_properties_step_added() -> void:
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
		
		_add_to_sequence(NewEntry)
		
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
		_update_sequence(selectedEntryIndex,NewEntry)
		selectedEntry = NewEntry
	$"%Properties".hide()

func _on_timer_timeout() -> void:
	currentSequenceSecond += 1
	$"%BaseFreq".value = sequenceToBaseFreq(currentSequenceSecond)
	$"%TargetFreq".value = sequenceToTargetFreq(currentSequenceSecond)
	print("Current second of sequence: "+str(currentSequenceSecond))


func _on_save_button_pressed() -> void:
	$SaveDialog.size.x = get_window().size.x / 3 * 2
	$SaveDialog.size.y = get_window().size.y / 3 * 2
	$SaveDialog.position.x = (get_window().size.x / 2) - ($SaveDialog.size.x / 2)
	$SaveDialog.position.y = (get_window().size.y / 2) - ($SaveDialog.size.y / 2)
	$SaveDialog.show()

func _on_file_dialog_confirmed() -> void:
	var serialised =  preload("res://Sequence.gd").new()
	serialised.items = Sequence
	var data = serialised._to_string()
	var file = FileAccess.open($SaveDialog.current_file, FileAccess.WRITE)
	file.store_string(data)
	file.close()

func _on_load_button_pressed() -> void:
	$LoadDialog.size.x = get_window().size.x / 3 * 2
	$LoadDialog.size.y = get_window().size.y / 3 * 2
	$LoadDialog.position.x = (get_window().size.x / 2) - ($LoadDialog.size.x / 2)
	$LoadDialog.position.y = (get_window().size.y / 2) - ($LoadDialog.size.y / 2)
	$LoadDialog.show()

func _on_load_dialog_confirmed() -> void:
	var file = FileAccess.open($LoadDialog.current_file, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	Sequence = {}
	$"%ItemList".clear()
	var parser = JSON.new()
	var result = parser.parse(content)
	if result == OK:
		for key in parser.data:
			var entry = SequenceEntry.from_dict(parser.data[key])
			var actualKey = int(key)
			if actualKey == 0 and not key == "0":
				actualKey = key
			Sequence.get_or_add(actualKey,entry)
	_sort_sequence()
	for key in Sequence:
		$"%ItemList".add_item(_entry_as_text(Sequence[key]))
	print(Sequence)
