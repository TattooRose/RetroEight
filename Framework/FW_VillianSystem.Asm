;
;***************************************************************************************************
;
;	Filename:		VillianSystem.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;

;
;**************************************************************************************************
; 	VillianAddAccelToSpeedX
;**************************************************************************************************
;
.proc VillianAddAccelToSpeedX

		ldx m_villianCurrIndex
		cpx #$FF
		bne AddAccel
		jmp Exit		

AddAccel

		lda VilSpeedX_L1,x				; update frame speed with frame accel	
		clc
		adc VilSideSpeedAccelX_L1,x
		sta VilSpeedX_L1,x
		
		lda VilSpeedX_H1,x
		adc VilSideSpeedAccelX_H1,x
		sta VilSpeedX_H1,x

Exit		
		rts
		
.endp

;
;**************************************************************************************************
; 	VillianAddSpeedToPositionX
;**************************************************************************************************
;
.proc VillianAddSpeedToPositionX

		ldx m_villianCurrIndex
		cpx #$FF
		bne AddSpeedToPosition
		jmp Exit		

AddSpeedToPosition

		lda VilLevelLeftX_L1,x					; update player side position
		clc
		adc VilSpeedX_L1,x
		sta VilLevelLeftX_L1,x
		
		lda VilLevelLeftX_H1,x		
		adc VilSpeedX_H1,x
		sta VilLevelLeftX_H1,x
		
		lda VilLevelLeftX_H2,x
		adc #0
		sta VilLevelLeftX_H2,x

		lda #0									; check collisions for a player moving to the right	
		sta VilState,x

		jsr VillianCheckRightCollision

		lda m_vilCollisionX
		beq Exit

FoundCollision
		
		ldx m_villianCurrIndex

		lda #$01
		sta VilState,x
		
		lda #$00
		sta VilSpeedX_L1,x
		sta VilSpeedX_H1,x

;*****	Exit
;
Exit
		
		rts

.endp

;
;**************************************************************************************************
; 	VillianCheckBottomCollision
;**************************************************************************************************
;
.proc VillianCheckBottomCollision

		ldx m_villianCurrIndex
		cpx #$FF
		bne CheckCollision
		jmp Exit		
		
CheckCollision

		lda VilWidth,x							; get the width
		sta m_vars00							; hold it
		dec m_vars00							; minus one for calcs below

		lda VilHeight,x							; get the height
		sta m_vars01							; hold it
		dec m_vars01							; minus one for calcs below
				
		lda VilLevelBottomY_H2,x				; get bottom char line
		sta m_charBuffer_H2						; store it off		
		lda VilLevelBottomY_H1,x				; get bottom char
		lsr m_charBuffer_H2						; divide by /2
		ror										; rotate right
		lsr m_charBuffer_H2						; divide by /4
		ror										; rotate right
		lsr m_charBuffer_H2						; divide by /8 = CHAR_PIXELS_Y
		ror										; rotate right	

		tax			
		inx										; move to x for the level line
		lda TabLevelLineAddressLSB,x			; get the LSB level line
		sta m_ptrLevelLine						; store it to zero page
		lda TabLevelLineAddressMSB,x			; get the MSB level line
		sta m_ptrLevelLine+1					; store it to zero page	

		ldx m_villianCurrIndex					; reset x to the index

		lda VilLevelLeftX_H1,x					; update right coordinate
		clc
		adc m_vars00
		sta VilLevelRightX_H1,x
		lda VilLevelLeftX_H2,x
		adc #0
		sta VilLevelRightX_H2,x

		lda VilLevelLeftX_H2,x					; get left point char column
		sta m_charBuffer_H2
		lda VilLevelLeftX_H1,x
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_leftBottomChar

		ldx m_villianCurrIndex					; reset x to the index

		lda VilLevelRightX_H2,x					; get right point char column
		sta m_charBuffer_H2
		lda VilLevelRightX_H1,x
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_rightBottomChar

		; fast collision check
		lda m_leftBottomChar
		and #01
		cmp #CT_BLOCK
		bne CPBC_check_next_char

		lda m_leftBottomChar
		and #%00010000
		bne CPBC_found_collision

;************************************************
;
CPBC_check_next_char

		lda m_rightBottomChar
		and #01
		cmp #CT_BLOCK
		bne Exit

		lda m_rightBottomChar
		and #%00010000
		beq Exit

