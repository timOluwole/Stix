=============================================================================================
#STIX PROJECT
=============================================================================================

This is a README for the Stix project

-------------------------------------------------------------------------------------------------------
DIRECTORY
-------------------------------------------------------------------------------------------------------

- PROJECT SOURCE
- WINDOWS EXECUTABLES

-------------------------------------------------------------------------------------------------------
PROJECT SOURCE
-------------------------------------------------------------------------------------------------------

Contains:
- All code used to develop Stix and the AI, developed in ActionScript3.0 (.as)
- The project .fla files
	- "Dev_StateSpace.fla"	- used to develop the AI state space graph
	- "Dev_Stix_AND_AI.fla"	- used to develop Stix and the AI

Feel free to look over any of the code in this folder

Note that you may need to open them in Notepad++ if you do not have anything capable 
of opening .as files

You may also not be able to open the .fla files either, unless you possess Adobe Flash

-------------------------------------------------------------------------------------------------------
Windows Executables
-------------------------------------------------------------------------------------------------------

Contains:
- All code used to develop Stix and the AI, developed in ActionScript3.0
- The project .fla files
	- "StateSpace_WinEXE.exe"	- the state space graph executable
	- "Stix_WinEXE.exe"		- the Stix game executable


-------------------------------------------------------------------------------------------------------
Stix Game
-------------------------------------------------------------------------------------------------------

To run the game, simply run "Stix_WinEXE.exe".

The menu is as follows

STIX MENU
	> Learning
		> Mirrored Learning 	- practice mode (AI vs AI)
		> Versus Random 	- practice mode (AI vs Random)
	> Testing 			- match mode (AI vs Random)
	? Free Use
		> Training 		- practice mode (Human vs Dummy)
		> Versus AI		- match mode (Human vs AI)

During any of the practice modes, 
- feel free to exit at any point using the Back button at the bottom right 
  of the screen
- the learning modes for the AI (Mirrored Learning/Versus Random) 
  automatically end after 1,000 agent decisions

If you wish to see how state-action-value data is added to the state space during 
AI practice sessions, make sure "StateSpace_WinEXE.exe" is also running

-------------------------------------------------------------------------------------------------------
Character Controls
-------------------------------------------------------------------------------------------------------

W - up input (on ground, jump)
A - left input (on ground, walk left. double tap to dash left. in air, move left)
S - down input (on ground, crouch)
D - right input (on ground, walk right. double tap to dash right. in air, move right)

P - punch
K - kick
O - block
I - throw

For a list of attack strings, please consult the AttackStrings.png image found in this folder.

You may be familiar with the Rock Paper Scissors system
- Strikes (punches and kicks) beat Throws
- Throws beat Blocks
- Blocks beat Strikes

-------------------------------------------------------------------------------------------------------
STAGES
-------------------------------------------------------------------------------------------------------

When you load the game, you will see the following options on the right

- Training Room (Red)
- Training Room (Green)
- Training Room (Blue)
- Training Room (Yellow)
- Neon Lights Floor Room

You may pick the stage for the next training session or match by clicking any of these options.

It will always reset to Training Room (Red) by default after conclusion.

Note that with the Neon Lights Floor Room, there are no walls. So there is no wall bounce interaction.
