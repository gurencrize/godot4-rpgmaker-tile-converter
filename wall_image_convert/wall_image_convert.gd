@tool
extends EditorScript

## 対象ディレクトリ
const TARGET_DIR = "res://wall_image_convert/input"
## 画像出力先ディレクトリ
const OUTPUT_SPRITE_DIR = "res://wall_image_convert/output"

const cell_size = 16

const remap_index = [
    [[0,0],[1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],[0,0],[1,0],[8,0],[0,9],null,null,[0,9],null,[2,9],[0,9],null,[2,9],[0,9],null,[8,3],[0,3],null,[2,9],[0,9],null,[8,3],[0,9],null,[8,6],null,null,[2,9]],
    [[0,1],[1,1],[2,1],[3,1],[4,1],[5,1],[6,1],[7,1],[8,1],[0,1],[1,1],[8,1],null,null,null,null,null,null,null,null,[2,10],null,null,[8,4],[0,4],null,null,[0,10],null,[8,4],[6,7],[7,7],[8,7],[0,10],null,null],
    [[0,2],[1,2],[2,2],[3,2],[4,2],[5,2],[6,2],[7,2],[8,2],[0,2],[1,2],[8,2],null,null,null,null,null,null,null,null,[2,11],null,null,[8,5],[0,5],null,null,[0,11],null,[8,5],[6,8],[7,8],[8,8],[0,11],null,null],
    [[0,3],[1,3],[2,3],[3,3],[4,3],[5,3],[6,3],[7,3],[8,3],[0,3],[1,3],[8,3],null,null,[2,9],null,null,[2,9],null,null,[2,9],null,null,[2,9],[0,9],null,null,[0,9],null,[2,9],[0,6],null,[2,9],[0,9],null,null],
    [[0,4],[1,4],[2,4],[3,4],[4,4],[5,4],[6,4],[7,4],[8,4],[0,4],[1,4],[8,4],null,null,null,null,null,[2,10],[0,10],null,[2,10],[3,7],[4,7],[5,7],[3,7],[4,7],[5,7],[3,7],[4,7],[5,7],[0,7],[1,7],[2,7],null,null,[2,10]],
    [[0,5],[1,5],[2,5],[3,5],[4,5],[5,5],[6,5],[7,5],[8,5],[0,5],[1,5],[8,5],null,null,null,null,null,[2,11],[0,11],null,[2,11],[3,8],[4,8],[5,8],[3,8],[4,8],[5,8],[3,8],[4,8],[5,8],[0,8],[1,8],[2,8],null,null,[2,11]],
    [[0,6],[1,6],[2,6],[3,6],[4,6],[5,6],[6,6],[7,6],[8,6],[0,6],[1,6],[8,6],null,null,null,null,null,null,[0,9],null,null,[0,3],null,null,null,null,[8,3],[0,3],null,[2,9],[0,0],[1,0],[2,0],[0,9],null,[2,9]],
    [[0,7],[1,7],[2,7],[3,7],[4,7],[5,7],[6,7],[7,7],[8,7],[0,7],[1,7],[8,7],null,null,[2,10],[0,10],null,[2,10],[0,10],null,[2,10],[0,4],null,[2,10],[0,10],null,[8,4],[0,4],null,[2,10],[0,1],null,[2,10],[0,10],null,[2,10]],
    [[0,8],[1,8],[2,8],[3,8],[4,8],[5,8],[6,8],[7,8],[8,8],[0,8],[1,8],[8,8],null,null,[2,11],[0,11],null,[2,11],[0,11],null,[2,11],[0,5],null,[2,11],[0,11],null,[8,5],[0,5],null,[2,11],[0,2],null,[2,11],[0,11],null,[2,11]],
    [[0,0],[1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],[0,0],[1,0],[8,0],null,null,null,[0,9],null,null,[0,9],null,[2,9],[3,0],[4,0],[5,0],[3,0],[4,0],[5,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],null,null,null],
    [[0,7],[1,7],[2,7],[3,7],[4,7],[5,7],[6,7],[7,7],[8,7],[0,7],[1,7],[8,7],[0,10],null,null,[0,10],null,null,[0,10],null,null,[0,10],null,null,null,null,[2,10],[0,10],null,[2,10],[0,10],null,[8,1],null,null,null],
    [[0,8],[1,8],[2,8],[3,8],[4,8],[5,8],[6,8],[7,8],[8,8],[0,8],[1,8],[8,8],[0,11],null,null,[0,11],null,null,[0,11],null,null,[0,11],null,null,null,null,[2,11],[0,11],null,[2,11],[0,11],null,[8,2],null,null,null]
]

func _run() -> void:
    reference()
    if !DirAccess.dir_exists_absolute(OUTPUT_SPRITE_DIR):
        DirAccess.make_dir_recursive_absolute(OUTPUT_SPRITE_DIR)
    
    var filenames:= DirAccess.get_files_at(TARGET_DIR)
    for filename in filenames:
        if filename.ends_with(".png"):
            convert_wall(TARGET_DIR.path_join(filename))
    EditorInterface.get_resource_filesystem().scan()
    await EditorInterface.get_resource_filesystem().filesystem_changed
    unreference()

func convert_wall(target_filepath:String):
    var target_image:Image = Image.load_from_file(target_filepath)
    var image_name = target_filepath.split("/")[-1]
    var remapping_image = Image.create(36 * cell_size, 12 * cell_size, false, Image.Format.FORMAT_RGBA8)
    
    # 初期化
    for y in range(4):
        for x in range(4,12):
            remapping_image.blit_rect(target_image,Rect2i(cell_size * 3, cell_size * 3, cell_size * 3, cell_size * 3),Vector2i(x * cell_size * 3, y * cell_size * 3))

    for y in remap_index.size():
        for x in remap_index[y].size():
            var source = remap_index[y][x]
            if !source is Array:
                continue
            remapping_image.blit_rect_mask(target_image,target_image,Rect2i(source[0] * cell_size, source[1] * cell_size, cell_size, cell_size),Vector2i(x * cell_size, y * cell_size))
    remapping_image.save_png(OUTPUT_SPRITE_DIR.path_join(image_name))
