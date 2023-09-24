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

class Tile extends FlxTypedGroup<TileSprite>
{
	public function isEmpty()
	{
		return this.countLiving() == -1;
	}

	public inline function isOccupied()
	{
		return !isEmpty();
	}
}

class Room
{
	public var width(default, null):Int;
	public var height(default, null):Int;

	var data:Array<Tile>;

	public function new(w, h)
	{
		this.width = w;
		this.height = h;

		this.data = new Array<Tile>();

		for (i in (0...(w * h)))
			this.data.push(new Tile());
	}

	public function isOutOfBounds(x, y)
	{
		return (x < 0 || x > this.width || y < 0 || y > this.height);
	}

	public function get(x, y)
	{
		if (isOutOfBounds(x, y))
			return null;
		return data[x + y * this.width];
	}

	public function addSprite(spr:TileSprite)
	{
		get(spr.tx, spr.ty).add(spr);
	}

	public function moveSprite(spr:TileSprite, x, y)
	{
		var tile = get(spr.tx, spr.ty);

		// Maybe this check is unnecessary
		if (tile.members.indexOf(spr) < 0)
			return;

		tile.remove(spr);

		var newtile = get(x, y);
		if (newtile == null)
			return;
		newtile.add(spr);
		spr.tx = x;
		spr.ty = y;
	}
}

class PlayState extends FlxState
{
	public var room:Room;

	var players:Array<Player> = new Array<Player>();

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

		var cmd:PlayerCommand = null;
		if (FlxG.keys.justPressed.UP)
			cmd = Up;
		else if (FlxG.keys.justPressed.LEFT)
			cmd = Left;
		else if (FlxG.keys.justPressed.RIGHT)
			cmd = Right;
		else if (FlxG.keys.justPressed.DOWN)
			cmd = Down;

		if (cmd != null)
			sendCommand(cmd, Player2);

		cmd = null;
		if (FlxG.keys.justPressed.W)
			cmd = Up;
		else if (FlxG.keys.justPressed.A)
			cmd = Left;
		else if (FlxG.keys.justPressed.D)
			cmd = Right;
		else if (FlxG.keys.justPressed.S)
			cmd = Down;

		if (cmd != null)
			sendCommand(cmd, Player1);

		for (p in this.players)
			p.gameUpdate(this, elapsed);
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
				p.command(this, cmd);
	}

	static function zsort(order:Int, a:FlxBasic, b:FlxBasic)
	{
		// Implement ZLayer or else!!
		var aa:ZLayer = cast a;
		var bb:ZLayer = cast b;

		if (aa.zlayer < bb.zlayer)
			return -1;
		else if (aa.zlayer > bb.zlayer)
			return 1;
		else
			return 0;
	}

	public function addTileSprite(spr:TileSprite)
	{
		add(spr);
		this.room.addSprite(spr);
		this.sort(zsort);
	}

	public function addPlayer(player:Player)
	{
		addTileSprite(player);
		this.players.push(player);
	}
}
