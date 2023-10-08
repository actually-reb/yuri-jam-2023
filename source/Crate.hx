package;

class Crate extends TileSprite
{
	public function new(game:PlayState, tx, ty)
	{
		super(game, tx, ty);

		loadGraphic("assets/crate.png");
	}

	public override function gameUpdate() {}

	function tryFall() {}

	public override function updatePriority()
		return 100;

	public override function isCarryable()
		return true;

	public override function isLiftable()
		return true;

	public override function isPushable()
		return true;

	public override function isHeavy()
	{
		var other = game.room.first((o) -> o.isCarryable(), tx, ty - 1);
		if (other == null)
			return false;

		if (other.isHeavy())
			return true;

		return false;
	}
}
