package Interactions {
	
	import Characters.Character;
	import Characters.HitData;
	import GameEvents.AttackEvent;	
	import GameEvents.CharacterEvent;
	import GameEvents.MiscEvent;
	
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.display.MovieClip;
	
	public class HitInteractions extends GameObject {
		
		private const LAUNCH_CAP:int = 2;
		private const JUGGLE_CAP:int = 10;
		
		private var gameStage:Stage;
		
		private var player1:Character;
		private var player2:Character;
		

		public function HitInteractions( s:Stage, p:Character, o:Character, playerNo:int, interactDisp:EventDispatcher ) {
			// constructor code
			gameStage = s;
			player1 = p;
			player2 = o;			
			this.dispatcher = interactDisp;
			
			this.createEventListeners([this.dispatcher, this.dispatcher, this.dispatcher, this.dispatcher, this.dispatcher, this.dispatcher],
									  [AttackEvent.ATTACK_CONTACT, AttackEvent.ATTACK_MISS, AttackEvent.ATTACK_AVOIDED, AttackEvent.ATTACK_SPECIAL, CharacterEvent.CHARACTER_HITSTUN, CharacterEvent.CHARACTER_BLOCKSTUN],
									  [attackContact, attackMiss, attackMiss, attackSpecialCase, callHitStun, callHitStun, callBlockStun]);
		}		
		
		private function attackContact( A:AttackEvent ):void {
			var info:Object = A.attackInfo;
			if (!info.attacker["grip"] && info.attacked["hittable"]) {
				var hit:Object = info.attacker.getHitPosition();
				
				// if hit location depends on position of attacked, move position
				if (adjustableHitPosition(info.attacker)) {
					info.attacker["hitpos"].x = (info.attacked.x - info.attacker.x) / info.attacker.scaleX;
					hit.pX = info.attacked.x;				
				}
				
				hitTest(hit.pX, hit.pY, info.attacker, info.attacked, info.attack);
			} else if (info.attacker["grip"]) {
				this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_SUCCESSFUL, { attacker:info.attacker, attack:info.attack, attackerIndex:((info.attacker == player1) ? 1 : 2) } ) );
			} else if (!info.attacked["hittable"]) {
				this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_MISS, { attacker:info.attacker, attacked:info.attacked, attack:info.attack } ) );
			}
		}
		
		private function attackSpecialCase( A:AttackEvent ):void {
			// no intervention, continue as normal
			var info:Object = A.attackInfo;			
			var hit:Object = info.attacker.getHitPosition();
			
			if (info.intervention == "none") {
				info.attacked.scaleX = -info.attacker.scaleX;
				if (hitWhileGrounded(info.attacked)) {
					if (info.attacker["attackStrength"] == "heavy") {
						heavyHit(hit.pX, hit.pY, info.attacker, info.attacked);
					} else {
						normalGroundHit(hit.pX, info.attacker, info.attacked, info.attack);
					}	
				} else {
					if (info.attacker["attackStrength"] == "heavy") {
						heavyHit(hit.pX, hit.pY, info.attacker, info.attacked);
					} else if (info.attacker["attackStrength"] == "medium") {
						mediumAerialHit(hit.pX, hit.pY, info.attacker, info.attacked);
					} else if (info.attacked.isHitFrame() && info.attacked["hitStrength"] == "medium" && info.attacker["attackStrength"] == "medium") {
						heavyHit(hit.pX, hit.pY, info.attacker, info.attacked);
					} else if (info.attacker["attackStrength"] == "light") {
						lightAerialHit(hit.pX, hit.pY, info.attacker, info.attacked);
					}
				}
				// trace("dispatched ATTACK_SUCCESSFUL");				
				this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_SUCCESSFUL, { attacker:info.attacker, attack:info.attack, attackerIndex:((info.attacker == player1) ? 1 : 2) } ) );
			} else {
				// something else happens, DEFAULT UNSUCCESSFUL
				// trace("dispatched ATTACK_UNSUCCESSFUL");
				this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_UNSUCCESSFUL, { attacker:info.attacker, attack:info.attack } ) );
			}
		}
		
		private function callHitStun( C:CharacterEvent ):void {
			var info:Object = C.charInfo;
			var attacked:Character = info.attacked;
			var excessHitStunFrames = Math.max(info.attackData.hitStun - 9, 0);
			
			attacked.hitStun = excessHitStunFrames;
		}
		
		private function callBlockStun( C:CharacterEvent ):void {
			var info:Object = C.charInfo;
			var attacked:Character = info.attacked;
			var blockStun = Math.max(info.attackData.blockStun, 0);
			
			attacked.blockStun = blockStun;
		}
		
		private function attackMiss( A:AttackEvent ):void {
			var info:Object = A.attackInfo;
			// trace("dispatched ATTACK_UNSUCCESSFUL");
			this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_UNSUCCESSFUL, {  attacker:info.attacker, attack:info.attacker.currentLabel } ) );
		}
		
		private function attackAvoided( A:AttackEvent ):void {
			var info:Object = A.attackInfo;
			// trace("dispatched ATTACK_UNSUCCESSFUL");
			this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_UNSUCCESSFUL, {  attacker:info.attacker, attack:info.attacker.currentLabel } ) );
		}
		
		
		public function hitTest( hitX:Number, hitY:Number, actor, actee:Character, attackLabel:String ):void {
			var hit:String;
			if (hitWhileGrounded(actee)) {
				hit = groundHitTest(hitX, hitY, actor, actee);	
			} else if (actor["attackLevel"] != "low") {
				hit = aerialHitTest(hitX, hitY, actor, actee);
			}
			switch (hit) {
					case "hit":
					// trace("dispatched ATTACK_HIT");
					this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_HIT, { attacker:actor, attacked:actee, attack:attackLabel } ) );
					break;					
				case "avoided":
					// trace("dispatched ATTACK_AVOIDED");
					this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_AVOIDED, { attacker:actor, attacked:actee, attack:attackLabel } ) );
					break;					
				case "blocked":
					// trace("dispatched ATTACK_BLOCKED");
					var block:int = actor.getHitData(actor.getStance() + " " + attackLabel).blockStun;
					this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_BLOCKED, { attacked:actee, blockStun:block } ) );
					break;
			}
		}
		
		// if oppponent is hit while on the ground
		public function groundHitTest( hitX:Number, hitY:Number, actor, actee:Character ):String {
			if (!correctGuard(actor, actee)) {
				if (!(actee.getStance() ==  "crouch" && actor["attackLevel"] == "high")) {
					return "hit";
				} else {
					return "avoided";
				}
			} else {
				blockedHit(actee, actor);
				return "blocked";
			}
		}
		
		// if opponent is hit while in the air
		public function aerialHitTest( hitX:Number, hitY:Number, actor, actee:Character ):String {
			
			return "hit";
		}
		
		private function heavyHit( hitX:Number, hitY:Number, actor, actee:Character ):void {
			var hitFrame:String = "";
			
			hitFrame += "hit heavy ";
			hitFrame += ((actor["attackDirection"] == "sideways") ? "direct" : actor["attackDirection"]);
			hitFrame += " " + String(actee.launchCount);
						
			actee.launchCount++;
			actee.repositionX(hitX);
			actee.repositionY(hitY);
			actee["movementX"] = -actor["attackKnockback"].kX;
			actee["movementY"] = actor["attackKnockback"].kY;
			actee.gotoAndPlay(hitFrame);
			actee.setFallSpeed(8);
			
			if (actee.currentLabel == "hit heavy direct 1") {
				actee.ro(actee["movementX"], actee["movementY"]);
			}
		}
		
		private function normalGroundHit( hitX:Number, actor, actee:Character, attackLabel:String ):void {
			var hitFrame:String = "";
			
			hitFrame += "hit " + actor["attackStrength"];
			hitFrame += " " + actor["attackLevel"];
			hitFrame += " " + ((actor["attackDirection"] == "sideways" && actor["attackLevel"] != "high") ? "direct" : actor["attackDirection"]);
			hitFrame += " " + actee.getStance();			
			
			actee.gotoAndPlay(hitFrame);
			if (actor["attackStrength"] == "light") {
				var attacker:Character = (actee == player1) ? player2 : player1;
				var attackString = attacker.getStance() + " " + attackLabel;
				var attack:HitData = attacker.getHitData(attackString);	
				actee.moveX(-actor["attackKnockback"].kX);
				this.dispatcher.dispatchEvent( new CharacterEvent( CharacterEvent.CHARACTER_HITSTUN, { attacked:actee, attackData:attack } ) );
			} else if (actor["attackStrength"] == "medium") {
				actee["movementX"] = -actor["attackKnockback"].kX;	
				actee.repositionX(hitX);					
			}			
		}
		
		private function mediumAerialHit( hitX:Number, hitY:Number, actor, actee:Character ):void {
			heavyHit(hitX, hitY, actor, actee);
		}

		private function lightAerialHit( hitX:Number, hitY:Number, actor, actee:Character ):void {
			if (actee.juggleCount >= JUGGLE_CAP) {
				heavyHit(hitX, hitY, actor, actee);
			} else {
				actee.gotoAndPlay("hit air");				
				actee.juggleCount++;
				actee.repositionX(hitX);
				actee.repositionY(hitY);					
				actee["movementX"] = -actor["attackKnockback"].kX;
				actee["movementY"] = actor["attackKnockback"].kY;	
				actee.ro(actee["movementX"], actee["movementY"]);
			}
		}


		private function blockedHit( actee:Character, actor ):void {
			// some form of blockstun
			actee.stop();
			var attackString = actor.getStance() + " " + actor.currentLabel;
			while (actee["moveStage"] != "guard") {
				actee.gotoAndPlay(actee.currentFrame + 1);
			}
			this.dispatcher.dispatchEvent( new CharacterEvent( CharacterEvent.CHARACTER_BLOCKSTUN, { attacked:actee, attackData:actor.getHitData(attackString) } ) );
			actee.moveX(-5);
		}

		
		
		private function correctGuard( actor, actee:Character ):Boolean {
			if (actee.isFacing() != actor.isFacing()) {
				if (actee.isGuarding("hi") && actor["attackLevel"] != "low") {
					return true;
				} else if (actee.isGuarding("lo") && actor["attackLevel"] == "low") {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}		
		
		private function adjustableHitPosition( actor ):Boolean {
			return !(actor["hitpos"].hitTestObject(actor["hitbox"]));
		}
		
		private function hitWhileGrounded( actee:Character ):Boolean {
			return (actee.getGrounded() && actee.getStance() != "air");
		}

	}
	
}
