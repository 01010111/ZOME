import Defs.IHasContext;
import Defs.ETool;
import Defs.EContext;
import panels.*;

class App implements IHasContext
{

    static function main() new App();
	public static var i:App;

	var tools:Tools;
	var layers:Layers;
	var levels:Levels;
	var tiles:Tiles;
	var entities:Entities;
	var inspector:Inspector;

	public var tool:ETool;
	public var context:EContext;

	public function new()
	{
		i = this;
		init_panels();
		layers.add_layer('Tile Layer FG', TILE);
		layers.add_layer('Entity Layer', ENTITY);
		layers.add_layer('Tile Layer BG', TILE);
		levels.add_level('Level 01');
		levels.add_level('Level 02');
	}

	function init_panels()
	{
		tools = new Tools();
		layers = new Layers();
		levels = new Levels();
		tiles = new Tiles();
		entities = new Entities();
		inspector = new Inspector();
	}

	public function set_context(context:EContext)
	{
		this.context = context;
		tools.set_context(context);
		tiles.set_context(context);
		entities.set_context(context);
		inspector.set_context(context);
	}

}