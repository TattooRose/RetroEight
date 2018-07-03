;
;**************************************************************************************************
;
;	Filename:		Retro8Bit.Asm
;
;	Created On:		June 25, 2018 08:00:00
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;	
;***************************************************************************************************
;
;	1 page 				= 256 bytes
;	1 K	   				= 004 pages - 1024 bytes	 
;	2 K	   				= 008 pages - 2048 bytes	 
;	3 K	   				= 012 pages - 3072 bytes	 
;	4 K	   				= 016 pages - 4096 bytes	 
;
;***** Memory Map - Atari XL/XE 64K
;
;	$0000-$007F			zeropage for OS
;	$0080-$00FF 		zeropage for you
;	$0100-$01FF 		CPU stack
;	$0200-$02FF 		OS vector, registers
;	$0300-$03FF 		OS vector, registers
;	$0400-$05FF 		OS buffers
;	$0600-$06FF 		Page 6, object code in BASIC
;	$0700-$1FFF 		Disk Operating System
;	$2000-$7FFF 		User Code Area 
;	$8000-$BFFF 		Cartrige A and B slots
;	$C000-$CBFF 		OS part 1
;	$CC00-$CFFF 		OS character set, international
;	$D000-$D7FF			Hardware registers
;	$D800-$DFFF			FP Routines
;	$E000-$E3FF 		OS character set, standard
;	$E000-$FFFF 		OS part 2
;
;**************************************************************************************************
; 	Include Library Files
;**************************************************************************************************
;
		icl "Framework/FW_SysEquates.Asm"
		icl "Framework/FW_SysMacros.Asm"

;
;**************************************************************************************************
; 	ORG Memory map
;**************************************************************************************************
;
ZeroPageAddress				= $80				; 122 bytes zero page ($80 to $F9) 

CommDspListAddr				= $0600				; 175 bytes for display list
TextMemoryAddress			= $06B0				; Heads up display are

SoundPlayerAddress			= $3400				; RMT player address
SoundDataAddress			= $4000				; RMT music and sound area

CodeAddress					= $4400				; 23K zone for code
DataAddress					= $9000				;  4K (size for data)

PmgAddress					= $A000				;  2K (2K size for PMG)
GameFontAddress				= $A800				; 42K (1K size for FNT)
TextFontAddress				= $AC00				; 39K (1K size for FNT)

GameMemoryAddress			= $B000				; 44K (4K size for Screen)
		
;
;**************************************************************************************************
; 	Zero Page Members and Constants
;**************************************************************************************************
;
		org ZeroPageAddress		
		
		icl "Framework/FW_ZeroPage.Asm"
		icl "Framework/FW_Constants.Asm"
		
;
;**************************************************************************************************
; 	Common constants placed here for better access
;**************************************************************************************************
;
DEBUG_ON					= 1
STEREOMODE					= 0
PAL_VERSION					= 0			

NUM_OF_LIVES				= 5

MAX_ROWS					= 40

CHAR_PIXELS_X				= 4
CHAR_PIXELS_Y				= 8

PM_BASE_SCREEN_X			= 48
PM_BASE_SCREEN_Y			= 32

LEVEL_CHAR_SIZE_X			= 42				
LEVEL_CHAR_SIZE_Y			= 24

WINDOW_CHAR_SIZE_X			= 40
WINDOW_CHAR_SIZE_Y			= 24

GAME_MEM					= GameMemoryAddress			; used in FW_Camera.Asm. Must set this for camera to work			
GAME_LMS1					= CommDspListAddr+3			; used in FW_Camera.Asm. Must set this for camera to work

;*****	Graphics Registers bit settings
;
GRACTL_OPTIONS				= [ENABLE_MISSILES 	| ENABLE_PLAYERS				| GTIA_MODE_9_COLOR]
PRIOR_OPTIONS				= [PM_PRIORITY_1   	| FIFTH_PLAYER        			| MULTICOLOR_PM]	
DMACTL_OPTIONS				= [ENABLE_DL_DMA 	| PLAYFIELD_WIDTH_NORMAL_MASK 	| ENABLE_PM_DMA 	| PM_1LINE_RESOLUTION] 

;
;**************************************************************************************************
; 	InitSystem - Start of code
;**************************************************************************************************
;
		org CodeAddress

;*****	Start here
;
InitSystem

		lda PAL									; only run in the correct system
		and #14

.if PAL_VERSION = 1								; PAL or NTSC TV Display

No_Pal_Loop
		bne No_Pal_Loop

.else

No_Ntsc_Loop
		beq No_Ntsc_Loop

.endif
		ClearSystem								; begin machine setup
		DisableBasic							; disable basic to use memory
		
		SetRamTop #32							; Set Ramtop less 8K

		lda #$00
		sta m_currLevelNum						; grab the current level number

		jsr InitGameLevel						; init the game play levle

;*****	Retro Game Loop
;
RetroLoop
		
		jsr PlayLevel							; play the level
		jmp RetroLoop							; inifinit loop
		
