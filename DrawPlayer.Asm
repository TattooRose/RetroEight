;
;***************************************************************************************************
;
;	Filename:		DrawPlayer.Asm
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
_animationTimer				.byte $00
_animationFrame				.byte $00
_animationOffset			.byte $00

_animationTableIndex		.byte $00
_animationTableFrame		.byte $00

_animationHeight			.byte $00
_animationHeightCount		.byte $00

;
;***************************************************************************************************
;	
;	AnimateClimbing
;
;***************************************************************************************************
;	
.proc AnimateClimbing

		ldx #$04		
		stx _animationTableIndex				; load the curren index

		lda #$00
		sta m_param01
		sta _animationTableFrame

		 jsr ProcessFrame	

Stick_Check

		; Check the state of the stick
		lda m_stick0
		and #[STICK_UP | STICK_DOWN]
		cmp #[STICK_UP | STICK_DOWN]
		bne Check_One
		jmp Exit
		
Check_One

		lda _animationFrame
		and #$0C
		cmp #$0C		
		bne Check_Two
		lda #$01
		sta m_param01
		jsr ProcessFrame

		jmp Exit

Check_Two

		lda _animationFrame
		and #$08
		cmp #$08		
		bne Check_Three
		lda #$02
		sta m_param01
		jsr ProcessFrame

		jmp Exit

Check_Three

		lda _animationFrame
		and #$04		
		cmp #$04		
		bne Exit
		lda #$03
		sta m_param01
		jsr ProcessFrame
				 
Exit		
		rts

.endp

;
;***************************************************************************************************
;	
;	AnimateWalking
;
;***************************************************************************************************
;	
.proc AnimateWalking

		lda m_lastPlayerSideDirection
		cmp #PSD_RIGHT
		bne SetLeftPointer
		
		lda #$00
		sta _animationTableIndex
		
		jmp StartLogic
		
SetLeftPointer		
		lda #$02
		sta _animationTableIndex

StartLogic

		; Check the state of the stick
		lda m_stick0
		and #[STICK_RIGHT | STICK_LEFT]
		cmp #[STICK_RIGHT | STICK_LEFT]
		bne Begin_Checks
		
		ldx _animationTableIndex
		lda #$00								; reset the frame counter
		sta m_param01
		sta _animationFrame						; reset the animation frame
		sta TabCurrFrames,x						; update the main arrays for this index
		sta TabCurrFrames+1,x					; update the main arrays for this index		
		jsr ProcessFrame		
		jmp Exit
		
Begin_Checks
		lda #$01
		sta m_param01
		jsr ProcessFrame
				
Check_One
		lda _animationFrame
		and #$04		
		cmp #$04
		bne Check_Two
		lda #$02
		sta m_param01
		jsr ProcessFrame
		jmp Exit
		
Check_Two
		lda _animationFrame
		and #$08
		cmp #$08
		bne Check_Three		
		lda #$03
		sta m_param01
		jsr ProcessFrame
		jmp Exit

Check_Three
		lda _animationFrame
		and #$0C
		cmp #$0C
		bne Exit
		lda #$01
		sta m_param01		
		jsr ProcessFrame
		
Exit		
		
		rts
		
.endp

;
;***************************************************************************************************
;	
;	DrawPlayer
;
;***************************************************************************************************
;	
.proc DrawPlayer

		lda m_redrawPlayerCounter
		bne Draw		
		jmp Exit				
		
Draw

StartDraw

		lda #$00
		sta m_redrawPlayerCounter 		
		
		jsr UpdateAnimationTimer
		 		
		jsr SetAnimationIndex

		lda m_playerScreenLeftX					; get the cuirrent horizontal position	
		sta HPOSP0								; store it in the regiaters	
		sta HPOSP1								; store it in the regiaters

		lda #$00
		ldy m_oldPlayerScreenTopY
		
ClearPlayer		

		sta p0_area_1,y	
		sta p1_area_1,y	
		iny
		cpy _animationHeight
		bne ClearPlayer
		
		ldx _animationTableIndex
		
		lda TabAnimLSB,x						; load the animation LSB
		sta m_paramW01							; store it in the LO byte
		lda TabAnimMSB, x						; load the animation MSB
		sta m_paramW01+1						; store it in the HI byte
		
		lda TabAnimLSB+1,x						; load the animation LSB
		sta m_paramW02							; store it in the LO byte
		lda TabAnimMSB+1,x						; load the animation MSB
		sta m_paramW02+1						; store it in the HI byte

		lda TabColorsLSB,x						; load the color LSB
		sta TabColor00+1						; store it in the LO color slot
		lda TabColorsMSB,x						; load the color LSB
		sta TabColor00+2						; store it in the HI color slot

		lda TabColorsLSB+1,x					; load the color LSB
		sta TabColor01+1						; store it in the LO color slot
		lda TabColorsMSB+1,x					; load the color LSB
		sta TabColor01+2						; store it in the HI color slot

		ldx _animationTableFrame
		
