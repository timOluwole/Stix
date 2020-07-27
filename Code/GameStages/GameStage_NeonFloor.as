package GameStages {
		
	import Characters.Character;
	import GameStages.GameStage;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.Stage;
	import GameEvents.*;
	
	public class GameStage_NeonFloor extends GameStage {

		public function GameStage_NeonFloor( s:Stage, scenario:Object, interactionDisp:EventDispatcher, walls:Boolean ) {
			// constructor code
			this.gameStage = s;
			this.scenario = scenario;
			this.dispatcher = interactionDisp;
			
			this.leftWall = false;
			this.rightWall = false;
			this.ceiling = false;
			
			this.createEventListeners([this.dispatcher, this.gameStage], 
									  [CharacterEvent.CHARACTER_MOVE, Event.ENTER_FRAME], 
									  [this.movement, this.respectiveMovement]);
		}

	}
	
}