;
;**************************************************************************************************
; 	InitGameLevel - Initializes the given level for game play
;**************************************************************************************************
;
.proc InitGameLevel

;*****	Start Game Play Setup
;
		lda #$00								; Turn off screen related functions	
		sta SDMCTL								; store it

;*****	Memory Settings
;
		lda #<TextMemoryAddress					; set the LSB text display address
		sta m_hudMemoryAddress					; store the LSB
		lda #>TextMemoryAddress					; set the MSB text display address
		sta m_hudMemoryAddress+1				; store the MSB

;*****	Display List Initialization
;
		lda #GameDLEnd							; length of games display list data
		sta m_param00 							; store it for the load routine		
							
		SetVector m_paramW01, GameDL			; source of display list data
		SetVector m_paramW02, CommDspListAddr	; destination of display list data
		
		jsr LoadDisplayListData					; perform the DL data move

		SetDisplayListInterrupt GameDli_01		; set the display list interrupts
		VcountWait 120

;*****	Display List, Font, PM addresses
;		
		SetDisplayListAddress CommDspListAddr	; set the display list address
		SetFontAddress GameFontAddress			; set the starting font address
		SetPMBaseAddress PmgAddress				; set the player missile address

		VcountWait 120							; make sure to wait so the setting takes effect		

;*****	Game Variables Initialization
;
		jsr SfxInit
		jsr InitVars							; Initialize the variables

;*****	Level Table Initialization
;
		lda #<GameMemoryAddress
		sta m_currentLineAddress
	
		lda #>GameMemoryAddress
		sta m_currentLineAddress+1
		
		jsr InitDraw							; set up the drawing members
		jsr InitLevelTable						; set up the level table
		
		lda m_currLevelNum						; grab the current level number
		sta m_param00							; store it to the parameter
		jsr LoadLevel							; load the level

		jsr InitPlayer
		jsr SetSpawnPos
		
		VCountWait 120
		
;*****	Initalize Level Components
;
		jsr VillianInitSystem		
		jsr VilliansInit
		
		jsr InitEnemyManager
		jsr InitMissileSystem
		
		jsr InitPlatforms
		jsr InitObjectCounters
		
		VcountWait 120
		
;*****	Initialize the Hardware
;
		lda #%01010101							; double width for all missiles
		sta SIZEM								; store it

		lda #12									; set the HSCROL value
		sta HSCROL								; store it	
	
		lda #0									; set the VSCROL value
		sta VSCROL								; store it

		lda #GRACTL_OPTIONS						; apply GRACTL options
		sta GRACTL								; store it

		lda #PRIOR_OPTIONS						; apply PRIOR options
		sta PRIOR								; store it

		lda #0									; clear the hit register
		sta HITCLR								; store it

		lda #[NMI_DLI]							; enable DLI's	
		sta NMIEN								; store it
	    sta IRQEN
	    
		cli										; enable interrupts		

		lda #DMACTL_OPTIONS						; apply DMACTL options
		sta DMACTL								; store it

		VcountWait 120

		rts

.endp		

;
;**************************************************************************************************
; 	PlayLevel
;**************************************************************************************************
;
.proc PlayLevel

;*****	Start Level
;
StartLevel

		lda #$00								; reset the game timer
		sta m_disableGameTimer					; to a zero value
		
;*****	Main target label for looping
;
Loop		
		lda m_stick0
		and #$0F
		cmp #$0F
		bne CheckState
		jmp CheckUserInput

;*****	Check th players state
;
CheckState
		
		lda m_playerState
		cmp #$02		
		beq JumpSound
*
		cmp #$03
		beq JumpSound
		
		jmp CheckUserInput
		
;*****	Set the jump sound
;
JumpSound
		
		lda #SFX_JUMP
		and #$0f
		sta m_sfxEffect
		
;*****	Check User Input
;		
CheckUserInput

		jsr CheckInput
		jsr UpdateTimers
		jmp (m_playerMethodPointer)
	
;*****	PlayerMethodReturn
;
PlayerMethodReturn

		lda m_playerState
		cmp #PS_LOSE
		beq PlayerEndStates
	
;*****	PlayerNormalStates	
;
PlayerNormalStates

		;jsr UpdateCameraWindow
		jsr SetPlayerScreenPos
		jsr DrawPlayer
			
;*****	EnemyUpdate
;
EnemyUpdate

		jsr VilliansUpdate
		jsr UpdateEnemyManager
	
;*****	MissilesStep
;
MissilesStep

		jsr UpdateMissileSystem
		jsr DrawEnemyExplosion
	
;*****	GameAnimations
;
GameAnimations
	
		jsr AnimatePlatformH		
		jsr DoFontAnimations
		jsr UpdateCoinAnimations
		jsr UpdateInfoLine
		jsr SfxUpdate
				
		VcountWait 120
		
		jsr CheckPMCollisions		
		jsr DebugInfo
		
		lda m_disableGameTimer	
		bne Exit		
		
		jmp Loop
	
