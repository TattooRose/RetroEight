;
;***************************************************************************************************
;
;	Filename:		DataDisplayList.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;

;
; Game Display List
;
GameDL 
		.byte DL_BLANK_8
		.byte DL_BLANK_8
		.byte DL_BLANK_8 + DL_DLI

GameDL_LMS1
		
		?dldata = GameMemoryAddress
		.rept 5
			.byte DL_TEXT_4 + DL_LMS 
			.byte <?dldata, >?dldata
			?dldata += LEVEL_CHAR_SIZE_X
		.endr
		
		.byte DL_TEXT_4 + DL_LMS + DL_DLI 
		.byte <?dldata, >?dldata
		?dldata += LEVEL_CHAR_SIZE_X

		.rept 5
			.byte DL_TEXT_4 + DL_LMS 
			.byte <?dldata, >?dldata
			?dldata += LEVEL_CHAR_SIZE_X
		.endr
		
		.byte DL_TEXT_4 + DL_LMS + DL_DLI 
		.byte <?dldata, >?dldata
		?dldata += LEVEL_CHAR_SIZE_X

		.rept 5
			.byte DL_TEXT_4 + DL_LMS 
			.byte <?dldata, >?dldata
			?dldata += LEVEL_CHAR_SIZE_X
		.endr
		
		.byte DL_TEXT_4 + DL_LMS + DL_DLI 
		.byte <?dldata, >?dldata
		?dldata += LEVEL_CHAR_SIZE_X

		.rept 5
			.byte DL_TEXT_4 + DL_LMS 
			.byte <?dldata, >?dldata
			?dldata += LEVEL_CHAR_SIZE_X
		.endr
		
		.byte DL_TEXT_4 + DL_LMS 
		.byte <?dldata, >?dldata
		?dldata += LEVEL_CHAR_SIZE_X
			
		.byte DL_BLANK_1 + DL_DLI

		?dldata = TextMemoryAddress
		.rept 2
			.byte DL_TEXT_2 + DL_LMS
			.byte <?dldata, >?dldata
			?dldata += WINDOW_CHAR_SIZE_X
		.endr	
	
		.byte DL_JUMP_VB, <CommDspListAddr, >CommDspListAddr

GameDLEnd = * - GameDL
