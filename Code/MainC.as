 package  {
	
	import Characters.Character;
	import Controllers.*;
	import Characters.Red.Character_Red;
	import Interactions.InteractionTest;
	import Interactions.VCam;
	import GameEvents.*;
	import GameStages.*;
	import DecisionValue;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.display.Stage;

	public class MainC extends MovieClip {
		
		private const TRAINING_PERIOD:int 	= 1000;		// duration of training period
		private const NUMBER_OF_MATCHES:int	= 50;		// number of matches used for testing
		
		// decision variables
		private var decisionsMade:int;							
		private var decisionsMadeInSession:int;
		
		// character variables
		private var playerNo:int = 1;
		private var player:Character;
		private var opponent:Character;
		
		// necessary
		private var dispatcher:EventDispatcher;
		private var iTest:InteractionTest;					
		private var initTimer:Timer;		
		private var gameStage:GameStage;
		
		// controllers
		private var clientController:HumanController;
		private var agent1Controller:AIController;
		private var agent2Controller:AIController;
		private var randomController:RandomController;
		
		// score tracking
		private var gameMode:String = "";
		private var testWins:int	= 0;
		private var testLosses:int	= 0;
		private var cycles:int		= 0;

		public function MainC() {
			// constructor code
			decisionsMade = 0;			
			dispatcher = new EventDispatcher();			
			initTimer= new Timer(10, 1);			
			resetEventListeners(null);		
			
			// stage.addEventListener(Event.ENTER_FRAME, stages);
		}
		
		// resets game after conclusion of match or practice
		public function resetGame( M:MiscEvent ):void {		
			nextFrame();
			
			if (gameMode == "mirrored learning"	|| 
				gameMode == "versus random" 	|| 
				gameMode == "training") {
					
				testWins	= 0;
				testLosses	= 0;
			}		
			
			gameMode = "";
			
			// update score
			TestScore.text = String(testWins) + " - " + String(testLosses);
			
			// delete previous game
			try {
				player.parent.removeChild(player);
				opponent.parent.removeChild(opponent);
				gameStage.parent.removeChild(gameStage);
			} catch (error:Error) {
				// oh well
			}
			
			iTest = null;
			player = null;
			opponent = null;
			gameStage = null;
			
			//show decisions made
			TDC.text = "Total Training Decisions Made: " + String(decisionsMade);
			decisionsMadeInSession = 0;
		}
		
		// resets event listeners
		public function resetEventListeners( M:MiscEvent ):void {	
			
			initTimer.addEventListener(TimerEvent.TIMER, initFunction);
			
			dispatcher.addEventListener(AttackEvent.ATTACK_DAMAGE, checkGame);
			dispatcher.addEventListener(ControllerEvent.CONTROLLER_DECISION, decisionMade);
			dispatcher.addEventListener(MiscEvent.MISC_GOBACK, resetGame);
			dispatcher.addEventListener(MiscEvent.MISC_GOBACK, resetEventListeners);
		}
		
		// if health depletes in match, end game, update score if AI
		private function checkGame( A:AttackEvent ):void {
			var info:Object = A.attackInfo;
			
			if (info.hp <= info.dmg && (gameMode == "testing" || gameMode == "versus ai")) {
				if (info.sufferer == player) {	
					if (gameMode == "testing") {
						// loss
						testLosses++;
					}
					dispatcher.dispatchEvent(new MiscEvent(MiscEvent.MISC_GOBACK, { } ) );
					dispatcher.dispatchEvent(new MiscEvent(MiscEvent.MISC_ENDGAME, { } ) );
				} else if (info.sufferer == opponent) {
					if (gameMode == "testing") {
						// win
						testWins++;
					}
					dispatcher.dispatchEvent(new MiscEvent(MiscEvent.MISC_GOBACK, { } ) );
					dispatcher.dispatchEvent(new MiscEvent(MiscEvent.MISC_ENDGAME, { } ) );
				}
			}
		}
		
		public function goMirrored( M:MouseEvent ):void {
			gotoAndStop(1, "Learning");
			gameMode = "mirrored learning";
			initTimer.start();
		}
		
		public function goRandom( M:MouseEvent ):void {
			gotoAndStop(1, "Learning");
			gameMode = "versus random";
			initTimer.start();
		}
		
		public function goTest( M:MouseEvent ):void {
			gotoAndStop(1, "Testing");
			gameMode = "testing";
			initTimer.start();
		}
		
		public function goTraining( M:MouseEvent ):void {
			gotoAndStop(1, "FreeUse");
			gameMode = "training";
			initTimer.start();
		}
		
		public function goAI( M:MouseEvent ):void {
			gotoAndStop(1, "FreeUse");
			gameMode = "versus ai";
			initTimer.start();
		}
		
		// initialise game
		private function initFunction( T:TimerEvent ):void {
			addStage();
			addPlayers();						
			editPlayers();
			addInteraction();
			
			initTimer.stop();
			initTimer.removeEventListener(TimerEvent.TIMER, initFunction);
		}
		
		// add chosen game stage
		private function addStage():void {			
			switch (room) {
				case "red":
					gameStage = new GameStage_TrainingRoomR(stage, this, dispatcher, true);	
					break;
				case "green":
					gameStage = new GameStage_TrainingRoomG(stage, this, dispatcher, true);
					break;
				case "blue":
					gameStage = new GameStage_TrainingRoomB(stage, this, dispatcher, true);
					break;
				case "yellow":
					gameStage = new GameStage_TrainingRoomY(stage, this, dispatcher, true);	
					break;
				case "neon":
					gameStage = new GameStage_NeonFloor(stage, this, dispatcher, false);	
					break;
			}				
					
			addChild(gameStage);
		}
		
		// player adition
		private function addPlayers():void {			
			player = new Character_Red(stage, this, dispatcher);
			player.x = 125;
			player.y = 400;
			player.scaleX = 1;
			addChild(player);
			
			opponent = new Character_Red(stage, this, dispatcher);
			opponent.x = 425;
			opponent.y = 400;
			opponent.scaleX = -1;
			addChild(opponent);						
		}
		
		/// set up character interaction
		private function addInteraction():void {
			iTest = new InteractionTest(stage, player, opponent, this, gameStage, "offline", playerNo, dispatcher);
			
			if (gameMode == "mirrored learning"	|| 
				gameMode == "versus random" 	|| 
				gameMode == "training") {
				dispatcher.dispatchEvent( new MiscEvent( MiscEvent.MISC_PRACTICE, { } ) );
			}
		}
		
		private function editPlayers():void {
			var myColorTransform = new ColorTransform();
				myColorTransform.redOffset   = 000;
				myColorTransform.greenOffset = 000;
				myColorTransform.blueOffset  = 255;
			
			opponent.transform.colorTransform = myColorTransform;	
			
			switch (gameMode) {
				case "mirrored learning":	// AI vs AI - practice
					stage.frameRate = 25;
					agent1Controller = new AIController(new CharController(stage, this, player, this), stage, opponent, dispatcher, true, this);
					agent2Controller = new AIController(new CharController(stage, this, opponent, this), stage, player, dispatcher, true, this);
					break;
				case "versus random":		// AI vs random - practice
					stage.frameRate = 25;
					agent1Controller = new AIController(new CharController(stage, this, player, this), stage, opponent, dispatcher, true, this);
					randomController = new RandomController(new CharController(stage, this, opponent, this), stage, player, dispatcher);
					break;
				case "testing":				// AI vs random - match
					stage.frameRate = 25;
					agent1Controller = new AIController(new CharController(stage, this, player, this), stage, opponent, dispatcher, false, this);
					randomController = new RandomController(new CharController(stage, this, opponent, this), stage, player, dispatcher);
					break;
				case "training":			// human vs dummy - practice
					stage.frameRate = 25;
					clientController = new HumanController(new CharController(stage, this, player, this), stage, dispatcher);
					// dummy
					break;
				case "versus ai":			// human vs AI - match
					stage.frameRate = 25;
					clientController = new HumanController(new CharController(stage, this, player, this), stage, dispatcher);
					agent1Controller = new AIController(new CharController(stage, this, opponent, this), stage, opponent, dispatcher, false, this);
					break;
			}
			
		}
		
		// increment decision count
		private function decisionMade( C:ControllerEvent ):void {		
			decisionsMade++;
			decisionsMadeInSession++;
			
			// exit practice if decision count has reached designated amount
			if (decisionsMadeInSession >= TRAINING_PERIOD) {
				decisionsMadeInSession = 0;
				dispatcher.dispatchEvent( new MiscEvent( MiscEvent.MISC_GOBACK, { } ) );
				dispatcher.dispatchEvent( new MiscEvent( MiscEvent.MISC_ENDGAME, { } ) );
			}
		}
	}
}
