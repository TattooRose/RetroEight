;
;***************************************************************************************************
;
;	Filename:		FW_Initialize.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
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
; InitObjectCounters
;**************************************************************************************************
;
.proc InitObjectCounters

		ldx #0									; line index

;****	1st Loop
; 
IGC_loop1
	
		ldy #0									; column index
	
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

;*****	2nd Loop
;
IGC_loop2

		lda (m_ptrLevelLine),y
		sta m_currChar	
		stx m_pageZeroTempValue
		tax
		lda TabCharDefinition,x
		ldx m_pageZeroTempValue
	
		and #15
		cmp #CT_COLLECTABLE
		bne WaterCheck
	
		inc m_goldCounter
		jmp IGC_no_gold
		
;*****	Water Check
;		
WaterCheck

		cmp #CT_WATER
		bne HealthCheck
		
		inc m_waterAvailable
		jmp IGC_no_gold
		
;*****	Health Check
;		
HealthCheck

		cmp #CT_HEALTH
		bne VertLaserCheck
		
		inc m_healthCounter
		jmp IGC_no_gold		
		
;*****	Vertical Check
;		
VertLaserCheck

		cmp #CT_VLASER
		bne HoriLaserCheck
		
		inc m_verticalLaserOn
		jmp IGC_no_gold

;*****	Horizontal Check
;		
HoriLaserCheck

		cmp #CT_HLASER
		bne IGC_no_gold

		inc m_horizontalLaserOn
			
;*****	No Gold
;	
IGC_no_gold

		iny
		cpy m_levelCharSizeX
		bne IGC_loop2

;*****	Check Loop Y
;
IGC_check_loop_Y

		inx
		cpx m_levelCharSizeY
		bne IGC_loop1
			
		rts

.endp	


