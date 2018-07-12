package;

import flixel.input.FlxPointer;
import FileUtils;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.math.FlxPoint;
import flash.display.BitmapData;

using Math;

class PlayState extends FlxState
{

	public static var i:PlayState;

	public var tilemap:Tilemap;
	public var tileset:Tileset;
	public var grid:FlxTilemap;
	public var selection_box:SelectionBox;

	public var map_cam:FlxCamera;
	public var tileset_cam:FlxCamera;
	public var object_palette_cam:FlxCamera;
	public var ui_cam:FlxCamera;
	public var map_cam_size:FlxPoint;
	public var tileset_cam_size:FlxPoint;
	public var object_palette_cam_size:FlxPoint;
	public var tileset_file:String;
	public var tile_size:FlxPoint = FlxPoint.get(16, 16);
	public var state:EditorState = PLACE_TILE;
	public var current_tiles:Array<Array<Int>> = [[0]];
	public var padding:Int = 8;
	public var tilemap_array:Array<Array<Int>>;
	public var tilemap_width:Int = 16;
	public var tilemap_height:Int = 9;
	public var tileset_width_in_tiles:Int = 16;
	public var tileset_height_in_tiles:Int = 16;
	public var last_mouse_pos:FlxPoint;
	public var tileset_loaded:Bool = false;
	public var load_text:FlxText;
	public var info_text:FlxText;
	public var min_zoom:Float = 1;
	public var max_zoom:Float = 2;
	public var mouse_down_pt:IntPoint;
	public var mouse_up_pt:IntPoint;
	public var status_text:FlxText;
	public var status_timer:Float = 0;

	override public function create():Void
	{
		i = this;
		super.create();
		init_cams();
		init_array();
		init_tilemap();
		init_tileset();
		init_selection_box();
		init_text();
	}

	function init_cams()
	{
		map_cam_size = FlxPoint.get((FlxG.width * 0.75).round(), FlxG.height);
		tileset_cam_size = FlxPoint.get((FlxG.width * 0.25).round(), (FlxG.height * 0.5).round());
		object_palette_cam_size = FlxPoint.get((FlxG.width * 0.25).round(), (FlxG.height * 0.5).round());

		map_cam = new FlxCamera(0, 0, map_cam_size.x.floor(), map_cam_size.y.floor());
		tileset_cam = new FlxCamera(map_cam_size.x.floor(), 0, tileset_cam_size.x.floor(), tileset_cam_size.y.floor());
		object_palette_cam = new FlxCamera(map_cam_size.x.floor(), tileset_cam_size.y.floor(), object_palette_cam_size.x.floor(), object_palette_cam_size.y.floor());
		ui_cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		
		map_cam.bgColor = 0xFF363543;
		tileset_cam.bgColor = 0xFF1E2028;
		object_palette_cam.bgColor = 0xFF1E2028;
		ui_cam.bgColor = 0x00FFFFFF;

		FlxG.cameras.add(map_cam);
		FlxG.cameras.add(tileset_cam);
		FlxG.cameras.add(object_palette_cam);
		FlxG.cameras.add(ui_cam);
	}

	function init_array()
	{
		tilemap_array = [for (j in 0...tilemap_height) [for (i in 0...tilemap_width) 0]];
	}

	function init_tilemap()
	{
		if (grid != null) remove(grid);
		if (tilemap != null) remove(tilemap);

		grid = new FlxTilemap();
		grid.setPosition(map_cam_size.x * 0.5, map_cam_size.y * 0.5);
		grid.cameras = [map_cam];
		add(grid);

		tilemap = new Tilemap(map_cam_size.x * 0.5, map_cam_size.y * 0.5);
		add(tilemap);
	}

	function init_tileset()
	{
		tileset = new Tileset(padding, padding);
		add(tileset);
	}

	function init_selection_box()
	{
		selection_box = new SelectionBox();
		add(selection_box);
		selection_box.draw_box();
		place_selection_box();
	}

