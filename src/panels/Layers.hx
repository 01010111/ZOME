package panels;

import js.Browser;
import Defs.EContext;
import js.html.ImageElement;
import js.html.ParagraphElement;
import js.html.Element;
import js.Browser.document;

using Math;

class Layers
{

	var element:Element;
	var window:Element;
	
	var current_layer:Layer;

	var add_btn:Element;
	var delete_btn:Element;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('layers');
		window = element.getElementsByClassName('window')[0];
		add_btn = document.getElementById('add_layer_btn');
		delete_btn = document.getElementById('delete_layer_btn');
		add_btn.onclick = (e) -> invoke_add_layer_modal();
		delete_btn.onclick = (e) -> invoke_delete_layer_modal(current_layer);
	}

	function invoke_add_layer_modal()
	{
		App.i.add_layer_modal.open();
	}

	function invoke_delete_layer_modal(layer:Layer)
	{
		if (App.i.levels.current_level.layers.length <= 1) return;
		App.i.delete_layer_modal.layer = layer;
		App.i.delete_layer_modal.open();
	}

	public function select_layer(layer:Layer)
	{
		if (current_layer != null) current_layer.deselect();
		current_layer = layer;
		current_layer.select();
		App.i.set_context(layer.context);
	}

	public function add_layer(name:String, context:EContext)
	{
		var layer = new Layer(context, name);
		layer.element.onclick = (e) -> select_layer(layer);
		if (current_layer == null) App.i.levels.current_level.layers.unshift(layer);
		else App.i.levels.current_level.layers.insert(App.i.levels.current_level.layers.indexOf(current_layer), layer);
		rebuild_layers();
		select_layer(layer);
	}

	public function delete_layer(layer:Layer)
	{
		if (App.i.levels.current_level.layers.length <= 1) return;
		var idx = App.i.levels.current_level.layers.indexOf(layer);
		window.removeChild(layer.element);
		App.i.levels.current_level.layers.remove(layer);
		if (current_layer != layer) return;
		select_layer(App.i.levels.current_level.layers[idx.min(App.i.levels.current_level.layers.length - 1).floor()]);
	}

	public function rebuild_layers()
	{
		while (window.lastChild != null) window.removeChild(window.lastChild);
		for (layer in App.i.levels.current_level.layers) window.appendChild(layer.element);
	}

}

class Layer
{

	public var element:Element;
	public var context:EContext;
	public var name:String;

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