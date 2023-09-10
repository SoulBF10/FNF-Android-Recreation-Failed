package;

import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import sys.thread.Thread;

class DiscordClient
{
	public static var isInitialized:Bool = false;

	public function new():Void
	{
		trace("Discord Client starting...");

		var handlers:DiscordEventHandlers = DiscordEventHandlers.create();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize("1096671725820854345", cpp.RawPointer.addressOf(handlers), 1, null);

		trace("Discord Client started.");

		while (true)
		{
			#if DISCORD_DISABLE_IO_THREAD
			Discord.UpdateConnection();
			#end
			Discord.RunCallbacks();
			Sys.sleep(2);
		}

		Discord.Shutdown();
	}

	public static function shutdown():Void
	{
		Discord.Shutdown();
	}

	public static function initialize():Void
	{
		Thread.create(function()
		{
			new DiscordClient();
		});

		trace("Discord Client initialized");

		isInitialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float):Void
	{
		var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		var discordPresence:DiscordRichPresence = DiscordRichPresence.create();
		discordPresence.details = details;
		discordPresence.state = state;
		discordPresence.largeImageKey = "icon";
		discordPresence.largeImageText = "Psych Engine";
		discordPresence.smallImageKey = smallImageKey;
		discordPresence.startTimestamp = Std.int(startTimestamp / 1000);
		discordPresence.endTimestamp = Std.int(endTimestamp / 1000);
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		var requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		trace('Discord: Connected to User (' + cast(requestPtr.username, String) + '#' + cast(requestPtr.discriminator, String) + ')');

		var discordPresence:DiscordRichPresence = DiscordRichPresence.create();
		discordPresence.details = "In the Menus";
		discordPresence.state = null;
		discordPresence.largeImageKey = "icon";
		discordPresence.largeImageText = "Psych Engine";
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Disconnected (' + errorCode + ': ' + cast(message, String) + ')');
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Error (' + errorCode + ': ' + cast(message, String) + ')');
	}
}
