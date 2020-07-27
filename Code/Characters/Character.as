package Characters {
	
	import GameObject;
	import Characters.Red.*;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import GameEvents.*;

	public class Character extends GameSprite {
		
		public const FIXED_CHARACTER_WIDTH:int = 30;	// general width of all characters
		
		public var hitStun:int			= -1;		// number of frames beyond 9 frame animation that character cannot take action
		public var blockStun:int		= -1;		// number of frames that character is locked in block
		public var stunFrame:Boolean	= false;	// flag for whether a frame is repeated (toggled per frame)
		public var juggleCount:int		= 1;		
		public var launchCount:int		= 1;
				
		private var isAble:Boolean;		// character can take action
		private var isPhysic:Boolean;	// character can move
				
		private var grounded:Boolean;	// whether character is on the ground
		protected var groundLevel:int;
		
		private var fallSpeed:Number;
		
		private var runningState:String = "reset";
		
		public var attacks:Dictionary;		
		public var attackList:Array = []; 
		
		public function Character() {
			// constructor code
			isAble = true;
			isPhysic = true;
			grounded = true;
			
			fallSpeed = 0;
		}		
		
		// COMMAND FUNCTIONS ----------------------------------------------------------------------
		
		// triggers standing animation
		public function Stand():void {
			gotoAndPlay("standing");
		}
		
		// triggers walking animation in specified direction
		public function Walk( dir:String ):void {
			if (currentLabel != ("walking " + dir)) { 
				gotoAndPlay("walking " + dir);
			}
		}
		
		// triggers jump animation
		public function Jump():void {
			gotoAndPlay("air");
		}
		
		// triggers guard animation
		public function Guard( guardStance:String ):void {
			var oldState:String = currentLabel;	// current guard state of character
			// walking counts as standing for the purposes of guarding
			if (currentLabel.indexOf("walking") == 0) {
				oldState = "standing";
			}			
			if (oldState.indexOf(guardStance) < 1) {
				gotoAndPlay("guard " + guardStance);
				// gets guard frame specific to character
				if (oldState == "crouch") {
					if (guardStance == "standing") {
						gotoAndPlay(this["GUARD_CROUCH_TO_STAND_FRAME"]);
					} else  {
						gotoAndPlay(this["GUARD_CROUCH_TO_CROUCH_FRAME"]);						
					}
				} else {
					if (guardStance == "standing") {
						gotoAndPlay(this["GUARD_STAND_TO_STAND_FRAME"]);
					} else  {
						gotoAndPlay(this["GUARD_STAND_TO_CROUCH_FRAME"]);						
					}					
				}
			}
		}
		
		// triggers dash animation in specified direction
		public function Dash( dir:String ):void { 
			gotoAndPlay("dash " + dir);
		}
		
		// triggers crouching animation
		public function Crouch( type:String ):void {
			gotoAndPlay("crouch");
			if (type == "instant") {
				gotoAndPlay(this["CROUCH_FRAME"]);
			}
		}
		
		/*
		public function Punch( inputType:String ):void {
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
		
		public function Kick( inputType:String ):void {
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
		
		public function Throw( inputType:String ):void {
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
		
		public function Special( inputType:String ):void {
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
		*/
		
		public function isStandingFrame():Boolean {
			return (currentLabel == "standing");
		}
		
		public function isWalkingFrame():Boolean {
			return (currentLabel.indexOf("walking") == 0);
		}
		
		public function isAirFrame():Boolean {
			return (currentLabel == "air" && getStance() == "air");
		}
		
		// character is being hit
		public function isHitFrame():Boolean {
			return (currentLabel.indexOf("hit") == 0);
		}
		
		// character is being grabbed
		public function isGrabbedFrame():Boolean {
			return (currentLabel.indexOf("grabbed") == 0);
		}
		
		// character is on the ground
		public function isDownedFrame():Boolean {
			return (currentLabel.indexOf("ground") == 0);
		}
		
		// character is on a recovery frame
		public function isRecoveryFrame():Boolean {
			return (currentLabel.indexOf("getting up") == 0);
		}
		
		// character is on an attack frame (Punch, Kick, Throw or Special)
		public function isAttackFrame():Array {
			return (currentLabel.match("[P|K|T|S]+"));
			// return (currentLabel.match("[P|K|T|S|u|d|f|b|-|c]+"));
		}
		
		// character's attack is a punch
		public function isPunch():Boolean {
			return (currentLabel.charAt(currentLabel.length - 1) == 'P');
		}
		
		// character's attack is a kick
		public function isKick():Boolean {
			return (currentLabel.charAt(currentLabel.length - 1) == 'K');
		}
		
		// character's attack is a thrown
		public function isThrow():Boolean {
			return (currentLabel.charAt(currentLabel.length - 1) == 'T');
		}
		
		// character's attack is a special move
		public function isSpecial():Boolean {
			return (currentLabel.charAt(currentLabel.length - 1) == 'S');
		}
		
		// character is on a dash frame
		public function isDashFrame():Boolean {
			return (currentLabel.indexOf("dash") == 0);
		}
		
		// character is on a guard frame
		public function isGuardFrame():Boolean {
			return (currentLabel.indexOf("guard") == 0);
		}
		
		// character is on a crouch frame
		public function isCrouchFrame():Boolean {
			return (currentLabel.indexOf("crouch") == 0);
		}
		
		// character's current attack is part of a throw combo (first move in this combo was a throw)
		public function isThrowCombo():Boolean {
			return (isAttackFrame() && (currentLabel.indexOf('T') >= 0));
		}
		
		// if the current attack follows on from the previous attack
		public function isSameCombo( lastAttack:String, thisAttack:String ):Boolean {
			return (thisAttack.indexOf(lastAttack) == 0);
		}
		
		// frame update
		protected function updater( E:Event ):void {
			thePhysics();
			figureControl();
			attackFrames();
			stateControl();
			resettingFrames();
		}
		
		
		private function attackFrames():void {
			if (isAttackFrame()) {				
				if (this["moveStage"] == "hit") {
					// trace("dispatched ATTACK_PERFORMED");
					dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_PERFORMED, { attacker:this, attemptedAttack:this.currentLabel } ) );
				} else if (this["moveStage"] == "grab") {
					// trace("dispatched GRAB_PERFORMED");
					dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_PERFORMED, { attacker:this, attemptedAttack:this.currentLabel } ) ); 
				}
								
				if (this["attackStance"] == "air") {
					if (getGrounded()) {
						if (this["moveStage"] == "wind up" && fallSpeed < 0) {
							fallSpeed = -15;
							moveY(-1);
							return;
						}
						if (!this["airLanding"] && getGrounded()) {
							gotoAndPlay("air");
							while(this["moveStage"] != "landing") {
								nextFrame();
							}
						}
						if (this["airLock"]) {
							play();
						}
						this["movementX"] = 0;
					} else {
						if (this["airLock"]) {
							stop();
						}
					}
				}
			}
		}
		
		// set whether the character can move or not
		public function setPhysic( physic:Boolean ):void {
			isPhysic = physic;
		}
		
		// get whether the character can take action or not
		public function getAble():Boolean {
			return isAble;
		}
		
		// set whether the character can take action or not
		public function setAble( able:Boolean ):void {
			isAble = able;
		}
		
		// ensures the character figure MovieClip is acting at the same time as the character itself
		private function figureControl():void {			
			if (this["figure"].currentFrame != currentFrame) {
				this["figure"].gotoAndStop(currentFrame);
			}
		}
		
		private function stateControl():void {
			if ((isRecoveryFrame() || isStandingFrame()) && runningState != "reset") {
				runningState = "reset";
				dispatcher.dispatchEvent( new CharacterEvent( CharacterEvent.CHARACTER_RESET, { char:this } ) );
			} else if (isHitFrame() && runningState == "reset") {
				runningState = "hit";
			} else if(isGrabbedFrame() && runningState == "reset") {
				runningState = "grabbed";
			}
			
			blockStunned();
			hitStunned();
		}
		
		// if on recovery frame, reset juggle/launch counts
		private function resettingFrames():void {
			if (isRecoveryFrame() && (juggleCount > 1 || launchCount > 1)) {
				juggleCount = 1;
				launchCount = 1;
			}
		}
		
		// manage block stun duration
		private function blockStunned():void {
			if (!isGuardFrame() && blockStun > 0) {
				blockStun = 0;
			} else if (blockStun > 0) {
				stop();
				blockStun--;
			} else if (blockStun == 0) {
				play();
				blockStun = -1;
			}			
		}
		
		// manage hit stun duration
		private function hitStunned():void {	
			if ((!isHitFrame() && hitStun > 0) || hitStun == 0) {
				play();
				stunFrame = false;
				hitStun = -1;
			} else if (hitStun > 0) {
				if (hitStun > 13) {
					stop();
					hitStun--;
				} else if (!stunFrame && this["hitStrength"] == "light") {
					play();
					stunFrame = true;
				} else {
					stop();
					stunFrame = false;
					hitStun--;
				}
			}		
		}
		
		// is character in block stun
		public function inBlockStun():Boolean {
			return (blockStun > 0);
		}
		
		// is character in hit stun
		public function inHitStun():Boolean {
			return (hitStun > 0);
		}
		
		// handles how the character moves
		private function thePhysics():void {
			if (isPhysic) {
				if (!getGrounded()) {
					if (isHitFrame()) {
						if (this["airLock"]) {
							stop();
						} else if (this["airMovement"]) {
							if (this["movementY"] < 0)  {
								stop();
							} else {
								play();
							}							
						}
						
						if (fallSpeed > 0 && this["movementY"] <= 0 && getMovementSpeed() >= 10) {
							fallSpeed--;
						} else {
							if (Math.abs(this["movementX"]) > 5 && this["movementY"] <= 0) {
								this["movementX"] *= 0.8;
							}
							this["movementY"] += 2;
						}						
						moveX(this["movementX"]);
						moveY(this["movementY"]);
						if (currentLabel == "hit heavy direct 1" || currentLabel == "hit air") {
							ro(this["movementX"], this["movementY"]);
						}
					} else if (!isAttackFrame()) {
						fallSpeed += 2;
						this["movementY"] = fallSpeed;
						moveY(this["movementY"]);
					} else {
						if (this["airMovement"]) {
							if (this["airPriority"]) {
								fallSpeed = this["movementY"];
							} else {
								if (fallSpeed <= 0) {
									fallSpeed = this["movementY"];
								} else {
									fallSpeed += 1;
									this["movementY"] = fallSpeed;
								}
							}
						} else {
							fallSpeed += 1;
							this["movementY"] = fallSpeed;
						}
					}						
				} else {
					// resets to -15 for the next time the character is in the air
					if (!isAttackFrame()) {
						fallSpeed = -15;
					}
					
					if (isHitFrame()) {
						if (this["hitStrength"] == "medium" || currentLabel.indexOf("hit wall") == 0) {
							moveX(this["movementX"]);						
						} else if (this["hitStrength"] == "heavy") {
							moveX(this["movementX"]);						
							play();
						}
					}
				}
			}
		}
		
		// get character stance
		public function getStance():String {
			var stance:String;
			if (getGrounded() && ((!isHitFrame() && !isAttackFrame() && currentLabel.indexOf("standing") >= 0) || currentLabel.indexOf("walking") == 0 || currentLabel.indexOf("dash") == 0 || (isAttackFrame() && this["attackStance"] == "standing") || (isHitFrame() && this["hitStance"] == "standing"))) {
				stance = "standing";
			} else if (getGrounded() && ((!isHitFrame() && !isAttackFrame() && currentLabel.indexOf("crouch") >= 0) || (isAttackFrame() && this["attackStance"] == "crouch") || (isHitFrame() && this["hitStance"] == "crouch"))) {
				stance = "crouch";
			} else if (currentLabel.indexOf("air") >= 0 || (isAttackFrame() && (this["attackStance"] == "air" || this["attackStance"] == "pseudoair")) || (isHitFrame() && (this["hitStance"] == "air" || this["hitStance"] == "pseudoair")) || currentLabel == "grabbed" || !getGrounded()) {
				stance = "air";
			} else { // any oversight defaults to standing
				stance = "standing";
			}
			return stance;
		}
		
		public function getGrounded():Boolean {			
			if (y < groundLevel) {
				grounded = false;
			} else {
				y = groundLevel;
				grounded = true;
			}
			return grounded;
		}
		
		private function canJump():Boolean {
			return (currentLabel == "standing" || currentLabel.indexOf("walking") == 0);
		}
		public function activeInAir():Boolean {
			return !(this["moveStage"] == "landing" || this["moveStage"] == "reset");
		}
		
		public function setFallSpeed( spd:Number ):void {
			fallSpeed = spd;
		}
		
		public function getFallSpeed():Number {
			return fallSpeed;
		}
		
		public function isFacing():String {
			var dir:String;
			if (scaleX < 0) {
				dir = "left";
			} else if (scaleX > 0) {
				dir = "right";
			}
			return dir;
		}
		
		public function isGuarding( stance:String ):Boolean {
			if (currentLabel.indexOf("guard") == 0 && this["moveStage"] != "reset") {
				if (this["moveStage"] == "reset") {
					return false;
				} else {
					if ((stance == "hi" && currentLabel == "guard standing") || (stance == "lo" && currentLabel == "guard crouching")) {
						return true;
					} else {
						return false;
					}
				}
			} else {
				return false;
			}
		}
		
		public function moveX( velocity:Number ):void {
			dispatcher.dispatchEvent( new CharacterEvent( CharacterEvent.CHARACTER_MOVE, { player:this, v:velocity } ) );
			
		}
		
		public function moveY( velocity:Number ):void {
			y = Math.min(y + velocity, groundLevel);			
		}
		
		public function repositionX( pos:Number ):void {
			x = pos;
		}
		
		public function repositionY( pos:Number ):void {
			y = pos;
		}
		
		// rotate based on x ad y speeds
		public function ro( xSpeed:Number, ySpeed:Number ):void {
			rotation = scaleX * Math.atan(ySpeed / xSpeed) * (360 / (2 * Math.PI));			
		}
		
		// get movement speed of character
		public function getMovementSpeed():Number {
			return Math.sqrt((this["movementX"] * this["movementX"]) + (this["movementY"] * this["movementY"]));
		}
		
		// look at point
		public function look( position:Number ):void {
			if (position > x) {
				scaleX = 1;
			} else if (position < x) {
				scaleX = -1;
			}
		}
		
		public function getHitPosition():Object {
			var posX:Number = x + (this["hitpos"].x * scaleX);
			var posY:Number = y + (this["hitpos"].y * scaleY);
			return { pX:posX, pY:posY };
		}
		
		public function repeatFrame():void {
			gotoAndPlay(currentFrame - 1);			
		}
		
		// get hit data for a certain attack
		public function getHitData( attack:String ):HitData {
			return attacks[attack];
		}
		
		// special case for being attacked, if any
		protected function attackSpecialCase( A:AttackEvent ):void {
			var info:Object = A.attackInfo;
			// for now, just cover the attacked's special case
			if (this == info.attacked) {
				// trace("dispatched ATTACK_SPECIAL");
				dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_SPECIAL, { attacker:info.attacker, attacked:info.attacked, attack:info.attack, intervention:"none" } ) );
			}
		}
		
		// special case for being grabbed, if any
		protected function grabSpecialCase( G:GrabEvent ):void {
			var info:Object = G.grabInfo;
			// for now, just cover the grabbed's special case
			if (this == info.attacked) {
				// trace("dispatched GRAB_SPECIAL");
				dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_SPECIAL, { attacker:info.attacker, attacked:info.attacked, attack:info.attack, intervention:"none" } ) );
			}
		}
	}
	
}
