@tool
extends Node


const texture_folder_path = "res://addons/proto-csgs/textures/"


var proto_csg_primitive: CSGPrimitive3D


func _ready() -> void:
	proto_csg_primitive = get_parent()


func _get_proto_texture(color: String, style: int) -> Texture2D:
	style = style + 1
	var relative_path := color + "/" + "texture_" + ("0" if style < 10 else "") + str(style) + ".png"
	var absolute_path := texture_folder_path + relative_path
	var texture = load(absolute_path)
	if not (texture is Texture2D):
		return null
	return texture


func apply_proto_texture(color: String, style: int) -> void:
	if proto_csg_primitive == null:
		return
	var texture := _get_proto_texture(color, style)
	if texture == null:
		return
	var material : Material = proto_csg_primitive.material
	if not (material is BaseMaterial3D):
		return
	
	material = material.duplicate()
	proto_csg_primitive.material = material
	
	var material_3d := material as BaseMaterial3D
	material_3d.albedo_texture = texture
