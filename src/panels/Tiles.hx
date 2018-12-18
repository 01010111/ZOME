package panels;

import Defs.EContext;
import js.html.Element;
import Defs.IHasContext;
import js.Browser.document;

class Tiles implements IHasContext
{

	var element:Element;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('tiles');
	}

	public function set_context(context:EContext)
	{
		switch (context) {
			case TILE: element.hidden = false;
			case ENTITY: element.hidden = true;
		}
	}

}