;************************************************
;
CPBC_found_collision

		ldx m_villianCurrIndex					; reset x to the index

		; need to move the player up and change to the platform state
		lda #$01
		sta VilState,x

		lda #0
		sta VilLevelBottomY_L1,x

		lda VilLevelBottomY_H1,x
		and #%11111000		; mask for CHAR_PIXELS_Y
		sec
		sbc #1
		sta VilLevelBottomY_H1,x
		lda VilLevelBottomY_H2,x
		sbc #0
		sta VilLevelBottomY_H2,x

;************************************************
;
Exit
		rts

.endp	

;
;**************************************************************************************************
; 	VillianCheckLeftCollision
;**************************************************************************************************
;
.proc VillianCheckLeftCollision

		ldx m_villianCurrIndex
		cpx #$FF
		bne CheckCollision
		jmp Exit		
		
;*****	Check Collision
;		
CheckCollision

		lda VilLevelBottomY_H1,x				; update top coordinate
		sec
		sbc #$08
		sta VilLevelTopY_H1,x
		
		lda VilLevelBottomY_H2,x
		sbc #$00
		sta VilLevelTopY_H2,x

		lda VilLevelLeftX_H2,x				; get left point char column
		sta m_charBuffer_H2
		lda VilLevelLeftX_H1,x

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		tay
		lda VilLevelTopY_H2,x				; get top char line	
		sta m_charBuffer_H2
		lda VilLevelTopY_H1,x

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda (m_ptrLevelLine),y
		tax
		lda TabCharDefinition,x
		sta m_leftTopChar

		ldx m_villianCurrIndex
		lda VilLevelBottomY_H2,x				; get bottom char line
		sta m_charBuffer_H2
		lda VilLevelBottomY_H1,x

		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda (m_ptrLevelLine),y
		tax
		
		lda TabCharDefinition,x
		sta m_leftBottomChar

		lda m_leftTopChar						; fast collision check
		and #15
		cmp #CT_BLOCK
		bne CheckNextChar

		lda m_leftTopChar
		and #%10000000
		bne FoundCollision

;*****	Check Next Char
;
CheckNextChar

		lda m_leftBottomChar
		and #01
		cmp #CT_BLOCK
		bne Exit

		lda m_leftBottomChar
		and #%10000000
		beq Exit

;*****	Found Collision
;
FoundCollision

		lda #1
		sta m_vilCollisionX

		ldx m_villianCurrIndex
		lda #$00									; need to move the player to the right
		sta VilLevelLeftX_L1,x

		lda VilLevelLeftX_H1,x
		and #%11111100							; mask for CHAR_PIXELS_X
		clc
		adc #CHAR_PIXELS_X
		sta VilLevelLeftX_H1,x
		
		lda VilLevelLeftX_H2,x
		adc #$00
		sta VilLevelLeftX_H2,x

;*****	Exit
;
Exit	

		rts

.endp	

;
;**************************************************************************************************
; 	VillianCheckRightCollision
;**************************************************************************************************
;
.proc VillianCheckRightCollision

		ldx m_villianCurrIndex
		cpx #$FF
		bne CheckCollision
		jmp Exit		

CheckCollision

		lda #$00
		sta m_oldCollisionX
		
		lda VilWidth,x
		sta m_vars00
		dec m_vars00
		
		lda VilHeight,x
		sta m_vars01
		dec m_vars01				

		lda VilLevelBottomY_H1,x				; update top coordinate
		sec
		sbc #$08
		sta VilLevelBottomY_H1,x	
		lda VilLevelBottomY_H2,x
		sbc #0
		sta VilLevelBottomY_H2,x

		lda VilLevelLeftX_H1,x					; update right coordinate
		clc
		adc m_vars00
		sta VilLevelLeftX_H1,x	
		lda VilLevelLeftX_H2,x
		adc #0
		sta VilLevelLeftX_H2,x

		lda VilLevelRightX_H2,x					; get right point char column
		sta m_charBuffer_H2
		lda VilLevelRightX_H1,x
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror
		tay

		lda VilLevelTopY_H2,x					; get top char line
		sta m_charBuffer_H2	
		lda VilLevelTopY_H1,x
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror	

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
	
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda (m_ptrLevelLine),y
		tax
	
		lda TabCharDefinition,x
		sta m_rightTopChar

		ldx m_villianCurrIndex
		
		lda VilLevelBottomY_H2,x				; get bottom char line
		sta m_charBuffer_H2
		lda VilLevelBottomY_H1,x
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror

		tax
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
	
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		lda (m_ptrLevelLine),y
		tax	
		lda TabCharDefinition,x
		sta m_rightBottomChar

		lda m_rightTopChar						; fast collision check
		and #01
		cmp #CT_BLOCK
		bne CheckNextChar

		lda m_rightTopChar
		and #%01000000
		bne FoundCollision

