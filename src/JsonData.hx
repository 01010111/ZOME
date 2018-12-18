import haxe.Json;

class JsonData
{

	public static var project_data:ProjectData = {
		name: 'Unknown',
		levels: [],
	}

	public static function save()
	{
		var json:String = Json.stringify(project_data);
		trace(json);
	}

	public static function load(data:String)
	{
		var temp_data:ProjectData = Json.parse(data);
		project_data = temp_data;
	}

}

typedef ProjectData =
{
	name:String,
	levels:Array<LevelData>,
}

typedef LevelData =
{
	name:String,
	layers:Array<LayerData>,
}

typedef LayerData =
{
	context:EContext,
	width:Int,
	height:Int,
	?tilemap:TilemapData,
	?entities:Array<EntityData>,
}

typedef TilemapData =
{
	data:Array<Array<Int>>,
	tileset:String,
	tile_width:Int,
	tile_height:Int,
}

typedef EntityData =
{
	name:String,
	x:Int,
	y:Int,
	options:Dynamic,
}

enum EContext
{
	TILE;
	ENTITY;
}
