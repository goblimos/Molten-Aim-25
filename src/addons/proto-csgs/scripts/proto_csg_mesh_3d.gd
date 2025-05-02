@tool
extends CSGMesh3D
class_name ProtoCSGMesh3D


enum PROTOCSG_COLOR {DARK, GREEN, LIGHT, ORANGE, PURPLE, RED}
const _enum_color_to_foldername := ["dark", "green", "light", "orange", "purple", "red"]

@export var block_color : PROTOCSG_COLOR = PROTOCSG_COLOR.DARK :
	set(value):
		block_color = value
		update_proto_texture()

enum PROTOCSG_STYLE {
	DEFAULT,
	CROSS,
	CONTRAST,
	DIAGONAL,
	DIAGONAL_FADED,
	GROUPED_CROSS,
	GROUPED_CHECKERS,
	CHECKERS,
	CROSS_CHECKERS,
	STAIRS,
	DOOR,
	WINDOW,
	INFO
}

@export var block_style : PROTOCSG_STYLE = PROTOCSG_STYLE.DEFAULT :
	set(value):
		block_style = value
		update_proto_texture()


@onready var proto_csg_component = $ProtoCSGComponent


func _ready() -> void:
	pass #if !Engine.is_editor_hint(): update_proto_texture()

func update_proto_texture() -> void:
	if proto_csg_component == null:
		return
	proto_csg_component.apply_proto_texture(
		_enum_color_to_foldername[block_color],
		block_style,
		)
