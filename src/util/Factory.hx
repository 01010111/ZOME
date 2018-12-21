package util;

import js.html.Element;
import js.Browser.document;
import js.html.OptionElement;

class Factory
{

	public static function make_option(value:String, text:String):OptionElement
	{
		var option = document.createOptionElement();
		option.value = value;
		option.innerHTML = text;
		return option;
	}

	public static function make_h1(text:String):Element
	{
		var h1 = document.createElement('h1');
		h1.innerText = text;
		return h1;
	}

	public static function make_spacer(size:Int):Element
	{
		var spacer = document.createElement('div');
		spacer.style.minHeight = '${size}px';
		return spacer;
	}

	public static function make_separator():Element
	{
		var separator = document.createElement('div');
		separator.classList.add('separator');
		return separator;
	}

	public static function make_div(?classes:Array<String>):Element
	{
		if (classes == null) classes = [];
		var div = document.createElement('div');
		for (c in classes) div.classList.add(c);
		return div;
	}

}