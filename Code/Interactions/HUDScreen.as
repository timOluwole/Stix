package Interactions {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;	
	
	import GameEvents.*;
	import Characters.Character;
	import Characters.CharacterInfo;
	import Characters.MoveData;
	import Characters.HitData;
	import Characters.Red.Character_Red;
	
	public class HUDScreen extends GameSprite {		
		
		private const MAX_BAR_WIDTH = 200;
		private const MAX_HEALTH = 1000;
		public const HEALTH_SCALE = MAX_BAR_WIDTH / MAX_HEALTH;
		
		public var p1HealthBar:MovieClip;
		public var p2HealthBar:MovieClip;
		public var player1Info:CharacterInfo;
		public var player2Info:CharacterInfo;
		
		public var resetTimer1:Timer;
		public var resetTimer2:Timer;
		public var redTimer1:Timer;
		public var redTimer2:Timer;
		
		public function HUDScreen( interactDisp:EventDispatcher, p1:Character, p2:Character ) {
			// constructor code			
			this.dispatcher = interactDisp;
			
			player1Info = new CharacterInfo(MAX_HEALTH, p1, this["p1health"], this.dispatcher);	// player 1
			player1Info.GUIComboCounter 	= this["p1ComboCounter"];
			player1Info.GUIBaseDamage 		= this["p1BaseDmg"];
			player1Info.GUIComboScaling 	= this["p1ComboScaling"];
			player1Info.GUIActualDamage 	= this["p1ActualDmg"];
			player1Info.GUIComboDamage 		= this["p1ComboDmg"];
			player1Info.GUIComboCounterBG	= this["p1ComboCounterBG"];
			player1Info.GUIComboDamageBG	= this["p1ComboDmgBG"];
											
			player2Info = new CharacterInfo(MAX_HEALTH, p2, this["p2health"], this.dispatcher);	// player 2
			player2Info.GUIComboCounter 	= this["p2ComboCounter"];
			player2Info.GUIBaseDamage 		= this["p2BaseDmg"];
			player2Info.GUIComboScaling 	= this["p2ComboScaling"];
			player2Info.GUIActualDamage 	= this["p2ActualDmg"];
			player2Info.GUIComboDamage 		= this["p2ComboDmg"];
			player2Info.GUIComboCounterBG	= this["p2ComboCounterBG"];
			player2Info.GUIComboDamageBG	= this["p2ComboDmgBG"];
						
			redTimer1 = new Timer(40, 25);
			redTimer2 = new Timer(40, 25);
			resetTimer1 = new Timer(3000, 1);
			resetTimer2 = new Timer(3000, 1);
			
			this.createEventListeners([this.dispatcher, this.dispatcher, this.dispatcher, resetTimer1, resetTimer2, redTimer1, redTimer2],
									  [AttackEvent.ATTACK_SUCCESSFUL, CharacterEvent.CHARACTER_RESET, MiscEvent.MISC_GOBACK, TimerEvent.TIMER, TimerEvent.TIMER, TimerEvent.TIMER, TimerEvent.TIMER],
									  [attackLanded, reset, removeReferences, resetComboHUD1, resetComboHUD2, drainRedHealth1, drainRedHealth2]);
			
		}
		
		private function removeReferences( M:MiscEvent ):void {
			if (redTimer1 != null) {
				if (redTimer1.running) {
					redTimer1.stop();
				}
			}
			
			if (redTimer2 != null) {
				if (redTimer2.running) {
					redTimer2.stop();
				}
			}
						
			if (resetTimer1) {
				if (resetTimer1.running) {
					resetTimer1.stop();
				}
			}
			
			if (resetTimer2) {
				if (resetTimer2.running) {
					resetTimer2.stop();
				}
			}
			
			redTimer1 = null;
			redTimer2 = null;
			resetTimer1 = null;
			resetTimer2 = null;
		}
		
		public function attackLanded( A:AttackEvent ):void {
			var info = A.attackInfo;
			var attacker:Character = info.attacker;
			var attackString:String = attacker.getStance() + " " + info.attack;
			var attackData:HitData = attacker.getHitData(attackString);
			
			effectHit( info.attackerIndex, attackData, info.attack );
		}
		
		public function reset( C:CharacterEvent ):void {
			var player:CharacterInfo;
			var resetTimer:Timer;
			
			if (C.charInfo.char == player1Info.player) {
				player = player2Info;	
				resetTimer = resetTimer2;
			} else {
				player = player1Info;
				resetTimer = resetTimer1;
			}
			
			player.resetCombo();
			
			resetTimer.reset();
			resetTimer.start();	
		}
		
		public function resetComboHUD1( T:TimerEvent ):void {
			player1Info.GUIComboCounter.text = "";
			player1Info.GUIComboDamage.text = "";
			player1Info.GUIComboCounterBG.text = "";
			player1Info.GUIComboDamageBG.text = "";
			player2Info.drain = (player2Info.GUIHealthBar.red.width - player2Info.GUIHealthBar.lifebar.width) / 25;
			
			redTimer2.reset();
			redTimer2.start();
		}
		
		public function resetComboHUD2( T:TimerEvent ):void {
			player2Info.GUIComboCounter.text = "";
			player2Info.GUIComboDamage.text = "";
			player2Info.GUIComboCounterBG.text = "";
			player2Info.GUIComboDamageBG.text = "";
			player1Info.drain = (player1Info.GUIHealthBar.red.width - player1Info.GUIHealthBar.lifebar.width) / 25;
			
			redTimer1.reset();
			redTimer1.start();
		}
		
		public function drainRedHealth1( T:TimerEvent ):void {	
			player1Info.GUIHealthBar.red.width -= player1Info.drain;
		}
		
		public function drainRedHealth2( T:TimerEvent ):void {	
			player2Info.GUIHealthBar.red.width -= player2Info.drain;
		}
		
		public function effectHit( attackerIndex:int, attack:HitData, attackName:String ):void {
			var attacker:CharacterInfo = (attackerIndex == 1) ? player1Info : player2Info;
			var sufferer:CharacterInfo = (attackerIndex == 1) ? player2Info : player1Info;
			var redTimer:Timer = (sufferer == player1Info) ? redTimer1 : redTimer2;
			var resetTimer:Timer = (sufferer == player1Info) ? resetTimer2 : resetTimer1;
			var damage:Number;
			var totalScaling:Number = 1.0;
			var repetitions:int = 0;
			
			if (redTimer) {
				if (redTimer.running) {				
					redTimer.stop(); 
					redTimer.reset();
				}
			}
			
			if (resetTimer) {
				if (resetTimer.running) {
					resetTimer.stop();
					resetTimer.reset(); 
				}
			}
			
			// current combo scaling
			totalScaling *= attacker.comboScaling;
			
			// stray hit scaling
			totalScaling = strayHitScaling(attacker, attack, totalScaling);
			
			// increment combo counter for attacker
			attacker.comboCounter++;			
				
			// mimimum hit scaling
			totalScaling = Math.max(totalScaling, attack.minimumHitScaling + 0);
									
			damage = baseDamage(attacker, attack, totalScaling);			
			
			attacker.comboDamage += damage;
			
			// deal damage
			sufferer.takeDamage(int(damage));
			updateHitData(attacker, attacker.comboCounter, attack.baseDamage, attacker.comboScaling, damage, attacker.comboDamage);
			updateHealthBar(sufferer, "damage", attacker.comboCounter);
			
			// post hit scaling
			postHitScaling(attacker, attackName, attack);
			
		}
		
		// get scaling for first hits
		private function strayHitScaling( attacker:CharacterInfo, attack:HitData, totalScaling:Number ):Number {
			if (attacker.comboCounter == 0) {
				totalScaling *= attack.strayHitScaling;
				attacker.comboScaling *= attack.strayHitScaling;
			}	
			return totalScaling;
			
		}
		
		// get natural (100%) damage of the hit
		private function baseDamage( attacker:CharacterInfo, attack:HitData, totalScaling:Number ):Number {
			if (attack.isMultiHit) {
				return (attack.baseDamage[attacker.player["hitNo"]] * totalScaling);
			} else if (attack.isCharged) {
				return (attack.baseDamage[attacker.player["chargeNo"]] * totalScaling);
			} else {
				return (attack.baseDamage * totalScaling);
			}
		}
		
		// get scaling for combo after hit is successful
		private function postHitScaling( attacker:CharacterInfo, attackName:String, attack:HitData ):void {
			if (attacker.lastAttackHit != attackName) {				
				// post hit scaling 
				if (attacker.lastAttackHit != "") {
					if (attack.isCharged) {
						attacker.comboScaling *= attack.postHitScaling[attacker.player["chargeNo"]];
					} else {
						attacker.comboScaling *= attack.postHitScaling;
					}			
					attacker.comboScaling = Math.max(attacker.comboScaling, attack.minimumHitScaling + 0);
				}
				attacker.lastAttackHit = attackName;
			}
		}
		
		public function updateHitData( player:CharacterInfo, counter:int, base:int, scaling:Number, damage:Number, total:Number ):void {
			player.GUIComboCounter.text = "x" + String(counter);
			player.GUIBaseDamage.text = String(base);
			player.GUIComboScaling.text = String(int(scaling * 100) / 100);
			player.GUIActualDamage.text = String(int(damage));
			player.GUIComboDamage.text = String(int(total)) + " Total Damage";
			
			player.GUIComboCounterBG.text = "x" + String(counter);
			player.GUIComboDamageBG.text = String(int(total)) + " Total Damage";
		}
		
		public function updateHealthBar( player:CharacterInfo, updateType:String, comboCounter:int ):void {
			if (player.GUIHealthBar.lifebar.width > player.GUIHealthBar.red.width && updateType == "damage") {
				player.GUIHealthBar.red.width = player.maxHealth * HEALTH_SCALE;
			} 
			if (comboCounter == 1) {
				player.GUIHealthBar.red.width = player.GUIHealthBar.lifebar.width;
			}
			
			player.GUIHealthBar.lifebar.width = player.health * HEALTH_SCALE;
		}
	}
	
}
