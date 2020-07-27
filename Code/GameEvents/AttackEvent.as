package GameEvents {
		
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class AttackEvent extends Event {
		
		public static const ATTACK_PERFORMED:String 	= "AttackPerformed";
		public static const ATTACK_CONTACT:String 		= "AttackContact";
		public static const ATTACK_HIT:String 			= "AttackHit";
		public static const ATTACK_MISS:String 			= "AttackMiss";
		public static const ATTACK_AVOIDED:String 		= "AttackAvoided";
		public static const ATTACK_BLOCKED:String 		= "AttackBlocked";
		public static const ATTACK_SPECIAL:String 		= "AttackSpecial";
		public static const ATTACK_SUCCESSFUL:String 	= "AttackSuccessful";
		public static const ATTACK_UNSUCCESSFUL:String 	= "AttackUnsuccessful";
		public static const ATTACK_DAMAGE:String		= "AttackDamage";
		public static const ATTACK_COUNTER:String		= "AttackCounter";
		
		public var attackInfo:Object;

		public function AttackEvent( type:String, info:Object, bubbles:Boolean = true, cancelable:Boolean = false) {
			super( type, bubbles, cancelable );
			attackInfo = info;
		}
		
		public override function clone():Event {
            return new AttackEvent(type, this.attackInfo, bubbles, cancelable);
        }
       
        public override function toString():String {
            return formatToString("AttackEvent", "attackInfo", "type", "bubbles", "cancelable");
        }

	}
	
}
