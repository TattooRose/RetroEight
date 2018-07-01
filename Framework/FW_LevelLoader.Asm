;
;***************************************************************************************************
;
;	Filename:		LevelLoader.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
;**************************************************************************************************
; Constants
;**************************************************************************************************
;
LN_BRK				= $FD
LN_CRG				= $FE
LN_EOD				= $FF

;
;**************************************************************************************************
; InitLevelTable
;**************************************************************************************************
;
.proc InitLevelTable
		
		;ClearLevelLineMemory
		
		ldy #0

;************************************************
;
ILTL_loop

		lda m_currentLineAddress
		sta TabLevelLineAddressLSB,y
		
		lda m_currentLineAddress+1
		sta TabLevelLineAddressMSB,y

		lda m_levelCharSizeX
		bne ILTL_below_256

		inc m_currentLineAddress+1				; if m_levelCharSizeX = 0, then add 256 chars
		jmp ILTL_check_loop

;************************************************
;
ILTL_below_256

		clc
		adc m_currentLineAddress				; from 1 to 255 chars
		sta m_currentLineAddress

		lda m_currentLineAddress+1
		adc #0
		sta m_currentLineAddress+1

;************************************************
;
ILTL_check_loop

		iny
		cpy m_levelCharSizeY					; from 1 to 255 lines, 0 = 256 lines in this case
		bne ILTL_loop
	
		lda m_currentLineAddress				; add one more line definition to fix problem of ladders in the last line, but this is not going to work if there are 256 lines!
		sta TabLevelLineAddressLSB,y
	
		lda m_currentLineAddress+1
		sta TabLevelLineAddressMSB,y
	
		rts
		
.endp		

;
;**************************************************************************************************
; 	LoadDisplayListData
;
;		Routine to load the desired display list data to Atari's LISTL and LISTH location.
;
;		Parameters:		m_param00	-	Length of data
;						m_paramW01	-	Source of data
;						m_paramW02	-	Destination of data
;
;		Destroy's A, X, and Y registers 
;
;**************************************************************************************************
.proc LoadDisplayListData

		ldx m_param00
		ldy #$00

;*****	Loop until data length is reached	
loop
		lda (m_paramW01), y
		sta (m_paramW02), y
		iny
		dex
		bne loop
		
		rts

.endp

;
;**************************************************************************************************
; LoadLevel
;
;	Level index is passed in zero page PARAM00
;
;**************************************************************************************************
.proc LoadLevel

		;jsr ClearLevelLineMemory				; clear all memory in the level lines

		ldx m_param00							; get the current level to work on		
				
		lda LevelsAddr_LSB,x					; get the LSB for the requested levels data
		sta m_paramW01							; store it in our zero page pointer
		lda LevelsAddr_MSB,x					; get the MSB for the requested levels data
		sta m_paramW01 + 1						; store it in our zero page pointer
		
		lda #$00								; initialize the counters
		sta m_scrYCount							; store it
		sta m_datYCount							; store it
		
		tay										; begin with the Y register set

;************************************************
;
GetNextRowCol		
		
		ldy m_datYCount		
		lda (m_paramW01), y						; make sure this level is valid (while not EOD)
		cmp #LN_EOD								; check for eof of level data
		beq ExitLoadLevel						; true jump to exit

StoreRow
		
		sta	m_currRow							; save off the first byte the current row

		inc m_datYCount							; increment for COLS value
		ldy m_datYCount							; use it
		lda (m_paramW01),y						; make sure this level is valid
		sta m_currCol							; now we have the current column
		
		ldx m_currCol
		lda TabLevelLineAddressLSB,x			; get the low part of the screen address by row
		clc										; clear the carry flag
		adc m_currRow							; add the current row value
		sta m_ptrLevelLine						; save it off to the current line address		
		lda TabLevelLineAddressMSB,x			; get the low part of the screen address by row
		adc #$00								; add with carry
		sta m_ptrLevelLine + 1					; save it off to the current line address

;************************************************
;
SetCharacter
  		
  		inc m_datYCount							; increment for next COLS value
		ldy m_datYCount							; use the value

		lda (m_paramW01),y						; check for line break
		cmp #LN_BRK								; did we hit it 
		beq GetNextDataLine						; go reset the counters and test for carriage return  

		ldy m_scrYCount
		sta (m_ptrLevelLine),y					; store it at location
		inc m_scrYCount							; increment the screen Y counter
		
		jmp SetCharacter						; do the process all over
		
;************************************************
;
GetNextDataLine
		
		lda #$00								; reset the screen Y count
		sta m_scrYCount							; store it
		
  		inc m_datYCount							; increment for next COLS value
		ldy m_datYCount							; use the value
		lda (m_paramW01), y						; load up the next level data item
		
		cmp #LN_CRG								; check for carraige return
		beq SetNextRowCol						; true get the next row of data
		
		jmp StoreRow		

SetNextRowCol
		inc m_datYCount		
		
		clc
		lda m_paramW01							; get the LSB for the requested levels data
		adc m_datYCount							; add in the data Y count
		sta m_paramW01							; store it in our zero page pointer
		lda m_paramW01 + 1						; get the MSB for the requested levels data
		adc #$00								; add with carry
		sta m_paramW01 + 1						; store it in our zero page pointer

		lda #$00								; reset the data Y counter
		sta m_datYCount							; store it

		jmp GetNextRowCol			
 
;************************************************
;
ExitLoadLevel

		rts
	
.endp	

;
;**************************************************************************************************
; 	ClearLevelLineMemory
;**************************************************************************************************
;
.proc ClearLevelLineMemory
		
		ldx #$00

Loop

		lda TabLevelLineAddressLSB,x
		sta m_gameScrnAddress
		
		lda TabLevelLineAddressMSB,x
		sta m_gameScrnAddress+1

		ldy #$00
		lda #$00

ClearMem

		sta (m_gameScrnAddress), y
		iny					
		cpy m_levelCharSizeX
		bne ClearMem

CheckLoop

		inx
		cpx m_levelCharSizeY
		bne Loop
	
		rts

.endp
		