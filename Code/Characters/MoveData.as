package Characters {
	
	public class MoveData extends Object {

		public var chain:Array;				// list of moves in chain
		public var stances:Array;			// list of stances for each move in chain
		public var isAttack:Array;			// determines if move is an attack, implies that it can be missed
		public var isGrab:Array;			// determines if move is a throw
		public var isGrabCombo:Boolean;		// determines if move chain starts with a grab
		public var baseDamage:Array;		// damage of hit at 100% scaling
		public var strayHitScaling:Array;	// damage scaling of hit itself if the first hit to land (first hit of a chain is always 1)
		public var postHitScaling:Array;	// combo damage scaling after landing the hit
		public var minimumHitScaling:Array;	// mimimum damage scaling of the hit (typically 0.1)		
		public var spamHitScaling:Array;	// damage scaling if move is used 3 or more times in a row (typically equals half of post-hit scaling)(only applies to the first move of a combo)
		public var blockStun:Array;			// number of frames upon hit after which opponent can exit block
		
		// whole chains
		public function MoveData( chainLength:int ) {
			this.isAttack 			= [];
			this.isGrab 			= [];
			this.minimumHitScaling 	= [];
			
			var i:int;
			for (i = 0; i < chainLength; i++) {
				this.isAttack.push(true);			// most moves are strikes, can overwrite to false for non-strikes
				this.isGrab.push(false);			// most moves are strikes, can overwrite to true for actual throws
				this.minimumHitScaling.push(0.1);	// minimum hit scaling for each hit of chain 0.2 by default
			}
		}

	}
	
}
