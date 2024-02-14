extends Camera2D

var decay := 1.0 #How quickly shaking will stop [0,1].
var max_offset := Vector2(50,25) #Maximum displacement in pixels.
var trauma := 0.0 #Current shake strength
var trauma_pwr := 2 #Trauma exponent. Use [2,3]
var rng
func _ready():
	randomize()
	rng = RandomNumberGenerator.new()

func add_trauma(amount : float):
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake(): 
	var amt = pow(trauma, trauma_pwr)
	offset.x = max_offset.x * amt * rng.randf()
	offset.y = max_offset.y * amt * rng.randf()
	
