package Interactions {
	
	import Characters.Character;	
	import Characters.HitData;
	
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	
	import GameEvents.GrabEvent;
	import GameEvents.MiscEvent;
	
	public class GrabInteractions extends GameObject {
		
		private var gameStage:Stage;
		
		private var you:Character;
		private var them:Character;

		public function GrabInteractions( s:Stage, p:Character, o:Character, playerNo:int, interactDisp:EventDispatcher ) {
			// constructor code
			gameStage = s;
			you = p;
			them = o;
			this.dispatcher = interactDisp;
			
			
			this.createEventListeners([this.dispatcher, this.dispatcher, this.dispatcher],
									  [GrabEvent.GRAB_CONTACT, GrabEvent.GRAB_MISS, GrabEvent.GRAB_SPECIAL],
									  [grabContact, grabMiss, grabSpecialCase]);
		}		
		
		private function grabContact( G:GrabEvent ):void {
			var info:Object = G.grabInfo;
			
			if (info.attacked["hittable"]) {
				if (correctGrab(info.attacker, info.attacked) && !attackPrioritised(info.attacker, info.attacked)) {
					this.dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_LAND, info ) );
				} else {
					this.dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_AVOIDED, info ) );
				}
			} else {
				this.dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_MISS, info ) );
			}
		}
		
		private function grabSpecialCase( G:GrabEvent ):void {
			// no intervention, continue as normal
			var info:Object = G.grabInfo;			
			
			if (info.intervention == "none") {
				grab(info.attacker, info.attacked);
				
				// trace("dispatched GRAB_SUCCESSFUL");
				this.dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_SUCCESSFUL, { attacker:info.attacker, attack:info.attack } ) );
			} else {
				// something else happens, DEFAULT UNSUCCESSFUL
				// trace("dispatched GRAB_UNSUCCESSFUL");
				this.dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_UNSUCCESSFUL, { attacker:info.attacker, attack:info.attack } ) );
			}
		}
		
		private function grabMiss( G:GrabEvent ):void {
			var info:Object = G.grabInfo;
			// trace("dispatched GRAB_UNSUCCESSFUL");
			this.dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_UNSUCCESSFUL, { attacker:info.attacker, attack:info.attacker.currentLabel } ) );
		}
		
		public function grab( actor:Character, actee:Character ):void {
			if (actee.currentLabel != "grabbed") {
				actee.gotoAndStop("grabbed");
			}
			if (actor["moveStage"] != "grab success") {
				var grabFrame:String = "GRAB_SUCCESS_FRAME_" + actor.currentLabel;
				actor.gotoAndPlay(actor[grabFrame]);
			}
			actee.setFallSpeed(0);
			actee["movementX"] = 1;		
			actee["movementY"] = 0;
		}
		
		
		public function whileGrabbed( actor:Character, actee:Character ):void {
			if (actor["grip"]) {
				actee.repositionX(actor.x + (actor.scaleX * actor["grip"].x));
				actee.repositionY(actor.y + (actor.scaleY * actor["grip"].y));
				actee.scaleX = -Math.round(actor.scaleX * actor["grip"].scaleX);
				actee.rotation = (actor.scaleX * actor["grip"].rotation);
				if (actor["grabState"].indexOf("grabbed") == 0) {
					if (actee.currentLabel != actor["grabState"]) {
						actee.gotoAndStop(actor["grabState"]);
					}
				} else {
					actee.play();
				}
			} else if (actee.currentLabel.indexOf("grabbed") == 0 && actor["moveStage"] == "reset") {
				if (actee.currentLabel != "grabbed") {
					actee.gotoAndPlay("grabbed");
				}			
				actee.play();
				actee.moveX(actee["movementX"]);
			}
		}
		
		// throw executed at the correct height
		public function correctGrab( actor:Character, actee:Character ):Boolean {
			return (actor["grabHeight"] == actee.getStance());
		}
		
		// if throw executed on target performing an attack
		public function attackPrioritised( attacker:Character, attacked:Character ):Boolean {
			if (attacked.isAttackFrame() && !attacked.isThrow() && (attacker.isFacing() != attacked.isFacing())) {
				var string:String = attacked.getStance() + " " + attacked.currentLabel;
				var attack:HitData = attacked.getHitData(string);
				if (!attack) {
					return false;
				}				
				if (attack.isAttack) {
					return (attacked["moveStage"] == "wind up" || attacked["moveStage"] == "hit");
				} else {
					return false;
				}
			} else {
				return false;
			}
		}

	}
	
}
