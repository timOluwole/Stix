package Interactions {
	
	import Characters.Character;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import GameEvents.*;
	
	public class VCam extends GameSprite {
		
		private var player1:Character;
		private var player2:Character;
		private var world:Object;
		public var HUD:HUDScreen;
				
		private var specialCamera:Boolean;
		private var decisionCount:int;		

		public function VCam( s:Stage, p:Character, o:Character, scenario:Object, sMC:MovieClip, interactDisp:EventDispatcher ) {
			// constructor code
			this.gameStage = s;
			player1 = p;
			player2 = o;
			world = scenario;
			this.dispatcher = interactDisp;
			
			decisionCount = 0;
			
			HUD = new HUDScreen(this.dispatcher, player1, player2);
			addChild(HUD);			
			
			specialCamera = false;
			this.createEventListeners([this.gameStage, HUD.btnBack, this.dispatcher, this.dispatcher],
									  [Event.ENTER_FRAME, MouseEvent.CLICK, ControllerEvent.CONTROLLER_DECISION, MiscEvent.MISC_PRACTICE],
									  [cameraFunction, endGame, decisionMade, showBackButton]);
		}
		
		// show back button if training
		private function showBackButton( M:MiscEvent ):void {
			if (M.type == MiscEvent.MISC_PRACTICE) {
				HUD.btnBack.visible = true;
			}
		}
		
		// end of session
		private function endGame( M:MouseEvent ):void {
			this.dispatcher.dispatchEvent( new MiscEvent( MiscEvent.MISC_GOBACK, { } ) );
			this.dispatcher.dispatchEvent( new MiscEvent( MiscEvent.MISC_ENDGAME, { } ) );	
		}
		
		// displays decision count in practice
		private function decisionMade( C:ControllerEvent ):void {
			decisionCount++;
			HUD.decisionCountText.text = String(decisionCount);
		}
		
		private function cameraFunction( C:Event ):void {
			cameraTransform();
			handleEnterFrame();
		}
		
		// track player movement
		private function cameraTransform():void {
			if (player1["cam"]) {
				specialTransform(player1, player1["cam"], "player1");
			} else if (player2["cam"]) {
				specialTransform(player2, player2["cam"], "player2");				
			} else {
				var vAtks:Array;
				if (specialCamera) {
					player1.play();
					player1.setPhysic(true);
					player1.setAble(true);
					specialCamera = false;
					vAtks = player1["visualAttacks"];
					for (var i in vAtks) {
						vAtks[i].play();
					}
					
					player2.play();
					player2.setPhysic(true);
					player2.setAble(true);
					specialCamera = false;
					vAtks = player2["visualAttacks"];
					for (var j in vAtks) {
						vAtks[j].play();
					}
				}
				var closerYToGround = Math.max(player1.y, player2.y);
				
				var midPointX:Number = (player1.x + player2.x) * 0.5;
				var midPointY:Number = (player1.y + player2.y) * 0.5;
				
				var distX:Number = Math.abs(player1.x - player2.x);
				var distY:Number = Math.abs(player1.y - player2.y);
				
				var biggerScale:Number = Math.min(Math.max((1.5 * distX / gameStage.stageWidth), (1.5 * distY / gameStage.stageHeight), 0.6), 1.5);
				if (Math.abs(biggerScale - scaleX) > 0.2) {
					if (biggerScale < scaleX) {
						biggerScale = scaleX - 0.2;
					} else {
						biggerScale = scaleX + 0.2;
					}
				}				
				
				x = midPointX;
				y = Math.min(midPointY, closerYToGround) - (150 * biggerScale);
				
				scaleX = biggerScale;
				scaleY = biggerScale;
			}
		}
		
		// transforms with specific special moves
		private function specialTransform( player:Character, cam:MovieClip, who:String ):void {
			if (!specialCamera) {
				specialCamera = true;
				var vAtks:Array;
				switch(who) {
					case "player2":
						player1.stop();
						player1.setPhysic(false);
						player1.setAble(false);
						vAtks = player1["visualAttacks"];
						break;
					case "player1":
						player2.stop();
						player2.setPhysic(false);
						player2.setAble(false);
						vAtks = player2["visualAttacks"];
						break;					
				}
				
				for (var i in vAtks) {
					vAtks[i].stop();
				}
			}
			x = player.x + (cam.x * player.scaleX);
			y = player.y + (cam.y * player.scaleY);
			z = player.z + cam.z;
			width = cam.width * Math.abs(player.scaleX);
			height = cam.height * Math.abs(player.scaleY);
			rotationX = cam.rotationX * Math.abs(player.scaleX);
			rotationY = cam.rotationY;
			rotationZ = cam.rotationZ;
		}
		
		// trasform of camera on each frame
		function handleEnterFrame():void {
			if (parent) {
				parent.scaleX = 1 / scaleX;
				parent.scaleY = 1 / scaleY;
		
				if (rotation == 0) {
					parent.x = (width / 2 - x) / scaleX;
					parent.y = (height / 2 - y) / scaleY;
					parent.rotation = 0;
				} else {
					var bounds:Rectangle = getBounds(this);
					var angle:Number = rotation * Math.PI / 180;
		
					var midX:Number = -x / scaleX;
					var midY:Number = -y / scaleY;
					var rx:Number = -bounds.width / 2;
					var ry:Number = -bounds.height / 2;
					
					var cos:Number = Math.cos(angle);
					var sin:Number = Math.sin(angle);
					var rotatedX:Number = rx * cos - ry * sin;
					var rotatedY:Number = ry * cos + rx * sin;
					var cornerX:Number = midX - rotatedX;
					var cornerY:Number = midY - rotatedY;
					
					cos = Math.cos(-angle);
					sin = Math.sin(-angle);
					parent.x = cornerX * cos - cornerY * sin;
					parent.y = cornerY * cos + cornerX * sin;
		
					parent.rotation = -rotation;
				}
			}
		}

	}
	
}
