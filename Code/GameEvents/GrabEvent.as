package GameEvents {
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class GrabEvent extends Event {
		
		public static const GRAB_PERFORMED:String 		= "GrabPerformed";
		public static const GRAB_CONTACT:String 		= "GrabContact";
		public static const GRAB_LAND:String 			= "GrabLand";
		public static const GRAB_MISS:String 			= "GrabMiss";
		public static const GRAB_AVOIDED:String 		= "GrabMiss";
		public static const GRAB_SPECIAL:String 		= "GrabSpecial";
		public static const GRAB_SUCCESSFUL:String 		= "GrabSuccessful";
		public static const GRAB_UNSUCCESSFUL:String 	= "GrabUnsuccessful";
		
		public var grabInfo:Object;

		public function GrabEvent( type:String, info:Object, bubbles:Boolean = true, cancelable:Boolean = false) {
			super( type, bubbles, cancelable );
			grabInfo = info;
		}
		
		public override function clone():Event {
            return new GrabEvent(type, this.grabInfo, bubbles, cancelable);
        }
       
        public override function toString():String {
            return formatToString("GrabEvent", "grabInfo", "type", "bubbles", "cancelable");
        }

	}
	
}
