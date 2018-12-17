import js.Node;
import electron.main.App;
import electron.main.BrowserWindow;

class Main 
{

	static var window : BrowserWindow;

	static function main()
	{
		electron.CrashReporter.start({
			companyName: 'hxelectron',
			submitURL : "https://github.com/tong/hxelectron/issues"
		});

		App.on(ready, (e) -> createWindow());
	}

	static function createWindow()
	{
		window = new BrowserWindow( { width: 1280, height: 800 } );
		window.on(closed, () -> {
			window = null;
			App.quit();
		});
		window.loadFile('app.html');
	}

}