package Characters.Red {
	
	import Characters.AttackChains;
	import Characters.MoveData;
	import Characters.HitData;
	import flash.utils.Dictionary;
	
	public class AttackChains_Red extends Dictionary {

		public function AttackChains_Red() {
			// constructor code
		}
		
		public static function Dict():Dictionary {
			var dict:Dictionary = new Dictionary();
			
			dict["standing P"] 		= new HitData(true , false, false, false, 30 , 1.0, 0.9 , 0.1 , 0.4 , 8 , 8);
			dict["standing PP"] 	= new HitData(true , false, false, false, 50 , 1.1, 0.95, 0.1 , 0.4 , 8 , 13);
			dict["standing PPP"] 	= new HitData(true , false, false, false, 65 , 1.1, 1.0 , 0.2 , 0.5 , 6 , 10);
			dict["standing PPP-P"] 	= new HitData(true , false, false, false, 35 , 1.4, 1.1 , 0.2 , 0.55, 10, 10);
			
			dict["PPP-P"] = new MoveData(4);
			dict["PPP-P"].chain = ["P", "PP", "PPP", "PPP-P"];
			dict["PPP-P"].stances = ["standing", "standing", "standing", "standing"];
			dict["PPP-P"].isAttack =  [true, true, true, true];
			dict["PPP-P"].isGrab = [false, false, false, false];
			dict["PPP-P"].isGrabCombo = false;
			dict["PPP-P"].baseDamage = [25, 35, 50, 50];
			dict["PPP-P"].strayHitScaling = [1.0, 1.1, 1.1, 1.4];
			dict["PPP-P"].postHitScaling = [0.8, 0.8, 1.0, 1.1];
			dict["PPP-P"].spamHitScaling = [0.4, 0.4, 0.5, 0.55];
			dict["PPP-P"].blockStun = [8, 8, 6, 10];			
			
			dict["standing PfP"] 	= new HitData(true , false, false, false, 45 , 1.1 , 0.9 , 0.1 , 0.4 , 8 , 15);
			dict["standing PfPfP"] 	= new HitData(true , false, false, false, 65 , 1.25, 0.7 , 0.1 , 0.4 , 8 , 10);
			dict["PfPfP"] = new MoveData(3);
			dict["PfPfP"].chain = ["P", "PfP", "PfPfP"];
			dict["PfPfP"].stances = ["standing", "standing", "standing"];
			dict["PfPfP"].isAttack =  [true, true, true];
			dict["PfPfP"].isGrab = [false, false, false];
			dict["PfPfP"].isGrabCombo = false;
			dict["PfPfP"].baseDamage = [25, 30, 40];
			dict["PfPfP"].strayHitScaling = [1.0, 1.1, 1.1];
			dict["PfPfP"].postHitScaling = [0.8, 0.9, 0.7];
			dict["PfPfP"].minimumHitScaling = [0.2, 0.2, 0.2];
			dict["PfPfP"].spamHitScaling = [0.4, 0.45, 0.35];
			dict["PfPfP"].blockStun = [8, 10, 10];
			
			/*
			dict["PPbK"] = new MoveData();
			dict["PPbK"].chain = ["P", "PP", "PPbK"];
			dict["PPbK"].stances = ["standing", "standing", "standing"];
			dict["PPbK"].isAttack =  [true, true, true];
			dict["PPbK"].isGrab = [false, false, false];
			dict["PPbK"].isGrabCombo = false;
			dict["PPbK"].baseDamage = [25, 35, 50];
			dict["PPbK"].strayHitScaling = [1.0, 1.1, 1.25];
			dict["PPbK"].postHitScaling = [0.8, 0.8, 1.0];
			dict["PPbK"].spamHitScaling = [0.4, 0.4, 0.5];
			dict["PfPfP"].blockStun = [8, 8, 10];
			*/
			
			dict["standing PPfdK"] 		= new HitData(true , false, false, false, 25 , 1.0, 0.6, 0.1 , 0.2, 6 , 11);
			dict["standing PPfdKfuP"] 	= new HitData(true , false, false, false, 50 , 1.1, 0.9, 0.15, 0.4, 10, 13);
			dict["standing PPfdKfuPP"] 	= new HitData(true , false, true , false, [30, 30, 40] , 1.2, 1.0 , 0.35, 0.6, [6, 6, 10], 10);
			
			dict["PPfdKfuPP"] = new MoveData(5);
			dict["PPfdKfuPP"].chain = ["P", "PP", "PPfdK", "PPfdKfuP", "PPfdKfuPP"];
			dict["PPfdKfuPP"].stances = ["standing", "standing", "standing", "standing", "standing"];
			
			/*
			dict["PPbuS"] = new Object();
			dict["PPbuS"].chain = ["P", "PP", "PPbuS"];
			dict["PPbuS"].stances = ["standing", "standing", "standing"]; // NEW - DONE
			*/
			
			/*
			dict["fP"] = new MoveData();
			dict["fP"].chain = ["fP"];
			dict["fP"].stances = ["standing"]; // NEW - DONE
			*/
			
			dict["standing bPcP"] = new HitData(true, false, false, true, [60, 110, 180], 1.0, [0.6, 0.75, 0.95], 0.3, 0.4, [7, 9, 12], 10);
			
			dict["bPcP"] = new MoveData(2);
			dict["bPcP"].chain = ["bP", "bPcP"];
			dict["bPcP"].stances = ["standing", "standing"];
			
			/*
			dict["KKuK"] = new Object();
			dict["KKuK"].chain = ["K", "KK", "KKuK"];
			dict["KKuK"].stances = ["standing", "standing", "standing"];
			*/
			
			dict["standing fK"] 	= new HitData(true, false, false, false, 35 , 1.0 , 0.8 , 0.1 , 0.3, 6 , 13);
			dict["standing fKbK"]	= new HitData(true, false, false, false, 80 , 1.35, 1.25, 0.15, 0.8, 10, 10);
			
			dict["fKbK"] = new MoveData(2);
			dict["fKbK"].chain = ["fK", "fKbK"];
			dict["fKbK"].stances = ["standing", "standing"];
			
			/*
			dict["bKbK"] = new Object();
			dict["bKbK"].chain = ["bK", "bKbK"];
			dict["bKbK"].stances = ["standing", "standing"];
			*/
			
			dict["standing bK"] = new HitData(true, false, false, false, 65, 1.0, 0.9, 0.1, 0.3, 7, 10);
			dict["crouch bKdK"] = new HitData(true, false, false, false, 55, 1.1, 0.8, 0.1, 0.8, 7, 10);
			
			dict["bKdK"] = new MoveData(2);
			dict["bKdK"].chain = ["bK", "bKdK"];
			dict["bKdK"].stances = ["standing", "standing"];
			
			/*
			dict["dP"] = new Object();
			dict["dP"].chain = ["dP"];
			dict["dP"].stances = ["crouch"];
			*/
			
			dict["crouch dK"] = new HitData(true, false, false, false, 25, 1.0, 0.5, 0.1, 0.3, 6, 6);
			
			dict["dK"] = new MoveData(1);
			dict["dK"].chain = ["dK"];
			dict["dK"].stances = ["crouch"];
			
			dict["crouch fdK"] 		= new HitData(true, false, false, false, 25, 1.0, 0.9, 0.2, 0.4, 10, 10);
			dict["standing fdKK"] 	= new HitData(true, false, false, false, 45, 1.0, 1.0, 0.2, 0.4, 10, 10);
			dict["standing fdKKfP"]	= new HitData(true, false, false, false, 40, 1.0, 0.7, 0.2, 0.4, 10, 10);
			
			
			dict["fdKKfP"] = new MoveData(3);
			dict["fdKKfP"].chain = ["fdK", "fdKK", "fdKKfP"];
			dict["fdKKfP"].stances = ["crouch", "crouch", "standing"];
			
			/*
			dict["PP"] = new Object();
			dict["PP"].chain = ["P", "PP"];
			dict["PP"].stances = ["air", "air"]; // NEW - DONE
			*/
			
			dict["air fdP"] = new HitData(true, false, true, false, [30, 45], 1.0, 0.9, 0.2, 0.4, [6, 12], 10);
			
			dict["fdP"] = new MoveData(1);
			dict["fdP"].chain = ["fdP"];
			dict["fdP"].stances = ["air"]; // NEW - DONE
			
			/*
			dict["fK"] = new Object();
			dict["fK"].chain = ["fK"];
			dict["fK"].stances = ["air"]; // NEW - DONE
			*/
			
			/*
			dict["uK"] = new Object();
			dict["uK"].chain = ["uK"];
			dict["uK"].stances = ["air"]; // NEW - DONE
			*/
			
			dict["air fdK"] = new HitData(true, false, true, false, [10, 40], 1.0, 0.8, 0.2, 0.4, 10, 10);
			
			dict["fdK"] = new MoveData(1);
			dict["fdK"].chain = ["fdK"];
			dict["fdK"].stances = ["air"];		
			
			dict["standing T"]	= new HitData(true, true , false, false, 0 , 1.0, 1.0, 0.2, 0.3, 0, 10);
			dict["standing TP"]	= new HitData(true, false, false, false, 60, 1.0, 0.8, 0.2, 0.3, 0, 10);
			
			dict["TP"] = new MoveData(2);
			dict["TP"].chain = ["T", "TP"];
			dict["TP"].stances = ["standing", "standing"];
			dict["TP"].isAttack = [true, true];
			dict["TP"].isGrab = [true, false];
			dict["TP"].isGrabCombo = true;
			dict["TP"].baseDamage = [0, 50];
			dict["TP"].strayHitScaling = [1.0, 1.0];
			dict["TP"].postHitScaling = [1.0, 0.8];
			dict["TP"].spamHitScaling = [0.3, 0.3];
			// dict["TP"].blockStun = [7, 7];
			
			dict["standing TK"]		= new HitData(true, false, false, false, 20, 1.0, 1.0, 0.2, 0.3, 0, 10);
			dict["standing TKP"]	= new HitData(true, false, false, false, 70, 1.0, 0.8, 0.2, 0.3, 0, 10);
			
			dict["TKP"] = new MoveData(3);
			dict["TKP"].chain = ["T", "TK", "TKP"];
			dict["TKP"].stances = ["standing", "standing", "standing"];
			
			dict["standing TKK"]	= new HitData(true, false, false, false, 40, 1.0, 1.0, 0.2, 0.3, 0, 10);
			dict["standing TKKP"]	= new HitData(true, false, false, false, 80, 1.0, 0.8, 0.2, 0.3, 0, 10);
			
			dict["TKKP"] = new MoveData(4);
			dict["TKKP"].chain = ["T", "TK", "TKK", "TKKP"];
			dict["TKKP"].stances = ["standing", "standing", "standing", "standing"];
			
			/*
			dict["TbT"] = new Object();
			dict["TbT"].chain = ["T", "TbT"];
			dict["TbT"].stances = ["standing", "standing"];
			*/
			
			/*
			dict["TS"] = new Object();
			dict["TS"].chain = ["T", "TS"];
			dict["TS"].stances = ["standing", "standing"];
			
			dict["TdTuS"] = new Object();
			dict["TdTuS"].chain = ["T", "TdT", "TdTuS"];
			dict["TdTuS"].stances = ["standing", "standing", "standing"];
			*/
			
			dict["standing dT"] = new HitData(true, false, false, false, 75, 1.0, 0.8, 0.3, 0.4, 0, 10);
			
			dict["dT"] = new MoveData(1);
			dict["dT"].chain = ["dT"];
			dict["dT"].stances = ["crouch"];	
			
			/*
			dict["fdTS"] = new Object();
			dict["fdTS"].chain = ["fdT", "fdTS"];
			dict["fdTS"].stances = ["air", "air"]; // NEW
			*/
			
			/*
			dict["dS"] = new Object(); // burnbomb
			dict["dS"].chain = ["dS"];
			dict["dS"].stances = ["crouch"];
			
			dict["bdS"] = new Object(); // boost fire
			dict["bdS"].chain = ["bdS"];
			dict["bdS"].stances = ["crouch"];
			
			*/
			
			dict["standing S"] = new HitData(false, false, false, false, 0, 1.0, 0.8, 0.3, 0.4, 0, 10);
			
			dict["S"] = new Object(); // heated
			dict["S"].chain = ["S"];
			dict["S"].stances = ["standing"];
			dict["S"].focusCost = 1;
			/*
			dict["fS"] = new Object(); // firefly
			dict["fS"].chain = ["fS"];
			dict["fS"].stances = [ ["standing", "air"] ];
			dict["fS"].focusCost = 1;
			
			dict["fdS"] = new Object(); // burning rings
			dict["fdS"].chain = ["fdS"];
			dict["fdS"].stances = ["air"];
			dict["fdS"].focusCost = 1;
			
			dict["bS"] = new Object(); // heatwave
			dict["bS"].chain = ["bS"];
			dict["bS"].stances = ["standing"];
			dict["bS"].focusCost = 3;
			*/
			
			return dict;
		}

	}
	
}
