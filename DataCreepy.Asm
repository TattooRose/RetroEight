;
;***************************************************************************************************
;
;	Filename:		DataCreepy.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;***************************************************************************************************
;	Local Storage
;***************************************************************************************************
;
CPY_WIDTH			= $08
CPY_HEIGHT			= $0C

CPY_ANIMATION_DELAY	= $06

CpyTabCurrFrames	.byte $00
CpyTabTotalFrames	.byte $04

CpyTabAnimLSB		.byte <CPY_WALKDATA
CpyTabAnimMSB		.byte >CPY_WALKDATA

CpyTabColorsLSB		.byte <CPY_WALKCOLORS
CpyTabColorsMSB		.byte >CPY_WALKCOLORS

CPY_WALKCOLORS		.BYTE $DC,$DC,$DC,$DC

CPY_WALKDATA
; FRAME 1
 .BYTE $18,$3c,$28,$4a,$7e,$7e,$62,$24
 .BYTE $18,$18,$18,$24
; FRAME 2
 .BYTE $18,$3c,$28,$4a,$7e,$7e,$62,$24
 .BYTE $18,$18,$24,$42
; FRAME 3
 .BYTE $00,$18,$3c,$28,$4a,$7e,$7e,$62
 .BYTE $24,$18,$24,$42
; FRAME 4
 .BYTE $00,$18,$3c,$28,$4a,$7e,$7e,$62
 .BYTE $24,$18,$18,$24

