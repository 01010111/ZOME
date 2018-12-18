package panels;

import Defs.EContext;
import js.html.Element;
import Defs.IHasContext;
import js.Browser.document;

class Entities implements IHasContext
{

	var element:Element;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('entities');
	}

	public function set_context(context:EContext)
	{
		switch (context) {
			case TILE: element.hidden = true;
			case ENTITY: element.hidden = false;
		}
	}

}