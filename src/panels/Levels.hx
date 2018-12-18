package panels;

import js.html.ParagraphElement;
import js.html.Element;
import js.Browser.document;

using Math;

class Levels
{

	var element:Element;
	var window:Element;

	var current_level:Level;
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
		add_btn = document.getElementById('add_level');
		delete_btn = document.getElementById('delete_level');
		add_btn.onclick = (e) -> invoke_add_level_modal();
		delete_btn.onclick = (e) -> invoke_delete_level_modal(current_level);
	}

	function invoke_add_level_modal()
	{
		/* Waiting on https://github.com/tong/hxelectron/issues/42 */
	}

	function invoke_delete_level_modal(level:Level)
	{
		/* Waiting on https://github.com/tong/hxelectron/issues/42 */
	}

	public function add_level(name:String)
	{
		var level = new Level(name);
		level.element.onclick = (e) -> select_level(level);
		window.appendChild(level.element);
		if (current_level == null) select_level(level);
		levels.push(level);
	}

	function select_level(level:Level)
	{
		if (current_level != null) current_level.deselect();
		current_level = level;
		current_level.select();
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

}

class Level
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