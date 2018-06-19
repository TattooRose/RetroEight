;
;***************************************************************************************************
;
;	Filename:		Retro.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
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
		icl "Framework/AtariEquates.Asm"				; Atari hardware DOS,OS,ANTIC,GITA,POKEY,PIA equates
		icl "Framework/SysMacros.Asm"					; General purpose macros used by system

;
;**************************************************************************************************
; 	Memory map
;**************************************************************************************************
;
ZeroPageAddress				= $80				; 122 bytes zero page ($80 to $F9) 

CommDspListAddr				= $0600				; 175 bytes for display list
TextMemoryAddress			= $06B0				; Heads up display are

DataAddress					= $2000				;  4K (size for data)
SoundPlayerAddress			= $3400
SoundDataAddress			= $4000

CodeAddress					= $4400				; 23K zone for code

PmgAddress					= $A000				;  2K (2K size for PMG)
GameFontAddress				= $A800				; 42K (1K size for FNT)
TextFontAddress				= $AC00				; 39K (1K size for FNT)

GameMemoryAddress			= $B000				; 44K (4K size for Screen)

;
;**************************************************************************************************
; 	Zero Page Members
;**************************************************************************************************
;
		org ZeroPageAddress		
		
		icl "Framework/ZeroPage.Asm"
		icl "Framework/EngineConstants.Asm"

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

;
;**************************************************************************************************
; 	Data Address
;**************************************************************************************************
;
		org DataAddress	
		
		icl "Framework/EngineData.Asm"
		icl "Data/Levels.Asm"

		icl "DataPlayer.Asm"
		icl "DataCreepy.Asm"
		icl "DisplayListData.Asm"

;*****	Data and Code area check
;
ENDOFDATA
.if ENDOFDATA > [SoundPlayerAddress - $0400]
	.error "Data area overwritting Sound player data area!"
.endif		

;
;**************************************************************************************************
; 	Sound Data Address
;**************************************************************************************************
;
		org SoundDataAddress
		opt h-									; RMT module is standard Atari binary file already
		ins "Data/sfx.rmt"						; include music RMT module
		opt h+

ENDOFSOUNDDATA
.if ENDOFSOUNDDATA > CodeAddress
	.error "Sound Data area overwritting Code area!"
.endif				

;
;**************************************************************************************************
; InitSystem - Start of code
;**************************************************************************************************
;
		org CodeAddress

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
		DisableBasic							; disable to use memory

		SetRamTop #32							; Set Ramtop
		
		jsr InitVars							; Initialize the variables
		jsr DoLoadLevel							; Initialize and load the first level

		jsr InitMissileSystem
					
RetroLoop
		
		jsr PlayLevel							; play this level
		jmp RetroLoop							; endless loop

;
;**************************************************************************************************
; 	PlayLevel
;**************************************************************************************************
;
.proc PlayLevel

PlayLoop		

		jsr CheckInput
		jsr UpdateTimers
		jmp (m_playerMethodPointer)
	
PlayerMethodReturn

		jsr SetPlayerScreenPos
		jsr DrawPlayer

		VcountWait 120
		jmp PlayLoop
		
Exit		
	
		rts

.endp
		
;
;**************************************************************************************************
;	DoLoadLevel
;**************************************************************************************************
;
.proc DoLoadLevel

		lda #<TextMemoryAddress					; set the text display address
		sta m_hudMemoryAddress					; store the LSB
		lda #>TextMemoryAddress					; set the text display address
		sta m_hudMemoryAddress+1				; store the MSB

		SetVerticalBlank Game_VBI, VBI_I		; set the vertical blank interrupt
		SetDisplayListInterrupt GameDli_01		; set the display list interrupts

		VcountWait 120
				
		lda #GameDLEnd							; length of games display list data
		sta m_param00 							; store it for the load routine		
							
		SetVector m_paramW01, GameDL			; source of display list data
		SetVector m_paramW02, CommDspListAddr	; destination of display list data
		
		jsr LoadDisplayListData					; perform the DL data move

;*****	Housekeeping
;
		jsr SfxInit
		jsr InitVars							; begin initialization
		jsr InitPlayer							; do player initialization		
		
;*****	Set the addresses
;
SetAddresses

		SetDisplayListAddress CommDspListAddr	; set the display list address	
		SetFontAddress GameFontAddress			; set the starting font address
		SetPMBaseAddress PmgAddress				; set the player missile address

		VcountWait 120							; make sure to wait so the setting takes effect
				
;*****	Load the level tables and the current level
;	

		lda #<GameMemoryAddress					; set the game memory address
		sta m_currentLineAddress				; to the zero page area
		lda #>GameMemoryAddress					; in order to load the LSB/MSB
		sta m_currentLineAddress+1				; of the display addresses

		jsr InitDraw							; set up the drawing members
		jsr InitLevelTable						; set up the level table

		lda m_currLevelNum						; grab the current level number
		sta m_param00							; store it to the parameter

		jsr LoadLevel							; load the level

		lda m_currLevelNum						; grab the current level number
		sta m_param00							; store it to the parameter
		jsr SetSpawnPos

;*****	Initialize the Hardware
;
InitHardware

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

		lda #DMACTL_OPTIONS						; apply DMACTL options
		sta DMACTL								; store it

		lda #0									; clear the hit register
		sta HITCLR								; store it

		lda #[NMI_VBI + NMI_DLI]				; enable VBI's and DLI's	
		sta NMIEN								; store it
	    sta IRQEN
	    
		cli										; enable interrupts

		rts

.endp
	
;
;**************************************************************************************************
;	DebugInfo
;**************************************************************************************************
;
.proc DebugInfo

.if DEBUG_ON = 1

		lda m_playerState		
		ldy #40
		jsr DisplayDebugInfoHexFF

		lda m_lastPlayerSideDirection		
		ldy #43
		jsr DisplayDebugInfoHexFF
					
		lda _plrAnimationTableIndex
		ldy #46
		jsr DisplayDebugInfoHexFF
		
		lda _plrAnimationTableFrame
		ldy #49
		jsr DisplayDebugInfoHexFF
		
		lda _plrAnimationOffset
		ldy #52
		jsr DisplayDebugInfoHexFF
		
		lda _plrAnimationFrame
		ldy #55
		jsr DisplayDebugInfoHexFF
		
.endif
		
		rts
.endp
		
;
;**************************************************************************************************
;	Game_VBI
;
;		Games Vertical Blank Routine
;
;**************************************************************************************************
;
Game_VBI
		
		jsr SfxUpdate							; update music and sound effects
		jsr UpdateInfoLine						; update the games HUD information
		jsr DebugInfo
		jmp XITVBL								; end vbi		
		
;
;**************************************************************************************************
;	Code Include Files
;**************************************************************************************************
;
		icl "DisplayListInterrupts.Asm"
		icl "DrawPlayer.Asm"
		
		icl "Framework/Initialize.Asm"
		icl "Framework/AudioManager.Asm"
		icl "Framework/AnimationsLogic.Asm"
		icl "Framework/EnemyManager.Asm"
		icl "Framework/FloatPlatform.Asm"
		icl "Framework/JoyKeyAndCollision.Asm"
		icl "Framework/LevelLoader.Asm"
		icl "Framework/MissileSystem.Asm"
		icl "Framework/PlayerMovement.Asm"
		icl "Framework/PlayerStates.Asm"	
		icl "Framework/RmtPlayer.Asm"
		icl "Framework/Utilities.Asm"
		icl "Framework/SysProcs.Asm"

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
					
					