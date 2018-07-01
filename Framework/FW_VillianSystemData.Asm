;
;***************************************************************************************************
;
;	Filename:		FW_VillianSystemData.Asm
;
;	Modified On:	Thur Apr 26, 2018 01:12 PM
;
;	Comments:		Portions of this code taken from NRV's OPEN_PLAT project and
;					Ken Jennings C64 to Atari MLP and also from WUDSN Tutorials.
;				
;***************************************************************************************************
;
MAX_VILLIANS_CHARS			= 8

VilChars					.byte $71, $72, $73, $74 
							.byte $75, $76, $77, $78
							
VilDir						:MAX_VILLIANS	.byte $00
VilDelay					:MAX_VILLIANS	.byte $00

VilState					:MAX_VILLIANS	.byte $00

VilBonus					:MAX_VILLIANS	.byte $00

VilActive					:MAX_VILLIANS	.byte $00
VilTimers					:MAX_VILLIANS	.byte $00

VilWidth					:MAX_VILLIANS	.byte $00
VilHeight					:MAX_VILLIANS	.byte $00

VilPosLSB					:MAX_VILLIANS	.byte $00
VilPosMSB					:MAX_VILLIANS	.byte $00

VilAnimLSB					:MAX_VILLIANS	.byte $00
VilAnimMSB					:MAX_VILLIANS	.byte $00

VilColorLSB					:MAX_VILLIANS	.byte $00
VilColorMSB					:MAX_VILLIANS	.byte $00

VilCurrFrame				:MAX_VILLIANS	.byte $00
VilTotalFrame				:MAX_VILLIANS	.byte $00

VilSpeedX_L1				:MAX_VILLIANS 	.byte $00
VilSpeedX_H1				:MAX_VILLIANS 	.byte $00

VilSpeedY_L1				:MAX_VILLIANS 	.byte $00
VilSpeedY_H1				:MAX_VILLIANS 	.byte $00

VilScreenTopY				:MAX_VILLIANS	.byte $00
VilOldScreenTopY			:MAX_VILLIANS	.byte $00

VilScreenLeftX				:MAX_VILLIANS	.byte $00
VilOldScreenLeftX			:MAX_VILLIANS	.byte $00

VilLevelLeftX_H1			:MAX_VILLIANS 	.byte $00
VilLevelLeftX_H2			:MAX_VILLIANS 	.byte $00
VilLevelLeftX_L1			:MAX_VILLIANS 	.byte $00

VilLevelRightX_H1			:MAX_VILLIANS 	.byte $00
VilLevelRightX_H2			:MAX_VILLIANS 	.byte $00
VilLevelRightX_L1			:MAX_VILLIANS 	.byte $00

VilLevelTopY_H1				:MAX_VILLIANS 	.byte $00
VilLevelTopY_H2				:MAX_VILLIANS 	.byte $00
VilLevelTopY_L1				:MAX_VILLIANS 	.byte $00

VilLevelBottomY_H1			:MAX_VILLIANS 	.byte $00
VilLevelBottomY_H2			:MAX_VILLIANS 	.byte $00
VilLevelBottomY_L1			:MAX_VILLIANS 	.byte $00

m_villianCurrIndex			.byte $FF


