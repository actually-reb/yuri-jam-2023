package;

class Crate extends TileSprite
{
	public function new(game:PlayState, tx, ty)
	{
		super(game, tx, ty);

		loadGraphic("assets/crate.png");
	}
}
