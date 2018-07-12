import flixel.tile.FlxTilemap;
import openfl.display.BitmapData;
import flixel.math.FlxPoint;

using Math;

class Tilemap extends FlxTilemap
{

	public function new(x:Float, y:Float)
	{
		super();
		setPosition(x, y);
		cameras = [PlayState.i.map_cam];
	}

	public function update_tiles(array:Array<Array<Int>>, bitmap_data:BitmapData, tile_size:FlxPoint)
	{
		loadMapFrom2DArray(array, bitmap_data, tile_size.x.round(), tile_size.y.round());
		offset.set(width * 0.5, height * 0.5);
	}

}