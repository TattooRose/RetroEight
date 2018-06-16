PLR_WIDTH			= $08
PLR_HEIGHT			= $18
PLR_NUM_PMG			= $02
PLR_ANIMATION_DELAY	= $02

HeroCurrPos_X	.byte $00
HeroCurrPos_Y	.byte $00
HeroLastPos_X	.byte $00
HeroLastPos_Y	.byte $00

TabCurrFrames	.byte $00, $00, $00, $00
				.byte $00, $00

TabTotalFrames	.byte $04, $04, $04, $04
				.byte $04, $04

TabAnimLSB		.byte <WALK0DATA_R,  	<WALK1DATA_R
				.byte <WALK0DATA_L,  	<WALK1DATA_L
				.byte <CLIMB0DATA, 	 	<CLIMB1DATA
				
TabAnimMSB		.byte >WALK0DATA_R,  	>WALK1DATA_R
				.byte >WALK0DATA_L,  	>WALK1DATA_L
				.byte >CLIMB0DATA, 	 	>CLIMB1DATA
				
TabColorsLSB	.byte <WALK0COLOURS_R,  <WALK1COLOURS_R
				.byte <WALK0COLOURS_L,  <WALK1COLOURS_L
				.byte <CLIMB0COLOURS, 	<CLIMB1COLOURS

TabColorsMSB	.byte >WALK0COLOURS_R,  >WALK1COLOURS_R
				.byte >WALK0COLOURS_L,  >WALK1COLOURS_L
				.byte >CLIMB0COLOURS, 	>CLIMB1COLOURS
				
WALK0COLOURS_R	.BYTE $86,$86,$86,$86
WALK1COLOURS_R	.BYTE $2c,$2c,$2c,$2c
WALK0COLOURS_L	.BYTE $86,$86,$86,$86
WALK1COLOURS_L	.BYTE $2c,$2c,$2c,$2c

CLIMB0COLOURS	.BYTE $86,$86,$86,$86
CLIMB1COLOURS	.BYTE $2c,$2c,$2c,$2c

WALK0DATA_R		

; FRAME 1
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$18,$3c,$7e,$7e,$10,$10,$10
 .BYTE $7e,$3c,$3c,$18,$10,$10,$10,$18
; FRAME 2
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$18,$3c,$7e,$7e,$10,$18,$08
 .BYTE $7e,$3c,$3c,$18,$18,$18,$18,$0c
; FRAME 3
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$18,$3c,$7e,$7e,$10,$18,$0c
 .BYTE $7e,$3c,$3c,$3c,$24,$24,$24,$36
; FRAME 4
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$18,$3c,$7e,$7e,$10,$18,$08
 .BYTE $7e,$3c,$3c,$18,$18,$18,$18,$0c

WALK1DATA_R

 .BYTE $18,$3c,$ff,$3c,$34,$3e,$34,$38
 .BYTE $1c,$00,$00,$10,$10,$7e,$7e,$7e
 .BYTE $10,$18,$00,$00,$10,$10,$10,$18
; FRAME 2
 .BYTE $18,$3c,$ff,$3c,$34,$3e,$34,$38
 .BYTE $1c,$00,$00,$10,$10,$7e,$7e,$7e
 .BYTE $0c,$00,$00,$00,$18,$18,$18,$0c
; FRAME 3
 .BYTE $18,$3c,$ff,$3c,$34,$3e,$34,$38
 .BYTE $1c,$00,$00,$10,$10,$7e,$7e,$7e
 .BYTE $06,$00,$00,$00,$24,$24,$24,$36
; FRAME 4
 .BYTE $18,$3c,$ff,$3c,$34,$3e,$34,$38
 .BYTE $1c,$00,$00,$10,$10,$7e,$7e,$7e
 .BYTE $0c,$00,$00,$00,$18,$18,$18,$0c

WALK0DATA_L

