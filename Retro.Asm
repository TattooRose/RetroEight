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
;***** Include Library Files
;
		icl "Lib/AtariEquates.Asm"				; Atari hardware DOS,OS,ANTIC,GITA,POKEY,PIA equates
		icl "Lib/SysMacros.Asm"					; General purpose macros used by system

;*****	Memory map
;
ZeroPageAddress				= $80				; 122 bytes zero page ($80 to $F9) 

CommDspListAddr				= $0600				; 176 bytes for display list
HudMemoryAddress			= $06B0				; Heads up display are

DataAddress					= $2000				;  4K (size for data)
SoundPlayerAddress			= $3400
SoundDataAddress			= $4000

CodeAddress					= $4400				; 23K zone for code

PmgAddress					= $A000				;  2K (2K size for PMG)
GameFontAddress				= $A800				; 42K (1K size for FNT)
TextFontAddress				= $AC00				; 39K (1K size for FNT)

GameMemoryAddress			= $B000				; 44K (4K size for Screen)

;*****	Zero Page Members
;
		org ZeroPageAddress		
		icl "ZeroPage.Asm"
		icl "Constants.Asm"

;*****	moved here for better access
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

LEVEL_CHAR_SIZE_X			= 42				; max level size now should be 256 x 255 lines	
LEVEL_CHAR_SIZE_Y			= 24

WINDOW_CHAR_SIZE_X			= 40
WINDOW_CHAR_SIZE_Y			= 24

;*****	Data Address includes
;
		org DataAddress	
		
		icl "Data/HeroData.Asm"
		icl "Data/DisplayListData.Asm"
		icl "Data/Levels.Asm"
		icl "RetroData.Asm"

;*****	Data and Code area check
;
ENDOFDATA
.if ENDOFDATA > [SoundPlayerAddress - $0400]
	.error "Data area overwritting Sound player data area!"
.endif		

;*****	Sound Data Address
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
		jsr InitAndLoadLevel					; Initialize and load the first level
					
RetroLoop
		
		jmp RetroLoop							; endless loop
		
;
;**************************************************************************************************
; InitVars
;**************************************************************************************************
;
.proc InitVars
	
		lda #1									; input info
		sta m_currentTrigger0
		sta m_oldTrigger0

		lda #0
		sta m_triggerState

		lda #15
		sta m_stick0
		sta m_oldStick0
		
		lda #>[CHAR_PIXELS_X]					; level info
		sta m_levelWindowX_H2
		
		lda #<[CHAR_PIXELS_X]
		sta m_levelWindowX_H1
		
		lda #0
		sta m_levelWindowY_H2
		
		lda #0
		sta m_levelWindowY_H1

		lda #LEVEL_CHAR_SIZE_X
		sta m_levelCharSizeX
		
		lda #LEVEL_CHAR_SIZE_Y
		sta m_levelCharSizeY

		lda #>[LEVEL_CHAR_SIZE_X*CHAR_PIXELS_X]
		sta m_levelSizeX_H2
		
		lda #<[LEVEL_CHAR_SIZE_X*CHAR_PIXELS_X]
		sta m_levelSizeX_H1

		lda #>[LEVEL_CHAR_SIZE_Y*CHAR_PIXELS_Y]
		sta m_levelSizeY_H2
		
		lda #<[LEVEL_CHAR_SIZE_Y*CHAR_PIXELS_Y]
		sta m_levelSizeY_H1

		rts
	
.endp			
		
;
;**************************************************************************************************
;	InitAndLoadLevel
;**************************************************************************************************
;
.proc InitAndLoadLevel

		lda #<HudMemoryAddress					; set the text display address
		sta m_hudMemoryAddress					; store the LSB
		lda #>HudMemoryAddress					; set the text display address
		sta m_hudMemoryAddress+1				; store the MSB

		SetDisplayListInterrupt GameDli_01		; set the display list interrupts
		VcountWait 120
				
		lda #GameDLEnd							; length of games display list data
		sta m_param00 							; store it for the load routine		
							
		SetVector m_paramW01, GameDL			; source of display list data
		SetVector m_paramW02, CommDspListAddr	; destination of display list data
		
		jsr LoadDisplayListData					; perform the DL data move

		SetDisplayListAddress CommDspListAddr	; set the display list address	

		SetFontAddress GameFontAddress			; set the starting font address

;*****	Housekeeping
;
		jsr SfxInit
		jsr InitVars							; begin initialization

;*****	Set the addresses
;
SetAddresses

		SetPMBaseAddress PmgAddress				; set the player missile address

		VcountWait 120							; make sure to wait so the setting takes effect
				
		lda #<GameMemoryAddress
		sta m_currentLineAddress		
		lda #>GameMemoryAddress
		sta m_currentLineAddress+1

		jsr InitLevelTable						; set up the level table

;*****	Load the starting level
;	
		lda m_currLevelNum						; grab the current level number
		sta m_param00							; store it to the parameter

		jsr LoadLevel							; load the level

;*****	InitHardware
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
;
		lda #0									; clear the hit register
		sta HITCLR								; store it

		SetVerticalBlankInterrupt Game_VBI, VBI_I

		lda #[NMI_VBI + NMI_DLI]				; enable VBI's and DLI's	
		sta NMIEN								; store it
	    sta IRQEN
	    
		cli

		rts

.endp
	
		
;*****	Game Vertical Blank Routine
;		
Game_VBI
		jsr SfxUpdate							; update music and sound effects
		jsr UpdateInfoLine						; update the games HUD information
		jmp XITVBL								; end vbi		
		
;*****	Code Include Files
;		
		icl "AudioManager.Asm"
		icl "RmtPlayer.Asm"
		icl "LevelLoader.Asm"
		icl "DisplayListInterrupts.Asm"
		icl "Utilities.Asm"
		icl "Lib/SysProcs.Asm"

;*****	Game Font Address
;
		org GameFontAddress
		ins "Data/scroller.fnt"

;*****	Text Font Address
;
		org TextFontAddress
		ins "Data/atari.fnt"
		
;*****	Game Memory Address
;
		org GameMemoryAddress
		.rept [$1000 - [LEVEL_CHAR_SIZE_Y*LEVEL_CHAR_SIZE_X]]
			.byte $00
		.endr
		:LEVEL_CHAR_SIZE_X .byte $61			; add additional line at end to insure no miscalcs on laddres, hazards, etc....

;*****	HUD Memory Address	
;
		org HudMemoryAddress							
		 
.if PAL_VERSION = 0
		.sb "  G 00    E 00    T 00:00.0  H 00 NTSC  "
.else
		.sb "  G 00    E 00    T 00:00.0  H 00  PAL  "
.endif
		.sb "                                        "

;*****	Run Address
;
		run InitSystem
					
					