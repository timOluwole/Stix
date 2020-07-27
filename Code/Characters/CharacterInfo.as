package Characters {
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.EventDispatcher;
	import GameEvents.AttackEvent;
	
	public class CharacterInfo {
		
		private var interaction:EventDispatcher;
		
		// character specific variables
		public var player:Character;
		public var health:Number;
		public var maxHealth:int;
		public var lastAttackHit:String = "";
		public var comboCounter:int = 0;
		public var comboScaling:Number = 1;
		public var comboDamage:Number = 0;
		public var comboList:Array = [];
		public var hitDamage:Number = 0;
		public var drain:Number = 0;
		
		// GUI Items
		public var GUIHealthBar:MovieClip;
		public var GUIComboCounter:TextField;
		public var GUIBaseDamage:TextField;
		public var GUIComboScaling:TextField;
		public var GUIActualDamage:TextField;
		public var GUIComboDamage:TextField;
		public var GUIComboCounterBG:TextField;
		public var GUIComboDamageBG:TextField;
		
		public function CharacterInfo( max:int, p:Character, bar:MovieClip, interactDisp:EventDispatcher ) {
			// constructor code
			player = p;
			health = max;
			maxHealth = max;
			GUIHealthBar = bar;
			interaction = interactDisp;
		}
		
		// resets combo settings upon dropping a combo
		public function resetCombo():void {
			comboCounter = 0;
			comboScaling = 1.0;
			comboDamage = 0;
			comboList.splice(0);
			lastAttackHit = "";
		}
		
		// reduce health upon taking damage
		public function takeDamage( damage:int ):void {
			interaction.dispatchEvent( new AttackEvent (AttackEvent.ATTACK_DAMAGE, { sufferer:player, hp:health, dmg:damage } ) );
			health = (health - Math.max(damage, 1) + maxHealth) % maxHealth;
		}

	}
	
}
