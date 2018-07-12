import flixel.FlxSprite;
import openfl.display.BitmapData;

using Math;

class Tileset extends FlxSprite
{

	public function new(x:Float, y:Float)
	{
		super(PlayState.i.padding, PlayState.i.padding);
		makeGraphic(16, 16, 0x00000000);
		cameras = [PlayState.i.tileset_cam];
	}

	public function update_tileset(img:BitmapData)
	{
		loadGraphic(img);
		PlayState.i.tileset_width_in_tiles = (width / PlayState.i.tile_size.x).floor();
		PlayState.i.tileset_height_in_tiles = (height / PlayState.i.tile_size.y).floor();
		var s = (PlayState.i.tileset_cam_size.x - PlayState.i.padding * 2) / width;
		origin.set();
		scale.set(s, s);
		updateHitbox();
	}

}