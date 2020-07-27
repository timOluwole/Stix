package Controllers {
		
	import Characters.*;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.*;
	
	import Controllers.*;
	import GameEvents.MiscEvent;
	
	public class AIController extends GameObject {
			
		private var unit:Character;
		private var char:CharController;
		private var opponent:Character;
		private var brain:AgentBrainC;
		
		private var decisionWait:int = 1;
		private var decisionTick:int = decisionWait;

		private var normalOptions:Dictionary;
		private var attackOptions:Dictionary;		
		
		private var countStanding:int = 0;
		private var countWalking:int = 0;
		private var countAir:int = 0;
		private var countCrouching:int = 0;
		private var countGuarding:int = 0;
		private var countWindow:int = 0;
		private var countCharging:int = 0;
		
		public function AIController( charController:CharController, gameStage:Stage, o:Character, interactDisp:EventDispatcher, learning:Boolean, scenario ) {
			// constructor code
			char = charController;
			unit = char.getPlayerUnit();
			opponent = o;			
			this.dispatcher = interactDisp;
			
			brain = new AgentBrainC(gameStage, unit, opponent, interactDisp, scenario);
			brain.setLearningState(learning);
			
			// specific to Red
			normalOptions = new Dictionary();
			attackOptions = new Dictionary();
			
			normalOptions["standing"]			= ["walk forwards", "walk backwards", "dash forwards", "dash backwards", "jump", "crouch", "guard", "attack"];
			normalOptions["walking"]			= ["stand", "walk forwards", "walk backwards", "dash forwards", "dash backwards", "jump", "crouch", "guard", "attack"];
			normalOptions["air"]				= ["move forwards", "move backwards", "attack"];
			normalOptions["crouch"]				= ["crouch", "guard", "attack"];
			normalOptions["stand guard"]		= ["guard", "crouch"];
			normalOptions["crouch guard"]		= ["guard", "stand"];
						
			attackOptions["standing"] 	= ["P", "bP", "fK", "bK", "T"];
			attackOptions["walking"] 	= ["P", "bP", "fK", "bK", "T"];
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
			if (decisionTick++ != decisionWait) { 
				return;
			}
			decisionTick = 1;
			
			if (unit.getAble() && unit.currentFrame > 1) {
				if (unit.currentLabel == "standing") {
					stateCounts("standing");
					decisionStanding();
				} else if (unit.currentLabel.indexOf("walking") == 0) {
					stateCounts("walking");
					decisionWalking();
				} else if (unit.currentLabel == "air") {
					stateCounts("air");
					decisionAir();
				} else if (unit.currentLabel == "crouch") {
					stateCounts("crouching");
					decisionCrouching();
				} else if (unit.currentLabel.indexOf("guard") == 0) {
					stateCounts("guarding");
					if (!unit.inBlockStun() && unit["moveStage"] == "guard") {
						if (unit.currentLabel== "guard standing") {
							decisionStandGuarding();
						} else {
							decisionCrouchGuarding();
						}						
					}
				} else if (unit.isAttackFrame()) {
					if (unit["moveStage"] == "window") {	
						stateCounts("window");					
						decisionAttack(unit.currentLabel);
					} else if (unit["moveStage"] == "charge") {	
						stateCounts("charging");
						decisionAttack(unit.currentLabel, true);
					}
				} else {
					stateCounts("none");					
				}
			}
		}
		
		private function stateCounts( currentState:String ):void {
			countStanding 	= (currentState == "standing") 	? (countStanding + 1) : 0;
			countWalking	= (currentState == "walking") 	? (countWalking + 1) : 0;
			countAir		= (currentState == "air") 		? (countAir + 1) : 0;
			countCrouching	= (currentState == "crouching")	? (countCrouching + 1) : 0;
			countGuarding 	= (currentState == "guarding") 	? (countGuarding + 1) : 0;
			countWindow 	= (currentState == "window")	? (countWindow + 1) : 0;
			countCharging	= (currentState == "charging")	? (countCharging + 1) : 0;			
		}
		
		private function decisionStanding():void {
			var options:Array;
			var decision:Number;
			
			options = normalOptions["standing"];			
			decision = brain.decide("standing", options);
			
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
				break;
				case "guard":
					char.setGuardInput(true);
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
			decision = brain.decide("walking", options);
			
			if (decision == options.length) {
				char.setLeftInput(false);
				char.setRightInput(false);
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
				case "stand":
					char.setLeftInput(false);
					char.setRightInput(false);
					// unit.Stand();
				break;
				case "jump":
					char.setUpInput(true);
					// unit.Jump();				
				break;
				case "crouch":
					char.setDownInput(true);
				break;
				case "guard":
					char.setGuardInput(true);
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
				decision = brain.decide("air", options);
				
				if (decision == options.length) {
					char.setLeftInput(false);
					char.setRightInput(false);		
					return;
				}
				
				switch (options[decision]) {
					case "attack":
						decisionAttack("air");
					break;
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
					default:
						performAttack(options[decision]);
				}
			} else if (unit["moveStage"] == "reset") {
				decision = brain.decide("landing", ["crouch"]);
				
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
			decision = brain.decide("crouch", options);
			
			if (decision == options.length) {
				char.setDownInput(false);
				unit.play();
				return;
			}
			 
			switch (options[decision]) {
				case "crouch":
					// LEAVE DOWN INPUT TRUE
				break;
				case "guard":
					char.setGuardInput(true);
				break;
				case "attack":
					decisionAttack("crouch");
				break;
				default:
					performAttack(options[decision]);
			}
		}
		
		private function decisionStandGuarding():void {
			var decision:Number = brain.decide("stand_guard", normalOptions["stand guard"]);
			
			if (decision == normalOptions["stand guard"].length) {
				char.setGuardInput(false);
				unit.play();
				return;
			}
			 
			switch (normalOptions["stand guard"][decision]) {
				case "guard":
					// LEAVE GUARD INPUT TRUE
				break;
				case "crouch":
					char.setDownInput(true);
				break;
			}
		}		
		
		private function decisionCrouchGuarding():void {
			var decision:Number = brain.decide("crouch_guard", normalOptions["crouch guard"]);
			
			if (decision == normalOptions["crouch guard"].length) {
				char.setGuardInput(false);
				unit.play();
				return;
			}
			 
			switch (normalOptions["crouch guard"][decision]) {
				case "guard":
					// LEAVE GUARD INPUT TRUE
				break;
				case "stand":
					char.setDownInput(false);
				break;
			}
		}		
		
		private function decisionAttack( currentState:String, charged:Boolean = false ):void {
			var decision:Number;
			
			if (charged) {
				decision = brain.decide(String("charge_" + currentState + "_" + String(countCharging)), ["release"]); 
				if (decision) {
					var chargedAttack:String = currentState + "c" + currentState.charAt(currentState.length - 1);
					unit.gotoAndPlay(chargedAttack);
				}
			} else {
				if (unit.isAttackFrame()) {
					decision = brain.decide(currentState + "_" + String(countWindow), attackOptions[currentState]);
				} else {
					decision = brain.decide(currentState, attackOptions[currentState]);
				}
							
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
