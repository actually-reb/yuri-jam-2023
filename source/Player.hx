package;

import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxDirectionFlags;
import js.html.ElementCreationOptions;
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
	Dropping;
	Lifting;
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
	var turntimer:Float = 0.0; // Physical turning, not a game turn
	var droptimer:Float = 0.0;
	var lifttimer:Float = 0.0;

	var supporting:Bool = false;
	var putdown:TileSprite = null;
	var pickup:TileSprite = null;
	var pushingthis:TileSprite = null;

	public function new(game:PlayState, tx, ty, type:PlayerType)
	{
		super(game, tx, ty);
		this.type = type;
		this.facing = RIGHT;
		game.addPlayer(this);

		if (type == Player1)
			loadGraphic("assets/player1.png", true, 32, 32);
		else
			loadGraphic("assets/player2.png", true, 32, 32);

		animation.add("idle", [0]);
		animation.add("turn", [1, 0], 15, false);
		animation.add("support", [2]);
		animation.play("idle");

		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
	}

	public override function gameUpdate()
	{
		// Add real animation system when this gets too complex
		trySupport();
		if (state == Climbing)
			climbAnimation();
		if (state == Walking)
			walkAnimation();
		if (state == Dropping)
			dropAnimation();
		if (state == Lifting)
			liftAnimation();

		tryFall();
		if (state == Falling)
		{
			fallAnimation();
			return;
		}
		turnAnimation();

		spriteAnimation();
	}

	public function command(cmd:PlayerCommand)
	{
		trySupport();

		switch cmd
		{
			case Up:
				climb();
			case Down:
				downaction();
			case Left:
				walk(-1);
			case Right:
				walk(1);
		}

		tryFall();
	}

	function walk(dir:Int)
	{
		if (state != Idle)
			return;
		var shouldface:FlxDirectionFlags = (dir < 0) ? LEFT : RIGHT;
		if (facing != shouldface)
		{
			turn(dir);
			return;
		}

		var canwalk = false;
		var held = getHeld();
		var pushed = game.room.first((o) -> o.isPushable(), tx + dir, ty);

		if (game.room.hasNoSolid(tx + dir, ty) && !game.room.hasType(Player, tx + dir, ty - 1))
		{
			if (held != null)
			{
				if (game.room.hasSolid(tx + dir, ty - 1))
					canwalk = false;
				else
					canwalk = true;
			}
			else
			{
				canwalk = true;
			}
		}

		if (pushed != null && held == null)
		{
			if (game.room.hasNoSolid(tx + dir + dir, ty))
				canwalk = true;
		}

		if (canwalk)
		{
			move(tx + dir, ty);
			walktimer = 0.0;
			state = Walking;

			if (held != null)
				held.move(tx, ty - 1);

			if (pushed != null)
			{
				pushed.move(tx + dir, ty);
				pushingthis = pushed;
			}
		}
	}

	function turn(dir:Int)
	{
		var shouldface:FlxDirectionFlags = (dir < 0) ? LEFT : RIGHT;
		if (facing == shouldface)
			return;
		facing = shouldface;
		state = Turning;
	}

	function climb()
	{
		if (state != Idle)
			return;
		var dir = getDirInt();

		if (game.room.hasNoSolid(tx + dir, ty))
			return;

		if (game.room.hasSolid(tx + dir, ty - 1))
			return;

		move(tx + dir, ty - 1);
		climbtimer = 0.0;
		state = Climbing;
	}

	function downaction()
	{
		var dir = getDirInt();
		var holding = getHeld();

		if (holding != null)
		{
			// Drop action
			if (game.room.hasSolid(tx + dir, ty - 1))
				return;

			if (game.room.hasSolid(tx + dir, ty))
			{
				holding.move(tx + dir, ty - 1);
			}
			else
			{
				holding.move(tx + dir, ty);
			}

			putdown = holding;
			state = Dropping;
		}
		else
		{
			// Pickup action
			var picked = game.room.first((o) -> o.isLiftable(), tx + dir, ty);
			if (picked == null)
				return;

			if (game.room.hasSolid(tx + dir, ty - 1) || game.room.hasSolid(tx, ty - 1))
				return;

			picked.move(tx, ty - 1);
			pickup = picked;
			state = Lifting;
		}
	}

	function getHeld()
		return game.room.first((o) -> o.isCarryable() && !o.isFalling(), tx, ty - 1);

	function tryFall()
	{
		if (state == Falling)
			return false;
		if (state == Walking)
			return false;
		if (game.room.hasSolid(tx, ty + 1))
			return false;

		move(tx, ty + 1);
		state = Falling;
		falltimer = 0.0;
		return true;
	}

	function trySupport()
	{
		var tile = game.room.get(tx, ty - 1);
		if (tile == null)
			return false;

		var other = getHeld();
		if (other != null)
		{
			supporting = true;
			// resetWorldPos();
		}
		else if (supporting == true)
		{
			supporting = false;
		}

		return false;
	}

	function fallAnimation()
	{
		if (!isFalling())
			return;

		falltimer += game.elapsed * 4;
		resetWorldPos();

		if (falltimer < 1.0)
		{
			y -= Global.tilesize * (1 - falltimer);
			return;
		}

		falltimer = 0.0;
		state = Idle;
		if (tryFall())
		{
			return fallAnimation();
		}
		else
		{
			// Play landing animation
		}
	}

	function walkAnimation()
	{
		// Let this kinda movement code happen while supporting too
		// Or other forseeable things
		if (state != Walking)
			return;

		walktimer += game.elapsed * 6;
		resetWorldPos();
		var dir = getDirInt();
		var held = getHeld();
		if (held != null)
			held.resetWorldPos();
		if (pushingthis != null)
			pushingthis.resetWorldPos();

		if (walktimer < 1.0)
		{
			// https://stackoverflow.com/questions/13462001/ease-in-and-ease-out-animation-formula
			var sq = walktimer * walktimer;
			var dist = sq / (2.0 * (sq - walktimer) + 1.0);

			x = (x + (Global.tilesize) * (-dir)) + Global.tilesize * dist * dir;

			if (held != null)
			{
				held.x = x;
			}
			if (pushingthis != null)
			{
				pushingthis.x = (pushingthis.x + (Global.tilesize) * (-dir)) + Global.tilesize * dist * dir;
			}
			return;
		}

		walktimer = 0.0;
		pushingthis = null;
		state = Idle;
	}

	function climbAnimation()
	{
		if (state != Climbing)
			return;

		climbtimer += game.elapsed * 4;
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

	function turnAnimation()
	{
		if (state != Turning)
			return;

		turntimer += game.elapsed * 15;

		if (turntimer < 1.0)
			return;

		turntimer = 0.0;
		state = Idle;
	}

	function dropAnimation()
	{
		if (state != Dropping)
			return;

		droptimer += game.elapsed * 4;
		resetWorldPos();
		putdown.resetWorldPos();
		var dir = getDirInt();

		if (droptimer < 0.5)
		{
			if (putdown.ty == ty)
				putdown.y -= Global.tilesize;
			putdown.x += Global.tilesize * (-dir);
			var t = (droptimer) * 2;
			putdown.x += Global.tilesize * -t * (t - 2) * dir;
			return;
		}
		else if (droptimer < 1.0)
		{
			if (putdown.ty == ty)
			{
				putdown.y -= Global.tilesize;
				var t = (droptimer - 0.5) * 2;
				putdown.y += Global.tilesize * t * t;
				return;
			}
		}

		droptimer = 0.0;
		state = Idle;
	}

	function liftAnimation()
	{
		if (state != Lifting)
			return;

		lifttimer += game.elapsed * 4;
		resetWorldPos();
		pickup.resetWorldPos();
		var dir = getDirInt();

		if (lifttimer < 0.5)
		{
			pickup.y += Global.tilesize;
			pickup.x += Global.tilesize * (dir);
			var t = (lifttimer) * 2;
			pickup.y -= Global.tilesize * t * t;
			return;
		}
		else if (lifttimer < 1.0)
		{
			pickup.x += Global.tilesize * (dir);
			var t = (lifttimer - 0.5) * 2;
			pickup.x -= Global.tilesize * -t * (t - 2) * dir;
			return;
		}

		lifttimer = 0.0;
		state = Idle;
	}

	function spriteAnimation()
	{
		if (state == Turning)
			animation.play("turn");
		else if (supporting)
			animation.play("support");
		else
			animation.play("idle");
	}

	function getDirInt()
	{
		if (facing == LEFT)
			return -1;
		else
			return 1;
	}

	public override function zlayer()
		return 500;

	public override function updatePriority()
		return 1;

	public override function isFalling()
		return state == Falling;

	public override function isHeavy()
		return true;

	public override function isCarryable()
		return true;
}
