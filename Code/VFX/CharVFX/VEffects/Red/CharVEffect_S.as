package VFX.CharVFX.VEffects.Red {
	
	import Characters.Character;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.BlurFilter;
	
	public class CharVEffect_S extends GameSprite {
		
		private var player:Character;
		private var match:Object;
		
		private var alphaN:Number; 
		
		public function CharVEffect_S( s:Stage, p:Character, scenario:Object, dispatcher:EventDispatcher ) {
			// constructor code
			player = p;
			match = scenario;
			this.dispatcher = dispatcher;
			
			initialiseAttributes();
			blur();
			
			this.createEventListeners([s], [Event.ENTER_FRAME], [deletion]);
		}
		
		private function initialiseAttributes():void {
			var attempts:int = 0;
			var touchingBody:Boolean = false;
			do {
				attempts++;
				x = player.x + (Math.random() * player["figure"].width) - (0.5 * player["figure"].width);
				y = player.y - (Math.random() * player["figure"].height);
				touchingBody = player["figure"].hitTestPoint(x, y, true);
			} while (!touchingBody && attempts < 8);
			if (!touchingBody) {
				gotoAndStop("delete");
			} else {
				gotoAndPlay(1 + (12 * Math.round(Math.random() * 2)));
				scaleX = 0.75 + (Math.random() * 0.5);
				scaleY = scaleX * 1 - ((Math.random() * 0.5));
				alpha = 0.4 + (Math.random() * 0.2);
				transform.colorTransform = player.transform.colorTransform;
			}
		}
		
		private function blur():void {
			var b:BlurFilter = new BlurFilter();
			b.blurX = 5 + Math.round(Math.random() * 5);
			b.blurY = 5 + Math.round(Math.random() * 5);
			b.quality = 1;
			this.filters = [b];
		}
		
		private function deletion( D:Event ):void {
			if (currentLabel == "delete") {
				if (parent) {
					parent.removeChild(this);
				} else {
					delete this;
				}
			}
		}

	}
	
}