;*****	Check Next Character
;
CheckNextChar
		
		lda m_rightBottomChar
		and #01
		cmp #CT_BLOCK
		bne Exit

		lda m_rightBottomChar
		and #%01000000
		beq Exit

;**************************************************
;
FoundCollision
		
		ldx m_villianCurrIndex
		
		lda #1
		sta m_oldCollisionX

		lda #0									; need to move the player to the left
		sta VilLevelLeftX_L1,x
	
		lda VilLevelRightX_H1,x
		and #%11111100							; mask for CHAR_PIXELS_X
		sec
		sbc VilWidth,x
		sta VilLevelLeftX_H1,x
	
		lda VilLevelRightX_H2,x
		sbc #$00
		sta VilLevelLeftX_H2,x

;*****	Exit
;
Exit
		rts

.endp


;
;***************************************************************************************************
;	VillianClear
;
;		Enemy to clear is passed in the X register
;		Call 'VillianGetIndex' before calling this method
;
;***************************************************************************************************
;
.proc VillianClear

		cpx MAX_VILLIANS							; Check if the X index is valid
		bcs Exit								; No then get the hell out
		
		lda #$00

		sta VilDir,x						
		sta VilActive,x
		sta VilTimers,x

		sta VilDelay,x					
		sta VilState,x					
		sta VilBonus,x					

		sta VilWidth,x					
		sta VilHeight,x					

		sta VilAnimLSB,x				
		sta VilAnimMSB,x				

		sta VilColorLSB,x				
		sta VilColorMSB,x				

		sta VilTotalFrame,x				

		sta VilCurrFrame,x			

		sta VilSpeedX_H1,x		
		sta VilSpeedX_L1,x		

		sta VilSpeedY_H1,x		
		sta VilSpeedY_L1,x		

		sta VilScreenTopY,x		
		sta VilOldScreenTopY,x	

		sta VilScreenLeftX,x		
		sta VilOldScreenLeftX,x	

		sta VilLevelLeftX_H2,x	
		sta VilLevelLeftX_H1,x	
		sta VilLevelLeftX_L1,x	

		sta VilLevelRightX_H2,x	
		sta VilLevelRightX_H1,x	
		sta VilLevelRightX_L1,x	

		sta VilLevelTopY_H2,x	
		sta VilLevelTopY_H1,x	
		sta VilLevelTopY_L1,x	

		sta VilLevelBottomY_H2,x	
		sta VilLevelBottomY_H1,x	
		sta VilLevelBottomY_L1,x	

Exit

		rts	

.endp

;
;**************************************************************************************************
; 	VillianSideMovement
;**************************************************************************************************
;
.proc VillianSideMovement

		ldx m_villianCurrIndex
		cpx #$FF
		beq Exit

;******	Check Deaccel Right
;
CheckDeaccelRight
	
		lda m_oldCollisionX
		cmp #PSD_RIGHT
		bne CheckDeaccelLeft

		jsr VillianSubstractDeaccelToSpeedX
		jsr VillianAddSpeedToPositionX
		jmp Exit

;*****	Check Deaccel Left
;
CheckDeaccelLeft
		
		cmp #PSD_LEFT
		beq Deaccel
		jmp Exit

;*****	Deaccel
;
Deaccel
	
		jsr VillianSubstractDeaccelToSpeedX
		jsr VillianSubstractSpeedToPositionX
		jmp Exit

;*****	Check Right
;
CheckRight

		lda m_oldCollisionX
		cmp #PSD_LEFT
		bne MoveToRight

		lda #$00
		sta VilSpeedX_L1,x
		sta VilSpeedX_H1,x

;*****	Move To Right
;
MoveToRight

		lda #PSD_RIGHT
		sta m_oldCollisionX
		jsr VillianAddAccelToSpeedX
		jsr VillianAddSpeedToPositionX
		jmp Exit


