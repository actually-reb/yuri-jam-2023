package;

import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
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
	Walking;
	Climbing;
	Falling;
	Supporting;
}

class Player extends TileSprite
{
	public var type:PlayerType;
	public var state:PlayerState = Idle;

	// var blockers:Array<Blocker> = new Array<Blocker>();
	var walktimer:Float = 0.0;
	var falltimer:Float = 0.0;
	var climbtimer:Float = 0.0;

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
		if (state == Climbing)
			climbAnimation(game, elapsed);
		if (state == Walking)
			walkAnimation(game, elapsed);

		tryFall(game);
		if (state == Falling)
		{
			fallAnimation(game, elapsed);
			return;
		}
	}

	public function command(game:PlayState, cmd:PlayerCommand)
	{
		if (state != Idle)
			return;

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

		tryFall(game);
	}

	function walk(game:PlayState, dir:Int)
	{
		facing = (dir < 0) ? LEFT : RIGHT;
		if (game.room.hasNoSolid(tx + dir, ty))
		{
			move(game, tx + dir, ty);
			walktimer = 0.0;
			state = Walking;
		}
	}

	function climb(game:PlayState)
	{
		var dir = getDirInt();

		if (game.room.hasNoSolid(tx + dir, ty))
			return;

		if (game.room.hasSolid(tx + dir, ty - 1))
			return;

		move(game, tx + dir, ty - 1);
		climbtimer = 0.0;
		state = Climbing;
	}

	function tryFall(game:PlayState)
	{
		if (state == Falling)
			return false;
		if (state == Walking)
			return false;
		if (game.room.hasSolid(tx, ty + 1))
			return false;

		move(game, tx, ty + 1);
		state = Falling;
		falltimer = 0.0;
		return true;
	}

	function fallAnimation(game:PlayState, elapsed:Float)
	{
		if (state != Falling)
			return;

		falltimer += elapsed * 4;
		resetWorldPos();

		if (falltimer < 1.0)
		{
			y -= Global.tilesize * (1 - falltimer);
			return;
		}

		falltimer = 0.0;
		state = Idle;
		if (tryFall(game))
		{
			return fallAnimation(game, elapsed);
		}
		else
		{
			// Play landing animation
		}
	}

	function walkAnimation(game:PlayState, elapsed:Float)
	{
		if (state != Walking)
			return;

		walktimer += elapsed * 6;
		resetWorldPos();
		var dir = getDirInt();

		if (walktimer < 1.0)
		{
			// https://stackoverflow.com/questions/13462001/ease-in-and-ease-out-animation-formula
			var sq = walktimer * walktimer;
			var dist = sq / (2.0 * (sq - walktimer) + 1.0);

			x = (x + (Global.tilesize) * (-dir)) + Global.tilesize * dist * dir;
			return;
		}

		walktimer = 0.0;
		state = Idle;
	}

	function climbAnimation(game:PlayState, elapsed:Float)
	{
		if (state != Climbing)
			return;

		climbtimer += elapsed * 4;
		resetWorldPos();
		var dir = getDirInt();

		if (climbtimer < 0.5)
		{
			y += Global.tilesize;
			x += Global.tilesize * (-dir);
			var t = climbtimer * 2;
			y -= Global.tilesize * t * t;
			return;
		}
		else if (climbtimer < 1.0)
		{
			x += Global.tilesize * (-dir);
			var t = (climbtimer - 0.5) * 2;
			x += Global.tilesize * -t * (t - 2) * dir;
			return;
		}

		climbtimer = 0.0;
		state = Idle;
	}

	function getDirInt()
	{
		if (facing == LEFT)
			return -1;
		else
			return 1;
	}
}
