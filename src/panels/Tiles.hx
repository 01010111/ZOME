package panels;

import Defs.EContext;
import js.html.Element;
import Defs.IHasContext;
import js.Browser.document;

class Tiles implements IHasContext
{

	var element:Element;
	var window:Element;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('tiles');
		window = document.getElementById('tile_selection_window');
	}

	public function set_context(context:EContext)
	{
		switch (context) {
			case TILE: element.hidden = false;
			case ENTITY: element.hidden = true;
		}
	}

}