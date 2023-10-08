package;

import flixel.FlxSprite;

class TileSprite extends FlxSprite implements ZLayer
{
	var game:PlayState;

	public var tx:Int;
	public var ty:Int;

	// Add height property? That effects the `offset` field so players can poke above their tile

	public function new(game:PlayState, tx, ty)
	{
		super(Global.tilesize * tx, Global.tilesize * ty);
		this.tx = tx;
		this.ty = ty;
		this.game = game;

		game.addTileSprite(this);
	}

	public function gameUpdate() {}

	public function move(x, y)
	{
		game.room.moveSprite(this, x, y);
		resetWorldPos();
	}

	public function resetWorldPos()
	{
		x = Global.tilesize * tx;
		y = Global.tilesize * ty;
	}

	public function zlayer()
		return 0;

	public function isSolid()
		return true;

	public function updatePriority()
		return 0;

	public function isFalling()
		return false;

	public function isCarryable()
		return false;

	public function isPushable()
		return false;

	public function isHeavy()
		return false;

	public function isLiftable()
		return false;
}
