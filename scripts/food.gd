extends StaticBody2D

var value = 0
var location

func _physics_process(delta):
	Disappear()

func Food():
	pass

func Disappear():
	value -= 1

func EateFood():
	location = self.position
	self.queue_free()
	World.FoodReSpawn(location)
