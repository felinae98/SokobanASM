.386
.model		flat, C
option		casemap:none

.data
map1		byte	9 dup('E') , 'EWWWWWWWE', 'EWGGBGTWE', 'EWGGWWWWE', 'EWGPWEEEE', 'EWWWWEEEE', 9 dup('E')
map2		byte	'EWWWWWWWE', 'EWGGPGGWE', 'EWGGGGGWE', 'EWGGGBTWE', 'EWGGGGGWE', 'EWWWWWWWE', 9 dup('E')
map3		byte	'EEWWWWWWE', 'WWWTGBGWE', 'WGGPGGGWE', 'WGGGGGGWE', 'WGGBGTGWE', 'WGGGGWWWE', 'WWWWWWEEE'
map4		byte	'EEEEEWWWW', 'EWWWEWTGW', 'EWPWWWGGW', 'WWGGGGGWW', 'WTGGBGBWE', 'WGGGGGGWE', 'WWWWWWWWE'
map5		byte	'EEEWWWWEE', 'EWWWGGWEE', 'EWPGTBWWE', 'EWGGGBGWE', 'EWGWTGGWE', 'EWGGGGGWE', 'EWWWWWWWE'
map6		byte	'EEWWWWWEE', 'EWWGGGWWE', 'EWPGWGGWE', 'EWGBFBGWE', 'EWGGTGGWE', 'EWWGTGWWE', 'EEWWWWWEE'
map7		byte	9 dup('E') , 'WWWWWWEEE', 'WGGGGWWWE', 'WGGGTTGWE', 'WGBBBPGWE', 'WGGWGTGWE', 'WWWWWWWWE'
map8		byte	'EWWWWWEEE', 'WWTGGWWWE', 'WGGWGBPWE', 'WGGWGWGWE', 'WGFGGBTWE', 'WGGGGWWWE', 'WWWWWWEEE'
map9		byte	9 dup('E') , 'EWWWWWWEE', 'EWPFGGWWE', 'EWGBWGGWE', 'EWGBGTGWE', 'EWTGGGWWE', 'EWWWWWWEE'
mapa		byte	9 dup('E') , 'EEWWWWWWE', 'EWWGGGGWW', 'EWGTTGGGW', 'EWGWGBBBW', 'EWGGGWPTW', 'EWWWWWWWW'
mapb		byte	9 dup('E') , 'EWWWWWWWE', 'EWGGGGGWW', 'EWGWGWBGW', 'EWTGBFGGW', 'EWGGPWGTW', 'EWWWWWWWW'
step		word	0
health		byte	5
stack_size	byte	0
stack		byte	378 dup(?)
stack_p		byte	0
.code
DllEntry	proc
	mov		eax, 1
	ret
DllEntry	endp
stack_push	proc	uses edi esi ebx ecx, map:ptr byte
	.if	stack_size < 6
		inc		stack_size
	.endif
	; copy map to stack
	mov		esi, map
	mov		bl, stack_p
	sub		eax, eax
	mov		al, 63
	mul		bl
	; res in ax
	mov		edi, offset stack
	add		edi, eax
	mov		ecx, 63
	cld
	rep		movsb
	; (stack_p ++) % 6
	mov		bl, stack_p
	inc		bl
	.if	bl >= 6
		sub		bl, 6
	.endif
	mov		stack_p, bl
	ret
stack_push	endp

; return 0 good
; return 1 empty stack
; return 2 dead
stack_pop	proc	uses edi esi ebx ecx, map:ptr byte
	; dec health
	.if health == 0
		mov		eax, 2
		ret
	.endif
	dec		health
	; dec stack_size
	.if stack_size == 1
		mov		eax, 1
		ret
	.endif
	dec		stack_size
	; (stack_p --) % 6
	add		stack_p, 5
	.if stack_p >= 6
		sub		stack_p, 6
	.endif
	; pop it!
	mov		edi, map
	mov		bl, stack_p
	add		bl, 5
	.if bl >= 6
		sub		bl, 6
	.endif
	sub		eax, eax
	mov		al, 63
	mul		bl
	; res in ax
	mov		esi, offset stack
	add		esi, eax
	mov		ecx, 63
	cld
	rep		movsb
	mov		eax, 0
	ret
