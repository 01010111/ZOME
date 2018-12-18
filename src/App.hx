import js.node.events.EventEmitter.Event;
import js.html.Animation;
import electron.main.BrowserWindow;
import electron.main.BrowserView;
import js.html.ParagraphElement;
import js.html.ImageElement;
import js.html.Element;
import js.Browser.document;
import js.Browser.window;
import js.Node.process;
import js.node.ChildProcess;
import JsonData;

using Math;

class App
{

    static function main() new App();
	public static var i:App;
	
	var panel_layers:Element;
	var panel_levels:Element;
	var panel_tools:Element;
	var panel_tiles:Element;
	var panel_entities:Element;
	var panel_inspector:Element;

	var tool_cursor:Element;
	var tool_pencil:Element;
	var tool_eraser:Element;
	var tool_bucket:Element;

	var btn_add_layer:Element;
	var btn_add_level:Element;
	var btn_delete_layer:Element;
	var btn_delete_level:Element;

	var current_tool:Element;
	var tool:ETool;
	var context:EContext;

	var current_layer:LayerPanel;
	var layers:Array<LayerPanel> = [];

	var current_level:LevelPanel;
	var levels:Array<LevelPanel> = [];

	public function new()
	{
		i = this;
		init_panels();
		init_tools();
		init_buttons();
		for (i in 0...32) add_layer_to_layers('Layer Name', (Math.random() > 0.5 ? TILE : ENTITY));
		for (i in 0...32) js.Node.setTimeout(() -> {
			add_level_to_levels('Level Name');
		}, i * 1000);
	}

	function init_panels()
	{
		panel_layers = document.getElementById('layers');
		panel_levels = document.getElementById('levels');
		panel_tools = document.getElementById('tools');
		panel_tiles = document.getElementById('tiles');
		panel_entities = document.getElementById('entities');
		panel_inspector = document.getElementById('inspector');
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
		btn_delete_layer = document.getElementById('delete_layer');
		btn_delete_level = document.getElementById('delete_level');

		btn_add_layer.onclick = (e) -> add_layer();
		btn_add_level.onclick = (e) -> add_level();
		btn_delete_layer.onclick = (e) -> delete_layer(current_layer);
		btn_delete_level.onclick = (e) -> delete_level(current_level);
	}

	function add_layer()
	{
		trace('hi');
		var add_layer_window = new BrowserWindow( { width: 400, height: 400 } );
		add_layer_window.on(closed, () -> add_layer_window = null);
		add_layer_window.loadFile('add_layer.html');
	}

	function add_layer_to_layers(name:String, context:EContext)
	{
		var win = panel_layers.getElementsByClassName('window')[0];
		var layer_panel = new LayerPanel(context, name);
		layer_panel.element.onclick = (e) -> select_layer(layer_panel);
		win.appendChild(layer_panel.element);
		if (current_layer == null) select_layer(layer_panel);
		layers.push(layer_panel);
	}

	function select_layer(layer:LayerPanel)
	{
		if (current_layer != null) current_layer.deselect();
		current_layer = layer;
		current_layer.select();
		switch (layer.context) {
			case TILE: show_tiles();
			case ENTITY: show_entities();
		}
	}

	function add_level()
	{

	}

	function add_level_to_levels(name:String)
	{
		var win = panel_levels.getElementsByClassName('window')[0];
		var level_panel = new LevelPanel(name);
		level_panel.element.onclick = (e) -> select_level(level_panel);
		win.appendChild(level_panel.element);
		if (current_level == null) select_level(level_panel);
		levels.push(level_panel);
	}

	function select_level(level:LevelPanel)
	{
		if (current_level != null) current_level.deselect();
		current_level = level;
		current_level.select();
	}

	function delete_layer(layer:LayerPanel, force:Bool = false)
	{
		if (layers.length <= 1 && !force) return;
		var win = panel_layers.getElementsByClassName('window')[0];
		win.removeChild(layer.element);
		if (current_layer != layer) return; 
		var idx = layers.indexOf(layer);
		layers.remove(layer);
		if (layers.length <= 0) return;
		select_layer(layers[idx.min(layers.length - 1).floor()]);
	}

	function delete_level(level:LevelPanel)
	{
		if (levels.length <= 1) return;
		var win = panel_levels.getElementsByClassName('window')[0];
		win.removeChild(level.element);
		if (current_level != level) return;
		var idx = levels.indexOf(level);
		levels.remove(level);
		select_level(levels[idx.min(levels.length - 1).floor()]);
	}

	function show_tiles()
	{
		context = TILE;

		panel_tiles.hidden = false;
		panel_entities.hidden = true;

		tool_bucket.hidden = false;
		tool_cursor.hidden = true;

		if (tool_cursor == current_tool) select_tool(tool_pencil);
	}

	function show_entities()
	{
		context = ENTITY;

		panel_tiles.hidden = true;
		panel_entities.hidden = false;

		tool_bucket.hidden = true;
		tool_cursor.hidden = false;

		if (tool_bucket == current_tool) select_tool(tool_pencil);
	}

}

class LayerPanel
{

	public var element:Element;
	public var context:EContext;

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

class LevelPanel
{

	public var element:Element;
	
	var name:String;
	var text:ParagraphElement;

	public function new(name:String)
	{
		this.name = name;
		create_element();
		create_text();
	}

	function create_element()
	{
		element = document.createElement('div');
		element.classList.add('level_panel');
		element.classList.add('window_panel');
	}

	function create_text()
	{
		text = document.createParagraphElement();
		text.innerText = name;
		text.classList.add('level_name');
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

enum ETool
{
	CURSOR;
	PENCIL;
	ERASER;
	BUCKET;
}