package VFX.EnvVFX {
	
	import Characters.Character;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	
	public class EnvFire extends MovieClip {
		
		private var gameStage:Stage;
		private var effectSource:MovieClip;
		private var duration:int;

		public function EnvFire( s:Stage, src:MovieClip, xPos:Number, yPos:Number, zPos:Number  ) {
			effectSource = src;
			gameStage = s;
			
			x = xPos;
			y = yPos;
			z = zPos;
			
			initialiseAttributes();
			blur();
						
						
			gameStage.addEventListener(Event.ENTER_FRAME, updater);
		}
		
		private function initialiseAttributes():void {
			duration = 100 + Math.round(Math.random() * 100);
			scaleX *= (duration / 150) * ((Math.round(Math.random()) * 2) - 1);
			scaleY *= (duration / 150);
			transform.colorTransform = effectSource.transform.colorTransform;
			gotoAndPlay(1 + (Math.round(Math.random() * 10)) + (23 * (Math.round(Math.random() * 2))));
		}
		
		private function blur():void {
			var b:BlurFilter = new BlurFilter();
			b.blurX = 5 + (Math.random() * 5);
			b.blurY = 5 + (Math.random() * 5);
			b.quality = 1;
			this.filters = [b];
		}
		
		
		private function updater( U:Event ):void {
			running();
			deletion();
		}
		
		private function running():void {
			duration--;
			if (duration <= 0) {
				alpha -= (0.05 + (Math.random() * 0.05));
			}
			if (alpha <= 0) {
				gameStage.removeEventListener(Event.ENTER_FRAME, running);
				gotoAndStop("delete");
			}
		}
		
		private function deletion():void {
			if (currentLabel == "delete") {
				if (parent) {
					gameStage.removeEventListener(Event.ENTER_FRAME, updater);
					parent.removeChild(this);
				}
			}
		}

	}
	
}
