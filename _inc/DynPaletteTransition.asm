; ---------------------------------------------------------------------------
; Subroutine that shifts each individual entry of a palette ever so slightly
; every time it is ran.
; Code by Giovanni
; Instructions: run this subroutine once per frame.
; See Variables.asm for instructions on the palette flags.
; Palette cycles that change mid level are to be read from RAM.
; ---------------------------------------------------------------------------

DynPaletteTransition:
		tst.b	(v_palflags).w			; check	if any of the flags are set
		beq.s	DynPalette_Return		; if not, return
		tst.b	(v_paltimecur).w		; check if it is time to transition the palette
		bne.s	@subtimer				; if it isn't, branch

		btst	#0,(v_palflags).w		; check the flag for above water palette changes
		beq.s	@skipabove				; if clear, skip
		bsr.s   DynPalette_AboveWater	; else, branch

	@skipabove:
		btst	#1,(v_palflags).w		; check the flag for below water palette changes
		beq.s	@skipbelow				; if clear, skip
		bsr.w   DynPalette_BelowWater	; else, branch

	@skipbelow:
		btst	#2,(v_palflags).w		; check the flag for palette cycle changes
		beq.s	@settimer				; if clear, skip
		bsr.w	DynPalette_Cycle		; else, branch

	@settimer:
		move.b	(v_paltime),(v_paltimecur).w
	@subtimer:
		subq.b	#1,(v_paltimecur).w
	DynPalette_Return:
		rts

; ---------------------------------------------------------------------------
; Go through the above water palette array
; ---------------------------------------------------------------------------

DynPalette_AboveWater:
		tst.b	(v_awcount).w			; check that the amount of colors to be changed has actually been set
		beq.s	Above_Nochange			; if it was not, branch

		moveq	#0,d0					; initialize d0. it will be used for the cycle ignore setup
		moveq	#0,d1					; initialize d1. it will be used for the cycle ignore setup
		moveq	#0,d2					; initialize d2. it will be used for comparisons.
		moveq	#0,d3					; initialize d3. it will be used for comparisons.
		moveq	#0,d4					; initialize d4. it will be used for comparisons.
		moveq	#0,d5					; initialize d5. it will be used for comparisons.
		bsr.w	DynPalette_AboveIgnore	; get the RAM address of the first palette entry to ignore
		moveq	#0,d0					; reinitialize d0. it will be used as a flag.
		moveq	#0,d1					; reinitialize d1. it will be used for a loop.
		movea.l	(p_awreplace).w,a0		; get the RAM pointer. this is the palette the game is using at the moment.
		movea.l	(p_awtarget).w,a1		; get the ROM pointer. this will be the palette once the replacements are done.
		move.b	(v_awcount).w,d1		; get the above water counter. it will be used for loops.
		subq.b	#1,d1					; subtract 1 from the counter.
		bsr.w	DynPalette_ColorCheck	; run the code that checks through the arrays.

		tst.b	d0						; check if d0 is set
		bne.s	Above_Return					; if it is, return

	Above_Nochange:
		bclr	#0,(v_palflags).w		; mark the above water palette as no longer in need of changes

	Above_Return:
		rts

; ---------------------------------------------------------------------------
; Go through the below water palette array
; ---------------------------------------------------------------------------

DynPalette_BelowWater:
		tst.b	(v_bwcount).w			; check that the amount of colors to be changed has actually been set
		beq.s	Below_Nochange				; if it was not, branch

		moveq	#0,d0					; initialize d0. it will be used for the cycle ignore setup
		moveq	#0,d1					; initialize d1. it will be used for the cycle ignore setup
		moveq	#0,d2					; initialize d2. it will be used for comparisons.
		moveq	#0,d3					; initialize d3. it will be used for comparisons.
		moveq	#0,d4					; initialize d4. it will be used for comparisons.
		moveq	#0,d5					; initialize d5. it will be used for comparisons.
		bsr.w	DynPalette_BelowIgnore	; get the RAM address of the first palette entry to ignore (TODO: Make this subroutine)
		moveq	#0,d0					; reinitialize d0. it will be used as a flag.
		moveq	#0,d1					; reinitialize d1. it will be used for a loop.
		movea.l	(p_bwreplace).w,a0		; get the RAM pointer. this is the palette the game is using at the moment.
		movea.l	(p_bwtarget).w,a1		; get the ROM pointer. this will be the palette once the replacements are done.
		move.b	(v_bwcount).w,d1		; get the above water counter. it will be used for loops.
		subq.b	#1,d1					; subtract 1 from the counter.
		bsr.w	DynPalette_ColorCheck	; run the code that checks through the arrays.

		tst.b	d0						; check if d0 is set
		bne.s	Below_Return					; if it is, return
	Below_Nochange:
		bclr	#1,(v_palflags).w		; mark the below water palette as no longer in need of changes

	Below_Return:
		rts

