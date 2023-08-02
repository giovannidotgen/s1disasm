; ---------------------------------------------------------------------------
; Level Headers
; ---------------------------------------------------------------------------

LevelHeaders:

lhead:	macro plc1,lvlgfx,plc2,sixteen,twofivesix,palwater1,palwater2,pal,pal2
	dc.l (plc1<<24)+lvlgfx
	dc.l (plc2<<24)+sixteen
	dc.l twofivesix
	dc.b palwater1, palwater2, pal, pal2
	endm

; 1st PLC, level gfx (unused), 2nd PLC, 16x16 data, 128x128 data,
; music (unused), palette, palette (alternate)

;		1st PLC				2nd PLC				128x128 data			palette
;				level gfx*			16x16 data			music*

	lhead	plcid_GHZ,	Nem_GHZ_2nd,	plcid_GHZ2,	Blk16_GHZ,	Blk128_GHZ,	palid_GHZ, palid_GHZ,	palid_GHZ, palid_GHZ	; Green Hill
	lhead	plcid_LZ,	Nem_LZ,		plcid_LZ2,	Blk16_LZ,	Blk128_LZ,	palid_LZWater,	  palid_SBZ3Water,		palid_LZ,	   palid_SBZ3	; Labyrinth
	lhead	plcid_MZ,	Nem_MZ,		plcid_MZ2,	Blk16_MZ,	Blk128_MZ,	palid_MZ,	   palid_MZ,		palid_MZ,	   palid_MZ; Marble
	lhead	plcid_SLZ,	Nem_SLZ,	plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,	palid_SLZ,	   palid_SLZ,	palid_SLZ,	   palid_SLZ	; Star Light
	lhead	plcid_SYZ,	Nem_SYZ,	plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,	palid_SYZ,	   palid_SYZ,	palid_SYZ,	   palid_SYZ; Spring Yard
	lhead	plcid_SBZ,	Nem_SBZ,	plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,	palid_SBZ1,	   palid_SBZ1,	palid_SBZ1,	   palid_SBZ1; Scrap Brain
	zonewarning LevelHeaders,$10
	lhead	0,		Nem_GHZ_2nd,	0,		Blk16_GHZ,	Blk128_GHZ,	palid_Ending,	   palid_Ending,	palid_Ending,	   palid_Ending	; Ending
	even

;	* music and level gfx are actually set elsewhere, so these values are useless