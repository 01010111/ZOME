package panels;

import panels.Layers.Layer;
import js.html.ParagraphElement;
import js.html.Element;
import js.Browser.document;

using Math;

class Levels
{

	var element:Element;
	var window:Element;

	public var current_level:Level;
	var levels:Array<Level> = [];

	var add_btn:Element;
	var delete_btn:Element;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('levels');
		window = element.getElementsByClassName('window')[0];
		add_btn = document.getElementById('add_level_btn');
		delete_btn = document.getElementById('delete_level_btn');
		add_btn.onclick = (e) -> invoke_add_level_modal();
		delete_btn.onclick = (e) -> invoke_delete_level_modal(current_level);
	}

	function invoke_add_level_modal()
	{
		App.i.add_level_modal.open();
	}

	function invoke_delete_level_modal(level:Level)
	{
		if (levels.length <= 1) return;
		App.i.delete_level_modal.level = level;
		App.i.delete_level_modal.open();
	}

	function select_level(level:Level, rebuild:Bool = true)
	{
		if (current_level != null) current_level.deselect();
		current_level = level;
		current_level.select();
		if (!rebuild) return;
		App.i.layers.rebuild_layers();
		App.i.layers.select_layer(current_level.layers[0]);
	}

	public function add_level(name:String)
	{
		var level = new Level(name);
		level.element.onclick = (e) -> select_level(level);
		if (current_level == null) levels.unshift(level);
		else levels.insert(levels.indexOf(current_level) + 1, level);
		rebuild_levels();
		select_level(level, false);
		App.i.layers.add_layer('Tiles', TILE);
		App.i.layers.rebuild_layers();
	}

	public function delete_level(level:Level)
	{
		if (levels.length <= 1) return;
		var idx = levels.indexOf(level);
		window.removeChild(level.element);
		levels.remove(level);
		if (current_level != level) return;
		select_level(levels[idx.min(levels.length - 1).floor()]);
	}

	function rebuild_levels()
	{
		while (window.lastChild != null) window.removeChild(window.lastChild);
		for (level in levels) window.appendChild(level.element);
	}

}

class Level
{

	public var element:Element;
	public var name:String;
	public var layers:Array<Layer> = [];

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