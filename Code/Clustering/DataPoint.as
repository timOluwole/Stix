package Clustering {
	
	import flash.events.EventDispatcher;
	import flash.net.LocalConnection;
	import GameEvents.MiscEvent;
	
	public class DataPoint {		
	
		private var dispatcher:EventDispatcher;
		
		public var x:Number;	// x difference from agent to opponent
		public var y:Number;	// y difference from agent to opponent
		public var s:String;	// denotes the state of the game (i.e. what the opponent is doing)
		public var a:String;	// denotes the action taken
		public var r:String;	// denotes the reward of the data point (positive/negative/neutral)
		public var v:Number;	// denotes the actual value of the reward
		
		public var wa:Number;	// proximity of agent to closest wall (halved)
		public var wo:Number;	// proximity of opponent to closest wall (halved)
		public var xo:Number;	// relative displacement of agent from opponent
		
		public function DataPoint( x:Number, y:Number, s:String, a:String, r:String, v:Number, dispatcher:EventDispatcher, xo:Number, wa:Number = 0, wo:Number = 0 ) {
			// constructor code
			this.x = x;
			this.y = y;
			this.s = s;
			this.a = a;
			this.r = r;
			this.v = v;
			this.dispatcher = dispatcher;
			this.xo = xo;
			this.wa = wa * 0.5;
			this.wo = wo * 0.5;
			
			this.dispatcher.addEventListener( MiscEvent.MISC_NEARCHECK, nearCheck );
		}
		
		// plot on graph (if graph executable is open)
		public function plot( scenario, opponentAction:String ) {
			// if neutral, delete it (optional)
			if (r == "neutral") {
				dispatcher.removeEventListener( MiscEvent.MISC_NEARCHECK, nearCheck );
				delete this;
				return;
			}
			var lc:LocalConnection = new LocalConnection();
			lc.isPerUser = true;
			lc.client = scenario;
			lc.send("plotting", "plot", x, y, a, r);
			
			// printData();
				  
			lc = null;
		}
		
		private function nearCheck( M:MiscEvent ):void {
			if (M.miscInfo.s != this.s) {
				return;
			}
			
			var pos:Object;
			var dist:Number;
			
			pos = M.miscInfo.pos;			
			pos.wa *= 0.5;
			pos.wo *= 0.5;
			
			// MANHATTAN DISTANCE of data point from the current state
			dist = (Math.abs(this.x - pos.dx) + Math.abs(this.y - pos.dy) + Math.abs(this.wa - pos.wa) + Math.abs(this.wo - pos.wo) + Math.abs(this.xo - pos.xo));
			
			// if within range, add to nearby data array
			if (dist <= M.miscInfo.range) {
				M.miscInfo.nearbyArray.push(this);
			}
		}
		
		/*
		private function printData():void {
			var xPos:String = String(Math.round(x * 100) / 100); 
			while ((xPos += " ").length < 5) {}
			var yPos:String = String(Math.round(y * 100) / 100); 
			while ((yPos += " ").length < 5) {}
			var vVal:String = String(Math.round(v * 100) / 100); 
			while ((vVal += " ").length < 6) {}
			var waPos:String = String(Math.round(wa * 100) / 100); 
			while ((waPos += " ").length < 7) {}
			var woPos:String = String(Math.round(wo * 100) / 100); 
			while ((woPos += " ").length < 7) {}
			var xoPos:String = String(Math.round(xo * 100) / 100); 
			while ((xoPos += " ").length < 7) {}
			var sStr:String = String("\"" + s + "\""); 
			while ((sStr += " ").length < 32) {}			
			var aStr:String = String("\"" + a + "\""); 
			while ((aStr += " ").length < 18) {}
			var rStr:String = String("\"" + r + "\"");
			while ((rStr += " ").length < 11) {}
			
			
			trace("[" + xPos + ", " + yPos + ", " + sStr + ", " + aStr + ", " + rStr + ", " + vVal + ", " + xoPos + ", " + waPos + ", " + woPos + "]");
		}
		*/

	}
	
}
