package Controllers {
		
	import Characters.*;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.*;
	import Clustering.DataPoint;
	
	import GameEvents.*;
	
	public class AgentBrainC extends GameObject {
		
		private const SECOND:int 				= 25;
		private const RANGE:int					= 40;
		private const EXPLORATION_RATE:Number 	= 0.1;
		private const LEARNING_RATE:Number		= 0.005;
		
		private var scenario:Object;
		private var agent:Character;
		private var opponent:Character;
		
		private var recentActions:Array = [];
		private var learning:Boolean;
		private var nearbyData:Array = [];		
		

		public function AgentBrainC( gameStage:Stage, agent:Character, opponent:Character, interactDisp:EventDispatcher, scenario ) {
			// constructor code
			this.agent = agent;
			this.opponent = opponent;
			this.scenario = scenario;
			this.dispatcher = interactDisp;
			learning = true;
			
			this.createEventListeners([this.dispatcher, gameStage],
									  [AttackEvent.ATTACK_DAMAGE, Event.ENTER_FRAME],
									  [rewardFunction, cycleRecentChoices]);		
		}
		
		public function setLearningState( learn:Boolean ):void {
			learning = learn;
		}
		
		// get state details
		/*
			displacement from agent to opponent
			altitude difference bwtween agent and opponent
			agent proximity to closest wall
			opponent proximity to closest wall
			displacement from opponent to agent
		*/
		private function getRelativePosition():Object {
			var stateString:String = "";
			var dist:Number = getRelativeDistance();
			var alt:Number = getRelativeAltitude();
			var wallProxAgent:Number = getDistanceToClosestWall(agent.x);
			var wallProxOpponent:Number = getDistanceToClosestWall(opponent.x);
			var disp:Number = getRelativeDistanceFromOpponent();
			
			return { dx:dist, dy:alt, wa:wallProxAgent, wo:wallProxOpponent, xo:disp };
		}
		
		private function getRelativeDistance():Number {
			var rd:Number = Math.round((opponent.x - agent.x) * (Math.abs(agent.scaleX) / agent.scaleX));			
			return rd;
		}
		
		private function getRelativeDistanceFromOpponent():Number {
			var rd:Number = Math.round((agent.x - opponent.x) * (Math.abs(opponent.scaleX) / opponent.scaleX));			
			return rd;
		}
		
		private function getRelativeAltitude():Number {
			var ra:Number = Math.round(opponent.y - agent.y)
			return ra;
		}
		
		private function getDistanceToClosestWall( xPos:Number ):Number {
			return Math.min(Math.abs(xPos + 125), Math.abs(xPos - 675));
		}
		
		private function getOpponentFacing():String {
			return ((((agent.x - opponent.x) * opponent.scaleX) > 0) ? "towards " : "away ");
		}
		
		
		// "action value" for opponent
		private function getOpponentAction():String {
			if (opponent.isStandingFrame()) {
				return "standing";
			} else if (opponent.isWalkingFrame()) {
				return "walking";
			} else if (opponent.isAirFrame()) {
				return "air";
			} else if (opponent.isAttackFrame()) {
				var attack:String = opponent.currentLabel;
				if (opponent.isThrow()) {
					attack = "throw " + attack;			// opponent is on a throw frame
				} else {
					attack = "attack " + attack;		// opponent is on an attack frame
				}
				attack += " " + opponent["moveStage"];
				return attack;
			} else if (opponent.isGuardFrame()) {
				return opponent.currentLabel;			// opponent is blocking
			} else if (opponent.isCrouchFrame()) {
				return "crouching";						// opponent is crouching
			} else if (opponent.isDashFrame()) {
				return opponent.currentLabel;			// opponent is dashing
			} else if (opponent.isHitFrame()) {
				var hitString:String = "hit " + opponent["hitStrength"];
				hitString += " " + opponent.getStance();
				hitString += " " + ((opponent["hittable"]) ?  "vulnerable" : "immune");
				return hitString;
			} else if (opponent.isDownedFrame()) {
				return "downed"							// opponent is downed
			} else if (opponent.isGrabbedFrame()) {
				return "grabbed"						// opponent is being grabbed
			} else if (opponent.isRecoveryFrame()) {
				return "recovering"						// opponent is getting up
			} else {				
				// prints the current labell and frame of the opponent to debug it
				trace("DEBUG: UNCONSIDERED STATE: ", opponent.currentLabel, opponent.currentFrame);
				return "???";							// state unknown
			}
		}
		
		// includes option to do nothing
		public function decide( currentState:String, options:Array ):int {
			var choices:Array = options.concat("nothing");
			var values:Array = [];
			var numOptions:int = choices.length;
			var decision:Number;
			var decisionSum:Number = 0;
			var i:int;
			var posObj:Object;
			
			if (nearbyData.length > 0) {
				nearbyData.splice(0, nearbyData.length);
			}
			
			// get state values
			posObj = getRelativePosition();
			
			// check for comparable previous experiences
			dispatcher.dispatchEvent( new MiscEvent( MiscEvent.MISC_NEARCHECK, { s:getOpponentAction(), pos:posObj, nearbyArray:nearbyData, range:RANGE } ) );
			
			// if no comparable experience, random
			if (nearbyData.length == 0 && learning) {
				i = makeDecision(choices, "random");
			} else {
				// if there is previous comparable experience, evaluate options
				values = assessChoices(choices);
				
				// 10% exploration chance, if met, go by weighted random decision
				if (Math.random() < EXPLORATION_RATE) {
					i = makeDecision(values, "explore");
				} else {
				// 90% best chance, if met, go by highest value decision
					i = makeDecision(values, "best");
				}
			}
			
			// decision made
			if (learning) {
				dispatcher.dispatchEvent( new ControllerEvent( ControllerEvent.CONTROLLER_DECISION, { } ) );
			}
			
			// add decision to recent actions
			recentActions.push( { t:1, d:(new DataPoint( posObj.dx, posObj.dy, getOpponentAction(), choices[i], "neutral", 1.0, dispatcher, posObj.xo, posObj.wa, posObj.wo )) } );			
			
			return i;
		}
		
		private function makeDecision( options:Array, type:String ):int {
			var decision:Number;
			var decisionIndices:Array = [];
			var decisionSum:Number = 0;
			var highestValue:Number = 0;
			var index:int = 0;
			var i:int;
			
			switch (type) {		// RANDOM
				case "random":
					// true random draw of options
					decision = Math.floor(Math.random() * options.length);
					index = decision;
				break;
				case "explore":	// EXPLORATIVE
					// random draw of options, based on how valued each option is after previous uses
					for (i = 0; i < options.length; i++) {
						decisionSum += options[i];						
					}
					decision = (Math.random() * decisionSum);	
					i = 0;
					while (decision > options[i] && index < (options.length - 1)) {
						decision -= options[i];
						index++;
					}				
				break;
				case "best":	// BEST
					// most valued option
					for (i = 0; i < options.length; i++) {
						highestValue = (highestValue < options[i]) ? options[i] : highestValue;
					}
										
					for (i = 0; i < options.length; i++) {
						if (highestValue == options[i]) {
							decisionIndices.push(i);
						}
					}
					
					decision = Math.floor(Math.random() * decisionIndices.length);
					index = decisionIndices[decision];
					
				break;
			}
			
			return index;
		}
		
		// evaluate options based on previous experiences
		private function assessChoices( choices:Array ):Array {
			var values:Array = [];
			var i:int;
			var j:int;
			
			// each option has initial value of 1
			for (i = 0; i < choices.length; i++) {
				values.push(1);
			}
			
			// for each option, adjust based on value of same action in previous uses
			for (i = 0; i < choices.length; i++) {
				for (j = 0; j < nearbyData.length; j++) {
					if (choices[i] == nearbyData[j].a) {
						values[i] *= nearbyData[j].v;
					}
				}
			}
			
			return values;
		}
		
		// reward function on damage
		private function rewardFunction( A:AttackEvent):void {
			if (!learning) {
				return;
			}			
			var modifier:Number; 
						
			// reward for dealing damage, punishment for receiving
			if (A.attackInfo.sufferer == opponent) {
				modifier = (A.attackInfo.dmg * LEARNING_RATE);
			} else if (A.attackInfo.sufferer == agent) {
				modifier = (A.attackInfo.dmg * -LEARNING_RATE);
			}
			
			// adjust all recent actions
			for (var i:int = 0; i < recentActions.length; i++) {
				recentActions[i].d.v *= (1 + (modifier * ((i + 1) / recentActions.length)));
				if (recentActions[i].d.v > 1) {
					recentActions[i].d.r = "positive";
				} else if (recentActions[i].d.v < 1) {
					recentActions[i].d.r = "negative";
				} else {
					recentActions[i].d.r = "neutral";
				}
			}
		}
		
		// if action taken more than a second ago, remove from recent actions list
		private function cycleRecentChoices( E:Event ):void {			
			for (var i:int = 0; i < recentActions.length; i++) {
				if (recentActions[i].t > SECOND) {
					recentActions[i].d.plot(scenario, getOpponentAction());
					recentActions.splice(i, 1);
				} else {
					recentActions[i].t++;					
				}				
			}
		}
	}
	
}
