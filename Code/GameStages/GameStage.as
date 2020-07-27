package GameStages {
		
	import Characters.Character;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.Stage;
	import flash.display.MovieClip;
	import GameEvents.CharacterEvent;
	import GameEvents.MiscEvent;
	
	public class GameStage extends GameSprite {
		
		public const LEFT_BOUND_X:int = -125;
		public const RIGHT_BOUND_X:int = 675;
		public const GROUND_Y:int = 400;
		public const CEILING_Y:int = 0;
		
		private const WALL_BOUNCE_HEIGHT:Number = 40;
		private const WALL_BOUNCE_BOUNDARY_HI:Number = 20;
		private const WALL_BOUNCE_BOUNDARY_LO:Number = 10;
		
		protected var leftWall:Boolean;
		protected var rightWall:Boolean;
		protected var ceiling:Boolean;		

		public function GameStage() {
			// constructor code
			x = 0;
			y = 0;
		}
		
		// management of movement relative to confines of stage
		protected function movement( C:CharacterEvent ):void {
			var info:Object = C.charInfo;
			var player:Character = info.player;
			var velocity:Number = info.v;
			
			var wallSpace:Number = player.FIXED_CHARACTER_WIDTH;
			if (player.currentLabel == "hit heavy direct 1" || player.currentLabel.indexOf("hit wall") == 0) {
				wallSpace = 0;
			}
			
			velocity *= player.scaleX;
			player.x = Math.min(Math.max(player.x + velocity, (LEFT_BOUND_X + wallSpace)), (RIGHT_BOUND_X - wallSpace));
			
			var guideDist:Number;
			if (player["guideFront"]) {
				guideDist = Math.abs(player["guideFront"].x * player.scaleX);
				if (player.scaleX > 0) {
					player.x = Math.min(Math.max(player.x, (LEFT_BOUND_X + wallSpace)), (RIGHT_BOUND_X - guideDist));
				} else if (player.scaleX < 0) {
					player.x = Math.min(Math.max(player.x, (LEFT_BOUND_X + guideDist)), (RIGHT_BOUND_X - wallSpace));					
				}
			}
			if (player["guideBack"]) {
				guideDist = Math.abs(player["guideBack"].x * player.scaleX);
				if (player.scaleX > 0) {
					player.x = Math.min(Math.max(player.x, (LEFT_BOUND_X + guideDist)), (RIGHT_BOUND_X - wallSpace));
				} else if (player.scaleX < 0) {
					player.x = Math.min(Math.max(player.x, (LEFT_BOUND_X + wallSpace)), (RIGHT_BOUND_X - guideDist));					
				}
			}
			
			// hitting a wall
			if (player.currentLabel == "hit heavy direct 1" && player.getMovementSpeed() >= 20) {
				if ((leftWall && player.x <= (LEFT_BOUND_X + 20.1)) || (rightWall && player.x >= (RIGHT_BOUND_X - 20.1))) {
					
					var altitude:Number = GROUND_Y - player.y;
					if (altitude > (WALL_BOUNCE_HEIGHT + WALL_BOUNCE_BOUNDARY_HI)) {
						if (Math.abs(player["movementY"]) < 5) {
							player.gotoAndPlay("hit wall air");
							player["movementY"] = -5;
						} else if (player["movementY"] < -10) {
							player.gotoAndPlay("hit wall air");
							player["movementY"] = -10;
						}
					} else if (altitude >= (WALL_BOUNCE_HEIGHT - WALL_BOUNCE_BOUNDARY_LO))  {
						if (Math.abs(player["movementY"]) < 5) {
							if (player.getMovementSpeed() >= 40) {
								player.gotoAndPlay("hit wall ground 2");
							} else {
								player.gotoAndPlay("hit wall ground " + String(player.launchCount - 1));								
							}
						}
						player.repositionY(GROUND_Y);
					}
				}
			}
		}
		
		protected function respectiveMovement( E:Event ):void {
			// blank
		}
	}
	
}
