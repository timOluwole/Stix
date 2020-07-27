package GameEvents {
		
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class MiscEvent extends Event {
		
		public static const MISC_GOBACK:String 		= "MiscGoBack";
		public static const MISC_ENDGAME:String		= "MiscEndGame";
		public static const MISC_NEARCHECK:String	= "MiscNearCheck";
		public static const MISC_HIDAMAGE:String	= "MiscHighDamage";
		public static const MISC_HICOUNTER:String	= "MiscHighCounter";
		public static const MISC_PRACTICE:String	= "MiscPractice";
		
		public var miscInfo:Object;

		public function MiscEvent( type:String, info:Object, bubbles:Boolean = true, cancelable:Boolean = false) {
			super( type, bubbles, cancelable );
			miscInfo = info;
		}
		
		public override function clone():Event {
            return new MiscEvent(type, this.miscInfo, bubbles, cancelable);
        }
       
        public override function toString():String {
            return formatToString("MiscEvent", "miscInfo", "type", "bubbles", "cancelable");
        }

	}
	
}
