extends StaticBody2D

var value = 0
var tween = create_tween()

func _ready():
	# Making it Disappear
	tween.tween_property(self, "modulate:a", 0, 20.0)


func _physics_process(delta):
	Disappear()


func PathDot():
	pass


func Disappear():
	value -= 1


func _on_timer_timeout():
	self.queue_free()
