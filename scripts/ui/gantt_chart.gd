extends PanelContainer

@onready var chart_area: Control = $MarginContainer/VBoxContainer/ChartArea

var completed_processes: Array[Process] = []
var total_time: int = 1

var process_colors: Dictionary = {
	1: Color("#8B5CF6"),
	2: Color("#2563EB"),
	3: Color("#0D9488")
}


func _ready() -> void:
	chart_area.draw.connect(_draw_chart)
	chart_area.resized.connect(chart_area.queue_redraw)


func setup(duration: int) -> void:
	total_time = maxi(duration, 1)
	completed_processes.clear()
	chart_area.queue_redraw()


func add_completed_process(process: Process) -> void:
	completed_processes.append(process)
	chart_area.queue_redraw()


func _draw_chart() -> void:
	var width: float = chart_area.size.x
	var bar_height: float = 35.0
	var top: float = 8.0

	if width <= 0:
		return

	var font: Font = ThemeDB.fallback_font

	for process in completed_processes:
		var start_x: float = (
			float(process.start_time) / float(total_time)
		) * width

		var end_x: float = (
			float(process.completion_time) / float(total_time)
		) * width

		var rect := Rect2(
			Vector2(start_x, top),
			Vector2(end_x - start_x, bar_height)
		)

		var color: Color = process_colors.get(
			process.pid,
			Color("#64748B")
		)

		chart_area.draw_rect(rect, color)

		chart_area.draw_string(
			font,
			Vector2(start_x + 8, top + 23),
			"P%d" % process.pid,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			Color.WHITE
		)

		chart_area.draw_string(
			font,
			Vector2(start_x, top + 55),
			str(process.start_time),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			12,
			Color.WHITE
		)

	if not completed_processes.is_empty():
		var last_process: Process = completed_processes.back()

		var end_x: float = (
			float(last_process.completion_time) / float(total_time)
		) * width

		chart_area.draw_string(
			font,
			Vector2(minf(end_x, width - 25), top + 55),
			str(last_process.completion_time),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			12,
			Color.WHITE
		)
