package renderers;


#if heaps
import js.Browser.document;
import js.Browser.window;
import js.html.Element;
import js.html.CanvasElement;
import Defs.LevelData;
import Defs.IRenderer;
import h2d.Graphics;
import h2d.Interactive;
import h2d.col.Point;
import hxd.Key;
import h2d.Object;

using Math;

class HeapsRenderer implements IRenderer {
  
	var workspace:Element;
	var canvas:CanvasElement;
	var ctx:HeapsContext;
	var tiles:Array<Array<Interactive>> = [];
	var brush = [
		[0xFFFFFFFF, 0xFFFF0000],
		[0xFF00FF00, 0xFF0000FF],
	];

	public function create(workspace:Element, on_create:Void->Void)
	{
		this.workspace = workspace;
		canvas = cast workspace.appendChild(document.createCanvasElement());
		canvas.id = 'webgl';
		ctx = new HeapsContext(on_create);
		hxd.Res.initEmbed();
		window.addEventListener('resize', resize);
		resize();
	}

	public function rebuild(width:Int, height:Int, tile_width:Int, tile_height:Int) 
	{
		reset();

		width = (width / tile_width).floor() * tile_width;
		height = (height / tile_height).floor() * tile_height;

		// draw the grid
		var grid = new h2d.Graphics(ctx.root);
		grid.setPosition(-width * 0.5, -height * 0.5);
		grid.beginFill(0, 0);
		grid.lineStyle(1, 0xff9c9fac);
		for(j in 0...(height / tile_height).ceil()) {
			tiles.push([]);
			for (i in 0...(width / tile_width).ceil())
			{
				grid.drawRect(i * tile_width, j * tile_height, tile_width, tile_height);
				var tile = new Interactive(tile_width, tile_height, ctx.root);
				tile.setPosition(i * tile_width - width * 0.5, j * tile_height - height *0.5);
				tile.onPush = (_) -> {
					if (Key.isDown(Key.SPACE)) return;
					draw(i, j);
				};
				tile.onOver = (_) -> {
					if (!Key.isDown(Key.MOUSE_LEFT) || Key.isDown(Key.SPACE)) return;
					draw(i, j);
				};
				tiles[j][i] = tile;
			}
		}
		grid.lineStyle(2, 0xFFC1C5D2);
		grid.drawRect(0, 0, width, height);
		grid.endFill();
		
		// scale and position the context
		var canvas_width = Std.parseInt(canvas.style.width);
		var canvas_height = Std.parseInt(canvas.style.height);
		var scale_x:Float = canvas_width / width;
		var scale_y:Float = canvas_height / height;
		var scale:Float = Math.min(scale_x, scale_y);
		ctx.root.setScale(1); //ctx.root.setScale(scale * 1.95);
		ctx.root.setPosition(canvas_width * 0.5, canvas_height * 0.5);
	}

	function draw(x:Int, y:Int)
	{
		trace(x, y);
		if (Key.isDown(Key.SHIFT)) draw_random(x, y);
		else draw_tiles(x, y);
	}

	function draw_random(x:Int, y:Int)
	{
		var j = (Math.random() * brush.length).floor();
		var i = (Math.random() * brush[j].length).floor();
		draw_tile(x, y, brush[j][i]);
	}

	function draw_tiles(x:Int, y:Int)
	{
		for (j in 0...brush.length) for (i in 0...brush[j].length) draw_tile(x + i, y + j, brush[j][i]);
	}

	function draw_tile(x:Int, y:Int, i:Int)
	{
		if (y > tiles.length || x > tiles[y].length) return;
		tiles[y][x].backgroundColor = i;
	}

	public function load_level(level:LevelData) 
	{

	}

	function resize() 
	{
		canvas.style.width = '${workspace.clientWidth}px';
		canvas.style.height = '${workspace.clientHeight}px';
	}

	function reset()
	{
		ctx.setScene(new h2d.Scene());
		ctx.root = new Object(ctx.s2d);
	}
}

class HeapsContext extends hxd.App {

	public var root:Object;
	var on_init:Void->Void;
	var last_mouse_pos:Point;

	public function new (on_init:Void->Void) {
		super();
		root = new Object(s2d);
		this.on_init = on_init;
	}

	override function init() 
	{
		engine.backgroundColor = 0xff757989;
		last_mouse_pos = new Point(s2d.mouseX, s2d.mouseY);
		on_init();
	}

	override function update(dt:Float) 
	{
		if (Key.isPressed(Key.MOUSE_WHEEL_UP)) root.scaleX = root.scaleY += 0.1;
		if (Key.isPressed(Key.MOUSE_WHEEL_DOWN)) root.scaleX = root.scaleY -= 0.1;
		if (Key.isDown(Key.SPACE) && Key.isDown(Key.MOUSE_LEFT)) s2d.startDrag((e:hxd.Event) -> {
			root.x -= (last_mouse_pos.x - e.relX);
			root.y -= (last_mouse_pos.y - e.relY);
		});
		if (Key.isReleased(Key.MOUSE_LEFT)) s2d.stopDrag();
		
		last_mouse_pos.x = s2d.mouseX;
		last_mouse_pos.y = s2d.mouseY;
		if (root.scaleX < 0.5 || root.scaleY < 0.5) root.setScale(0.5);
	}
}
#end