package panels;

import Defs.EContext;
import Defs.IHasContext;
import js.html.Element;
import js.Browser.document;

class Tools implements IHasContext
{

	var element:Element;

	var tool_cursor:Element;
	var tool_pencil:Element;
	var tool_eraser:Element;
	var tool_bucket:Element;
	var current_tool:Element;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('tools');
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
		App.i.tool = switch (tool.id)
		{
			case 'icon_cursor': CURSOR;
			case 'icon_pencil': PENCIL;
			case 'icon_eraser': ERASER;
			case 'icon_bucket': BUCKET;
			default: PENCIL;
		}
		if (current_tool != null) current_tool.classList.remove('selected');
		current_tool = tool;
		current_tool.classList.add('selected');
	}

	public function set_context(context:EContext)
	{
		switch (context) {
			case TILE:
				tool_cursor.hidden = true;
				tool_bucket.hidden = false;
				if (current_tool == tool_cursor) select_tool(tool_pencil);
			case ENTITY:
				tool_cursor.hidden = false;
				tool_bucket.hidden = true;
				if (current_tool == tool_bucket) select_tool(tool_pencil);
		}
	}

}