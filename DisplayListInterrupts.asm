;
;***************************************************************************************************
;
;	Filename:		DisplayListInterrupts.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;	Color			Dec			HEX    	Color			Dec				HEX
;	-------------------------------		-----------------------------------
;	Black           00,			$00		Medium blue      08,    		$08
;	Rust            01,			$01		Dark blue        09,    		$09
;	Red-orange      02,			$02		Blue-grey      	 10,    		$0A
;	Dark orange     03,			$03		Olive green    	 11,    		$0B
;	Red             04,			$04		Medium green   	 12,    		$0C
;	Dk lavender     05,			$05		Dark green     	 13,    		$0D
;	Cobalt blue     06,			$06		Orange-green   	 14,    		$0E
;	Ultramarine     07,			$07		Orange         	 15,    		$0F
;
;**************************************************************************************************
; Display list 1 interruptions code
;**************************************************************************************************
;
GameDli_01
		
		pha
		tya
		pha
		
.if PAL_VERSION = 0

		SetColor $00, $03, $04
		SetColor $01, $00, $0F
		SetColor $02, $08, $08
		SetColor $03, $0F, $0C		
		
.else

		SetColor 1, 15, 14		; yellow (collectables)
		SetColor 2, 7, 2		; blue (water)

.endif
		
		SetFontAddress GameFontAddress
		
		;lda VCOUNT
		;sta m_villianDliIndex


;		sta m_hldA
;		stx m_hldX

		VillianDli $00, $06
    	sta WSYNC   			; Wait off-screen
				
;		ldx m_hldX
;		lda m_hldA

		
		SetDisplayListInterrupt GameDli_02 

		pla
		tay
		pla
		
		rti
		
;
;**************************************************************************************************
; 	Game DLI 2 
;**************************************************************************************************
;
GameDli_02

		pha
		tya
		pha

;.if PAL_VERSION = 0
;
;		SetColor $00, $03, $04
;		SetColor $01, $0E, $0F
;		SetColor $02, $0E, $08
;		SetColor $03, $0F, $0C		
;		
;.else
;
;		SetColor 1, 15, 14		; yellow (collectables)
;		SetColor 2, 7, 2		; blue (water)
;
;.endif
;
;		sta m_hldA
;		stx m_hldX
		
		VillianDli $06, $0C
		
;		ldx m_hldX
;		lda m_hldA
				
;		lda VCOUNT
;		ldy #76
;		jsr DisplayDebugInfoHexFF

		
    	sta WSYNC   			; Wait off-screen
		
		SetDisplayListInterrupt GameDli_03 

		pla
		tay
		pla
		
		rti

;
;**************************************************************************************************
; 	Game DLI 3 
;**************************************************************************************************
;
GameDli_03

		pha
		tya
		pha

.if PAL_VERSION = 0

		SetColor $00, $03, $04
		SetColor $01, $0E, $0F
		SetColor $02, $0A, $08
		SetColor $03, $0F, $0C		
		
.else

		SetColor 1, 15, 14		; yellow (collectables)
		SetColor 2, 7, 2		; blue (water)

.endif

		;lda VCOUNT
		;sta m_villianDliIndex


		VillianDli $0C, $12
		
    	sta WSYNC   			; Wait off-screen
		SetDisplayListInterrupt GameDli_04 

		pla
		tay
		pla
		
		rti
		

;
;**************************************************************************************************
; 	Game DLI 4 
;**************************************************************************************************
;
GameDli_04

		pha
		tya
		pha

.if PAL_VERSION = 0

		SetColor $00, $04, $0F
		SetColor $01, $01, $0F
		SetColor $02, $08, $0F
		SetColor $03, $0B, $0F		
		
.else

		SetColor 1, 15, 14		; yellow (collectables)
		SetColor 2, 7, 2		; blue (water)

.endif


		;lda VCOUNT
		;sta m_villianDliIndex

		VillianDli $12, $18
    	sta WSYNC   			; Wait off-screen
		
		SetDisplayListInterrupt TextDli 

		pla
		tay
		pla
		
		rti
		

;
;**************************************************************************************************
; 	Text Display list 2 interrupt code
;**************************************************************************************************
;
TextDli

		pha
		tya
		pha
			
.if PAL_VERSION = 0

		SetColor 1, $03, $0A
		SetColor 2, $04, $01			
.else

		SetColor 1, 15, 14		; yellow (collectables)
		SetColor 2, 7, 2		; blue (water)

.endif
;		lda VCOUNT
;		ldy #76
;		jsr DisplayDebugInfoHexFF

		SetFontAddress TextFontAddress
		STA WSYNC 				;Wait off-screen

		SetDisplayListInterrupt GameDli_01 

		pla
		tay
		pla
		
		rti
