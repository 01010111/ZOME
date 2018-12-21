package panels;

import js.html.Element;
import js.Browser.document;
import util.Factory;

using Math;

class Workspace
{

	var element:Element;
	var tile_container:Element;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('workspace');
		tile_container = document.getElementById('tile_container');
	}

	public function rebuild(width:Int, height:Int, tile_width:Int, tile_height:Int)
	{
		reset();

		width = (width / tile_width).floor() * tile_width;
		height = (height / tile_height).floor() * tile_height;

		tile_container.style.minWidth = '${width}px';
		tile_container.style.minHeight = '${height}px';
		tile_container.style.maxWidth = '${width}px';
		tile_container.style.maxHeight = '${height}px';

		for (j in 0...(height / tile_height).ceil())
		{
			var row = Factory.make_div(['workspace_row']);
			for (i in 0...(width / tile_width).ceil())
			{
				var cell = Factory.make_div(['workspace_tile']);
				cell.style.width = '${tile_width}px';
				cell.style.height = '${tile_height}px';
				cell.onclick = (e) -> trace(i, j);
				row.appendChild(cell);
			}
			tile_container.appendChild(row);
		}
	}

	function reset()
	{
		while (tile_container.lastChild != null)
		{
			while (tile_container.lastChild.lastChild != null) tile_container.lastChild.removeChild(tile_container.lastChild.lastChild);
			tile_container.removeChild(tile_container.lastChild);
		}
	}

}