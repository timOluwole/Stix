package Controllers {
		
	import Characters.*;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.*;
	
	import Controllers.*;
	import GameEvents.MiscEvent;
	
	public class RandomController extends GameObject {
		
		private var unit:Character;
		private var char:CharController;
		private var opponent:Character;

		private var normalOptions:Dictionary;
		private var attackOptions:Dictionary;		
		
		public var gS:Stage;
		
		public function RandomController( charController:CharController, gameStage:Stage, o:Character, interactDisp:EventDispatcher ) {
			// constructor code
			char = charController;
			unit = char.getPlayerUnit();
			opponent = o;
			this.dispatcher = interactDisp;
			
			// specific to Red
			normalOptions = new Dictionary();
			attackOptions = new Dictionary();
			
			normalOptions["standing"]		= ["walk forwards", "walk backwards", "dash forwards", "dash backwards", "jump", "crouch", "guard", "attack"];
			normalOptions["walking"]		= ["stand", "walk forwards", "walk backwards", "dash forwards", "dash backwards", "jump", "crouch", "guard", "attack"];
			normalOptions["air"]			= ["move forwards", "move backwards", "attack"];
			normalOptions["crouch"]			= ["crouch", "guard", "attack"];
			normalOptions["stand guard"]	= ["guard", "crouch"];
			normalOptions["crouch guard"]	= ["guard", "stand"];
						
			attackOptions["standing"] 	= ["P", "bP", "fK", "bK", "T", "S"];
			attackOptions["walking"] 	= ["P", "bP", "fK", "bK", "T", "S"];
			attackOptions["crouch"]		= ["dK", "fdK", "dT"];
			attackOptions["air"]		= ["fdP", "fdK"];
			
			attackOptions["P"]			= ["PP", "PfP"];
			attackOptions["fK"]			= ["fKbK"];
			attackOptions["bK"]			= ["bKdK"];
			attackOptions["T"]			= ["TP", "TK"];
			attackOptions["fdK"]		= ["fdKK"];
			attackOptions["PP"]			= ["PPP", "PPfdK"];
			attackOptions["PfP"]		= ["PfPfP"];
			attackOptions["TK"]			= ["TKK", "TKP"];
			attackOptions["fdKK"]		= ["fdKKfP"];
			attackOptions["PPP"]		= ["PPP-P"];
			attackOptions["PPfdK"]		= ["PPfdKfuP"];
			attackOptions["TKK"]		= ["TKKP"];
			attackOptions["PPfdKfuP"]	= ["PPfdKfuPP"];			
			
			this.createEventListeners([gameStage], [Event.ENTER_FRAME], [decisionFrames]);	
		}
		
		private function decisionFrames( E:Event ):void {
			
			if (unit.getAble() && unit.currentFrame > 1) {
				if (unit.currentLabel == "standing") {
					decisionStanding();
				} else if (unit.currentLabel.indexOf("walking") == 0) {
					decisionWalking();
				} else if (unit.currentLabel == "air") {
					decisionAir();
				} else if (unit.currentLabel == "crouch") {
					decisionCrouching();
				} else if (unit.currentLabel.indexOf("guard") == 0) {
					if (!unit.inBlockStun() && unit["moveStage"] == "guard") {
						if (unit.currentLabel== "guard standing") {
							decisionStandGuarding();
						} else {
							decisionCrouchGuarding();
						}						
					}
				} else if (unit.isAttackFrame()) {
					if (unit["moveStage"] == "window") {	
						decisionAttack(unit.currentLabel);
					} else if (unit["moveStage"] == "charge") {	
						decisionAttack(unit.currentLabel, true);
					}
				}
			}
		}
		
		private function decisionStanding():void {
			var options:Array;
			var decision:Number;
			
			options = normalOptions["standing"];			
			decision = Math.round(Math.random() * options.length);
			
			if (decision == options.length) {
				return;
			}
			
			switch (options[decision]) {
				case "walk forwards":
					if (unit.isFacing() == "left") {
						char.setLeftInput(true);
					} else {
						char.setRightInput(true);
					}
				break;
				case "walk backwards":					
					if (unit.isFacing() == "right") {
						char.setLeftInput(true);
					} else {
						char.setRightInput(true);
					}
				break;
				case "dash forwards":
					char.setDashEnabled(true);
					if (unit.isFacing() == "left") {
						char.setLeftInput(true);
					} else {
						char.setRightInput(true);
					}
				break;
				case "dash backwards":					
					char.setDashEnabled(true);
					if (unit.isFacing() == "right") {
						char.setLeftInput(true);
					} else {
						char.setRightInput(true);
					}
				break;
				case "jump":
					char.setUpInput(true);
				break;
				case "crouch":					
					char.setDownInput(true);
					// unit.Crouch("normal");	
				break;
				case "guard":
					char.setGuardInput(true);
					// unit.Guard("standing");
				break;
				case "attack":
					decisionAttack("standing");
				break;
			}
		}
		
		private function decisionWalking():void {
			var options:Array;
			var decision:Number;
			
			options = normalOptions["walking"];			
			decision = Math.round(Math.random() * options.length);
			
			if (decision == options.length) {
				return;
			}
			
			switch (options[decision]) {
				case "stand":
					char.setLeftInput(false);
					char.setRightInput(false);
					// unit.Stand();
				break;
				case "walk forwards":
					if (unit.isFacing() == "left") {
						char.setLeftInput(true);
					} else {
						char.setRightInput(true);
					}
				break;
				case "walk backwards":
					if (unit.isFacing() == "right") {
						char.setLeftInput(true);
					} else {
						char.setRightInput(true);
					}
				break;
				case "dash forwards":
					char.setDashEnabled(true);
					if (unit.isFacing() == "left") {
						char.setLeftInput(true);
					} else {
						char.setRightInput(true);
					}
				break;
				case "dash backwards":					
					char.setDashEnabled(true);
					if (unit.isFacing() == "right") {
						char.setLeftInput(true);
					} else {
						char.setRightInput(true);
					}
				break;
				case "jump":
					char.setUpInput(true);
					// unit.Jump();				
				break;
				case "crouch":
					char.setDownInput(true);
					// unit.Crouch("normal");	
				break;
				case "guard":
					char.setGuardInput(true);
					// unit.Guard("standing");
				break;
				case "attack":
					decisionAttack("standing");
				break;
			}
		}
		
		private function decisionAir():void {
			var options:Array;
			var decision:Number;
			
			if (unit["moveStage"] == "air") {			
				
				options = normalOptions["air"];
				decision = Math.round(Math.random() * options.length);
				
				if (decision == options.length) { 
					char.setLeftInput(false);
					char.setRightInput(false);		
					return;
				}
				 
				switch (options[decision]) {
					case "move forwards":
						if (unit.isFacing() == "left") {
							char.setLeftInput(true);
						} else {
							char.setRightInput(true);
						}
					break;
					case "move backwards":
						if (unit.isFacing() == "right") {
							char.setLeftInput(true);
						} else {
							char.setRightInput(true);
						}
					break;
					case "attack":
						decisionAttack("air");
					break;
				}
			} else if (unit["moveStage"] == "reset") {
				decision = Math.round(Math.random());
				
				if (decision == 0) {
					char.setDownInput(true);					
				} else {
					// LAND AS NORMAL
				}
			}
		}
		
		private function decisionCrouching():void {
			var options:Array; 
			var decision:Number;
			
			options = normalOptions["crouch"];		
			decision = Math.round(Math.random() * options.length);
			
			if (decision == options.length) {
				char.setDownInput(false);
				unit.play();
				return;
			}
			 
			switch (options[decision]) {
				case "crouch":
					// LEAVE DOWN INPUT TRUE
					// unit.repeatFrame();
				break;
				case "guard":
					char.setGuardInput(true);
					// unit.Guard("crouching");
				break;
				case "attack":
					decisionAttack("crouch");
				break;
			}
		}
		
		private function decisionStandGuarding():void {
			var decision:Number = Math.round(Math.random() * normalOptions["stand guard"].length);
			
			if (decision == normalOptions["stand guard"].length) {
				char.setGuardInput(false);
				unit.play();
				return;
			}
			 
			switch (normalOptions["stand guard"][decision]) {
				case "guard":
					// LEAVE GUARD INPUT TRUE
					// unit.repeatFrame();
				break;
				case "crouch":
					char.setDownInput(true);
					// unit.Guard("crouching");
				break;
			}
		}		
		
		private function decisionCrouchGuarding():void {
			var decision:Number = Math.round(Math.random() * normalOptions["crouch guard"].length);
			
			if (decision == normalOptions["crouch guard"].length) {
				char.setGuardInput(false);
				unit.play();
				return;
			}
			 
			switch (normalOptions["crouch guard"][decision]) {
				case "guard":
					// LEAVE GUARD INPUT TRUE
					// unit.repeatFrame();
				break;
				case "stand":
					char.setDownInput(false);
					// unit.Guard("crouching");
				break;
			}
		}		
		
		private function decisionAttack( currentState:String, charged:Boolean = false ):void {
			var decision:Number;
			
			if (charged) {
				decision = Math.round(Math.random());
				if (decision) {
					var chargedAttack:String = currentState + "c" + currentState.charAt(currentState.length - 1);
					unit.gotoAndPlay(chargedAttack);
				}
			} else {
				decision = Math.round(Math.random() * attackOptions[currentState].length);
				// var decision:Number = Math.floor(Math.random() * (attackOptions[currentState].length + 1));
							
				if (decision == attackOptions[currentState].length) {
					return;
				}
				
				performAttack(attackOptions[currentState][decision]);
			}
		}
		
		private function performAttack( attack:String ):void {			
				if (unit.currentLabel.indexOf("walking") == 0) { // for the purposes of showing combos, standing attacks can be executed while walking
					unit.gotoAndPlay(attack);
					char.finder("attackStance", "standing");				
				} else if (unit.currentLabel == "standing" || unit.currentLabel == "crouch" || (unit.currentLabel == "air" && unit.activeInAir())) {
					var stance:String = unit.currentLabel;
					unit.gotoAndPlay(attack);
					char.finder("attackStance", stance);
				} else if (unit.isAttackFrame()) {
					unit.gotoAndPlay(attack);
				}				
		}
		
		public function getPlayerUnit():Character {
			return char.getPlayerUnit();
		}

	}
	
}
