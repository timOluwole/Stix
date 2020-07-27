package GameEvents {
		
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class ControllerEvent extends Event {
		
		public static const CONTROLLER_DECISION:String 	= "ControllerDecision";
		public static const CONTROLLER_REVALUE:String 	= "ControllerRevalue";
		public static const CONTROLLER_OPTION:String 	= "ControllerOption";
		
		public var contInfo:Object;

		public function ControllerEvent( type:String, info:Object, bubbles:Boolean = true, cancelable:Boolean = false) {
			super( type, bubbles, cancelable );
			contInfo = info;
		}
		
		public override function clone():Event {
            return new ControllerEvent(type, this.contInfo, bubbles, cancelable);
        }
       
        public override function toString():String {
            return formatToString("ControllerEvent", "contInfo", "type", "bubbles", "cancelable");
        }

	}
	
}
