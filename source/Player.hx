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

enum PlayerState
{
	Idle;
	Moving;
}

class Player extends TileSprite
{
	public var type:PlayerType;
	public var state:PlayerState = Idle;

	// var blockers:Array<Blocker> = new Array<Blocker>();

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

	public override function gameUpdate(game:PlayState, elapsed:Float)
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
		if (game.room.hasNoSolid(this.tx + dir, this.ty))
		{
			move(game, this.tx + dir, this.ty);
		}
	}

	function climb(game:PlayState)
	{
		var dir = getDirInt();

		if (game.room.hasNoSolid(this.tx + dir, this.ty))
			return;

		if (game.room.hasSolid(this.tx + dir, this.ty - 1))
			return;

		move(game, this.tx + dir, this.ty - 1);
	}

	function fall(game:PlayState)
	{
		var depth = 0;

		while (game.room.hasNoSolid(this.tx, this.ty + depth + 1))
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