;***** Check Left
;
CheckLeft
	
		lda m_oldCollisionX
		cmp #PSD_RIGHT
		bne MoveToLeft

		lda #$00
		sta VilSideSpeedX_H1,x
		sta VilSideSpeedX_L1,x

;*****	Move To Left
;
MoveToLeft
	
		lda #PSD_LEFT
		sta m_oldCollisionX
		jsr VillianAddAccelToSpeedX
		jsr VillianSubstractSpeedToPositionX

;*****	Exit
;
Exit
		
		rts

.endp

;
;***************************************************************************************************
;	VillianGetIndex
;
;		Gets the next available index for an enemy
;
;***************************************************************************************************
;
.proc VillianGetIndex

		ldx #$00
Loop
		lda VilActive,x
		beq Exit
		
		inx
		cpx #MAX_VILLIANS
		bne Loop
		
		ldx #$FF
		
Exit

		rts

.endp

;
;***************************************************************************************************
;	VillianGetFontChar
;
; 		use X as a parameter (the index of the current enemy)
; 		return in A the character definition value
;
;***************************************************************************************************
;
.proc VillianGetFontChar

		ldx m_villianCurrIndex
		cpx #$FF
		beq Exit

		lda VilWidth,x
		sta m_param00
		
		; get front point char column
		lda VilDir,x
		cmp #1
		bne CheckLeft

;*****	Check right character
;
CheckRight
			
		dec m_param00							; Enemy width minus one
		
		clc
		lda VilLevelLeftX_H1,x
		adc m_param00
		sta m_pixelPositionX_H1
		lda VilLevelLeftX_H2,x
		adc #$00
		sta m_pixelPositionX_H2
		
		jmp CheckMiddle
		
;*****	Check left character
;
CheckLeft

		lda VilLevelLeftX_H1,x
		sta m_pixelPositionX_H1
		
		lda VilLevelLeftX_H2,x
		sta m_pixelPositionX_H2

;*****	Check middle character
;
CheckMiddle

		clc
		lda VilLevelBottomY_H1,x
		adc #$01
		sta m_pixelPositionY_H1
		lda VilLevelBottomY_H2,x
		adc #0
		sta m_pixelPositionY_H2

		jsr VillianGetCharFromPixelPos
		
	
Exit

		rts
		
.endp

;
;**************************************************************************************************
;
;	VillianGetCharFromPixelPos
;
; 		put coord "x" in m_pixelPositionX_H2/_H1 and coord "y" in m_pixelPositionY_H2/_H1
; 		return in A the character definition value (and also use the Y register)
; 		(this assume that there no more than 256 chars in x or in y, in a room)
;
;**************************************************************************************************
;
.proc VillianGetCharFromPixelPos
		
		lda m_pixelPositionY_H2					; get char line, divide by 8 (put in Y)
		sta m_charBuffer_H2

		lda m_pixelPositionY_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4
		ror
		lsr m_charBuffer_H2						; /8 = CHAR_PIXELS_Y
		ror
		sta m_charPositionY
		tay

		lda TabLevelLineAddressLSB,y			; init pointer to char
		sta CharPointer+1
		sta m_lineAddressLSB
	
		lda TabLevelLineAddressMSB,y
		sta CharPointer+2
		sta m_lineAddressMSB

		; get char column, divide by 4 (put in Y)
		lda m_pixelPositionX_H2
		sta m_charBuffer_H2
		lda m_pixelPositionX_H1
		lsr m_charBuffer_H2						; /2
		ror
		lsr m_charBuffer_H2						; /4 = CHAR_PIXELS_X
		ror

		sta m_charPositionX
		tay

		ldx m_villianCurrIndex
		lda VilDir,x
		cmp #PSD_RIGHT
		bne CheckLeft
		iny
		jmp CharPointer
		
CheckLeft
		
		dey

CharPointer
		
		lda $FFFF,y
		sta m_charRaw

		tay
		lda TabCharDefinition,y
		sta m_charDef

		rts

.endp

;
;***************************************************************************************************
;	VillianInitSystem
;
;		Loop to number of max enemies and clear the data.
;
;***************************************************************************************************
;
.proc VillianInitSystem

		ldx #LEVEL_CHAR_SIZE_X
		stx m_numberOfValidRows
		
		ldx #$00
		