TabColor00		
		lda $FFFF,x								; grab the color
		sta COLPM0								; store it in the register
		
TabColor01		
		lda $FFFF,x								; grab the color
		sta COLPM1								; store it in the register

		lda #$00
		sta _animationHeightCount

		ldx m_playerScreenTopY
		ldy _animationOffset
	
TabAnim

		lda (m_paramW01),y
		sta p0_area_1,x	
		lda (m_paramW02),y
		sta p1_area_1,x	
		
		iny
		inx
		
		inc _animationHeightCount
		lda _animationHeightCount
		cmp _animationHeight
		bne TabAnim
Exit
		rts
.endp

;
;***************************************************************************************************
;	
;	InitDraw
;
;***************************************************************************************************
;	
.proc InitDraw

		lda #$00
		sta _animationFrame
		sta _animationOffset
		sta _animationTableIndex
		sta _animationTableFrame
		sta _animationHeight
		sta _animationHeightCount
				
		lda #PLR_ANIMATION_DELAY
		sta _animationTimer

		rts
		
.endp

;
;***************************************************************************************************
;	
;	ProcessFrame
;
;***************************************************************************************************
;	
.proc ProcessFrame

		sta m_hldA								; save off AXY
		stx m_hldX								; save off AXY
		sty m_hldY								; save off AXY

		ldx _animationTableIndex	

		lda m_param01
		sta _animationTableFrame
		
		sta TabCurrFrames,x						; update the main arrays for this index
		sta TabCurrFrames+1,x					; update the main arrays for this index
		
Exit		
		lda m_hldA								; save off AXY
		ldx m_hldX								; save off AXY
		ldy m_hldY								; save off AXY
		
		rts

.endp

;
;***************************************************************************************************
;	
;	SetAnimationIndex
;
;		const used:	PS_CLIMBING
;					PS_FALLING
;					PS_IN_WATER
;					PS_JUMPING
;					PS_LOSE
;					PS_OVER_PLATFORM
;					PS_STATIC
;
;		vars used:	m_playerState
;					m_stick0
;					m_animFrame
;					m_animHeight
;
;					_animationTableIndex
;
;***************************************************************************************************
;	
.proc SetAnimationIndex

StartState		
		lda #PLR_HEIGHT							; load the players height
		sta _animationHeight					; save if off

		lda m_playerState						; load current player state
		cmp m_oldPlayerState					; did it change
		beq ProcessState						; if not then process players state
		
ProcessState		
		lda m_playerState						; check the current state
		sta m_oldPlayerState					; update the old state with the current

		cmp #PS_OVER_PLATFORM					; over a platform
		bne CheckClimbing						; no check the climbing state
		jsr AnimateWalking
		jmp Return_Exit

CheckClimbing		
		cmp #PS_CLIMBING
		bne CheckStatic
		jsr AnimateClimbing
		jmp Return_Exit

CheckStatic		
;		cmp #PS_STATIC
;		beq StandingIndex
		jmp Return_Exit
CheckJumping
;		cmp #PS_JUMPING
;		beq JumpFallIndex
		jmp Return_Exit
CheckFalling
;		cmp #PS_FALLING
;		beq JumpFallIndex
		jmp Return_Exit
CheckInWater		
;		cmp #PS_IN_WATER
;		beq StandingIndex
		jmp Return_Exit
CheckLose		
;		cmp #PS_LOSE
		jmp Return_Exit
		 

;JumpFallIndex
;		
;		lda #$09
;		jmp Return_Exit
;		
;ClimbingIndex		
;		inc m_floatAnimClimb
;		lda m_floatAnimClimb
;		and #$10
;		beq LeftClimb 
;		
;RightClimb		
;		lda #$0C		
;		jmp Return_Exit
;		
;LeftClimb
;		lda #$0F		
;		jmp Return_Exit				
;		

Return_Exit

		lda _animationTableFrame
		ldx _animationHeight		
		MultiplyAX
		
		lda _productLo
		sta _animationOffset
	
Exit				
		rts		

.endp

;
;***************************************************************************************************
;	
;	UpdateAnimationTimer
;
;***************************************************************************************************
;	
.proc UpdateAnimationTimer
		
		dec  _animationTimer
		bne	Exit
		
		lda #PLR_ANIMATION_DELAY
		sta _animationTimer
		
		inc _animationFrame

Exit		
		rts

	.endp


