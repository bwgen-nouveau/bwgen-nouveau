class_name FormatSpinBox extends SpinBox
## A format field for numbers that allows for more control than [SpinBox].
##
## This can be used to, for example, always display values with a specific precision.
## [code]%.2f[/code] will display floats with two decimal places.

## A format string with a single specifier to display the box value.
## See [method String.format] for more information on format strings.
@export var format_string: String = "%s"


## Convenience initializer that sets [member format_string] to [param fstring] if set.
func _init(fstring: String = "") -> void:
	if not fstring.is_empty():
		format_string = fstring


# Connect the signal handlers required to make this work seamlessly.
func _ready() -> void:
	value_changed.connect(_on_value_changed, CONNECT_DEFERRED)
	get_line_edit().focus_entered.connect(_on_focus_entered, CONNECT_DEFERRED)
	get_line_edit().focus_exited.connect(_on_focus_exited, CONNECT_DEFERRED)

	# Also, set this up initially
	get_line_edit().text = (prefix + format_string + suffix) % value


# This handler ensures the format is maintained while editing the field.
func _on_value_changed(value: float) -> void:
	get_line_edit().text = (prefix + format_string + suffix) % value


# This handler ensures the format is retained when entering the field.
func _on_focus_entered() -> void:
	get_line_edit().text = format_string % value


# This handler ensures the format is retained when exiting the field.
func _on_focus_exited() -> void:
	get_line_edit().text = (prefix + format_string + suffix) % value
