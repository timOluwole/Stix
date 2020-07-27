package Controllers {
	
	import Characters.*;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.*;
	
	import Controllers.*;
	
	public class HumanController extends GameObject {
		
		public var char:CharController;
		private var unit:Character;
		
		private var lastPressed:String = "";
		private var upTime:Number;
		
		private var lInput:Boolean = false;
		private var rInput:Boolean = false;
		private var uInput:Boolean = false;
		private var dInput:Boolean = false;
		
		private static const INPUT_KEYCODE_LEFT:int		= 65;	// A
		private static const INPUT_KEYCODE_RIGHT:int	= 68;	// D
		private static const INPUT_KEYCODE_UP:int		= 87;	// W
		private static const INPUT_KEYCODE_DOWN:int		= 83;	// S
		private static const INPUT_KEYCODE_GUARD:int	= 79;	// O
		private static const INPUT_KEYCODE_PUNCH:int 	= 80;	// P
		private static const INPUT_KEYCODE_KICK:int		= 75;	// K
		private static const INPUT_KEYCODE_THROW:int	= 73;	// I
		private static const INPUT_KEYCODE_SPECIAL:int	= 74;	// J
		
		public function HumanController( cController:CharController, gameStage:Stage, interactDisp:EventDispatcher ) {
			// constructor code
			this.char = cController;			
			this.unit = char.unit;			
			this.dispatcher = interactDisp;
			
			this.createEventListeners([gameStage, gameStage, gameStage],
									  [KeyboardEvent.KEY_UP, KeyboardEvent.KEY_DOWN, Event.ENTER_FRAME],
									  [keysUp, keysDown, doubleTapDetection]);	
									  
			// gameStage.addEventListener(Event.ENTER_FRAME, update_function(gameStage));
		}
		
		/*
		public function update_function(gameStage):Function {
			return function(E:Event):void {				
				gameStage.addEventListener(KeyboardEvent.KEY_UP, keysUp);
				gameStage.addEventListener(KeyboardEvent.KEY_DOWN, keysDown);
				gameStage.addEventListener(Event.ENTER_FRAME, doubleTapDetection);
			}
		}	
		*/
		
		private function keysUp(K:KeyboardEvent):void {
			if (K.keyCode == INPUT_KEYCODE_LEFT) {
				lInput = false;
				char.setLeftInput(false);
				lastPressed = "left";
				upTime = getTimer();
			}
			if (K.keyCode == INPUT_KEYCODE_RIGHT) {
				rInput = false;
				char.setRightInput(false);
				lastPressed = "right";
				upTime = getTimer();
			}
			if (K.keyCode == INPUT_KEYCODE_UP) {
				uInput = false;
				char.setUpInput(false);
			}
			if (K.keyCode == INPUT_KEYCODE_DOWN) {
				dInput = false;
				char.setDownInput(false);
			}
			if (K.keyCode == INPUT_KEYCODE_GUARD) { // o - guard
				char.setGuardInput(false);
			}
			if (K.keyCode == INPUT_KEYCODE_PUNCH) { // p - punch
				char.setPunchInput(false);
			}
			if (K.keyCode == INPUT_KEYCODE_KICK) { // k - kick
				char.setKickInput(false);
			}
			if (K.keyCode == INPUT_KEYCODE_THROW) { // i - throw
				char.setThrowInput(false);
			}
			if (K.keyCode == INPUT_KEYCODE_SPECIAL) { // j - special
				char.setSpecialInput(false);
			}
		}
		
		private function keysDown(K:KeyboardEvent):void {
			if (K.keyCode == INPUT_KEYCODE_LEFT) {
				lInput = true;
				char.setLeftInput(true);
				char.setRightInput(false);
				detectDoubleTap("left");
			}
			if (K.keyCode == INPUT_KEYCODE_RIGHT) {
				rInput = true;
				char.setRightInput(true);
				char.setLeftInput(false);
				detectDoubleTap("right");
			}
			if (K.keyCode == INPUT_KEYCODE_UP) {
				uInput = true;
				char.setUpInput(true);
				char.setDownInput(false);
			}
			if (K.keyCode == INPUT_KEYCODE_DOWN) {
				dInput = true;
				char.setDownInput(true);
				char.setUpInput(false);
			}
			if (K.keyCode == INPUT_KEYCODE_GUARD) { // o - guard
				char.setGuardInput(true);
			}
			if (K.keyCode == INPUT_KEYCODE_PUNCH) { // p - punch
				char.setPunchInput(true);
			}
			if (K.keyCode == INPUT_KEYCODE_KICK) { // k - kick
				char.setKickInput(true);
			}
			if (K.keyCode == INPUT_KEYCODE_THROW) { // i - throw
				char.setThrowInput(true);
			}
			if (K.keyCode == INPUT_KEYCODE_SPECIAL) { // j - special
				char.setSpecialInput(true);
			}
		}
		
		
		private function detectDoubleTap(nextPressed:String):void {
			if (lastPressed == nextPressed) {
				var downTime = getTimer();
				var delay:Number = (downTime - upTime) * 0.001;
				if (delay <= 0.08) {
					char.doubleTapDetected(nextPressed);
				}
			}
		}
		
		private function doubleTapDetection( D:Event ):void {
			if ((lastPressed == "left" && lInput) || (lastPressed == "right" && rInput)) {
				var downTime = getTimer();				
				var delay:Number = (downTime - upTime) * 0.001;
				if (delay > 0.08) {
					char.setDashEnabled(false);
				}
			}
		}
		
		public function getPlayerX():Number {
			return unit.x;
		}
		
		public function getPlayerY():Number {
			return unit.y;
		}
		
		public function getPlayerUnit():Character {
			return char.getPlayerUnit();
		}

	}
	
}
