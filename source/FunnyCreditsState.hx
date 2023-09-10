package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.utils.Assets;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class FunnyCreditsState extends MusicBeatState // Reusing CreditsState cuz BIG BRAIN TIME
{
	var curIcon:Int = -1;

	var lookin:Bool = false;
	var canClick:Bool = false;
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];
	var credIcons:Array<FlxSprite> = [];

	var bg:FlxSprite;
	var border:FlxSprite;
	var selector:FlxSprite;
	var stars:FlxSprite;

	var nameText:FlxText;
	var roleText:FlxText;
	var quoteText:FlxText;

	var selXLerp:Float = 0;
	var selYLerp:Float = 0;

	var bigIcons:FlxTypedGroup<FlxSprite>;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Perusing the Credits", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menus/credits/bg'));
		add(bg);

		selector = new FlxSprite().loadGraphic(Paths.image('menus/credits/credits_selector'));
		add(selector);

		border = new FlxSprite().loadGraphic(Paths.image('menus/credits/creditsoverlay'));
		add(border);

		if (Assets.exists(Paths.txt('creditss')))
		{
			for (i in Assets.getText(Paths.txt('creditss')).split('\n'))
			{
				final arr:Array<String> = i.replace('\\n', '\n').split('::');

				if (arr.length >= 5)
					arr.push('');

				creditsStuff.push(arr);
			}

			creditsStuff.push(['']);
		}

		var pisspoop:Array<Array<String>> = [];

		bigIcons = new FlxTypedGroup<FlxSprite>();
		add(bigIcons);

		for (i in pisspoop)
			creditsStuff.push(i);

		for (i in 0...creditsStuff.length)
		{
			var smallIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/credits/icons/' + creditsStuff[i][1]));
			smallIcon.scale.set(0.6, 0.6);
			smallIcon.antialiasing = true;
			smallIcon.updateHitbox();

			// look man im tired
			switch (i)
			{
				case 0:
					smallIcon.x = 192;
					smallIcon.y = 36;
				case 1:
					smallIcon.x = 452;
					smallIcon.y = 34;
				case 2:
					smallIcon.x = -7;
					smallIcon.y = 161;
				case 3:
					smallIcon.x = 105;
					smallIcon.y = 179;
				case 4:
					smallIcon.x = 223;
					smallIcon.y = 184;
				case 5:
					smallIcon.x = 345;
					smallIcon.y = 190;
				case 6:
					smallIcon.x = 488;
					smallIcon.y = 198;
				case 7:
					smallIcon.x = 649;
					smallIcon.y = 200;
				case 8:
					smallIcon.x = -6;
					smallIcon.y = 286;
				case 9:
					smallIcon.x = 105;
					smallIcon.y = 294;
				case 10:
					smallIcon.x = 222;
					smallIcon.y = 306;
				case 11:
					smallIcon.x = 346;
					smallIcon.y = 319;
				case 12:
					smallIcon.x = 494;
					smallIcon.y = 337;
				case 13:
					smallIcon.x = 654;
					smallIcon.y = 350;
				case 14:
					smallIcon.x = 38;
					smallIcon.y = 401;
				case 15:
					smallIcon.x = 167;
					smallIcon.y = 428;
				case 16:
					smallIcon.x = 296;
					smallIcon.y = 459;
				case 17:
					smallIcon.x = 440;
					smallIcon.y = 492;
				case 18:
					smallIcon.x = 591;
					smallIcon.y = 510;
				default:
					smallIcon.x = 0;
					smallIcon.y = 0;
			}

			if (i <= 18)
			{
				add(smallIcon);
				smallIcon.ID = i;

				credIcons.push(smallIcon);
				FlxMouseEvent.add(smallIcon, null, null, hoverCallback, null, false, true, false);

				var bigIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/credits/portrait/' + creditsStuff[i][1]));
				bigIcon.scale.set(0.65, 0.65);
				bigIcon.x = 875;
				bigIcon.y = 35;
				bigIcon.updateHitbox();

				add(bigIcon);
				bigIcon.ID = i;
				bigIcons.add(bigIcon);
			}
		}

		stars = new FlxSprite().loadGraphic(Paths.image('menus/credits/credits_stars'));
		add(stars);

		nameText = new FlxText(860, 400, 1180, "", 35);
		nameText.setFormat(Paths.font("Marker Felt.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nameText.scrollFactor.set();
		nameText.borderSize = 1.2;
		add(nameText);

		roleText = new FlxText(860, 440, 400, "", 30);
		roleText.setFormat(Paths.font("Marker Felt.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		roleText.scrollFactor.set();
		roleText.borderSize = 1.2;
		add(roleText);

		quoteText = new FlxText(860, 540, 400, "", 30);
		quoteText.setFormat(Paths.font("Marker Felt.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		quoteText.scrollFactor.set();
		quoteText.borderSize = 1.2;
		add(quoteText);

		FlxG.mouse.visible = true;

		updateSelection(0);

		#if mobile
		addVirtualPad(BLANK, B);
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			exit();
		}

		selector.x = FlxMath.lerp(selector.x, selXLerp, 0.25);
		selector.y = FlxMath.lerp(selector.y, selYLerp, 0.25);

		super.update(elapsed);
	}

	function exit()
	{
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('cancelMenu'));
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		MusicBeatState.switchState(new MainMenuState());
	}

	function updateSelection(sel:Int)
	{
		var smallIcon:FlxSprite = credIcons[sel];

		selXLerp = smallIcon.x;
		selYLerp = smallIcon.y;

		nameText.text = creditsStuff[sel][0];
		roleText.text = creditsStuff[sel][2];
		quoteText.text = creditsStuff[sel][3];

		bigIcons.forEach(function(spr:FlxSprite) // portrait
		{
			if (spr.ID == sel)
			{
				spr.alpha = 1.0;
			}
			else
			{
				spr.alpha = 0;
			}
		});
	}

	function hoverCallback(object:FlxObject)
	{
		trace("overlap " + object.ID);
		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateSelection(object.ID);
		curIcon = object.ID;
	}
}