;*****	PlayerEndStates
;
PlayerEndStates		

		lda SFX_DEATH
		and #$0F
		sta m_sfxEffect

		jsr AnimatePlatformH		
		jsr DrawPlayerExplosion
		jsr DoFontAnimations
		jsr UpdateCoinAnimations
		jsr UpdateMissileSystem
		jsr DrawEnemyExplosion
		jsr UpdateInfoLine
		jsr SfxUpdate
		jsr DebugInfo				

		VcountWait 120

		lda #0
		sta HITCLR	

		jmp Loop		
		
;*****	Exit Play Level - Cleanup
;
Exit
		jsr SfxInit
		rts		
.endp

;
;**************************************************************************************************
;	DebugInfo
;**************************************************************************************************
;
.proc DebugInfo

.if DEBUG_ON = 1

		lda #$28
		sta m_vars00
		ldx #$08
Loop
		lda TabHardwareCollision,x
		ldy m_vars00		
		jsr DisplayDebugInfoHexFF

		lda m_vars00
		adc #$03
		sta m_vars00

		inx
		cpx #$10
		bne Loop		
		
		lda m_playerScreenLeftX
		ldy #64
		jsr DisplayDebugInfoHexFF

		lda VilCollisionX
		ldy #67
		jsr DisplayDebugInfoHexFF
		
		lda VilCollisionY
		ldy #70
		jsr DisplayDebugInfoHexFF
		
		ldx #$00
		lda VilScreenLeftX,x
		ldy #73
		jsr DisplayDebugInfoHexFF

		lda VilScreenTopY,x
		ldy #76
		jsr DisplayDebugInfoHexFF
		
.endif
		
		rts
		
.endp
		
;
;**************************************************************************************************
;	Code Include Files
;**************************************************************************************************
;
		icl "DisplayListInterrupts.Asm"		
		icl "DrawPlayer.Asm"
		icl "DrawCreepy.Asm"

		icl "Framework/FW_Initialize.Asm"
		icl "Framework/FW_CameraLogic.Asm"
		icl "Framework/FW_AudioManager.Asm"
		icl "Framework/FW_AnimationsLogic.Asm"
		icl "Framework/FW_EnemyManager.Asm"
		icl "Framework/FW_VillianSystem.Asm"
		icl "Framework/FW_FloatPlatform.Asm"
		icl "Framework/FW_JoyKeyAndCollision.Asm"
		icl "Framework/FW_LevelLoader.Asm"
		icl "Framework/FW_MissileSystem.Asm"
		icl "Framework/FW_PlayerMovement.Asm"
		icl "Framework/FW_PlayerStates.Asm"	
		icl "Framework/FW_RmtPlayer.Asm"
		icl "Framework/FW_SysUtils.Asm"
		icl "Framework/FW_SysProcs.Asm"

;*****	End of code check
;
ENDOFCODE
.PRINT "End of Code: ", ENDOFCODE
.if ENDOFCODE > $9000
	.error "Code exceeds alloted area!"
.endif		

;
;**************************************************************************************************
; 	Data Address
;**************************************************************************************************
;
		org DataAddress	
		
		icl "Framework/FW_FrameworkData.Asm"
		icl "Framework/FW_VillianSystemData.Asm"		

		icl "Data/Levels.Asm"		

		icl "DataDisplayList.Asm"
		icl "DataSystem.Asm"
		icl "DataPlayer.Asm"
		icl "DataCreepy.Asm"

;
;**************************************************************************************************
; 	Sound Data Address
;**************************************************************************************************
;
		org SoundDataAddress
		
		opt h-									; RMT module is standard Atari binary file already
		ins "Data/sfx.rmt"						; include music RMT module
		opt h+

;
;**************************************************************************************************
;	Game Font Address
;**************************************************************************************************
;
		org GameFontAddress
		
		ins "Data/scroller.fnt"

;
;**************************************************************************************************
;	Text Font Address
;**************************************************************************************************
;
		org TextFontAddress
		
		ins "Data/atari.fnt"
		
;
;**************************************************************************************************
;	Game Memory Address
;**************************************************************************************************
;
		org GameMemoryAddress
		
		.rept [$1000 - [LEVEL_CHAR_SIZE_Y*LEVEL_CHAR_SIZE_X]]
			.byte $00
		.endr
		:LEVEL_CHAR_SIZE_X .byte $61			; add additional line at end to insure no miscalcs on laddres, hazards, etc....

;
;**************************************************************************************************
;	HUD Memory Address
;**************************************************************************************************
;
		org TextMemoryAddress							
		 
.if PAL_VERSION = 0
		.sb "  G 00    E 00    T 00:00.0  H 00 NTSC  "
.else
		.sb "  G 00    E 00    T 00:00.0  H 00  PAL  "
.endif
		.sb "                                        "

;
;**************************************************************************************************
;	Run Address
;**************************************************************************************************
;
		run InitSystem
