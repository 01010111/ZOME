import Defs.IHasContext;
import Defs.ETool;
import Defs.EContext;
import panels.*;
import modals.*;

class App implements IHasContext
{

    static function main() new App();
	public static var i:App;

	public var tools:Tools;
	public var layers:Layers;
	public var levels:Levels;
	public var tiles:Tiles;
	public var entities:Entities;
	public var inspector:Inspector;

	public var workspace:Workspace;

	public var add_layer_modal:AddLayer;
	public var add_level_modal:AddLevel;
	public var delete_layer_modal:DeleteLayer;
	public var delete_level_modal:DeleteLevel;

	public var tool:ETool;
	public var context:EContext;

	public function new()
	{
		i = this;
		init_panels();
		init_modals();
		levels.add_level('Level');
		workspace.init(() -> {
			workspace.rebuild(512, 288, 16, 16);
		});
	}

	function init_panels()
	{
		tools = new Tools();
		layers = new Layers();
		levels = new Levels();
		tiles = new Tiles();
		entities = new Entities();
		inspector = new Inspector();
		workspace = new Workspace();
	}

	function init_modals()
	{
		add_layer_modal = new AddLayer();
		add_level_modal = new AddLevel();
		delete_layer_modal = new DeleteLayer();
		delete_level_modal = new DeleteLevel();
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