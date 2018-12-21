package modals;

import panels.Layers.Layer;
import js.html.ParagraphElement;
import Defs.LayerData;
import Defs.EContext;
import js.html.DivElement;
import js.html.OptionElement;
import js.html.ButtonElement;
import js.html.InputElement;
import js.html.SelectElement;
import js.Browser.document;
import js.html.Element;
import Defs.IModal;
import util.Factory;

class DeleteLayer implements IModal
{

	public var element:Element;
	public var text:ParagraphElement;
	public var button:ButtonElement;
	public var layer:Layer;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('delete_layer_modal');
		
		var body = document.createElement('div');
		body.classList.add('modal_content');
		body.classList.add('panel');
		body.style.width = '300px';
		body.style.height = '200px';
		
		text = document.createParagraphElement();

		button = document.createButtonElement();
		button.innerHTML = 'YES';
		button.classList.add('full_width');
		button.classList.add('red');
		button.onclick = (e) -> {
			App.i.layers.delete_layer(layer);
			close();
		}

		var cancel_btn = document.createButtonElement();
		cancel_btn.innerHTML = 'Cancel';
		cancel_btn.classList.add('full_width');
		cancel_btn.onclick = (e) -> {
			close();
		}

		element.appendChild(body);
		body.appendChild(Factory.make_h1('Delete Layer'));
		body.appendChild(Factory.make_separator());
		body.appendChild(Factory.make_spacer(8));
		body.appendChild(text);
		body.appendChild(Factory.make_spacer(16));
		body.appendChild(button);
		body.appendChild(Factory.make_spacer(8));
		body.appendChild(cancel_btn);

		close();
	}

	public function open()
	{
		text.innerHTML = 'Are you sure you want to delete the ${layer.context.getName().toLowerCase()} layer "${layer.name}"? Its contents will be lost forever!';
		element.style.display = 'block';
	}

	public function close()
	{
		element.style.display = 'none';
	}

}