package;

import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import js.html.PlaybackDirection;

/*
	enum Facing
	{
		Left;
		Right;
	}
 */
enum PlayerType
{
	Player1;
	Player2;
}

enum PlayerCommand
{
	Up;
	Down;
	Left;
	Right;
}

/*
	class PlayerInput
	{
	public var player:PlayerType;
	public var cmd:PlayerCommand;

	public function new(player, cmd)
	{
		this.player = player;
		this.cmd = cmd;
	}
	}
 */
class Player extends TileSprite
{
	public var type:PlayerType;

	public function new(game:PlayState, tx, ty, type:PlayerType)
	{
		super(game, tx, ty);
		this.type = type;
		this.zlayer = 500;
		this.facing = RIGHT;
		game.addPlayer(this);

		if (type == Player1)
			loadGraphic("assets/player1.png");
		else
			loadGraphic("assets/player2.png");

		var x:FlxTilemap;

		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
	}

	public function gameUpdate(game:PlayState, elapsed:Float)
	{
		fall(game);
	}

	public function command(game:PlayState, cmd:PlayerCommand)
	{
		switch cmd
		{
			case Up:
				climb(game);
			case Down:
			case Left:
				walk(game, -1);
			case Right:
				walk(game, 1);
		}

		fall(game);
	}

	function walk(game:PlayState, dir:Int)
	{
		facing = (dir < 0) ? LEFT : RIGHT;
		if (game.room.get(this.tx + dir, this.ty).isEmpty())
		{
			move(game, this.tx + dir, this.ty);
		}
	}

	function climb(game:PlayState)
	{
		var dir = getDirInt();

		if (game.room.get(this.tx + dir, this.ty).isEmpty())
			return;

		if (game.room.get(this.tx + dir, this.ty - 1).isOccupied())
			return;

		move(game, this.tx + dir, this.ty - 1);
	}

	function fall(game:PlayState)
	{
		var depth = 0;
		// Need to start handling OOB checks better real soon!
		while (game.room.get(this.tx, this.ty + depth + 1).isEmpty())
		{
			depth += 1;
		}

		if (depth == 0)
			return;

		move(game, this.tx, this.ty + depth);
	}

	function getDirInt()
	{
		if (facing == LEFT)
			return -1;
		else
			return 1;
	}
}
