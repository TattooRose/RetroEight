;
;***************************************************************************************************
;
;	Filename:		RetroData.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
m_livesLeft					.byte $00				; holder for number of lives left	
m_currLevelNum				.byte $00				; holder for the current game level

m_currChar					.byte $00				; temp holder for the current char being processed
m_sfxEffect					.byte $00				; temp holder for the current sound effect being processed

m_totalScore				.byte $00,$00,$00,$00	; 32 byte score data area (Hi to Lo)

m_currRow					.byte $00
m_currCol					.byte $00
m_scrYCount					.byte $00
m_datYCount					.byte $00
m_currentLineAddress		.word $0000

m_verticalLaserOn			.byte $00				; is vertical laser available
m_horizontalLaserOn			.byte $00				; is horizontal laser available

m_totalEnemies 				.byte $00
m_activeEnemies 			.byte $00

m_goldCounter 				.byte $00				; current gold counter
m_healthCounter				.byte $00				; current health counter
m_waterAvailable			.byte $00				; is water available

m_disableGameTimer			.byte $00				; disable game flag

m_gameTimerSeconds			.byte $00				; seconds timer
m_gameTimerMinutes			.byte $00				; minutes timer
m_gameTimerTSeconds			.byte $00				; seconds timer total
m_gameTSFrameCounter		.byte $00				; frame counter total

m_stick0					.byte $00
m_oldStick0					.byte $00
m_oldTrigger0				.byte $00
m_triggerState				.byte $00			; 0 - not pressed, 1 - just released, 2 - just pressed, 3 - pressed
m_currentTrigger0			.byte $00

TabLevelLineAddressLSB		:256 .byte $00
TabLevelLineAddressMSB		:256 .byte $00

TabHardwareCollision		:16	 .byte $00

 