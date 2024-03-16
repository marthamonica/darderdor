extends Sprite2D

var blink_timer = 0.0
var blink_interval = 0.1
var is_visible = true
var is_blinking = false

func _process(delta):
	if (is_blinking):
		blink_timer += delta
		if blink_timer >= blink_interval:
			is_visible = !is_visible
			self.visible = is_visible
			blink_timer = 0.0
	else:
		self.visible = true
		blink_timer = 0.0

func blink(blink: bool):
	is_blinking = blink
	self.modulate.a = 0.5 if blink else 1
