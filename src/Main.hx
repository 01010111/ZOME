import js.Node;
import electron.main.App;
import electron.main.BrowserWindow;

class Main 
{

	static function main()
	{
		electron.CrashReporter.start({
			companyName: 'hxelectron',
			submitURL : "https://github.com/tong/hxelectron/issues"
		});

		App.on(ready, (e) -> createWindow());
		#if !heaps
		App.disableHardwareAcceleration();
		#end
	}

	static function createWindow()
	{
		var window = new BrowserWindow( { width: 1280, height: 800, minWidth: 800, minHeight: 600 } );
		window.on(closed, () -> {
			window = null;
			App.quit();
		});
		window.loadFile('app.html');
	}

}