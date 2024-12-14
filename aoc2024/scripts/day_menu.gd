@tool
extends GridContainer

func _ready():
    print("_ready")
    for n in range(1,26):
        var button = Button.new()
        button.text = "%02d" % n
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        add_child(button)
        button.pressed.connect(self._on_button_pressed.bind(n))
        #button.disabled = false
        button.disabled = !scene_exists(n)

func scene_exists(n: int):
    var scene_uri = "res://scenes/day%02d.tscn" % n
    return ResourceLoader.exists(scene_uri)

# This function will be called when any button is pressed
func _on_button_pressed(n: int):
    print("Button %s was pressed!" % n)
    var scene_uri = "res://scenes/day%02d.tscn" % n
    if scene_exists(n):
        print("scene %s exists" % scene_uri)
        get_tree().change_scene_to_file(scene_uri)
    else:
        print("scene %s does not exist" % scene_uri)
