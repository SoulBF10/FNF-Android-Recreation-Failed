package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

using StringTools;

class Main extends Sprite
{
	public static var fpsVar:FPS;

	public function new():Void
	{
		super();

		SUtil.uncaughtErrorHandler();
		SUtil.checkFiles();

		ClientPrefs.loadDefaultKeys();

		addChild(new FlxGame(1280, 720, TitleState, 60, 60, true, false));

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		fpsVar.visible = ClientPrefs.showFPS;
		addChild(fpsVar);

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}
}