;*****	Loop till max enemies
;
ClearLoop
		jsr VillianClear		
		inx
		cpx #MAX_VILLIANS
		bne ClearLoop

;*****	Reseed the x and y values
	
		ldx #$00								; row index
		stx m_hldX
		
;*****	Look at the level table for enemies
;
Loop	
		ldx m_hldX

		ldy #$0									; column index
		sty m_hldY							
			
		lda TabLevelLineAddressLSB,x
		sta m_ptrLevelLine
		lda TabLevelLineAddressMSB,x
		sta m_ptrLevelLine+1

		ldx #$00

;*****	Character search loop
;
CharLoop		

		lda (m_ptrLevelLine),y
		beq NextX
		and VilChars,x		
		cmp VilChars,x
		bne NextX
		
		jmp InitVillian
		
NextX		
		inx
		cpx #MAX_VILLIANS_CHARS		
		bne CharLoop
		
		jmp CheckYLoop

;****	Initialize this enemy			
InitVillian

		and #$0F								; reduce it to just the number		
		tax										; get ready for the init method call
		dex										

		lda EnemyInitLSB,x						; the LSB of the method
		sta m_paramW01							; store to zero page
		lda EnemyInitMSB,x						; the LSB of the method
		sta m_paramW01+1						; store to zero page

		lda m_ptrLevelLine						; the LSB of the method
		sta m_paramW03							; store to zero page
		lda m_ptrLevelLine+1					; the MSB of the method
		sta m_paramW03+1						; store to zero page

		lda #$00								; get the blank character
		sta  (m_ptrLevelLine),y					; remove the marker from the screen

		lda m_hldY								; column index
		sta m_param00							; set the parameter
				
		lda m_hldX								; row index
		sta m_param01							; set the parameter
						
		lda #>(CheckYLoop - 1)					; LSB for the set up stack to act like a JSR
		pha										; push a simulated return LSB address
		lda #<(CheckYLoop - 1)					; MSB for the set up stack to act like a JSR 
		pha										; push a simulated return MSB address	
				
		jmp (m_paramW01)						; issue the jump

;*****	Increment and Check the column loop 
;
CheckYLoop
		ldy m_hldY
		iny										; increment Y
		sty m_hldY
					
		cpy m_numberOfValidRows					 
		beq CheckXLoop

		ldx #$00		
		jmp CharLoop		

;*****	Increment and Check the row loop
;		
CheckXLoop
		
		ldx m_hldX
		inx
		stx m_hldX
		
		cpx m_levelCharSizeY
		beq Exit
		jmp Loop	
				
Exit

		rts

.endp

;
;***************************************************************************************************
;	VillianSetSpawnPos
;
;		params:		m_villianCurrIndex	-	Index of enemy to work on
;
;		uses:		m_vars00	-	Width of enemy minus one
;					m_vars01	-	Height of enemy minus one
;
;***************************************************************************************************
;
.proc VillianSetSpawnPos

		ldx m_villianCurrIndex
		cpx #$FF
		beq Exit

		lda #0
		sta VilLevelLeftX_L1,x				; fractional part
		sta VilLevelLeftX_H1,x
		sta VilLevelLeftX_H2,x
		
		sta VilLevelRightX_L1,x				; fractional part
		sta VilLevelRightX_H1,x
		sta VilLevelRightX_H2,x
				
		sta VilLevelTopY_H1,x
		sta VilLevelTopY_L1,x				; fractional part
		sta VilLevelTopY_H2,x
		
		sta VilLevelBottomY_H1,x
		sta VilLevelBottomY_L1,x				; fractional part
		sta VilLevelBottomY_H2,x
		
		lda VilScreenLeftX,x
		sta m_vars02		
		
		lda VilScreenTopY,x
		sta m_vars03
		
		; set spawn position
		ldx m_vars02
		lda #$04
		jsr MultiplyAX
		
		ldx m_villianCurrIndex
		clc
		lda _productLo
		adc #$03
		sta VilLevelLeftX_H1,x
		
		ldx m_vars03
		lda #$08		
		jsr MultiplyAX
		
		ldx m_villianCurrIndex
		clc
		lda _productLo
		adc #$07
		sta VilLevelBottomY_H1,x

		jsr VillianSetInfo						; Set the enemy info
	
Exit

		rts
		
.endp

