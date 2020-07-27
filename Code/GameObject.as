package  {
	
	import flash.events.*;
	import GameEvents.*;
	
	public class GameObject {
		
		protected var dispatcher:EventDispatcher = null;
		protected var listeners:Array	= [];
		protected var eventTypes:Array	= [];
		protected var callbacks:Array	= [];
		
		public function GameObject() {
			// constructor code
		}
		
		protected function createEventListeners( l:Array, e:Array, c:Array ):void {						
			this.listeners = l;
			this.eventTypes = e;
			this.callbacks = c;
			
			for (var i:int = 0; i < listeners.length; i++) {
				this.listeners[i].addEventListener(this.eventTypes[i], this.callbacks[i]);
			}
			
			this.dispatcher.addEventListener(MiscEvent.MISC_ENDGAME, remove);
		}
		
		protected function removeEventListeners():void {
			for (var i:int = 0; i < listeners.length; i++) {
				this.listeners[i].removeEventListener(this.eventTypes[i], this.callbacks[i]);
			}
			listeners.splice(0, listeners.length);
			eventTypes.splice(0, eventTypes.length);
			callbacks.splice(0, callbacks.length);
			
			this.dispatcher.removeEventListener(MiscEvent.MISC_ENDGAME, remove);
		}
		
		private function remove( M:MiscEvent ):void {
			removeEventListeners();
			delete this;
		}

	}
	
}
