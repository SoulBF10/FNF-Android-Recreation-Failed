package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['notes', 'controls', 'prefs'];
	private var grpOptions:FlxTypedGroup<Alphabet>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	var menuItemz:FlxTypedGroup<FlxSprite>;

	function openSelectedSubstate(label:String)
	{
		#if mobile
		removeVirtualPad();
		#end

		switch (label)
		{
			case 'notes':
				openSubState(new options.NotesSubState());
			case 'controls':
				openSubState(new options.ControlsSubState());
			case 'prefs':
				openSubState(new options.PreferencesSubState());
		}
	}

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/options/optioness'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		menuItemz = new FlxTypedGroup<FlxSprite>();
		add(menuItemz);

		for (i in 0...options.length)
		{
			var offset:Float = 108 - (Math.max(options.length, 4) - 4) * 80;
			// Reusing the main menu code like some non lmao
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.frames = Paths.getSparrowAtlas('menus/options/buddons/options-' + options[i]);
			menuItem.animation.addByPrefix('idle', 'options-' + options[i] + " unsel", 1);
			menuItem.animation.addByPrefix('selected', 'options-' + options[i] + " sel", 1);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItemz.add(menuItem);
			var scr:Float = (options.length - 4) * 0.135;
			if (options.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
		}

		var overlayy:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/options/optionoverlay'));
		overlayy.updateHitbox();
		overlayy.screenCenter();
		overlayy.antialiasing = ClientPrefs.globalAntialiasing;
		add(overlayy);

		changeItem();

		ClientPrefs.saveSettings();

		#if mobile
		addVirtualPad(UP_DOWN, A_B);
		#end

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeItem(-1);
		}

		if (controls.UI_DOWN_P)
		{
			changeItem(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			openSelectedSubstate(options[curSelected]);
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItemz.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItemz.length - 1;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		menuItemz.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if (menuItemz.length > 4)
				{
					add = menuItemz.length * 8;
				}
				spr.centerOffsets();
			}
		});
	}
}
