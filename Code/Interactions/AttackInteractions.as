package Interactions {
		
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	
	import Characters.Character;
	import GameEvents.AttackEvent;
	import GameEvents.GrabEvent;
	import GameEvents.MiscEvent;
	
	public class AttackInteractions extends GameObject {
		
		private var gameStage:Stage;
		
		private var player1:Character;
		private var player2:Character;
		
		private var hI:HitInteractions;
		private var gI:GrabInteractions;
		
		public var playerNo:int;

		public function AttackInteractions( s:Stage, p:Character, o:Character, pNo:int, interactDisp:EventDispatcher ) {
			// constructor code
			gameStage = s;
			player1 = p;
			player2 = o;
			playerNo = pNo;
			this.dispatcher = interactDisp;
			
			gI = new GrabInteractions(s, player1, player2, playerNo, this.dispatcher);
			hI = new HitInteractions(s, player1, player2, playerNo, this.dispatcher);			
			
			this.createEventListeners([gameStage, this.dispatcher, this.dispatcher],
									  [Event.ENTER_FRAME, AttackEvent.ATTACK_PERFORMED, GrabEvent.GRAB_PERFORMED],
									  [interactionSequence, attackCheck, grabCheck]);
		}
		
		private function attackCheck( A:AttackEvent ):void {
			var info:Object = A.attackInfo;
			var actor:Character = info.attacker;
			var actee:Character = opponentOf(actor);			
			
			if (actee["body"]) {
				if (actor["hitbox"].hitTestObject(actee["body"])) {
					// trace("dispatched ATTACK_CONTACT");
					this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_CONTACT, { attacker:actor, attacked:actee, attack:info.attemptedAttack } ) );
				} else {
					// trace("dispatched ATTACK_MISS");
					this.dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_MISS, info ) );
				}
			}
		}
		
		private function grabCheck( G:GrabEvent ):void {
			var info:Object = G.grabInfo;
			var actor:Character = info.attacker;
			var actee:Character = opponentOf(actor);
			
			if (actee["body"]) {
				if (actor["hitbox"].hitTestObject(actee["body"])) {
					this.dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_CONTACT, { attacker:actor, attacked:actee, attack:info.attemptedAttack } ) );
				} else {
					this.dispatcher.dispatchEvent( new GrabEvent( GrabEvent.GRAB_MISS, info ) );
				}
			}
		}
		
		private function interactionSequence(I:Event):void {
			if (gI != null) {
				gI.whileGrabbed(player2, player1);
				gI.whileGrabbed(player1, player2);
			}
		}
		
		private function opponentOf( player:Character ):Character {
			return ((player == player1) ? player2 : player1);
		}

	}
	
}