	function init_text()
	{
		info_text = new FlxText(padding, FlxG.height - padding - 12, map_cam_size.x);
		info_text.setFormat(null, 8, 0xB4A895, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE_FAST, 0xFF000000);
		info_text.cameras = [ui_cam];
		info_text.scrollFactor.set();
		add(info_text);

		status_text = new FlxText(0, FlxG.height - padding - 12, FlxG.width - padding);
		status_text.setFormat(null, 8, 0xB4A895, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE_FAST, 0xFF000000);
		status_text.cameras = [ui_cam];
		status_text.scrollFactor.set();
		add(status_text);

		load_text = new FlxText(0, FlxG.height * 0.5, map_cam_size.x);
		load_text.setFormat(null, 8, 0xB4A895, FlxTextAlign.CENTER);
		load_text.text = 'Click anywhere to load a tileset';
		load_text.cameras = [ui_cam];
		add(load_text);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		run_status_timer(elapsed);
		if ((FlxG.mouse.justPressed || FlxG.keys.justPressed.T) && !tileset_loaded) load_tileset();

		selection_box.visible = tileset_loaded;
		load_text.visible = !tileset_loaded;
		if (!tileset_loaded) return;

		if (check_save()) return;
		if (check_load()) return;
		if (set_pan()) return;

		last_mouse_pos = null;
		mouse_click_tileset();
		mouse_click_tilemap();

		map_cam.zoom = (FlxG.mouse.wheel * 0.1 + map_cam.zoom).max(min_zoom).min(max_zoom);
		
		set_info_text();

		if (FlxG.keys.justPressed.W) push_up();
		if (FlxG.keys.justPressed.S) push_down();
		if (FlxG.keys.justPressed.A) push_left();
		if (FlxG.keys.justPressed.D) push_right();
		if (FlxG.keys.justPressed.Q) trim();
		if (FlxG.keys.justPressed.UP) offset_current_tiles(-tileset_width_in_tiles);
		if (FlxG.keys.justPressed.DOWN) offset_current_tiles(tileset_width_in_tiles);
		if (FlxG.keys.justPressed.LEFT) offset_current_tiles(-1);
		if (FlxG.keys.justPressed.RIGHT) offset_current_tiles(1);

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.T) load_tileset();
		if (FlxG.keys.pressed.ALT && FlxG.keys.justPressed.R) FlxG.resetState();
	}

	function run_status_timer(dt:Float)
	{
		if (status_timer > 0)
		{
			status_timer -= dt;
			if (status_timer <= 0)
			{
				status_text.text = '';
			}
		}
	}

	function set_status(s:String)
	{
		status_text.text = s;
		status_timer = 5;
	}

	function check_save():Bool
	{
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
		{
			FileUtils.save_json(tileset_file, tilemap_array);
			return true;
		}
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.S)
		{
			FileUtils.save_json(tileset_file, tilemap_array, true);
			return true;
		}
		return false;
	}

	function check_load():Bool
	{
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.O)
		{
			load_json();
			return true;
		}
		return false;
	}

	function load_tileset()
	{
		var img_with_data = FileUtils.load_image();
		if (img_with_data == null) return;
		tileset_file = img_with_data.name;
		openSubState(new TileDimensionsDialog(img_with_data.img));
		set_status('LOADED TILESET: $tileset_file');
	}

	public function show_tileset(data:BitmapData)
	{
		tileset_loaded = true;
		tileset.update_tileset(data);
		selection_box.scale.set(tileset.scale.x, tileset.scale.y);
		current_tiles = [[0]];
		selection_box.draw_box();
		place_selection_box();
		update_tilemap();
	}
	
	function set_pan():Bool
	{
		if (FlxG.mouse.pressed && FlxG.keys.pressed.SPACE)
		{
			if (last_mouse_pos != null)
			{
				map_cam.scroll.x += (last_mouse_pos.x - FlxG.mouse.x) / map_cam.zoom;
				map_cam.scroll.y += (last_mouse_pos.y - FlxG.mouse.y) / map_cam.zoom;
			}
			last_mouse_pos = FlxG.mouse.getPosition();
			return true;
		}
		return false;
	}

	function set_info_text()
	{
		var tilemap_pos = get_map_coord_from_point(get_mouse_tilemap_pos());
		info_text.text = 'MAP SIZE: $tilemap_width x $tilemap_height | MOUSE x: ${tilemap_pos.x}, y: ${tilemap_pos.y} / x: ${get_mouse_tilemap_pos().x.floor()}, y: ${get_mouse_tilemap_pos().y.floor()} | ZOOM: ${map_cam.zoom}';
	}

	function offset_current_tiles(diff:Int)
	{
		var rect:IntRect = {
			x: current_tiles[0][0] % tileset_width_in_tiles,
			y: (current_tiles[0][0] / tileset_width_in_tiles).floor(),
			w: current_tiles[0].length,
			h: current_tiles.length
		};

		if (diff.abs() == 1) 
		{
			if (rect.x + rect.w + diff > tileset_width_in_tiles || rect.x + diff < 0) return;
		}
		else 
		{
			var vdiff = diff > 0 ? 1 : -1;
			if (rect.y + rect.h + vdiff > tileset_height_in_tiles || rect.y + vdiff < 0) return;
		}

		for (j in 0...current_tiles.length) for (i in 0...current_tiles[j].length) current_tiles[j][i] += diff;
		place_selection_box();
	}

	function mouse_click_tileset()
	{
		var m_p = FlxG.mouse.getPositionInCameraView(tileset_cam);
		if (FlxG.mouse.justPressed && tileset.overlapsPoint(m_p)) on_tileset_click(m_p.x - tileset.x, m_p.y - tileset.y);
		if (FlxG.mouse.pressed && tileset.overlapsPoint(m_p)) on_tileset_release(m_p.x - tileset.x, m_p.y - tileset.y);
	}

	function on_tileset_click(x:Float, y:Float) mouse_down_pt = { x: (x / (tile_size.x * tileset.scale.x)).floor(), y: (y / (tile_size.y * tileset.scale.y)).floor() };
	function on_tileset_release(x:Float, y:Float)
	{
		mouse_up_pt = { x: (x / (tile_size.x * tileset.scale.x)).floor(), y: (y / (tile_size.y * tileset.scale.y)).floor() };
		
		var selection:IntRect = { x: mouse_down_pt.x.min(mouse_up_pt.x).floor(), y: mouse_down_pt.y.min(mouse_up_pt.y).floor(), w: (mouse_down_pt.x - mouse_up_pt.x).abs().floor() + 1, h: (mouse_down_pt.y - mouse_up_pt.y).abs().floor() + 1 };
		
		var a:Array<Array<Int>> = [for (i in 0...selection.h) []];
		for (i in 0...selection.w) for (j in 0...selection.h) a[j][i] = selection.x + i + (selection.y + j) * tileset_width_in_tiles;
		
		select_tiles(a);
	}

	function select_tiles(i:Array<Array<Int>>)
	{
		current_tiles = i;
		place_selection_box();
	}

	function place_selection_box()
	{
		var x = current_tiles[0][0] % tileset_width_in_tiles;
		var y = (current_tiles[0][0] / tileset_width_in_tiles).floor();
		selection_box.setPosition(x * tile_size.x * tileset.scale.x + padding, y * tile_size.y * tileset.scale.y + padding);
		selection_box.draw_box(current_tiles[0].length, current_tiles.length);
	}

	function mouse_click_tilemap()
	{
		var m_p = FlxG.mouse.getPositionInCameraView(map_cam).addPoint(map_cam.scroll).addPoint(tilemap.offset);
		if (FlxG.mouse.pressed && grid.overlapsPoint(m_p)) on_tilemap_click(m_p.x - grid.x, m_p.y - grid.y, current_tiles);
		if (FlxG.mouse.pressedRight && grid.overlapsPoint(m_p)) on_tilemap_click(m_p.x - grid.x, m_p.y - grid.y, [[0]]);
	}

	function get_mouse_tilemap_pos():FlxPoint
	{
		return FlxG.mouse.getPositionInCameraView(map_cam).addPoint(map_cam.scroll).addPoint(tilemap.offset).add(-grid.x, -grid.y);
	}

	function get_map_coord_from_point(p:FlxPoint):FlxPoint
	{
		return FlxPoint.get((p.x / tile_size.x).floor(), (p.y / tile_size.y).floor());
	}

	function on_tilemap_click(x:Float, y:Float, i:Array<Array<Int>>)
	{
		var x = (x / tile_size.x).floor();
		var y = (y / tile_size.y).floor();
		if (x >= tilemap_width || y >= tilemap_height) return;
		FlxG.keys.pressed.SHIFT ? paint_random(tilemap_array, i, x, y) : paint_to_array(tilemap_array, i, x, y);
		update_tilemap();
	}

	function paint_random(array:Array<Array<Int>>, brush:Array<Array<Int>>, x:Int, y:Int) array[y][x] = brush[(Math.random() * brush.length).floor()][(Math.random() * brush[0].length).floor()];
	function paint_to_array(array:Array<Array<Int>>, brush:Array<Array<Int>>, x:Int, y:Int)
	{
		for (j in 0...brush.length)
		{
			for (i in 0...brush[j].length)
			{
				if (j + y >= array.length) return;
				if (i + x >= array[0].length) continue;
				array[j + y][i + x] = brush[j][i];
			}
		}
	}

	function push_up()
	{
		var empty_first_row = true;
		for (i in 0...tilemap_width) if (tilemap_array[0][i] > 0) empty_first_row = false;
		if (!empty_first_row) tilemap_array.push([for (i in 0...tilemap_width) 0]);
		else tilemap_array.push(tilemap_array.shift());
		update_tilemap();
	}

	function push_down()
	{
		var empty_last_row = true;
		for (i in 0...tilemap_width) if (tilemap_array[tilemap_array.length - 1][i] > 0) empty_last_row = false;
		if (!empty_last_row) tilemap_array.unshift([for (i in 0...tilemap_width) 0]);
		else tilemap_array.unshift(tilemap_array.pop());
		update_tilemap();
	}

	function push_left()
	{
		var empty_first_column = true;
		for (row in tilemap_array) if (row[0] > 0) empty_first_column = false;
		if (!empty_first_column) for (row in tilemap_array) row.push(0);
		else for (row in tilemap_array) row.push(row.shift());
		update_tilemap();
	}

	function push_right()
	{
		var empty_last_column = true;
		for (row in tilemap_array) if (row[row.length - 1] > 0) empty_last_column = false;
		if (!empty_last_column) for (row in tilemap_array) row.unshift(0);
		else for (row in tilemap_array) row.unshift(row.pop());
		update_tilemap();
	}

	function trim()
	{
		var empty_first_row = true;
		var empty_last_row = true;
		var empty_first_column = true;
		var empty_last_column = true;

		while (empty_first_row && tilemap_array.length > 1)
		{
			for (i in 0...tilemap_width) if (tilemap_array[0][i] > 0) empty_first_row = false;
			if (empty_first_row) tilemap_array.shift();
		}

		while (empty_last_row && tilemap_array.length > 1)
		{
			for (i in 0...tilemap_width) if (tilemap_array[tilemap_array.length - 1][i] > 0) empty_last_row = false;
			if (empty_last_row) tilemap_array.pop();
		}

		while (empty_first_column && tilemap_array[0].length > 1)
		{
			for (row in tilemap_array) if (row[0] > 0) empty_first_column = false;
			if (empty_first_column) for (row in tilemap_array) row.shift();
		}

		while (empty_last_column && tilemap_array[0].length > 1)
		{
			for (row in tilemap_array) if (row[row.length - 1] > 0) empty_last_column = false;
			if (empty_last_column) for (row in tilemap_array) row.pop();
		}

		update_tilemap();
	}

	function update_tilemap()
	{
		tilemap_width = tilemap_array[0].length;
		tilemap_height = tilemap_array.length;
		if (tilemap_array.length != tilemap.heightInTiles || tilemap_array[0].length != tilemap.widthInTiles) init_tilemap();
		tilemap.update_tiles(tilemap_array, tileset.pixels, tile_size);

		grid.loadMapFrom2DArray([for (j in 0...tilemap_array.length + 1) [for (i in 0...tilemap_array[0].length + 1) 0]], 'assets/images/grid.png', tile_size.x.round(), tile_size.y.round(), null, 0, 0, 0);
		grid.offset.set(tilemap.width * 0.5, tilemap.height * 0.5);
	}

	function save_json() 
	{
		FileUtils.save_json(tileset_file, tilemap_array);
		set_status('SAVED MAP: ${FileUtils.json_path}');
	}

	function load_json()
	{
		var data = FileUtils.load_json();
		if (data.save.data == null) return;
		tilemap_array = data.save.data;
		data.save.tileset == tileset_file ? set_status('LOADED MAP: ${data.path}') : set_status('LOADED MAP: ${data.path} (ORIGINAL TILES: ${data.save.tileset})');
		update_tilemap();
	}

}

typedef SaveFile =
{
	tileset:String,
	data:Array<Array<Int>>
}

enum EditorState
{
	PLACE_TILE;
	PLACE_OBJECT;
}

typedef IntPoint =
{
	x:Int,
	y:Int
}

typedef IntRect = 
{
	x:Int,
	y:Int,
	w:Int,
	h:Int
}