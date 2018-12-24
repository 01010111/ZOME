package panels;

import Defs.IRenderer;
import js.html.Element;
import js.Browser.document;

class Workspace
{

	var element:Element;
	var renderer:IRenderer;

	public function new()
	{
		element = document.getElementById('workspace');
	}

	public function init(on_init:Void->Void)
	{
		#if heaps
		renderer = Type.createInstance(renderers.HeapsRenderer, []);
		#else
		renderer = Type.createInstance(renderers.HtmlRenderer, []);
		#end

		renderer.create(element, on_init);
	}

	public function rebuild(width:Int, height:Int, tile_width:Int, tile_height:Int)
	{
		renderer.rebuild(width, height, tile_width, tile_height);
	}

}