;
;***************************************************************************************************
;	VillianSetInfo
;
;		params:		m_villianCurrIndex	-	Index of villian to work on
;
;		uses:		m_param01			-	Width of villian minus one
;					m_param02			-	Height of villian minus one
;
;***************************************************************************************************
;
.proc VillianSetInfo

		ldx m_villianCurrIndex
		cpx #$FF
		beq Exit
		
		lda VilWidth,x
		sta m_vars00
		dec m_vars00
		
		lda VilHeight,x
		sta m_vars01
		dec m_vars01
		
		lda VilLevelLeftX_H1,x					; update right coordinate
		clc
		adc m_vars00
		sta VilLevelRightX_H1,x
		lda VilLevelLeftX_H2,x
		adc #0
		sta VilLevelRightX_H2,x

		lda VilLevelBottomY_H1,x				; update top coordinate
		sec
		sbc m_vars01
		sta VilLevelTopY_H1,x				
		lda VilLevelBottomY_H2,x				
		sbc #0
		sta VilLevelTopY_H2,x				

Exit

		rts
		
.endp		

;
;**************************************************************************************************
;	VillianSetScreenPos
;
; 		get new screen pos
; 		this must use the "_H2" positions for 
; 		when the delta between the missile and 
; 		the camera is too big (64 chars in X, or 32 chars in Y)
;
;		params:		m_villianCurrIndex	-	Index of villian to work on
;
;**************************************************************************************************
;	
.proc VillianSetScreenPos

		ldx m_villianCurrIndex
		cpx #$FF
		beq Exit

		lda VilScreenLeftX,x				; save old screen pos
		sta VilOldScreenLeftX,x

		lda VilScreenTopY,x
		sta VilOldScreenTopY,x
		
		; get new screen pos
		; this must use the "_H2" positions for 
		; when the delta between the missile and 
		; the camera is too big (64 chars in X, or 32 chars in Y)
		;
		lda VilLevelLeftX_H1,x
		sec
		sbc m_levelWindowX_H1
		sta m_screenDelta_H1
		lda VilLevelLeftX_H2,x
		sbc m_levelWindowX_H2
		bcc SMSP_set_outside					; this is not totally correct, because it doesn't use the width of the missile
		sta m_screenDelta_H2					; (but if we do it correctly we should clip the missile graphics)

		bne SMSP_set_outside					; could remove the bcc and only use this..
		lda m_screenDelta_H1
		cmp #[160-1]							; 40 chars x 4 pixels, minus (missile width - 1)
		bcs SMSP_set_outside
	
		adc #PM_BASE_SCREEN_X
		sta VilScreenLeftX,x
	
		lda VilLevelTopY_H1,x
		sec
		sbc m_levelWindowY_H1
		sta m_screenDelta_H1
		lda VilLevelTopY_H2,x
		sbc m_levelWindowY_H2
		bcc SMSP_set_outside					; this is not totally correct, because it doesn't use the height of the missile
		sta m_screenDelta_H2					; (but if we do it correctly we should clip the missile graphics)

		bne SMSP_set_outside					; could remove the bcc and only use this..
		lda m_screenDelta_H1
		cmp #[193-2]							; 24 chars x 8 scan lines, plus one extra scan line, minus (missile height - 1)
		bcs SMSP_set_outside
	
		adc #PM_BASE_SCREEN_Y
		sta VilScreenTopY,x

		rts
	
; if outside the visible range in X or Y, just set it out of the screen (for a p/m the screen coordinate 0 is outside the visible range)
SMSP_set_outside
		
		lda #0
		sta VilScreenTopY,x
		sta VilScreenLeftX,x
	
Exit	
		rts

.endp

;
;**************************************************************************************************
; 	VillianSubstractDeaccelToSpeedX
;**************************************************************************************************
;
.proc VillianSubstractDeaccelToSpeedX

		ldx m_villianCurrIndex
		cpx #$FF
		beq Exit

		lda VilSideSpeedX_L1,x					; update frame speed with frame accel
		sec
		sbc VilSideSpeedDeaccelX_L1,x
		sta VilSideSpeedX_L1,x

		lda VilSideSpeedX_H1,x
		sbc VilSideSpeedDeaccelX_L1,x
		bcs DontResetSpeed

;*****	Reset Speed
;
ResetSpeed
		lda #0
		sta VilSideSpeedX_L1,x

