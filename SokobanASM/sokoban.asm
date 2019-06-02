.386
.model		flat, stdcall
option		casemap:none

.data
map1		byte	9 dup('E') , 'EWWWWWWWE', 'EWGGBGTWE', 'EWGGWWWWE', 'EWGPWEEEE', 'EWWWWEEEE', 9 dup('E')
map2		byte	'EWWWWWWWE' , 'EWGGPGGWE', 'EWGGGGGWE', 'EWGGGBTWE', 'EWGGGGGWE', 'EWWWWWWWE', 9 dup('E')
map3		byte	'EEWWWWWWW', 'WWWTGBGWW', 'WGGPGGGWW', 'WGGGGGGWW', 'WGGBGTGWW', 'WGGGGWWWW', 'WWWWWWEEE'
map4		byte	'EEEEEWWWW', 'EWWWEWTGW', 'EWPWWWGGW', 'WWGGGGGWW', 'WTGGBGBWE', 'WGGGGGGWE', 'WWWWWWWWE'
map5		byte	'EEEWWWWEE', 'EWWWGGWEE', 'EWPGTBWWE', 'EWGGGBGWE', 'EWGWTGGWE', 'EWGGGGGWE', 'EWWWWWWWE'
map6		byte	'EEWWWWWEE', 'EWWGGGWWE', 'EWPGWGGWE', 'EWGBFBGWE', 'EWGGTGGWE', 'EWWGTGWWE', 'EEWWWWWEE'
map7		byte	9 dup('E') , 'WWWWWWEEE', 'WGGGGWWWE', 'WGGGTTGWE', 'WGBBBPGWE', 'WGGWGTGWE', 'WWWWWWWWE'
map8		byte	'EWWWWWEEE', 'WWTGGWWWE', 'WGGWGBPWE', 'WGGWGWGWE', 'WGFGGBTWE', 'WGGGGWWWE', 'WWWWWWEEE'
map9		byte	9 dup('E') , 'EWWWWWWEE', 'EWPFGGWWE', 'EWGBWGGWE', 'EWGBGTGWE', 'EWTGGGWWE', 'EWWWWWWEE'
mapa		byte	9 dup('E') , 'EEWWWWWWE', 'EWWGGGGWE', 'EWGTTGGGW', 'EWGWGBBBW', 'EWGGGWPTW', 'EWWWWWWWW'
mapb		byte	9 dup('E') , 'WWWWWWWWE', 'WWGGGGGWW', 'WWGWGWBGW', 'WWTGBFGGW', 'WWGGPWGTW', 9 dup('W')
.code
DllEntry	proc
	mov		eax, 1
	ret
DllEntry	endp
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
	.elseif byte ptr [edi+ebx] == 'G'; front is empty groud
		mov		byte ptr [edi+ebx], 'P'
		mov		dl, up
		mov		byte ptr [edi+eax], dl
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
		.elseif byte ptr [edi+ecx] == 'G' ; front front is empty groud
			mov		byte ptr [edi+ecx], 'B'
			mov		dl, uf
			mov		byte ptr [edi+ebx], dl
			mov		dl, up
			mov		byte ptr [edi+eax], dl
		.endif
	.endif
	ret
move		endp
control		proc	uses esi edi ebx ecx, map:ptr byte, action:dword
	local	ppos:byte
	mov		edi, map
	.if		action == 0h ; load level 1
		lea		esi, map1
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 1h ; load level 2
		lea		esi, map2
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 2h ; load level 3
		lea		esi, map3
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 3h ; load level 4
		lea		esi, map4
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 4h ; load level 5
		lea		esi, map5
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 5h ; load level 6
		lea		esi, map6
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 6h ; load level 7
		lea		esi, map7
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 7h ; load level 8
		lea		esi, map8
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 8h ; load level 9
		lea		esi, map9
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 9h ; load level 10
		lea		esi, mapa
		cld
		mov		ecx, 63
		rep		movsb
	.elseif	action == 0ah ; load level S
		lea		esi, mapb
		cld
		mov		ecx, 63
		rep		movsb
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
	.endif
	; check if pass
	mov		ebx, 1
	mov		ecx, 0
	.while	ecx < 63
		.if		byte ptr [edi+ecx] == 'B'
			mov		ebx, 0
			.break	
		.endif
		inc		ecx
	.endw
	mov		eax, ebx
	ret
control		endp
end
