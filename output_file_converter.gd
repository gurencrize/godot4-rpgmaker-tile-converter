@tool
extends EditorScript

## 対象ディレクトリ
const TARGET_DIR = "res://output_sprite/"
## 出力先ディレクトリ
## 画像出力先ディレクトリ
const OUTPUT_SPRITE_DIR = "res://converted_sprite/"
const TILE_SIZE = 48
const DEFAULT_INDEX = [[0,0],[1,0],[2,0],[3,0],[4,0],[5,0],[0,1],[1,1],[2,1],[3,1],[4,1],[5,1],[0,2],[1,2],[2,2],[3,2],[4,2],[5,2],[0,3],[1,3],[2,3],[3,3],[4,3],[5,3],[0,4],[1,4],[2,4],[3,4],[4,4],[5,4],[0,5],[1,5],[2,5],[3,5],[4,5],[5,5],[0,6],[1,6],[2,6],[3,6],[4,6],[5,6],[0,7],[1,7],[2,7],[3,7],[4,7],[5,7]]
const CHANGED_INDEX = [[1,1],[4,0],[4,1],[5,0],[4,2],[11,1],[5,1],[6,0],[4,3],[5,3],[11,0],[6,3],[5,2],[6,2],[6,1],[11,2],[0,1],[8,0],[7,2],[9,2],[1,0],[8,3],[7,3],[9,3],[2,1],[8,2],[7,0],[9,0],[1,2],[8,1],[7,1],[9,1],[3,1],[1,3],[0,0],[10,2],[2,0],[10,3],[2,2],[10,0],[0,2],[10,1],[3,0],[0,3],[3,2],[2,3],[3,3],[11,3]]


func _run() -> void:
    reference()
    
    if !DirAccess.dir_exists_absolute(OUTPUT_SPRITE_DIR):
            DirAccess.make_dir_recursive_absolute(OUTPUT_SPRITE_DIR)
    
    # A1の変換
    convert_a1()
    
    # A2の変換
    convert_a2()
    
    # A3の変換
    convert_a3()
    
    # A4の変換
    convert_a4()
    
    EditorInterface.get_resource_filesystem().scan()
    
    await EditorInterface.get_resource_filesystem().filesystem_changed
    
    unreference()
    
func convert_a1():
    var a1_image_paths:= get_target_autotile_image_file_paths("_A1")
    for image_path in a1_image_paths:
        var imagefilename:String = image_path.get_basename().split("/")[-1]
        var target_image:Image = Image.new()
        target_image.load(image_path)
        var output_counter = 1
        for y in range(4):
            for x in range(7):
                if (y == 2 or y == 3) and x == 3:
                    continue
                var target_tile:Image = target_image.get_region(Rect2i(TILE_SIZE * 6 * x, TILE_SIZE * 8 * y, TILE_SIZE * 6, TILE_SIZE * 8))
                convert_map_unit(imagefilename, "_{0}".format([output_counter]), target_tile)
                output_counter += 1
func convert_a2():
    var a2_image_paths:= get_target_autotile_image_file_paths("_A2")
    for image_path in a2_image_paths:
        var imagefilename:String = image_path.get_basename().split("/")[-1]
        var target_image:Image = Image.new()
        target_image.load(image_path)
        var output_counter = 1
        for y in range(4):
            for x in range(8):
                var target_tile:Image = target_image.get_region(Rect2i(TILE_SIZE * 6 * x, TILE_SIZE * 8 * y, TILE_SIZE * 6, TILE_SIZE * 8))
                convert_map_unit(imagefilename, "_{0}".format([output_counter]), target_tile)
                output_counter += 1
func convert_a3():
    # 未対応
    pass
func convert_a4():
    var a4_image_paths:= get_target_autotile_image_file_paths("_A4")
    for image_path in a4_image_paths:
        var imagefilename:String = image_path.get_basename().split("/")[-1]
        var target_image:Image = Image.new()
        target_image.load(image_path)
        var output_counter = 1
        for y in range(3):
            for x in range(8):    
                var target_tile:Image = target_image.get_region(Rect2i(TILE_SIZE * 6 * x, TILE_SIZE * (8 + 4) * y, TILE_SIZE * 6, TILE_SIZE * 8))
                convert_map_unit(imagefilename, "_{0}".format([output_counter]), target_tile)
                var target_wall:Image = target_image.get_region(Rect2i(TILE_SIZE * 6 * x, TILE_SIZE * (8 + 4) * y + TILE_SIZE * 8, TILE_SIZE * 4, TILE_SIZE * 4))
                convert_map_wall(imagefilename, "_{0}_wall".format([output_counter]), target_wall)
                output_counter += 1
 
func convert_map_unit(imagefilename:String, suffix:String, source:Image):
    var result:Image = Image.create_empty(TILE_SIZE * 12, TILE_SIZE * 4, false, source.get_format())
    for d in range(DEFAULT_INDEX.size()):
        var default_i = DEFAULT_INDEX[d]
        var changed_i = CHANGED_INDEX[d]
        result.blit_rect(source, Rect2i(TILE_SIZE * default_i[0], TILE_SIZE * default_i[1], TILE_SIZE, TILE_SIZE), Vector2i(TILE_SIZE * changed_i[0], TILE_SIZE * changed_i[1]))
    try_make_dir(imagefilename)
    result.save_png(OUTPUT_SPRITE_DIR.path_join(imagefilename + "/" + imagefilename + suffix + ".png"))

func convert_map_wall(imagefilename:String, suffix:String, source:Image):
    var result:Image = Image.create_empty(TILE_SIZE * 12, TILE_SIZE * 4, false, source.get_format())
    result.blit_rect(source, Rect2i(0, 0, TILE_SIZE * 4, TILE_SIZE * 4), Vector2i(0, 0))
    try_make_dir(imagefilename)
    result.save_png(OUTPUT_SPRITE_DIR.path_join(imagefilename + "/" + imagefilename + suffix + ".png"))


func get_target_autotile_image_file_paths(target_type:String) -> Array[String]:
    var filenames:= DirAccess.get_files_at(TARGET_DIR)
    var resary:Array[String] = []
    for filename in filenames:
        if filename.to_upper().contains(target_type)\
        and !(filename.ends_with(".import")):
            resary.append(TARGET_DIR.path_join(filename))
    return resary


func try_make_dir(dir_name:String):
    var diraccess = DirAccess.open(OUTPUT_SPRITE_DIR)
    if diraccess.dir_exists(dir_name):
        return
    diraccess.make_dir(dir_name)
    
    
