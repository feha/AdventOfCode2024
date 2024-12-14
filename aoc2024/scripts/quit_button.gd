extends Button

func _ready():
    self.pressed.connect(_on_button_pressed)

func _on_button_pressed():
    print("Button pressed! Closing the application...")
    get_tree().quit()
