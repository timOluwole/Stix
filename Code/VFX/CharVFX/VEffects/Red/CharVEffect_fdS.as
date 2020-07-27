package VFX.CharVFX.VEffects.Red {
	
	import Characters.Character;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	public class CharVEffect_fdS extends MovieClip {
		
		private var player:Character;
		private var match;
		
		private var attackLevel:String = "mid";
		private var attackStrength:String = "heavy";
		private var attackDirection:String = "direct";
		private var attackKnockback:Object = { kX:80, kY:0 };

		public function CharVEffect_fdS( s:Stage, p:Character, scenario ) {
			// constructor code
			player = p;
			match = scenario;

			initialiseAttributes();
			blur();
						
			s.addEventListener(Event.ENTER_FRAME, deletion);
		}
		
		private function initialiseAttributes():void {
			x = player.x + (player["vfxbox"].x * player.scaleX);
			y = player.y + (player["vfxbox"].y * player.scaleY);
			rotation = (player["thisRotation"] * player.scaleX);
			scaleX = player.scaleX;
			
			transform.colorTransform = player.transform.colorTransform;
		}
		
		private function blur():void {
			var b:BlurFilter = new BlurFilter();
			b.blurX = 5;
			b.blurY = 5;
			b.quality = 1;
			this.filters = [b];
		}
		
		private function deletion(D:Event):void {
			if (currentLabel == "delete") {
				if (parent) {
					parent.removeChild(this);
				}
			}
		}

	}
	
}
