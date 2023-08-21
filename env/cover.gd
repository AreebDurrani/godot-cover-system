class_name Cover extends StaticBody3D

@export var cover_points : Array[Node]

func _ready():
	cover_points = $cover_points.get_children()
	print(find_vacant_point())

func find_vacant_point() -> CoverPoint:
	for point in cover_points:
		if point is CoverPoint:
			if point.occupied == false:
				return point
	return null
