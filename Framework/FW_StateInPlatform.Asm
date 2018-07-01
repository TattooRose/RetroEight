
PlayerMethodOverPlatform

	jsr CheckCollectable
	jsr CheckCreatePlayerMissile
	jsr DoSideMovement


;----------------------------------------
PMGT_check_up
	lda m_stick0
	and #STICK_UP	; check up
	bne PMGT_check_fall

	lda m_oldStick0
	and #STICK_UP	; check old up (looking for "just pressed")
	beq PMGT_check_fall


; check bottom of a stair (left pixel)
	lda #0
	sta m_bottomPosOffsetX
	lda #0
	sta m_bottomPosOffsetY
	jsr CheckPlayerBottomDownPos

	lda m_middleBottomChar
	and #15
	cmp #CT_LADDER
	beq PMGT_snap_ladder_up

; check bottom of a stair (right pixel)
	lda #3
	sta m_bottomPosOffsetX
	lda #0
	sta m_bottomPosOffsetY
	jsr CheckPlayerBottomDownPos

	lda m_middleBottomChar
	and #15
	cmp #CT_LADDER
	bne PMGT_check_jump

; snap player to center of the ladder
PMGT_snap_ladder_up
	lda #0
	sta m_playerLevelLeftX_L1
	sta m_playerLevelLeftX_H2

	lda m_middleBottomCharPosX
	asl
	rol m_playerLevelLeftX_H2	; x2
	asl
	rol m_playerLevelLeftX_H2	; x4 = CHAR_PIXELS_X
	sta m_playerLevelLeftX_H1

; start climbing state
	ldx #PS_CLIMBING
	jsr SetPlayerMethod

	jmp PMGT_end


;----------------------------------------
PMGT_check_jump
; start jumping state
	ldx #PS_JUMPING
	jsr SetPlayerMethod

; reduce side speed a little
	lda m_playerSideSpeed_L1
	sec
	sbc #JUMP_HSPEED_SLOWDOWN
	sta m_playerSideSpeed_L1
	lda m_playerSideSpeed_H1
	sbc #0
	bcs PMGT_jump_side_speed
	lda #0
	sta m_playerSideSpeed_L1
PMGT_jump_side_speed
	sta m_playerSideSpeed_H1

	jmp PMGT_end


;----------------------------------------
PMGT_check_fall
	jsr CheckHoleBelowPlayer

	lda m_playerOverPlatformFlag
	bne PMGT_check_down

; start falling state
	ldx #PS_FALLING
	jsr SetPlayerMethod

; divide by 2 the side speed, if there was any movement previous to falling
	lsr m_playerSideSpeed_H1
	ror m_playerSideSpeed_L1

	jmp PMGT_end


;----------------------------------------
PMGT_check_down
	lda m_stick0
	and #STICK_DOWN	; check down
	bne PMGT_end

; 	lda m_oldStick0
; 	and #STICK_DOWN	; check old down (looking for "just pressed")
; 	beq PMGT_end

; search for a ladder one char below (left pixel)
	lda #0
	sta m_bottomPosOffsetX
	lda #[CHAR_PIXELS_Y+1]
	sta m_bottomPosOffsetY
	jsr CheckPlayerBottomDownPos

	lda m_middleBottomChar
	and #15
	cmp #CT_LADDER
	beq PMGT_snap_ladder_down

; search for a ladder one char below (right pixel)
	lda #3
	sta m_bottomPosOffsetX
	lda #[CHAR_PIXELS_Y+1]
	sta m_bottomPosOffsetY
	jsr CheckPlayerBottomDownPos

	lda m_middleBottomChar
	and #15
	cmp #CT_LADDER
	bne PMGT_end

; snap player to center of the ladder
PMGT_snap_ladder_down
	lda #0
	sta m_playerLevelLeftX_L1
	sta m_playerLevelLeftX_H2

	lda m_middleBottomCharPosX
	asl
	rol m_playerLevelLeftX_H2	; x2
	asl
	rol m_playerLevelLeftX_H2	; x4 = CHAR_PIXELS_X
	sta m_playerLevelLeftX_H1

; put player one line below
	lda #0
	sta m_playerLevelBottomY_L1
	lda m_playerLevelBottomY_H1
	clc
	adc #1
	sta m_playerLevelBottomY_H1
	lda m_playerLevelBottomY_H2
	adc #0
	sta m_playerLevelBottomY_H2

; start climbing state
	ldx #PS_CLIMBING
	jsr SetPlayerMethod


;----------------------------------------
PMGT_end
	jsr SetPlayerInfo
	jmp PlayLevel.PlayerMethodReturn