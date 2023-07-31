PalCycle_ToRAM:

		moveq	#0,d0					; initialize d0
		move.b	(v_zone).w,d0		; get the zone number
		add.w	d0,d0					; double all that
		move.w	PalCycle_ToRAM_Index(pc,d0.w),d1
		jmp	PalCycle_ToRAM_Index(pc,d1.w)
	
	.assumenull:
		rts
; ---------------------------------------------------------------------------

PalCycle_ToRAM_Index:
		dc.w	@null-PalCycle_ToRAM_Index
		dc.w 	PalCycle_ToRAM_LZ-PalCycle_ToRAM_Index
		dc.w 	@null-PalCycle_ToRAM_Index
		dc.w 	@null-PalCycle_ToRAM_Index
		dc.w 	@null-PalCycle_ToRAM_Index
		dc.w 	@null-PalCycle_ToRAM_Index
		
; ---------------------------------------------------------------------------

@null:
		rts		; zones using @null can load their Palette Cycle data from ROM.
		
; ---------------------------------------------------------------------------

PalCycle_ToRAM_LZ:
		lea		(v_palcycleram).w,a0	; get RAM
		lea		(Pal_LZCyc1).l,a1		; get cycle data
		cmpi.b	#3,(v_act).w	; check if level is SBZ3
		bne.s	@notSBZ3
		tst.b	(v_paltracker).w
		beq.s	@notSBZ3
		lea	(Pal_SBZ3Cyc1).l,a1 ; load SBZ3	palette instead
@notSBZ3:		
		moveq	#($20/4)-1,d0			; size of file, divided by 4, minus 1.
		
@loop:
		move.l	(a1)+,(a0)+
		dbf		d0,@loop
		
		rts