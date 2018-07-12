import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.FlxSubState;
import openfl.display.BitmapData;
import flixel.group.FlxGroup;
import flixel.FlxG;

using Math;

class TileDimensionsDialog extends FlxSubState
{

	var bmp:BitmapData;
	var width:Int = 16;
	var height:Int = 16;
	var width_slider:Slide;
	var height_slider:Slide;

	public function new(data:BitmapData)
	{
		super(0x80000000);
		bmp = data;

		var bg = new FlxSprite();
		bg.makeGraphic(288, 180, 0xFF363543);
		bg.screenCenter();
		add(bg);

		var text = new FlxText(0, 0, 200);
		text.setFormat(null, 8, 0xB4A895, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE_FAST, 0xFF000000);
		text.screenCenter();
		text.y -= 64;
		text.text = 'Please input the size of the tiles in your tileset, then press "OK".\n\nUse Arrow Keys for fine-tuning!';
		add(text);

		width_slider = new Slide(FlxG.width * 0.5, FlxG.height * 0.5, 'width', 16, function(n:Int){ width = n; });
		height_slider = new Slide(FlxG.width * 0.5, FlxG.height * 0.5 + 16, 'height', 16, function(n:Int){ height = n; });

		add(width_slider);
		add(height_slider);

		var ok_btn = new FlxButton(0, 0, 'OK', function () { exit(); });
		ok_btn.screenCenter(FlxAxes.XY);
		ok_btn.y += 64;
		add(ok_btn);
	}

	override public function update(dt:Float)
	{
		super.update(dt);

		if (FlxG.keys.justPressed.UP) height_slider.add_to(1);
		if (FlxG.keys.justPressed.DOWN) height_slider.add_to(-1);
		if (FlxG.keys.justPressed.LEFT) width_slider.add_to(-1);
		if (FlxG.keys.justPressed.RIGHT) width_slider.add_to(1);
	}

	public function exit()
	{
		PlayState.i.tile_size.set(width, height);
		PlayState.i.show_tileset(bmp);
		close();
	}

}

class Slide extends FlxGroup
{

	var label:FlxText;
	var track:FlxSprite;
	var ball:FlxSprite;
	var value:FlxText;

	var val:Int;
	var min:Int = 1;
	var max:Int = 128;
	var clicked:Bool = false;
	var last_mx:Int;
	var callback:Int -> Void = function(n:Int){};
	var min_pos:Int;
	var max_pos:Int;

	public function new(x:Float, y:Float, label:String, init_value:Int, callback:Int -> Void)
	{
		super();

		this.callback = callback;

		this.label = new FlxText(0, 0, 100);
		this.label.text = label;
		this.label.setFormat(null, 8, 0xB4A895, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE_FAST, 0xFF000000);

		value = new FlxText(0, 0, 100);
		value.setFormat(null, 8, 0xB4A895, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE_FAST, 0xFF000000);

		track = new FlxSprite();
		track.makeGraphic(132 + 2, 8, 0xFF1E2028);

		ball = new FlxSprite();
		ball.makeGraphic(3 + 2, 6, 0xFFB4A895);

		this.label.setPosition(x - 164 - 8, y);
		this.value.setPosition(x + 64 + 10, y);
		this.track.setPosition(x - 64, y + 2);
		this.ball.setPosition(x - 63 + init_value, y + 2);

		min_pos = x.round() - 63;
		max_pos = x.round() - 63 + 127;

		val = init_value;
		
		add(this.label);
		add(value);
		add(track);
		add(ball);
	}

	override public function update(dt:Float)
	{
		super.update(dt);

		value.text = '$val';

		if (FlxG.mouse.justPressed && ball.overlapsPoint(FlxG.mouse.getPosition()))
		{
			clicked = true;
			last_mx = FlxG.mouse.x.round();
		}
		if (FlxG.mouse.justReleased) clicked = false;

		if (!clicked) return;

		ball.x = FlxG.mouse.x - 1;
		ball.x = ball.x.min(max_pos).max(min_pos).round();
		val = ball.x.round() - track.x.round();
		callback(val);
	}

	public function add_to(n:Int)
	{
		ball.x = (ball.x + n).min(max_pos).max(min_pos).round();
		val = ball.x.round() - track.x.round();
		callback(val);
	}

}