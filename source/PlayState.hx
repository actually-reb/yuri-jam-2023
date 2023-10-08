package;

import Player.PlayerCommand;
import Player.PlayerType;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.scaleModes.RatioScaleMode;
import openfl.utils.Assets;

typedef LevelData =
{
	var name:String;
	var map:Array<String>;
}

class PlayState extends FlxState
{
	public var room:Room;
	public var elapsed:Float;

	var players:Array<Player> = new Array<Player>();
	var tileUpdates:Array<TileSprite> = new Array<TileSprite>();

	override public function create()
	{
		super.create();
		FlxG.mouse.useSystemCursor = true;

		var levels:Array<LevelData> = haxe.Json.parse(Assets.getText("assets/levels.json"));
		loadLevel(levels[0]);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		this.elapsed = elapsed;

		var cmd:PlayerCommand = null;
		if (FlxG.keys.justPressed.UP)
			cmd = Up;
		else if (FlxG.keys.pressed.LEFT)
			cmd = Left;
		else if (FlxG.keys.pressed.RIGHT)
			cmd = Right;
		else if (FlxG.keys.justPressed.DOWN)
			cmd = Down;

		if (cmd != null)
			sendCommand(cmd, Player2);

		cmd = null;
		if (FlxG.keys.justPressed.W)
			cmd = Up;
		else if (FlxG.keys.pressed.A)
			cmd = Left;
		else if (FlxG.keys.pressed.D)
			cmd = Right;
		else if (FlxG.keys.justPressed.S)
			cmd = Down;

		if (cmd != null)
			sendCommand(cmd, Player1);

		for (o in tileUpdates)
			o.gameUpdate();
	}

	public function loadLevel(level:LevelData)
	{
		var height = level.map.length;
		var width = level.map[0].length;
		this.room = new Room(width, height);

		var y = 0;
		for (line in level.map)
		{
			for (x in (0...line.length))
			{
				var char = line.charAt(x);
				switch char
				{
					case "#":
						new Wall(this, x, y);
					case "$":
						new Crate(this, x, y);
					case "1":
						new Player(this, x, y, Player1);
					case "2":
						new Player(this, x, y, Player2);
				}
			}
			y += 1;
		}
	}

	function sendCommand(cmd:PlayerCommand, type:PlayerType)
	{
		for (p in this.players)
			if (p.type == type)
				p.command(cmd);
	}

	static function zsort(order:Int, a:FlxBasic, b:FlxBasic)
	{
		// Implement ZLayer or else!!
		var aa:ZLayer = cast a;
		var bb:ZLayer = cast b;

		if (aa.zlayer() < bb.zlayer())
			return -1;
		else if (aa.zlayer() > bb.zlayer())
			return 1;
		else
			return 0;
	}

	static function prioritysort(a:TileSprite, b:TileSprite)
	{
		if (a.updatePriority() < b.updatePriority())
			return -1;
		else if (a.updatePriority() > b.updatePriority())
			return 1;
		else
			return 0;
	}

	public function addTileSprite(spr:TileSprite)
	{
		add(spr);
		room.addSprite(spr);
		sort(zsort);
		if (spr.updatePriority() > 0)
		{
			tileUpdates.push(spr);
			tileUpdates.sort(prioritysort);
		}
	}

	public function addPlayer(player:Player)
	{
		players.push(player);
	}
}
