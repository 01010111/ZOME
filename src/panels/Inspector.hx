package panels;

import Defs.EContext;
import js.html.Element;
import Defs.IHasContext;
import js.Browser.document;

class Inspector implements IHasContext
{

	var element:Element;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('inspector');
	}

	public function set_context(context:EContext)
	{
		
	}

}