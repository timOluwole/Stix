package VFX.CharVFX.VEffects.Red {
	
	import Characters.Character;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	public class CharVEffect_fS extends MovieClip {
		
		private var player:Character;
		private var match;
		
		public function CharVEffect_fS( s:Stage, p:Character, scenario ) {
			// constructor code
			player = p;
			match = scenario;
			
			initialiseAttributes();
			blur();
						
			s.addEventListener(Event.ENTER_FRAME, setAttributes);
			s.addEventListener(Event.ENTER_FRAME, deletion);
		}
		
		private function initialiseAttributes():void {
			x = player.x + (player["vfxbox"].x * player.scaleX);
			y = player.y + (player["vfxbox"].y * player.scaleY);
			rotation = (player["vfxbox"].rotation * player.scaleX);
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
		
		private function setAttributes( S:Event ):void {
			if (parent) {
				parent.setChildIndex(this, parent.getChildIndex(player) - 1);
			}
		}
		
		private function deletion( D:Event ):void {
			if (currentLabel == "delete") {
				if (parent) {
					parent.removeChild(this);
				}
			}
		}

	}
	
}
