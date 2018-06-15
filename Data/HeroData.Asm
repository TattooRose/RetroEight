HERO_NUM_PMG	= 2

HeroCurrPos_X	.byte $00
HeroCurrPos_Y	.byte $00
HeroLastPos_X	.byte $00
HeroLastPos_Y	.byte $00

TabWalkFrames	.byte $04
TabWalkHeight	.byte $1D

TabAnimIndex	.byte $00
TabColorIndex	.byte $00

TabAnimLSB		.byte <WALK0DATA, <WALK1DATA
TabAnimMSB		.byte >WALK0DATA, >WALK1DATA

TabColorsLSB	.byte <WALK0COLOURS, <WALK1COLOURS
TabColorsMSB	.byte >WALK0COLOURS, >WALK1COLOURS

WALK0COLOURS	.BYTE $14,$14,$14,$14
WALK1COLOURS	.BYTE $28,$28,$28,$28

WALK0DATA		
				; FRAME 1
 				.BYTE $00,$00,$1c,$2a,$5e,$40,$9f,$bc
 				.BYTE $68,$7c,$fc,$ff,$7f,$1c,$00,$3e
 				.BYTE $47,$52,$53,$62,$77,$3f,$26,$24
 				.BYTE $24,$24,$24,$38,$3c
				; FRAME 2
 				.BYTE $00,$00,$1c,$2a,$5e,$40,$9f,$bc
 				.BYTE $68,$7c,$fc,$ff,$7f,$1c,$00,$3e
 				.BYTE $47,$52,$53,$62,$77,$3f,$22,$30
 				.BYTE $70,$78,$f0,$e6,$63
				; FRAME 3
 				.BYTE $00,$00,$1c,$2a,$5e,$40,$9f,$bc
 				.BYTE $7c,$7c,$e8,$ff,$7f,$1c,$00,$3e
 				.BYTE $47,$52,$4b,$2a,$3f,$3f,$26,$24
 				.BYTE $24,$24,$24,$38,$3c
				; FRAME 4
 				.BYTE $00,$00,$1c,$2a,$5e,$40,$9f,$bc
 				.BYTE $7c,$7c,$e8,$ff,$7f,$1c,$00,$3e
 				.BYTE $47,$52,$4b,$2a,$3f,$3f,$62,$46
 				.BYTE $4e,$8e,$96,$e6,$63
WALK1DATA
				; FRAME 1
 				.BYTE $00,$00,$00,$1c,$3c,$3f,$60,$5c
 				.BYTE $3c,$28,$68,$5f,$0f,$20,$3c,$00
 				.BYTE $38,$2d,$2c,$3d,$38,$30,$18,$18
 				.BYTE $18,$18,$18,$1c,$1e
				; FRAME 2
 				.BYTE $00,$00,$00,$1c,$3c,$3f,$60,$5c
 				.BYTE $3c,$28,$68,$5f,$0f,$20,$3c,$00
 				.BYTE $38,$2d,$2c,$3d,$38,$30,$1c,$0e
 				.BYTE $0e,$06,$06,$c6,$63
				; FRAME 3
 				.BYTE $00,$00,$00,$1c,$3c,$3f,$60,$5c
 				.BYTE $28,$28,$7c,$5f,$0f,$20,$3c,$00
 				.BYTE $38,$2d,$34,$1d,$0c,$0c,$18,$18
 				.BYTE $18,$18,$18,$1c,$1e
				; FRAME 4
 				.BYTE $00,$00,$00,$1c,$3c,$3f,$60,$5c
 				.BYTE $28,$28,$7c,$5f,$0f,$20,$3c,$00
 				.BYTE $38,$2d,$34,$1d,$0c,$0c,$1c,$38
 				.BYTE $30,$70,$60,$c6,$63

