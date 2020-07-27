package GameEvents {
		
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class CharacterEvent extends Event {
		
		public static const CHARACTER_RESET:String 		= "CharacterReset";		// trigger combo reset
		public static const CHARACTER_MOVE:String		= "CharacterMove";		// trigger stage movement handler
		public static const CHARACTER_DASH:String 		= "CharacterDash";		// trigger shadow step
		public static const CHARACTER_DOWNED:String 	= "CharacterDowned";	// trigger knock couuter/knee caps
		public static const CHARACTER_FALLEN:String 	= "CharacterFallen";	// trigger knock counter/downed immunity
		public static const CHARACTER_RISING:String 	= "CharacterRising";	// trigger standing immunity
		public static const CHARACTER_CAMERA:String 	= "CharacterCamera";	// trigger camera tracking toggle
		public static const CHARACTER_BLOCKSTUN:String	= "CharacterBlockStun";	// trigger block stun
		public static const CHARACTER_HITSTUN:String	= "CharacterHitStun";	// trigger hit stun
		
		public var charInfo:Object;

		public function CharacterEvent( type:String, info:Object, bubbles:Boolean = true, cancelable:Boolean = false) {
			super( type, bubbles, cancelable );
			charInfo = info;
		}
		
		public override function clone():Event {
            return new CharacterEvent(type, this.charInfo, bubbles, cancelable);
        }
       
        public override function toString():String {
            return formatToString("AttackEvent", "charInfo", "type", "bubbles", "cancelable");
        }

	}
	
}
