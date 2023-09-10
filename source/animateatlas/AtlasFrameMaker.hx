package animateatlas;

import animateatlas.JSONData;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import haxe.Json;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

using StringTools;

class AtlasFrameMaker extends FlxFramesCollection
{
	public static function construct(key:String, ?excludeFrames:Array<String>, ?noAntialiasing:Bool = false):FlxFramesCollection
	{
		if (Paths.fileExists('images/$key/spritemap1.json', TEXT))
		{
			PlayState.instance.addTextToDebug("Only Spritemaps made with Adobe Animate 2018 are supported", FlxColor.RED);
			trace("Only Spritemaps made with Adobe Animate 2018 are supported");
			return null;
		}

		var animData:AnimationData = Json.parse(Paths.getTextFromFile('images/$key/Animation.json'));
		var atlasData:AtlasData = Json.parse(Paths.getTextFromFile('images/$key/spritemap.json').replace("\uFEFF", ""));
		var image:FlxGraphic = Paths.image('$key/spritemap');

		var movieClip:SpriteMovieClip = new SpriteAnimationLibrary(animData, atlasData, image.bitmap).createAnimation(noAntialiasing);
		var frameCollection:FlxFramesCollection = new FlxFramesCollection(image, IMAGE);

		for (i in (excludeFrames == null ? movieClip.getFrameLabels() : excludeFrames))
		{
			trace('Creating "$i" for "$key"...');

			for (j in getFramesArray(movieClip, i))
				frameCollection.pushFrame(j);

			trace('Finished creating "$i" for "$key"...');
		}

		return frameCollection;
	}

	@:noCompletion private static function getFramesArray(movieClip:SpriteMovieClip, animation:String):Array<FlxFrame>
	{
		movieClip.currentLabel = animation;

		var daFrames:Array<FlxFrame> = [];

		for (i in movieClip.getFrame(animation)...movieClip.numFrames)
		{
			movieClip.currentFrame = i;

			if (movieClip.currentLabel == animation)
			{
				var data:BitmapData = new BitmapData(Std.int(movieClip.getRect(movieClip).width + movieClip.getRect(movieClip).x), Std.int(movieClip.getRect(movieClip).height + movieClip.getRect(movieClip).y), true, 0);
				data.draw(movieClip, true);

				var theFrame:FlxFrame = new FlxFrame(FlxGraphic.fromBitmapData(data));
				theFrame.name = movieClip.currentLabel + movieClip.currentFrame;
				theFrame.frame = new FlxRect(0, 0, data.width, data.height);
				theFrame.sourceSize.set(data.width, data.height);
				daFrames.push(theFrame);

				data = FlxDestroyUtil.dispose(data);
			}
			else
				break;
		}

		return daFrames;
	}
}
