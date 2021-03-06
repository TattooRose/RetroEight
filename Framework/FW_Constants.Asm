;
;**************************************************************************************************
;
;	Filename:		FW_Contants.Asm
;
;	Created On:		June 25, 2018 08:00:00
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;	
;***************************************************************************************************
;
KEY							= $2fc				;keypressed code

MUSIC_MENU 					= 0
MUSIC_GAME 					= $0B
MUSIC_GAME_OVER 			= $0E
MUSIC_DUMMY 				= $10

SFX_DIAMOND 				= 1
SFX_FIRE					= 4
SFX_ALL_PICKED 				= 12
SFX_DEATH 					= 3
SFX_CONGRATULATIONS 		= 15
SFX_JUMP 					= 2

PSD_NONE					= 0					; player side direction
PSD_RIGHT					= 1
PSD_LEFT					= 2
PSD_UP						= 3
PSD_DOWN					= 4

PS_STATIC					= 0					; player states
PS_OVER_PLATFORM			= 1
PS_JUMPING					= 2
PS_FALLING					= 3
PS_CLIMBING					= 4
PS_IN_WATER					= 5
PS_GRAVITY_TEST				= 6
PS_LOSE						= 7

CT_BLANK					= 0					; character types
CT_BLOCK					= 1
CT_COLLECTABLE				= 2
CT_DANGER					= 3
CT_LADDER					= 4
CT_WATER					= 5
CT_HEALTH					= 6
CT_FLOATPLATFORMH			= 7
CT_VLASER					= 8
CT_FLOATPLATFORMV			= 9
CT_HLASER					= 10

TS_NOT_PRESSED				= 0					; trigger states
TS_JUST_RELEASED			= 0
TS_PRESSED					= 0
TS_JUST_PRESSED				= 0

ENEMY_SHOOT_DELTA_Y			= 32

;*****	Set these constants depending on TV system
; 
.if PAL_VERSION = 0

	TENTH_OF_SECOND_FRAMES	= 6
	MINIMUM_CAMERA_STEP		= 1
	JUMP_HOLD_FRAMES		= 8
	JUMP_HSPEED_SLOWDOWN	= 64
	WATER_NO_JUMP_FRAMES	= 30

	SIDE_SPEED_LAND_H1		= 1					; 001.160 --> 97.5 pixels per second (at 60 fps only!)
	SIDE_SPEED_LAND_L1		= 1 ;64
	
	SIDE_ACCEL_LAND_H1		= 1					; 6 frames (at 60 fps only!) or 0.x seconds, to reach max speed
	SIDE_ACCEL_LAND_L1		= 128
	
	SIDE_DEACCEL_LAND_H1	= 1					; 3 frames (at 60 fps only!) or 0.x seconds, to reach zero speed
	SIDE_DEACCEL_LAND_L1	= 128
	
	SIDE_SPEED_WATER_H1		= 0
	SIDE_SPEED_WATER_L1		= 128

	SIDE_ACCEL_WATER_H1		= 0					; _ frames (at 60 fps only!) or _ seconds, to reach max speed
	SIDE_ACCEL_WATER_L1		= 4

	SIDE_DEACCEL_WATER_H1	= 0					; _ frames (at 60 fps only!) or _ seconds, to reach zero speed
	SIDE_DEACCEL_WATER_L1	= 4

	SIDE_SPEED_AIR_H1		= 1					; 001.120 --> 88.125 pixels per second (at 60 fps only!)
	SIDE_SPEED_AIR_L1		= 32

	SIDE_ACCEL_AIR_H1		= 0					; 17.3 frames (at 60 fps only!) or 0.288 seconds, to reach max speed
	SIDE_ACCEL_AIR_L1		= 16

	SIDE_DEACCEL_AIR_H1		= 0					; 17.3 frames (at 60 fps only!) or 0.288 seconds, to reach zero speed
	SIDE_DEACCEL_AIR_L1		= 16

	CLIMB_UP_SPEED_Y_H1		= 0
	CLIMB_UP_SPEED_Y_L1		= 224

	CLIMB_DOWN_SPEED_Y_H1	= 0
	CLIMB_DOWN_SPEED_Y_L1	= 224

	PLAYER_MISSILE_SPEED_X	= 2*256+128
	ENEMY_MISSILE_SPEED_X	= 2*256
	ENEMY_INIT_TIMER		= 120
	VLASER_DISABLED_INDEX	= 60

.else

	TENTH_OF_SECOND_FRAMES	= 5
	MINIMUM_CAMERA_STEP		= 1
	JUMP_HOLD_FRAMES		= 6					; 6.67 for pal
	JUMP_HSPEED_SLOWDOWN	= 77
	WATER_NO_JUMP_FRAMES	= 25

	SIDE_SPEED_LAND_H1		= 1					;  pixels per second (at 50 fps only!)
	SIDE_SPEED_LAND_L1		= 128

	SIDE_ACCEL_LAND_H1		= 0					;  frames (at 50 fps only!) or 0.x seconds, to reach max speed
	SIDE_ACCEL_LAND_L1		= 38

	SIDE_DEACCEL_LAND_H1	= 0					;  frames (at 50 fps only!) or 0.x seconds, to reach zero speed
	SIDE_DEACCEL_LAND_L1	= 154

	SIDE_SPEED_WATER_H1		= 0
	SIDE_SPEED_WATER_L1		= 154

	SIDE_ACCEL_WATER_H1		= 0					; _ frames (at 50 fps only!) or _ seconds, to reach max speed
	SIDE_ACCEL_WATER_L1		= 5

	SIDE_DEACCEL_WATER_H1	= 0					; _ frames (at 50 fps only!) or _ seconds, to reach zero speed
	SIDE_DEACCEL_WATER_L1	= 5

	SIDE_SPEED_AIR_H1		= 1					;  pixels per second (at 50 fps only!)
	SIDE_SPEED_AIR_L1		= 90
	
	SIDE_ACCEL_AIR_H1		= 0					;  frames (at 50 fps only!) or  seconds, to reach max speed
	SIDE_ACCEL_AIR_L1		= 19

	SIDE_DEACCEL_AIR_H1		= 0					;  frames (at 50 fps only!) or  seconds, to reach zero speed
	SIDE_DEACCEL_AIR_L1		= 19

	CLIMB_UP_SPEED_Y_H1		= 1
	CLIMB_UP_SPEED_Y_L1		= 13

	CLIMB_DOWN_SPEED_Y_H1	= 1
	CLIMB_DOWN_SPEED_Y_L1	= 13

	PLAYER_MISSILE_SPEED_X	= 3*256
	ENEMY_MISSILE_SPEED_X	= 2*256+104
	ENEMY_INIT_TIMER		= 100
	VLASER_DISABLED_INDEX	= 50

.endif

;*****	Player missle address definitions
;
ms_area_1 					= PmgAddress + $0300
p0_area_1 					= PmgAddress + $0400
p1_area_1 					= PmgAddress + $0500
p2_area_1 					= PmgAddress + $0600
p3_area_1 					= PmgAddress + $0700

