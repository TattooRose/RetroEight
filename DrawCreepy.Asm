;
;***************************************************************************************************
;
;	Filename:		DrawCreepy.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;

;
;***************************************************************************************************
;	CreepyInit
;
;		Initialize an instance of the creepy villian
;
;		params:			m_param00	-	column for character to start in
;						m_param01	-	row for character to start in
;						m_paramW03	-	level line of character 
;
;***************************************************************************************************
;
.proc CreepyInit

		jsr GetVillianIndex						; Find an open index

		cpx #$FF								; See if it's valid		
		bne Continue			
		jmp Exit								; No cannot init this instance		

Continue

		stx m_villianCurrIndex					; hold this index for later
		
		lda #PSD_RIGHT							; set initial direction
		sta VilDir,x							; store it off
		
		lda #CPY_ANIMATION_DELAY				; set the delay value
		sta VilDelay,x							; store it off

		lda #CPY_BONUS_AMOUNT					; set the value to 100
		sta VilBonus,x							; store it off

		lda #CPY_WIDTH							; set the character width
		sta VilWidth,x							; store it off

		lda #CPY_HEIGHT							; set the character height		
		sta VilHeight,x							; store it off
		
		lda #CPY_TOTAL_FRAMES					; get the total frames
		sta VilTotalFrame,x						; store it off
		
		lda #<CPY_WALKCOLORS						; load the colors
		sta VilColorLSB,x						; store it off

		lda #>CPY_WALKCOLORS						; load the colors
		sta VilColorMSB,x						; store it off

		lda #<CPY_WALKDATA						; load the animation
		sta VilAnimLSB,x						; store it off

		lda #>CPY_WALKDATA						; load the animation
		sta VilAnimMSB,x						; store it off

		lda #$01								; set the state value
		sta VilActive,x
		
		lda #$01								; set the characters speed
		sta VilSpeedX_L1						; store it off

		lda m_param00							; get the column value
		sta VilScreenLeftX,x					; store it off
		
		lda m_param01							; get the row value
		sta VilScreenTopY,x						; store it off
		
		lda m_paramW03							; load level line LSB
		sta VilPosLSB							; store it off
		lda m_paramW03+1						; load level line MSB
		sta VilPosMSB							; store it off

		lda #$00
		sta VilState,x							; store it off
		sta VilSpeedY_L1						; store it off
		
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
;***************************************************************************************************
;	CreepyDraw
;
;		Draws the creepy villian
;
;		uses:			m_villianCurrIndex	-	Index value to work against
;
;***************************************************************************************************
;
.proc CreepyDraw

		ldx m_villianCurrIndex
		cpx #$FF
		bne GetTimer
		jmp Exit
		
GetTimer
		
		lda VilTimers,x
		cmp #CPY_ANIMATION_DELAY
		beq ResetTimer
		
		inc VilTimers,x
		jmp Exit
				
ResetTimer
				
		lda #$00
		sta VilTimers,x

GetFrame			
		
;		inc VilCurrFrame,x
;		lda VilCurrFrame,x
;		cmp VilTotalFrame,x
;		bcc GetParams

;		lda #$00		
;		sta VilCurrFrame,x
				
GetParams			

		lda VilScreenTopY,x
		sta m_vars00
		
		lda VilHeight,x
		sta m_vars01
		
		lda VilCurrFrame,x
		sta m_vars03

		lda #$00
		ldy VilOldScreenTopY,x		
					
		ldx #$00		
		lda #$00
		
ClearPlayer

		sta p2_area_1,y	
		iny
		inx
		cpx m_vars01
		bne ClearPlayer
		
		ldx m_villianCurrIndex

		lda VilScreenLeftX,x
		sta HPOSP2
		
		lda VilColorLSB,x
		sta Color00+1
		lda VilColorMSB,x
		sta Color00+2

		lda VilAnimLSB,x
		sta m_paramW01
		lda VilAnimMSB,x
		sta m_paramW01+1
		
		ldx m_vars03
		
Color00

		lda $FFFF,x		
		sta COLPM2

		ldx m_vars01
		lda m_vars03
		jsr MultiplyAX
				
		ldy _productLo
		ldx m_vars00

		lda #$00
		sta m_vars02

Anim00	

		lda (m_paramW01),y
		sta p2_area_1,x
		
		inx
		iny
		
		inc m_vars02
		lda m_vars02
		cmp m_vars01
		
		bne Anim00

Exit

		rts	
.endp

;
;***************************************************************************************************
;	CreepyMove
;
;		Moves with collision checking the creepy villian
;
;		uses:			m_villianCurrIndex	-	Index value to work against
;
;***************************************************************************************************
;
.proc CreepyMove

		ldx m_villianCurrIndex
		cpx #$FF
		bne ResetState
		jmp Exit
		
ResetState

		lda #$00
		sta VilState,x
		
CheckDirection

		lda VilDir,x
		cmp #PSD_LEFT
		beq MoveLeft
		
MoveRight

;		lda VilLevelLeftX_H1,x
;		adc #$01
;		sta VilLevelLeftX_H1,x
;				
;		jsr SetVillianInfo		
		jsr GetVillianFontChar
		
		cmp #$00
		beq Exit
		lda #$01
		sta VilState,x
		bne Exit
		
MoveLeft
		


Exit

		rts
		
.endp