; FRAME 1
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$18,$3c,$7e,$7e,$08,$08,$08
 .BYTE $7e,$3c,$3c,$18,$08,$08,$08,$18
; FRAME 2
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$18,$3c,$7e,$7e,$08,$18,$10
 .BYTE $7e,$3c,$3c,$18,$18,$18,$18,$30
; FRAME 3
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$18,$3c,$7e,$7e,$08,$18,$30
 .BYTE $7e,$3c,$3c,$3c,$24,$24,$24,$6c
; FRAME 4
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$18,$3c,$7e,$7e,$08,$18,$10
 .BYTE $7e,$3c,$3c,$18,$18,$18,$18,$30

WALK1DATA_L

; FRAME 1
 .BYTE $18,$3c,$ff,$3c,$2c,$7c,$2c,$1c
 .BYTE $38,$00,$00,$08,$08,$7e,$7e,$7e
 .BYTE $08,$18,$00,$00,$08,$08,$08,$18
; FRAME 2
 .BYTE $18,$3c,$ff,$3c,$2c,$7c,$2c,$1c
 .BYTE $38,$00,$00,$08,$08,$7e,$7e,$7e
 .BYTE $30,$00,$00,$00,$18,$18,$18,$30
; FRAME 3
 .BYTE $18,$3c,$ff,$3c,$2c,$7c,$2c,$1c
 .BYTE $38,$00,$00,$08,$08,$7e,$7e,$7e
 .BYTE $60,$00,$00,$00,$24,$24,$24,$6c
; FRAME 4
 .BYTE $18,$3c,$ff,$3c,$2c,$7c,$2c,$1c
 .BYTE $38,$00,$00,$08,$08,$7e,$7e,$7e
 .BYTE $30,$00,$00,$00,$18,$18,$18,$30
 
CLIMB0DATA

; FRAME 1
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $00,$db,$bd,$ff,$ff,$00,$00,$00
 .BYTE $7e,$7e,$7e,$3c,$24,$24,$24,$24
; FRAME 2
 .BYTE $18,$3c,$ff,$00,$00,$00,$c0,$80
 .BYTE $83,$99,$bd,$ff,$ff,$00,$00,$00
 .BYTE $7e,$7e,$7e,$3c,$24,$24,$04,$04
; FRAME 3
 .BYTE $18,$3c,$ff,$00,$00,$00,$00,$00
 .BYTE $c3,$99,$bd,$ff,$ff,$00,$00,$00
 .BYTE $7e,$7e,$7e,$3c,$24,$24,$24,$24
; FRAME 4
 .BYTE $18,$3c,$ff,$00,$00,$00,$03,$01
 .BYTE $c1,$99,$bd,$ff,$ff,$00,$00,$00
 .BYTE $7e,$7e,$7e,$3c,$24,$24,$20,$20
 
CLIMB1DATA

; FRAME 1
 .BYTE $18,$3c,$ff,$3c,$3c,$3c,$3c,$3c
 .BYTE $18,$c3,$81,$81,$c3,$7e,$7e,$7e
 .BYTE $00,$00,$00,$00,$24,$24,$24,$24
; FRAME 2
 .BYTE $18,$3c,$ff,$3c,$3c,$3c,$fc,$bc
 .BYTE $9b,$81,$81,$81,$c3,$7e,$7e,$7e
 .BYTE $00,$00,$00,$00,$24,$24,$04,$04
; FRAME 3
 .BYTE $18,$3c,$ff,$3c,$3c,$3c,$3c,$3c
 .BYTE $db,$81,$81,$81,$c3,$7e,$7e,$7e
 .BYTE $00,$00,$00,$00,$24,$24,$24,$24
; FRAME 4
 .BYTE $18,$3c,$ff,$3c,$3c,$3c,$3f,$3d
 .BYTE $d9,$81,$81,$81,$c3,$7e,$7e,$7e
 .BYTE $00,$00,$00,$00,$24,$24,$20,$20