;*****	Dont Reset Speed
;
DontResetSpeed
		sta VilSideSpeedX_H1,x

;*****	Exit
;
Exit

		rts	

.endp

;
;**************************************************************************************************
; VillianSubstractSpeedToPositionX
;**************************************************************************************************
;
.proc VillianSubstractSpeedToPositionX

		ldx m_villianCurrIndex
		cpx #$FF
		beq Exit
		
;*****	Update side position
;		
		lda VilLevelLeftX_L1,x	
		sec
		sbc VilSideSpeedX_L1,x
		sta VilLevelLeftX_L1,x
		
		lda VilLevelLeftX_H1,x
		sbc VilSideSpeedX_H1,x
		sta VilLevelLeftX_H1,x
		
		lda VilLevelLeftX_H2,x
		sbc #$00
		sta VilLevelLeftX_H2,x
		
		; check collisions for a player moving to the left
		bcs CheckLeftCollision
		
		lda #$00
		sta VilLevelLeftX_H2,x
		sta VilLevelLeftX_H1,x
		sta VilLevelLeftX_L1,x
		jmp FoundCollision

;*****	Check Left Collision
;
CheckLeftCollision
		
		lda #$00
		sta m_vilCollisionX

		jsr VillianCheckLeftCollision

		lda m_vilCollisionX
		beq Exit

;*****	Found Collision
;
FoundCollision
		
		ldx m_villianCurrIndex
		lda #0
		sta VilSideSpeedX_H1,x
		sta VilSideSpeedX_L1,x

;*****	Exit
;
Exit
		rts
		
.endp		

;
;***************************************************************************************************
;	VilliansInit
;
;		loops for MAX_VILLIANS and initializes position and draws
;
;***************************************************************************************************
;
.proc VilliansInit

		ldx #$00
		stx m_villianCurrIndex
						
Loop

		ldx m_villianCurrIndex
		lda VilActive,x
		cmp #$01
		beq PositionEnemy
		jmp NextEnemy		

PositionEnemy

		jsr VillianSetSpawnPos
		jsr VillianSetInfo
		jsr VillianSetScreenPos

DrawEnemy

		ldx m_villianCurrIndex
		lda EnemyDrawLSB,x
		sta m_paramW00
		lda EnemyDrawMSB,x
		sta m_paramW00+1
		
		lda #>(NextEnemy - 1)					; LSB for the set up stack to act like a JSR
		pha										; push a simulated return LSB address
		lda #<(NextEnemy - 1)					; MSB for the set up stack to act like a JSR 
		pha										; push a simulated return MSB address

		jmp (m_paramW00)	
								
NextEnemy

		inx
		stx m_villianCurrIndex
		cpx #MAX_VILLIANS
		beq Exit
		jmp Loop

Exit

	rts
	
.endp

;
;***************************************************************************************************
;	VilliansUpdate
;
;		loops for MAX_VILLIANS and updates the arrays
;
;***************************************************************************************************
;
.proc VilliansUpdate

		ldx #$00
		stx m_villianCurrIndex
		
Loop
	
		ldx m_villianCurrIndex
		lda VilActive,x
		cmp #$01
		beq UpdateFrame
		jmp NextEnemy		
		
UpdateFrame				

		inc VilCurrFrame,x
		lda VilCurrFrame,x
		cmp VilTotalFrame,x		
		bne EnemyMove
		
		lda #$00
		sta VilCurrFrame,x
		
EnemyMove
		
		ldx m_villianCurrIndex
		
		lda EnemyMoveLSB,x
		sta m_paramW00
		lda EnemyMoveMSB,x
		sta m_paramW00+1
		
		lda #>(DrawEnemy - 1)
		pha
		lda #<(DrawEnemy - 1)
		pha
		
		jmp (m_paramW00)		

DrawEnemy

		ldx m_villianCurrIndex
		
		lda EnemyDrawLSB,x
		sta m_paramW00

		lda EnemyDrawMSB,x
		sta m_paramW00+1
		
		lda #>(NextEnemy - 1)
		pha
		lda #<(NextEnemy - 1)
		pha
		
		jmp (m_paramW00)
	
;*****	Simulated JSR return address
;		
NextEnemy
		
		ldx m_villianCurrIndex
		inx
		stx m_villianCurrIndex

		cpx #MAX_VILLIANS
		bne Loop
		
Exit

		rts

.endp