; ---------------------------------------------------------------------------
; Go through the palette cycle array
; ---------------------------------------------------------------------------

DynPalette_Cycle:
		tst.b	(v_pcyccount).w			; check that the amount of colors to be changed has actually been set
		beq.s	Cycle_Nochange				; if it was not, branch

		moveq	#0,d0					; initialize d0. it will be used as a flag.
		moveq	#0,d1					; initialize d1. it will be used for a loop.
		moveq	#0,d2					; initialize d2. it will be used for comparisons.
		moveq	#0,d3					; initialize d3. it will be used for comparisons.
		moveq	#0,d4					; initialize d4. it will be used for comparisons.
		moveq	#0,d5					; initialize d5. it will be used for comparisons.
		lea		(v_palcycleram).w,a0	; get the RAM pointer. this is the palette the game is using at the moment.
		movea.l	(p_pcyctarget).w,a1		; get the ROM pointer. this will be the palette once the replacements are done.
		move.b	(v_pcyccount).w,d1		; get the above water counter. it will be used for loops.
		subq.b	#1,d1					; subtract 1 from the counter.
		bsr.s	DynPalette_ColorCheck	; run the code that checks through the arrays.

		tst.b	d0						; check if d0 is set
		bne.s	Cycle_Return					; if it is, return
	Cycle_Nochange:
		bclr	#2,(v_palflags).w		; mark the above water palette as no longer in need of changes

	Cycle_Return:
		bra.w	DynPalette_CycleOverride

; ---------------------------------------------------------------------------
; Go through the array using instructions given by either of the three leading subroutines
; ---------------------------------------------------------------------------

DynPalette_ColorCheck:
		cmp.l	(a2),a0					; check if the palette entry currently selected is to be ignored
		beq.s	@entryignore			; if yes, branch
		move.w	(a0),d2					; move the palette entry from the current palette in d2
		move.w	(a1),d3					; move the palette entry from the target palette in d3
		cmp.w	d2,d3					; compare the two values
		beq.w	@nextpalette			; if they are not equal, branch

		moveq	#1,d0					; set the flag that marks that a change has occured.

	; check for blue
		move.w	d2,d4					; move the palette entry from the current palette in d4
		move.w  d3,d5					; move the palette entry from the target palette in d5
		andi.w  #$E00,d4				; get only blue
		andi.w	#$E00,d5				; get only blue
		cmp.w	d5,d4					; compare the two colors
		beq.s	@chkgreen					; if blue is equal, skip
		bhi.s	@decblue				; if blue is higher, branch

	; blue is lower
		addi.w	#$200,(a0)				; add some blue to the current color entry
		bra.s   @chkgreen					; go to the next color

	; blue is higher
	@decblue:
		subi.w	#$200,(a0)				; subtract some blue from the current color entry

	@chkgreen:
		move.w	d2,d4					; move the palette entry from the current palette in d4
		move.w  d3,d5					; move the palette entry from the target palette in d5
		andi.w  #$E0,d4					; get only green
		andi.w	#$E0,d5					; get only green
		cmp.w	d5,d4					; compare the two colors
		beq.s	@chkred					; if green is equal, skip
		bhi.s	@decgreen				; if green is higher, branch

	; green is lower
		addi.w	#$20,(a0)				; add some green to the current color entry
		bra.s   @chkred					; go to the next color

	@decgreen:
		subi.w	#$20,(a0)				; subtract some green from the current color entry

	@chkred:
		move.w	d2,d4					; move the palette entry from the current palette in d4
		move.w  d3,d5					; move the palette entry from the target palette in d5
		andi.w  #$E,d4					; get only red
		andi.w	#$E,d5					; get only red
		cmp.w	d5,d4					; compare the two colors
		beq.s	@nextpalette			; if red is equal, skip
		bhi.s	@decred					; if red is higher, branch

	; red is lower
		addq.w	#$2,(a0)				; add some red to the current color entry
		bra.s   @nextpalette			; go to the next color
		
	@decred:
		subq.w	#$2,(a0)				; subtract some red from the current color entry
		bra.s	@nextpalette
		
	@entryignore:
		adda.l	#4,a2					; next ignored entry
		
	@nextpalette:
		adda.l	#2,a0					; next palette entry
		adda.l	#2,a1					; next palette entry
		dbf		d1,DynPalette_ColorCheck; repeat
		rts								; if no colors are left to be checked, return
		
