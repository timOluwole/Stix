package Controllers {
	
	import Characters.Character;
	import Characters.Red.Character_Red;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class CharController extends GameObject {
		public var unit:Character;
		
		private var lInput:Boolean = false;
		private var rInput:Boolean = false;
		private var uInput:Boolean = false;
		private var dInput:Boolean = false;
		
		private var ability1Input:Boolean = false;
		
		private var guardInput:Boolean = false;
		
		private var lastInput:String;
		
		private var punchInput:Boolean = false;
		private var punchTimer:Number = 0;
		
		private var kickInput:Boolean = false;
		private var kickTimer:Number = 0;
		
		private var throwInput:Boolean = false;
		private var throwTimer:Number = 0;	
		
		private var specialInput:Boolean = false;
		private var specialTimer:Number = 0;			
		
		private var dashEnabled:Boolean = false;
		private var dashDirection:String;
		
		private var dirInputs:Object;
		
		private var groundLevel:Number;

		public function CharController( gameStage:Stage, scenario:Object, player:Character, interactDisp:EventDispatcher ) {
			// constructor code
			unit = player;
			groundLevel = gameStage.stageHeight;
			this.dispatcher = interactDisp;
			
			this.createEventListeners([gameStage], [Event.ENTER_FRAME], [frame_by_frame]);
			
			//gameStage.addEventListener(Event.ENTER_FRAME, update_function(gameStage));
		}
		
		/*
		public function update_function( gameStage:Stage ):Function {
			return function(E:Event):void {
				gameStage.addEventListener(Event.ENTER_FRAME, frame_by_frame);
			};
		}
		*/
		
		public function frame_by_frame(F:Event):void {
			playerMovement();
			punchCheck();
			kickCheck();
			throwCheck();
			specialCheck();
		}
			
		// KEY STATES ================================================
		
		public function setLeftInput(down):void {
			lInput = down;
			if (lInput) {
				rInput = false;
			}
		}
			
		public function setRightInput(down):void {
			rInput = down;
			if (rInput) {
				lInput = false;
			}
		}
			
		public function setUpInput(down):void {
			uInput = down;
			if (uInput) {
				dInput = false;
			}
		}
			
		public function setDownInput(down):void {
			dInput = down;
			if (dInput) {
				uInput = false;
			}
		}
		
		public function setGuardInput(down):void {
			guardInput = down;
		}
		
		public function setAbility1Input(down):void {
			ability1Input = down;
		}
		
		public function setPunchInput(down):void {
			if (punchInput != down && down && unit.getAble()) {
				lastInput = "punch";
				punchTimer = getTimer();
				punchType("release");
			}
			punchInput = down;
		}
		
		public function setKickInput(down):void {
			if (kickInput != down && down && unit.getAble()) {
				lastInput = "kick";
				kickTimer = getTimer();
				kickType("release");
			}
			kickInput = down;
		}
		
		public function setThrowInput(down):void {
			if (throwInput != down && down && unit.getAble()) {
				lastInput = "throw";
				throwTimer = getTimer();
				throwType("release");
			}
			throwInput = down;
		}
		
		public function setSpecialInput(down):void {
			if (specialInput != down && down && unit.getAble()) {
				lastInput = "special";
				specialTimer = getTimer();
				specialType("release");
			}
			specialInput = down;
		}
		
		// ============================================================
		
		// INPUT CHECKS ===============================================
		private function punchCheck():void {
			if (punchInput) {
				var inputDuration:Number = (getTimer() - punchTimer);
				dirInputs = { l:lInput, r:rInput, u:uInput, d:dInput };
				if (inputDuration < 200) {
					punchType("fired");					
				} else {
					punchType("held");
				}
			} else {
				if (unit.isAttackFrame()) {
					if (unit["chargeAttack"] && lastInput == "punch") {
						if (unit["moveStage"] == "charge") {
							punchType("charged");
						}
					}
				}
			}
		}
		
		
		private function kickCheck():void {
			if (kickInput) {
				var inputDuration:Number = (getTimer() - kickTimer);
				dirInputs = { l:lInput, r:rInput, u:uInput, d:dInput };
				if (inputDuration < 200) {
					kickType("fired");
				} else {
					kickType("held");
				}
			} else {
				if (unit.isAttackFrame()) {
					if (unit["chargeAttack"] && lastInput == "kick") {
						if (unit["moveStage"] == "charge") {
							kickType("charged");
						}
					}
				}
			}
		}
		
		private function throwCheck():void {
			if (throwInput) {
				var inputDuration:Number = (getTimer() - throwTimer);
				dirInputs = { l:lInput, r:rInput, u:uInput, d:dInput };
				if (inputDuration < 200) {
					throwType("fired");
				} else {
					throwType("held");
				}
			} else {
				if (unit.isAttackFrame()) {
					if (unit["chargeAttack"] && lastInput == "throw") {
						if (unit["moveStage"] == "charge") {
							throwType("charged");
						}
					}
				}
			}
		}
		
		private function specialCheck():void {
			if (specialInput) {
				var inputDuration:Number = (getTimer() - specialTimer);
				dirInputs = { l:lInput, r:rInput, u:uInput, d:dInput };
				if (inputDuration < 200) {
					specialType("fired");
				} else {
					specialType("held");
				}
			} else {
				if (unit.isAttackFrame()) {
					if (unit["chargeAttack"] && lastInput == "special") {
						if (unit["moveStage"] == "charge") {
							specialType("charged");
						}
					}
				}
			}
		}
		
		public function punchType( inputType:String ):void {
			var newAttack:String;
			switch (inputType) {
				case "fired":
					attackInputFired("P");
					break;
				case "held":
					attackInputHeld("-P");
					break;
				case "charged":
					attackInputCharged("cP");
			}
		}
		
		public function kickType( inputType:String ):void {
			var newAttack:String;
			switch (inputType) {
				case "fired":
					attackInputFired("K");
					break;
				case "held":
					attackInputHeld("-K");
					break;
				case "charged":
					attackInputCharged("cK");
			}
		}
		
		public function throwType( inputType:String ):void {
			var newAttack:String;
			switch (inputType) {
				case "fired":
					attackInputFired("T");
					break;
				case "held":
					attackInputHeld("-T");
					break;
				case "charged":
					attackInputCharged("cT");
			}
		}
		
		public function specialType( inputType:String ):void {
			var newAttack:String;
			switch (inputType) {
				case "fired":
					attackInputFired("S");
					break;
				case "held":
					attackInputHeld("-S");
					break;
				case "charged":
					attackInputCharged("cS");
			}
		}
		
		private function inputDirection():String {
			var dir:String;
			if ((unit.isFacing() == "left" && lInput) || (unit.isFacing() == "right" && rInput)) {
				dir = "forwards";
			} else if ((unit.isFacing() == "right" && lInput) || (unit.isFacing() == "left" && rInput)) {
				dir =  "backwards";
			}
			return dir;
		}
		
		private function playerMovement():void {
			if (unit.getAble()) {
				if (unit.currentLabel == "standing") {
					standingFrames();
				} else if (unit.currentLabel.indexOf("walking") == 0) {
					walkingFrames();
				} else if (unit.currentLabel == "air") {
					airFrames();
				} else if (unit.currentLabel.indexOf("dash") == 0) {
					dashFrames();
				} else if (unit.currentLabel == "crouch") {
					crouchFrames();
				} else if (unit.currentLabel.indexOf("guard") == 0) {
					guardFrames();
				} else if (unit.isAttackFrame()) {
					attackFrames();
				}
			}
		}
		
		private function standingFrames():void {
			if (dashEnabled && inputDirection()) {
				unit.Dash(inputDirection());			
			} else {
				if (inputDirection() == "forwards") {
					unit.Walk("forwards");
					unit.moveX(5);				
				} else if (inputDirection() == "backwards") {
					unit.Walk("backwards");
					unit.moveX(-3);
				}
			}
			if (uInput) {
				unit.Jump();
				setUpInput(false);
			} else if (dInput) {
				unit.Crouch("normal");						
			}
			if (guardInput) {
				unit.Guard("standing");
			}
		}
		
		private function walkingFrames():void {
			if (lInput || rInput) {
				if (inputDirection() == "forwards") {
					unit.Walk("forwards");
					unit.moveX(5);				
				} else if (inputDirection() == "backwards") {
					unit.Walk("backwards");
					unit.moveX(-3);
				}
			} else {			
				unit.Stand();					
			}
			if (uInput) {
				unit.Jump();
				setUpInput(false);
				unit.moveY(unit.getFallSpeed());
			} else if (dInput) {
				unit.Crouch("normal");				
			}
			if (guardInput) {
				unit.Guard("standing");
			}
		}
		
		private function airFrames():void {
			if (!unit.getGrounded()) {
				if (unit["moveStage"] == "air") {
					if (unit.getFallSpeed() < -2) {
						if (unit["moveDirection"] == "upwards") {
							unit.repeatFrame();
						}
					} else {
						if (unit["moveDirection"] == "downwards") {
							unit.repeatFrame();
						}
					}
				}
				if (lInput || rInput) {
					var airSpeed;
					if (inputDirection() == "forwards") {
						airSpeed = 8;
					} else if (inputDirection() == "backwards") {
						airSpeed = -5;
					}
					unit.moveX(airSpeed);										
				}
			} else {
				if (unit["moveStage"] == "jumping") {
					unit.moveY(unit.getFallSpeed());
				} else if (unit["moveStage"] == "reset") {			
					if (dInput) {
						unit.Crouch("instant");
					}
				} else if (unit["moveStage"] != "landing" && unit.getFallSpeed() > 0) {
					finder("moveStage", "landing");
				} else if (unit["moveStage"] == "landing") {
					unit.play();
				}
			}
		}
		
		private function dashFrames():void {
			if (unit["moveStage"] == "dash") {
				if (unit["moveDirection"] == "forwards") {
					unit.moveX(50);
				} else {
					unit.moveX(-30);
				}
				setDashEnabled(false);
			}
		}
		
		private function crouchFrames():void {
			if (unit["moveStage"] == "crouch") {
				if (dInput) {
					unit.repeatFrame();
					if (guardInput) {
						unit.Guard("crouching");
					}
				}
			}
		}
		
		private function guardFrames():void {
			if (unit["moveStage"] == "guard") {
				if (guardInput) {
					unit.repeatFrame();
					if (dInput) {
						unit.Guard("crouching");
					} else {
						unit.Guard("standing");
					}
				} else {
					finder("moveStage", "reset");
				}
			}
		}
		
		private function attackFrames():void {
			unit.moveX(unit["movementX"]);
			unit.moveY(unit["movementY"]);
		}
		
		
		
		public function doubleTapDetected( tappedKey:String ):void {
			if (tappedKey == "left" || tappedKey == "right") {
				if (unit.currentLabel == "standing") {
					setDashEnabled(true);				
				}
			}
		}
		
		private function attackInputFired( nextMove:String ):void {
			if (unit.currentLabel.indexOf("walking") == 0) { // for the purposes of showing combos, standing attacks can be executed while walking
				if (findAttack("", nextMove)) {
					finder("attackStance", "standing");
				}
			} else if (unit.currentLabel == "standing" || unit.currentLabel == "crouch" || (unit.currentLabel == "air" && unit.activeInAir())) {
				var stance:String = unit.currentLabel;
				if (findAttack("", nextMove)) {
					finder("attackStance", stance);
				}
			} else if (unit.isAttackFrame()) {
				if (unit["moveStage"] == "window") {
					if (!unit["holdableInput"]) {
						findAttack(unit.currentLabel, nextMove);
					}
				}
			}
		}
		
		private function attackInputHeld( nextMove:String ):void {
			if (unit.isAttackFrame()) {
				if (unit["moveStage"] == "window") {
					if (unit["holdableInput"]) {
						findAttack(unit.currentLabel, nextMove);
					}
				}
			}
		}
		
		private function attackInputCharged( nextMove:String ):void {
			findAttack(unit.currentLabel, nextMove);
		}
		
		public function findAttack( previousChain:String, nextMove:String ):Boolean {
			var addDir:String = "";
			/*
			priority given to up and down inputs because players are likely more predisposed to
			holding down left or right while attacking to immediately keep moving, whereas up and
			down inputs are usually input when needed
			*/
			if (dirInputs.u) {
				if ((dirInputs.l && unit.isFacing() == "left") || (dirInputs.r && unit.isFacing() == "right")) {
					addDir = "fu"; // forwards upwards
				} else if ((dirInputs.r && unit.isFacing() == "left") || (dirInputs.l && unit.isFacing() == "right")) {
					addDir = "bu"; // backwards upwards
				} else if (!dirInputs.l && !dirInputs.r) {
					addDir = "u"; // upwards
				}
			} else if (dirInputs.d) {
				if ((dirInputs.l && unit.isFacing() == "left") || (dirInputs.r && unit.isFacing() == "right")) {
					addDir = "fd"; // forwards downwards
				} else if ((dirInputs.r && unit.isFacing() == "left") || (dirInputs.l && unit.isFacing() == "right")) {
					addDir = "bd"; // backwards downwards
				} else if (!dirInputs.l && !dirInputs.r) {
					addDir = "d"; // downwards
				}
			} else if (dirInputs.l) {
				if (unit.isFacing() == "left") {
					addDir = "f"; // forwards
				} else if (unit.isFacing() == "right") {
					addDir = "b"; // backwards
				}
			} else if (dirInputs.r) {
				if (unit.isFacing() == "right") {
					addDir = "f"; // forwards
				} else if (unit.isFacing() == "left") {
					addDir = "b"; // backwards
				}
			}
			
			var found:Boolean = false;
			var newAttack:String;
			var dirs:Array;
			var dirI:int = 0;
			
			switch( addDir.length ) {
				case 0: dirs = [""]; 									  		 break;
				case 1: dirs = [addDir, ""]; 						      		 break;
				case 2: dirs = [addDir, addDir.charAt(1), addDir.charAt(0), ""]; break;
			}
			
			while ((dirI < dirs.length) && !found) {
				newAttack = previousChain + dirs[dirI] + nextMove;
				if (existingAttackChain(newAttack)) {
					unit.gotoAndPlay(newAttack);
					found = true;
				} else {
					dirI++;
				}
			}
			
			return found;
		}
		
		private function existingAttackChain( chain:String ):Boolean {
			var i:int = 0;
			var foundChain:Boolean = false;
			while (!foundChain && i < unit.attackList.length) {
				if (unit.attackList[i].indexOf(chain) == 0) {
					var j:int = 0;
					while (chain != unit.attacks[unit.attackList[i]].chain[j]) {
						j++;
					}
					if (unit.isAttackFrame()) {
						if (unit.attacks[unit.attackList[i]].stances[j].indexOf(unit["attackStance"]) != -1) {
							foundChain = true;
						} else {
							i++;
						}
					} else {
						var stance:String;
						if (unit.currentLabel.indexOf("walking") == 0) {
							stance = "standing";
						} else {
							stance = unit.currentLabel;
						}if (unit.attacks[unit.attackList[i]].stances[j].indexOf(stance) != -1) {
							foundChain = true;
						} else {
							i++;
						}
					}
				} else {
					i++;
				}
			}
			return foundChain;
		}
		
		public function finder( unitTag:String, tagValue ):void {
			var originalLabel:String = unit.currentLabel;
			var originalFrame:int = unit.currentFrame;
			if (unit[unitTag]) {
				var newFrame:int = unit.currentFrame;
				var found:Boolean = false;
				while (!found && originalLabel == unit.currentLabel) {
					unit.gotoAndPlay(newFrame);
					found = (unit[unitTag] == tagValue);
					unit.gotoAndPlay(originalFrame);
					if (!found) {
						newFrame++;
					}
				}
				if (found) {
					unit.gotoAndPlay(newFrame);
				} else {
					unit.gotoAndPlay(originalFrame);
				}
			}
		}
		
		public function setDashEnabled(isEnabled):void {
			dashEnabled = isEnabled;
		}
		
		
		public function getPlayerUnit():Character {
			return unit;
		}
		
	}		
}
