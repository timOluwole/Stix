package VFX.CharVFX.VAttacks.Red {
	
	import Characters.Character;
	import Characters.Red.Character_Red;
	import VFX.EnvVFX.EnvFire;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	
	import GameEvents.*;
	
	public class CharVAttack_bS extends VisualAttacks {
		
		private var dispatcher:EventDispatcher;
		
		public var attackLevel:String = "mid";
		public var attackStrength:String = "heavy";
		public var attackDirection:String = "direct";
		public var attackKnockback:Object = { kX:75, kY:0 };
		public var attackDamage = 10;

		private var player:Character_Red;
		private var gameStage:Stage;
		private var match;
		
		public var vAtkIndex:int;
		
		public var baseScaleX:int;		

		public function CharVAttack_bS( s:Stage, p:Character_Red, scenario, heatStacks:int, index:int, atkDisp:EventDispatcher ) {
			// constructor code
			player = p;
			gameStage = s;
			match = scenario;
			
			vAtkIndex = index;
			
			dispatcher = atkDisp;
			
			initialiseAttributes(heatStacks);
			blurAndGlow();
						
			gameStage.addEventListener(Event.ENTER_FRAME, updater);
			
			dispatcher.addEventListener(AttackEvent.ATTACK_HIT, attackSpecialCase);
		}
		
		
		private function initialiseAttributes( heatStacks:int ):void {
			x = player.x + (player["vatkbox"].x * player.scaleX);
			y = player.y + (player["vatkbox"].y * player.scaleY);
			scaleX = player.scaleX;
			baseScaleX = player.scaleX;
			scaleY = 1 + (0.05 * heatStacks);
			transform.colorTransform = player.transform.colorTransform;
		}
		
		private function blurAndGlow():void {
			var b:BlurFilter = new BlurFilter();
			b.blurX = 5;
			b.blurY = 5;
			b.quality = 3;
			
			var g:GlowFilter = new GlowFilter();
			g.blurX = 30;
			g.blurY = 10;
			g.strength = 1.5;
			g.quality = 3;
			
			this.filters = [b, g];
		}
		
		
		private function updater( U:Event ):void {
			running();
			deletion();
		}
		
		private function running():void {
			if (currentLabel == "hit" && (player["moveStage"] != "fire" && player["moveStage"] != "firing")) {
				var fires:int = 5 + Math.round(Math.random() * 2); 
				var i:int = 0;
				var xPos:Number = x;
				var yPos:Number = 400;
				while (i < fires && (i == 0 || (xPos <= 550 && xPos >= 5 && i > 0))) {
					xPos += (75 + (Math.random() * 75)) * scaleX;
					var zPos:Number = z + 25 - (Math.random() * 50);
					i++;
					var envFire:EnvFire = new EnvFire(gameStage, this, xPos, yPos, zPos);
					match.addChild(envFire);
					match.setChildIndex(envFire, match.getChildIndex(this) + ((zPos < z) ? 2 : -1));		
				}
				gotoAndPlay("reset");
			} else if (player.currentLabel != "bS") {
				gotoAndPlay("reset");
			}
		}
		
		public function getHitPosition():Object {
			var posX:Number = x + (this["hitpos"].x * scaleX);
			var posY:Number = y + (this["hitpos"].y * scaleY);
			return { pX:posX, pY:posY };
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
		
		public function getStance():String {
			return player.getStance();
		}
		
		private function deletion():void {
			if (currentLabel == "delete") {
				if (parent) {
					player.shiftVisualAttackArray(vAtkIndex);
					player.visualAttacks.splice(vAtkIndex, 1);
					player.heatwaves = 0;
					parent.removeChild(this);
					gameStage.removeEventListener(Event.ENTER_FRAME, updater);
				}
			}
		}
		
		private function attackSpecialCase( A:AttackEvent ):void {
			var info:Object = A.attackInfo;
			// for now, just cover the attacked's special case
			if (this == info.attacked) {
				// trace("dispatched ATTACK_SPECIAL");
				dispatcher.dispatchEvent( new AttackEvent( AttackEvent.ATTACK_SPECIAL, {attacker:info.attacker, attacked:info.attacked, attack:info.attack, intervention:"none" } ) );
			}
		}

	}
	
}