; ---------------------------------------------------------------------------
; Some changes to the palettes need to be overridden with duplicates of the palette cycling subroutines.
; ---------------------------------------------------------------------------

DynPalette_CycleOverride:
		moveq	#0,d0					; initialize d0
		move.b	(v_zone).w,d0		; get the zone number
		add.w	d0,d0					; double all that
		move.w	CycleOverride_Index(pc,d0.w),d1
		jmp	CycleOverride_Index(pc,d1.w)
		
; ---------------------------------------------------------------------------

CycleOverride_Index:
		dc.w	CycleOverride_GHZ-CycleOverride_Index
		dc.w 	CycleOverride_Return-CycleOverride_Index
		dc.w 	CycleOverride_Return-CycleOverride_Index
		dc.w 	CycleOverride_Return-CycleOverride_Index
		dc.w 	CycleOverride_Return-CycleOverride_Index
		dc.w 	CycleOverride_Return-CycleOverride_Index
		
; ---------------------------------------------------------------------------		
		
CycleOverride_GHZ:
		lea	(v_palcycleram).w,a0	
		move.w	(v_pcyc_time).w,d0
		subq.w	#1,d0
		andi.w	#3,d0
		lsl.w	#3,d0
		lea	(v_pal_dry+$50).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)
		
CycleOverride_Return:	
		rts			
		
; ---------------------------------------------------------------------------
; For the flags to clear correctly, pointers to cycling colors must be specified here.
; These must be in increasing order.
; ---------------------------------------------------------------------------		
		
DynPalette_AboveIgnore:

		moveq	#0,d0							; initialize d0
		move.b	(v_zone).w,d0				; get the zone number
		lsl.w	#2,d0						; quadruple that
		movea.l	AboveIgnore_Index(pc,d0.w),a2	; based on zone number, fetch the list of palette entries to be ignored
		rts

; ---------------------------------------------------------------------------
		
AboveIgnore_Index:
		dc.l	AboveIgnore_GHZ
		dc.l	AboveIgnore_LZ
		dc.l	AboveIgnore_Null
		dc.l	AboveIgnore_Null
		dc.l	AboveIgnore_Null
		dc.l	AboveIgnore_Null
		
; ---------------------------------------------------------------------------		
		
AboveIgnore_GHZ:	dc.l	$FFFFFB50, 		$FFFFFB52, 		$FFFFFB54, 		$FFFFFB56, 		$FFFFFFFF
AboveIgnore_LZ:		dc.l	v_pal_dry+$56, 	v_pal_dry+$58,	v_pal_dry+$5A,	v_pal_dry+$5C,	v_pal_dry+$76,	v_pal_dry+$78,	v_pal_dry+$7A,	$FFFFFFFF
AboveIgnore_Null:	dc.l	$FFFFFFFF

; ---------------------------------------------------------------------------
; For the flags to clear correctly, pointers to cycling colors must be specified here.
; These must be in increasing order.
; ---------------------------------------------------------------------------		
		
DynPalette_BelowIgnore:

		moveq	#0,d0							; initialize d0
		move.b	(v_zone).w,d0				; get the zone number
		lsl.w	#2,d0						; quadruple that
		movea.l	BelowIgnore_Index(pc,d0.w),a2	; based on zone number, fetch the list of palette entries to be ignored
		rts

; ---------------------------------------------------------------------------
		
BelowIgnore_Index:
		dc.l	BelowIgnore_Null
		dc.l	BelowIgnore_LZ
		dc.l	BelowIgnore_Null
		dc.l	BelowIgnore_Null
		dc.l	BelowIgnore_Null
		dc.l	BelowIgnore_Null
		
; ---------------------------------------------------------------------------		
		
BelowIgnore_LZ:		dc.l	v_pal_water+$56, 	v_pal_water+$58,	v_pal_water+$5A,	v_pal_water+$5C,	v_pal_water+$76,	v_pal_water+$78,	v_pal_water+$7A,	$FFFFFFFF
BelowIgnore_Null:	dc.l	$FFFFFFFF