;
;****************************************************************************************************
;
;	Player Data
;
;		Each row of X and Y is associated with a level number (zero based).
;
;****************************************************************************************************
;
MAX_GAME_LEVELS = 1

LevelsPlayer_X
			.byte $03

LevelsPlayer_Y
			.byte $16
;
;****************************************************************************************************
;
;	Level Data
;
;		Low (LSB) and High (MSB) addresses of the level data map
;
;****************************************************************************************************
;
LevelsAddr_LSB
	.byte <LEVELS_01

LevelsAddr_MSB
	.byte >LEVELS_01
;
;****************************************************************************************************
;
LEVELS_01
			.byte $00,$17,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$FD,$FE
			.byte $FF

