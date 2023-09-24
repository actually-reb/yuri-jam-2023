package;

class Blocker extends TileSprite
{
	public function new(game:PlayState, tx, ty)
	{
		super(game, tx, ty);

		visible = false;
	}
}
