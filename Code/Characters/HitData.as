package Characters {
	
	public class HitData extends Object {

		public var chain:Array;				// list of moves in chain
		public var stances:Array;			// list of stances for each move in chain
		public var isAttack:Boolean;		// determines if move is an attack, implies that it can be missed
		public var isMultiHit:Boolean;		// hits more than once
		public var isCharged:Boolean;		// hit can be charged
		public var isGrab:Boolean;			// determines if move is a throw
		public var isGrabCombo:Boolean;		// determines if move chain starts with a grab
		public var baseDamage;				// damage of hit at 100% scaling
		public var strayHitScaling:Number;	// damage scaling of hit itself if the first hit to land (first hit of a chain is always 1)
		public var postHitScaling;			// combo damage scaling after landing the hit
		public var minimumHitScaling:Number;// mimimum damage scaling of the hit (typically 0.2)		
		public var spamHitScaling:Number;	// damage scaling if move is used 3 or more times in a row (typically equals half of post-hit scaling)(only applies to the first move of a combo)
		public var blockStun;				// number of frames upon hit after which opponent can exit block
		public var hitStun;					// number of frames upon hit for which opponent is recovering (apply to light attacks, subtract 9 frames)
				
		// individual hits
		public function HitData( attack:Boolean, grab:Boolean, multi:Boolean, charged:Boolean, base, stray:Number, post, min:Number, spam:Number, block, hit ) {
			this.isAttack 			= attack;
			this.isGrab 			= grab;
			this.isMultiHit			= multi;
			this.isCharged			= charged;
			this.baseDamage			= base;
			this.strayHitScaling	= stray;
			this.postHitScaling		= post;
			this.minimumHitScaling 	= min;
			this.spamHitScaling		= spam;
			this.blockStun			= block;			
			this.hitStun			= hit;
		}

	}
	
}
