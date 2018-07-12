import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;

class SelectionBox extends FlxSprite
{

	public function new()
	{
		super();
		makeGraphic(132, 132, 0x00FFFFFF);
		offset.set(3, 3);
		cameras = [PlayState.i.tileset_cam];
		origin.set();
	}

	public function draw_box(w:Int = 1, h:Int = 1)
	{
		FlxSpriteUtil.fill(this, 0x00FFFFFF);
		FlxSpriteUtil.drawRect(this, 0, 0, PlayState.i.tile_size.x * w + 4, PlayState.i.tile_size.y * h + 4, 0x00FFFFFF, { thickness: 2, color:0xFF000000 });
		FlxSpriteUtil.drawRect(this, 1, 1, PlayState.i.tile_size.x * w + 2, PlayState.i.tile_size.y * h + 2, 0x00FFFFFF, { thickness: 2, color:0xFFFFFFFF });
	}

}