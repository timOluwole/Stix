package Interactions {
	
	import Characters.Character;
	import GameStages.*;
	
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	
	import GameEvents.AttackEvent;
	import GameEvents.GrabEvent;
	import GameEvents.MiscEvent;
	
	public class InteractionTest extends GameObject {
		
		private const PLAYER_WIDTH:int = 30;
		private const PLAYER_HEIGHT_STANDING:int = 75;
		private const PLAYER_HEIGHT_CROUCHING:int = 45;		
		
		private var player1:Character;
		private var player2:Character;
		
		public var attackInteractions:AttackInteractions;
		public var gameStage:GameStage;
		public var camera:VCam;		
		private var gS:Stage;
		
		private var line:String;
		
		public var updatesSinceLast:int = 0;
		
		public var playerNo:int;
		
		public function InteractionTest( s:Stage, p:Character, o:Character, scenario, sMC:MovieClip, lineState:String, pNo:int, interactionDispatcher:EventDispatcher ) {
			// constructor code
			gS = s;
			player1 = p;
			player2 = o;
			
			line = lineState;
			playerNo = pNo;
			this.dispatcher = interactionDispatcher;
			
			camera = new VCam(s, player1, player2, scenario, sMC, interactionDispatcher);
			scenario.addChild(camera);
				
			attackInteractions = new AttackInteractions(s, player1, player2, playerNo, interactionDispatcher);
			
			
			this.createEventListeners([gS], [Event.ENTER_FRAME], [interact]);
		}
		
		public function interact( I:Event ):void {
			playerAdjustment(player1, player2);
			playerAdjustment(player2, player1);
			correction(player1, player2);
			correction(player2, player1);
		}
		
		private function playerAdjustment( p1:Character, p2:Character ):void {
			if (p2.isAttackFrame()) {
				if (p2["moveStage"] == "wind up" || p2["moveStage"] == "delay") {
					if (p1.getStance() != "air") {
						groundAdjustment(p1, p2);
					} else {
						aerialAdjustment(p1, p2);
					}
				}
			}
			if (p1.getGrounded() && p2.getGrounded() && !p1.isGrabbedFrame() && !p2.isGrabbedFrame()) {
				generalAdjustment(p1, p2);
			}
		}
		
		private function groundAdjustment( p1:Character, p2:Character ):void {
			if (correctDirection(p2, p1)) {
				if (Math.abs(p1.x - p2.x) < PLAYER_WIDTH) {
					p1.moveX((10 + Math.max(p2["movementX"], 0)) * p2.scaleX * p1.scaleX);							
				}
			}
		}
		
		private function aerialAdjustment( p1:Character, p2:Character ):void {
			if (p2["hitbox"] && p1["body"]) {
				if (p2["hitbox"].hitTestObject(p1["body"]) && p1.isHitFrame() && correctDirection(p2, p1)) {
					if (p2["movementX"] > 0) {
						p1["movementX"] = p2["movementX"] * p2.scaleX * p1.scaleX;		
					}
					if (p1.getGrounded()) {	
						p1["movementY"] = 0;
					} else {						
						p1["movementY"] = p2["movementY"];
					}
					p1.setFallSpeed(0);
				}
			}
		}
		
		// ensures characters are at least a character's width apart
		private function generalAdjustment( p1:Character, p2:Character ):void {
			var minDist:Number = (p1.FIXED_CHARACTER_WIDTH + p2.FIXED_CHARACTER_WIDTH) / 2;
			var distAttempts:int = 0;
			while (Math.abs(p1.x - p2.x) < minDist && distAttempts++ < 10) {
				if (p1.x < p2.x) {
					p1.moveX(-5 * p1.scaleX);
					p2.moveX( 5 * p2.scaleX);
				} else {
					p1.moveX( 5 * p1.scaleX);
					p2.moveX(-5 * p2.scaleX);			
				}
			}
		}
		
		// checks if opponent is facing the target
		private function correctDirection( viewer:Character, object:Character ):Boolean {
			return ((object.x - viewer.x) * viewer.scaleX) > -10;
		}
		
		// makes character face opponent
		private function correction( p1:Character, p2:Character ):void {
			if (p1.currentLabel.indexOf("walking") == 0 || (p1.currentLabel == "air" && !p1.getGrounded() && Math.abs(p1.x - p2.x) >= 30)) {
				p1.look(p2.x);
			}
		}
		
	}
	
}