stack_pop	endp
move		proc	uses edi ebx ecx edx, map:ptr byte, ppos:dword, fpos:dword, ffpos:dword
	local	up:byte
	local	uf:byte
	mov		edi, map
	mov		eax, ppos
	mov		ebx, fpos
	mov		ecx, ffpos
	.if	byte ptr [edi+eax] == 'P' ;standing on groud 
		mov		up, 'G'
	.else
		mov		up, 'T' ; standing on marked place
	.endif
	.if byte ptr [edi+ebx] == 'T' ; front is marked place
		mov		byte ptr [edi+ebx], 'Q'
		mov		dl, up
		mov		byte ptr [edi+eax],  dl
		inc		step
		invoke	stack_push, edi
	.elseif byte ptr [edi+ebx] == 'G'; front is empty groud
		mov		byte ptr [edi+ebx], 'P'
		mov		dl, up
		mov		byte ptr [edi+eax], dl
		inc		step
		invoke	stack_push, edi
	.elseif byte ptr [edi+ebx] == 'B' || byte ptr [edi+ebx] == 'F' ; front is a box
		.if byte ptr [edi+ebx] == 'B'
			mov		uf, 'P'
		.else
			mov		uf, 'Q'
		.endif
		.if	byte ptr [edi+ecx] == 'T'; front front is marked place
			mov		byte ptr [edi+ecx], 'F'
			mov		dl, uf
			mov		byte ptr [edi+ebx], dl
			mov		dl, up
			mov		byte ptr [edi+eax], dl
			inc		step
			invoke	stack_push, edi
		.elseif byte ptr [edi+ecx] == 'G' ; front front is empty groud
			mov		byte ptr [edi+ecx], 'B'
			mov		dl, uf
			mov		byte ptr [edi+ebx], dl
			mov		dl, up
			mov		byte ptr [edi+eax], dl
			inc		step
			invoke	stack_push, edi
		.endif
	.endif
	ret
move		endp
control		proc	uses esi edi ebx ecx, map:ptr byte, action:dword
	local	ppos:byte
	local	state:byte
	mov		state, 0 ; init state -- normal
	mov		edi, map
	.if		action == 0h ; load level 1
		lea		esi, map1
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 1h ; load level 2
		lea		esi, map2
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 2h ; load level 3
		lea		esi, map3
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 3h ; load level 4
		lea		esi, map4
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 4h ; load level 5
		lea		esi, map5
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 5h ; load level 6
		lea		esi, map6
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 6h ; load level 7
		lea		esi, map7
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 7h ; load level 8
		lea		esi, map8
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 8h ; load level 9
		lea		esi, map9
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 9h ; load level 10
		lea		esi, mapa
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 0ah ; load level S
		lea		esi, mapb
		cld
		mov		ecx, 63
		rep		movsb
		mov		step, 0
		mov		health, 5
		mov		stack_size, 0
	.elseif	action == 10h ; move up
		mov		eax, 0
		.while		byte ptr [edi+eax] != 'P' && byte ptr [edi+eax] != 'Q'
			inc			eax
		.endw
		mov		ppos, al
		mov		ebx, eax
		sub		ebx, 9
		mov		ecx, ebx
		sub		ecx, 9
		invoke	move, edi, eax, ebx, ecx
	.elseif action == 11h ; move down
		mov		eax, 0
		.while		byte ptr [edi+eax] != 'P' && byte ptr [edi+eax] != 'Q'
			inc			eax
		.endw
		mov		ebx, eax
		add		ebx, 9
		mov		ecx, ebx
		add		ecx, 9
		invoke	move, edi, eax, ebx, ecx
	.elseif action == 12h ; move left
		mov		eax, 0
		.while		byte ptr [edi+eax] != 'P' && byte ptr [edi+eax] != 'Q'
			inc			eax
		.endw
		mov		ebx, eax
		sub		ebx, 1
		mov		ecx, ebx
		sub		ecx, 1
		invoke	move, edi, eax, ebx, ecx
	.elseif action == 13h ; move right
		mov		eax, 0
		.while		byte ptr [edi+eax] != 'P' && byte ptr [edi+eax] != 'Q'
			inc			eax
		.endw
		mov		ebx, eax
		add		ebx, 1
		mov		ecx, ebx
		add		ecx, 1
		invoke	move, edi, eax, ebx, ecx
	.elseif action == 20h ; go back
		invoke	stack_pop, edi
		.if eax == 1
			mov		state, 2
		.elseif eax == 2
			mov		state, 3
		.endif
		dec		step
	.endif
	mov		edi, map ; reload edi
	.if action < 10h ; load map
		invoke	stack_push, edi
	.endif
	; check if pass
	mov		ecx, 0
	.while	ecx < 63 && state == 0
		.if		byte ptr [edi+ecx] == 'B'
			mov		state, 1
			.break	
		.endif
		inc		ecx
	.endw
	; eax state | health | step
	sub		eax, eax
	sub		ebx, ebx
	mov		ax, step
	mov		bl, health
	shl		ebx, 16
	or		eax, ebx
	sub		ebx, ebx
	mov		bl, state
	shl		ebx, 24
	or		eax, ebx
	ret
control		endp
end
