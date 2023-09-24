package;

import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxDirectionFlags;
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
	Turning;
	Climbing;
	Falling;
	Supporting;
}

class Player extends TileSprite
{
	public var type:PlayerType;
	public var state:PlayerState = Idle;

	var bufferedcommand:PlayerCommand;

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
			loadGraphic("assets/player1.png", true, 32, 32);
		else
			loadGraphic("assets/player2.png", true, 32, 32);

		animation.add("idle", [0]);
		animation.add("turn", [1], 15, false);
		animation.add("support", [2]);
		animation.finishCallback = spriteAnimFinish;
		animation.play("idle");

		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
	}

	public override function gameUpdate(game:PlayState, elapsed:Float)
	{
		trySupport(game);
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
		trySupport(game);
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
		if (state != Idle)
			return;
		var shouldface:FlxDirectionFlags = (dir < 0) ? LEFT : RIGHT;
		if (facing != shouldface)
		{
			turn(game, dir);
			return;
		}
		if (game.room.hasNoSolid(tx + dir, ty))
		{
			move(game, tx + dir, ty);
			walktimer = 0.0;
			state = Walking;
		}
	}

	function turn(game:PlayState, dir:Int)
	{
		var shouldface:FlxDirectionFlags = (dir < 0) ? LEFT : RIGHT;
		if (facing == shouldface)
			return;
		facing = shouldface;
		animation.play("turn");
		state = Turning;
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

	function trySupport(game:PlayState)
	{
		var tile = game.room.get(tx, ty - 1);
		if (tile == null)
			return false;

		if (tile.hasType(Player))
		{
			state = Supporting;
			animation.play("support");
		}
		else if (state == Supporting)
		{
			state = Idle;
			animation.play("idle");
		}

		return false;
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

	function spriteAnimFinish(name:String)
	{
		if (name == "turn")
		{
			animation.play("idle");
			state = Idle;
		}
	}
}
