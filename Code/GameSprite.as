package  {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import GameEvents.*;
	
	public class GameSprite extends MovieClip {
		
		protected var dispatcher:EventDispatcher;	// reference to the dispatcher
		protected var gameStage:Stage;				// reference to the game stage
		protected var scenario:Object;				// reference to the whole game
		
		protected var listeners:Array	= [];	// array of event listeners
		protected var eventTypes:Array	= [];	// array of event types
		protected var callbacks:Array	= [];	// array of event callbacks
		
		public function GameSprite() {
			// constructor code
		}
		
		// adding event listeners to object
		protected function createEventListeners( l:Array, e:Array, c:Array ):void {
			this.listeners = l;
			this.eventTypes = e;
			this.callbacks = c;
			// assigniing event types and callbacks to event listeners 
			for (var i:int = 0; i < listeners.length; i++) {
				this.listeners[i].addEventListener(this.eventTypes[i], this.callbacks[i]);
			}
			
			this.dispatcher.addEventListener(MiscEvent.MISC_ENDGAME, remove);
		}
		
		// removeing event listeners from object
		protected function removeEventListeners():void {
			for (var i:int = 0; i < listeners.length; i++) {
				this.listeners[i].removeEventListener(this.eventTypes[i], this.callbacks[i]);
			}
			
			this.dispatcher.removeEventListener(MiscEvent.MISC_ENDGAME, remove);
		}
		
		// remove object from stage
		private function remove( M:MiscEvent ):void {
			removeEventListeners();
			if (this.parent) {		
				this.parent.removeChild(this);
			} else {
				delete this;
			}
		}

	}
	
}
