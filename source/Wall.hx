package;

class Wall extends TileSprite
{
	public function new(game:PlayState, tx, ty)
	{
		super(game, tx, ty);

		loadGraphic("assets/wall.png");
	}
}
