package modals;

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

class AddLevel implements IModal
{

	public var element:Element;
	public var name:InputElement;
	public var button:ButtonElement;

	public function new()
	{
		init();
	}

	function init()
	{
		element = document.getElementById('add_level_modal');
		
		var body = document.createElement('div');
		body.classList.add('modal_content');
		body.classList.add('panel');
		body.style.width = '300px';
		body.style.height = '224px';
		
		name = document.createInputElement();
		name.classList.add('full_width');
		name.placeholder = 'Level Name';
		name.oninput = (e) -> button.disabled = name.value.length == 0;
		name.onkeydown = (e) -> if (name.value.length > 0 && e.keyCode == 13) button.onclick();

		button = document.createButtonElement();
		button.innerHTML = 'Add Level';
		button.classList.add('full_width');
		button.disabled = true;
		button.onclick = (e) -> {
			App.i.levels.add_level(name.value);
			reset();
			close();
		}

		var cancel_btn = document.createButtonElement();
		cancel_btn.innerHTML = 'Cancel';
		cancel_btn.classList.add('full_width');
		cancel_btn.classList.add('red');
		cancel_btn.onclick = (e) -> {
			reset();
			close();
		}

		element.appendChild(body);
		body.appendChild(Factory.make_h1('New Level'));
		body.appendChild(Factory.make_separator());
		body.appendChild(Factory.make_spacer(8));
		body.appendChild(name);
		body.appendChild(Factory.make_spacer(16));
		body.appendChild(button);
		body.appendChild(Factory.make_spacer(8));
		body.appendChild(cancel_btn);

		close();
	}

	function get_context_enum(value:String):EContext
	{
		switch (value)
		{
			case 'TILE': return TILE;
			case 'ENTITY': return ENTITY;
			default: return TILE;
		}
	}

	function reset()
	{
		name.value = '';
		button.disabled = true;
	}

	public function open()
	{
		element.style.display = 'block';
	}

	public function close()
	{
		element.style.display = 'none';
	}

}