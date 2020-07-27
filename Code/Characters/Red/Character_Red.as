package Characters.Red {
	
	import Characters.*;
	import VFX.CharVFX.VAttacks.Red.*; 
	import VFX.CharVFX.VEffects.Red.*;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import GameEvents.*;
	
	public class Character_Red extends Character {
		// guard frames
		
		public const GUARD_STAND_TO_STAND_FRAME:int		= 113;
		public const GUARD_CROUCH_TO_STAND_FRAME:int	= 117;
		public const GUARD_CROUCH_TO_CROUCH_FRAME:int	= 123;
		public const GUARD_STAND_TO_CROUCH_FRAME:int 	= 127;
		
		// crouch frame
		public const CROUCH_FRAME:int = 109;
		// grab frames
		public const GRAB_SUCCESS_FRAME_T:int	= 643;
		public const GRAB_SUCCESS_FRAME_dT:int	= 996;
		
		// personal frames
		private const HEATWAVE_FIRE_FRAME:int = 1123;
		
		// personal variables
		// - heated ---------------------------------------
		private var heatedCount:int = 0;
		private var heatedInterval:int = 0;
		private var heatedDuration:int = 0;		
		// - S --------------------------------------------
		private var SFXDelay:int = 0;
		// - fS -------------------------------------------
		private var fSFXDelay:int = 0;
		// - fdS ------------------------------------------
		private var fdSFXDelay:int = 0;		
		public var visualAttacks:Array;		
		public var heatwaves:int = 0;
		
		// WHOLE ATTACK LIST
		// private var attackList:Array = ["PPP-P", "PfPfP", "PPbK", "PPfdKfuPP", "bPcP", "KKuK", "fKbK", "bKbK", "bKdK", "dP", "dK", "fdKKfP", "fdP", "fdK", "TP", "TKP", "TKKP", "TbT", "TS", "TdTuS", "dT", "dS", "bdS", "S", "fS", "fdS", "bS"];		
		
		public function Character_Red( s:Stage, scenario:Object, interaction:EventDispatcher ) {
			// constructor code
			this.gameStage = s;
			this.scenario = scenario;
			this.dispatcher = interaction;
			
			this.groundLevel = this.gameStage.stageHeight;
			this.attacks = AttackChains_Red.Dict();
			this.attackList = ["PPP-P", "PfPfP", "PPfdKfuPP", "bPcP", "fKbK", "bKdK", "dK", "fdKKfP", "fdP", "fdK", "TP", "TKP", "TKKP", "dT"];
		
			visualAttacks = [];
						
			this.createEventListeners([this.gameStage, this.gameStage, this.gameStage, this.dispatcher, this.dispatcher],
									  [Event.ENTER_FRAME, Event.ENTER_FRAME, Event.ENTER_FRAME, AttackEvent.ATTACK_HIT, GrabEvent.GRAB_LAND],
									  [specifics, visuals, this.updater, this.attackSpecialCase, this.grabSpecialCase]);
		}
		
		
		// ignore
		private function specifics( S:Event ):void {
			heatedDuration = Math.max(heatedDuration - 1, 0);
			if (heatedDuration <= 0) {
				heatedCount = 0;
			}
			if (currentLabel == "S" && this["moveStage"] == "heat") {
				heatedCount = Math.min(heatedCount + 1, 5);
				heatedDuration = ((10 * heatedCount) + (0.5 * heatedCount * (heatedCount + 1))) * 25;
			}
		}
		
		// ignore
		private function visuals(V:Event):void {
			if (heatedDuration > 0) {
				if (heatedCount <= 5) {
					heatedInterval = 12 - heatedCount;
				}
				if (SFXDelay == 0) {
					for (var i:int = 0; i < ((heatedCount == 5) ? 3 : 1); i++) {
						var heatedFlame:CharVEffect_S = new CharVEffect_S(gameStage, this, scenario, this.dispatcher);
						scenario.addChild(heatedFlame);
						if (this) {
							// scenario.setChildIndex(heatedFlame, scenario.getChildIndex(this) + Math.round(Math.random() * 2) - 1);					
						}
					}
				}
				SFXDelay = ((SFXDelay + 1) % heatedInterval);
			} else {
				heatedCount = 0;
			}
			
			if (this["vatkbox"]) {
				switch( currentLabel ) {	
					case "bS":
						if (heatwaves == 0 && (this["moveStage"] == "fire" || currentFrame == HEATWAVE_FIRE_FRAME)) {
							var heatwave:CharVAttack_bS = new CharVAttack_bS(gameStage, this, scenario, heatedCount, visualAttacks.length, dispatcher);
							visualAttacks.push(heatwave);
							scenario.addChild(heatwave);
							scenario.setChildIndex(heatwave, scenario.getChildIndex(this));
							heatwaves = 1;
						}
					break;
				}
			} else if (this["vfxbox"]) {
				switch( currentLabel ) {	
					case "fS":
						if (fSFXDelay == 0) {
							var fireflyTrail:CharVEffect_fS = new CharVEffect_fS(gameStage, this, scenario);
							scenario.addChild(fireflyTrail);
							scenario.setChildIndex(fireflyTrail, scenario.getChildIndex(this) - 1);
						}				
						
						fSFXDelay = ((fSFXDelay + 1) % 2);
					break;
					case "fdS":
						if (fdSFXDelay == 0) {
							var burningRings:CharVEffect_fdS = new CharVEffect_fdS(gameStage, this, scenario);
							scenario.addChild(burningRings);
							scenario.setChildIndex(burningRings, scenario.getChildIndex(this) + 1);										   
							fdSFXDelay++;
						}
						fdSFXDelay = ((fdSFXDelay + 1) % 3);
					break;				
				} 
			}
		}
		
		// handling projectile attackss
		public function shiftVisualAttackArray( removedIndex:int ):void {
			for (var i in visualAttacks) {
				if (i > removedIndex) {
					visualAttacks[i].vAtkIndex--;
				}
			}
		}

	}
	
}
