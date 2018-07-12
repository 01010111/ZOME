import openfl.display.BitmapData;
import systools.Dialogs;
import haxe.Json;
import PlayState;

class FileUtils
{

	public static var json_path:String;

	public static function load_json():SaveFileWithPath
	{
		var result:Array<String> = Dialogs.openFile(
			"Select a file please!",
			"Please select one or more files, so we can see if this method works",
			{
				count: 2,
				descriptions: ["JSON files"],
				extensions: ["*.json"]
			}
		);
		if (result != null && result.length > 0)
		{
			json_path = result[0];
			var json = sys.io.File.getContent(result[0]);

			if (json != null)
			{
				var o = Json.parse(json);
				if (o.data != null && o.tileset != null) return {
					save:o,
					path:result[0]
				};
			}
		}
		return null;
	}

	public static function save_json(filename:String, array:Array<Array<Int>>, save_as:Bool = false)
	{
		var json = Json.stringify({
			tileset: filename,
			data: array
		});
		if (json_path == null) save_as = true;
		var destination = save_as ? systools.Dialogs.saveFile( "", "Select a destination", "../../../") : json_path;
        if (destination != null) 
		{
            var file = sys.io.File.write(destination,false);
            try 
			{ 
                file.write(haxe.io.Bytes.ofString(json)); 
                file.flush(); 
            }
			catch(err:Dynamic) trace('saveText',err,true);
            file.close();
			json_path = destination;
        }
	}

	public static function load_image():Null<ImageWithData>
	{
		var result:Array<String> = Dialogs.openFile(
			"Select a file please!",
			"Please select one or more files, so we can see if this method works",
			{
				count: 2,
				descriptions: ["PNG files", "JPEG files"],
				extensions: ["*.png","*.jpg;*.jpeg"]
			}
		);

		if (result != null && result.length > 0)
		{
			var split_path = result[0].split('/');
			var name = split_path[split_path.length - 1];
			var img = BitmapData.fromFile(result[0]);
			if (img != null) return {
				img:img,
				name:name
			};
		}

		return null;
	}

}

typedef ImageWithData =
{
	name:String,
	img:BitmapData
}

typedef SaveFileWithPath =
{
	save:SaveFile,
	path:String
}