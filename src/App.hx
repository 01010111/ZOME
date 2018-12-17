import js.html.ParagraphElement;
import js.html.ImageElement;
import js.html.Element;
import js.Browser.document;
import js.Browser.window;
import js.Node.process;
import js.node.ChildProcess;

class App
{

    static function main() new App();
	public static var i:App;
	
	var layers:Element;
	var levels:Element;
	var tools:Element;
	var tiles:Element;
	var entities:Element;
	var inspector:Element;

	var tool_cursor:Element;
	var tool_pencil:Element;
	var tool_eraser:Element;
	var tool_bucket:Element;

	var btn_add_layer:Element;
	var btn_add_level:Element;

	var current_tool:Element;
	var tool:ETool;
	var context:EContext;

	public function new()
	{
		i = this;
		init_panels();
		init_tools();
		init_buttons();
		show_entities();
	}

	function init_panels()
	{
		layers = document.getElementById('layers');
		levels = document.getElementById('levels');
		tools = document.getElementById('tools');
		tiles = document.getElementById('tiles');
		entities = document.getElementById('entities');
		inspector = document.getElementById('inspector');

		for (i in 0...32) add_layer_to_layers('Layer Name', (Math.random() > 0.5 ? TILE : ENTITY));
	}

	function init_tools()
	{
		tool_cursor = document.getElementById('icon_cursor');
		tool_pencil = document.getElementById('icon_pencil');
		tool_eraser = document.getElementById('icon_eraser');
		tool_bucket = document.getElementById('icon_bucket');
		for (tool in [tool_cursor, tool_pencil, tool_eraser, tool_bucket]) tool.onclick = (e) -> select_tool(tool);
		select_tool(tool_cursor);
	}

	function select_tool(tool:Element)
	{
		if (current_tool == tool) return;
		switch (tool.id)
		{
			case 'icon_cursor': this.tool = CURSOR;
			case 'icon_pencil': this.tool = PENCIL;
			case 'icon_eraser': this.tool = ERASER;
			case 'icon_bucket': this.tool = BUCKET;
			default: return;
		}
		if (current_tool != null) current_tool.classList.remove('selected');
		current_tool = tool;
		current_tool.classList.add('selected');
	}

	function init_buttons()
	{
		btn_add_layer = document.getElementById('add_layer');
		btn_add_level = document.getElementById('add_level');

		btn_add_layer.onclick = (e) -> add_layer();
		btn_add_level.onclick = (e) -> add_level();
	}

	function add_layer()
	{

	}

	function add_layer_to_layers(name:String, context:EContext)
	{
		var win = layers.getElementsByClassName('window')[0];
		win.appendChild(new LayerPanel(context, name).element);
	}

	function add_level()
	{

	}

	function show_tiles()
	{
		context = TILE;

		tiles.hidden = false;
		entities.hidden = true;

		tool_bucket.hidden = false;
		tool_cursor.hidden = true;

		if (tool_cursor == current_tool) select_tool(tool_pencil);
	}

	function show_entities()
	{
		context = ENTITY;

		tiles.hidden = true;
		entities.hidden = false;

		tool_bucket.hidden = true;
		tool_cursor.hidden = false;

		if (tool_bucket == current_tool) select_tool(tool_pencil);
	}

}

class LayerPanel
{

	public var element:Element;

	var context:EContext;
	var name:String;
	var visible:Bool = true;

	var text:ParagraphElement;
	var icon:ImageElement;
	var vis_icon:Element;

	public function new(context:EContext, name:String)
	{
		this.context = context;
		this.name = name;
		create_element();
		create_icon();
		create_text();
	}

	function create_element()
	{
		element = document.createElement('div');
		element.classList.add('layer_panel');
		element.classList.add('window_panel');
	}

	function create_icon()
	{
		icon = document.createImageElement();
		icon.src = switch (context) {
			case TILE: 'icons/icon_tiles.svg';
			case ENTITY: 'icons/icon_objects.svg';
		}
		icon.classList.add('layer_icon');
		element.appendChild(icon);
	}

	function create_text()
	{
		text = document.createParagraphElement();
		text.innerText = name;
		text.classList.add('layer_name');
		element.appendChild(text);
	}

	public function select()
	{
		element.classList.add('selected');
	}

	public function deselect()
	{
		element.classList.remove('selected');
	}

}

enum EContext
{
	TILE;
	ENTITY;
}

enum ETool
{
	CURSOR;
	PENCIL;
	ERASER;
	BUCKET;
}