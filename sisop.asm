[BITS 16]			; identifica que o codigo abaixo eh 16 bits

[ORG 0X7C00]		; o bootstrap eh carregado neste endereco

;----------------------------------------------------------------------------
; main16
;----------------------------------------------------------------------------
main16:
	mov SI, boostring  		; guarda ponteiro de boostring em si
	call print_str			; chama o print_str (imprime bootstring)
	call print_ln			; imprime um crlf		
	call activate_32		; entra em pmode32, clear e main32


;----------------------------------------------------------------------------
; print_char: imprime caractere na tela, assume que o valor ascii esta em al
;----------------------------------------------------------------------------
print_char:			
	mov AH, 0x0e		; bios: diz que vamos imprimir caractere na tela
	mov BH, 0x00		; numero da pagina
	mov BL, 0x07		; atributo do texto: fundo negro e cor cinza
	int 0x10			; chama interrupcao de impressao da bios
	ret					; retorna para quem chamou



;----------------------------------------------------------------------------
; print_str: imprime uma string na tela, assume que o ponteiro da str esta em si
;----------------------------------------------------------------------------
print_str:		
	next_char:					; label que define proximo caracter a imprimer
		mov AL, [SI]			; pega um byte da string e carrega em al
		inc SI					; incrementa o si (proximo caractere)
		or AL, AL				; verifique se ha \0 em al (fim da string)
		jz return		 		; se fim, entao retorna
		call print_char 		; senao imprime caractere que esta em al
		jmp next_char			; busca o proximo caractere
	return:						; label para fim
		ret						; retorna para quem chamou



;----------------------------------------------------------------------------
; print_ln: imprime str definida em crlf
;----------------------------------------------------------------------------
print_ln:
	mov SI, crlf		; SI eh argumento do print_str
	call print_str		; chama print_str
	ret					; retorna a quem chamou


;----------------------------------------------------------------------------
; hang: loop infinto, imprime msg na tela
;----------------------------------------------------------------------------
hang:
	mov SI, hangstring      ; si eh argumento do print
	call print_str			; chama print para informar hang
	jmp $					; pula para o inicio da instrucao ($) - loop infinto 

;----------------------------------------------------------------------------
; data
;----------------------------------------------------------------------------
boostring 	db 	'stage 0: real 16 bits', 0			; string de start terminando em 0
hangstring 	db 	'system hang', 0					; mensagem de hang
crlf		db   13,10,0							; crlf + \0


;----------------------------------------------------------------------------
; activate_32
;----------------------------------------------------------------------------
activate_32:
        cli                     ; desliga interrupcoes

        xor AX, AX
        mov DS, AX              ; atribui 0 ao DS (para lgdt)

        lgdt [gdt_desc]         ; carrega descritor da GDT

        mov EAX, CR0            ; copia CR0 em EAX
        or EAX, 1               ; atribui 0
        mov CR0, EAX            ; copia EAX em CR0

        jmp 08h:clear_main32    ; pula para segmento de codigo


[BITS 32]                       ; daqui para frente codigo 32 bits

;----------------------------------------------------------------------------
; clear_main32
;----------------------------------------------------------------------------
clear_main32:
        mov AX, 10h             ; salva identificados do segmento
        mov DS, AX              ; move dados segmento  para o reg segmento dados
        mov SS, AX              ; move dados segmento para o ref segmento pilha
        mov ESP, 090000h        ; move stack pointer para 090000h
        call enableA20
		call main32

;----------------------------------------------------------------------------
; main32
;----------------------------------------------------------------------------
main32:
        mov byte [DS:0b8000h], 'p'      ; move the ascii-code of 'p' into first video memory
        mov byte [DS:0b8001h], 1bh      ; assign a color code
        call hang32
        
;----------------------------------------------------------------------------
; enable a20
;----------------------------------------------------------------------------
enableA20:
	push	ax
	mov	al, 0xdd	; manda comando pro controlador do teclado e, boa sorte!
	out	0x64, al
	pop	ax
	ret
        
        
;----------------------------------------------------------------------------
; clear_main32
;----------------------------------------------------------------------------
hang32:
        jmp hang32       ; hang, duplicado para codigo 32 bits


;----------------------------------------------------------------------------
; GDT - 4GB data e code sobrescritos
;----------------------------------------------------------------------------
gdt:                    ; apenas marca endereco do inicio da gdt
	gdt_null:           ; segmento nulo
			dd 0
			dd 0
	gdt_code:               ; segmento code, read/execute, nonconforming
			dw 0ffffh
			dw 0
			db 0
			db 10011010b
			db 11001111b
			db 0
	gdt_data:               ; data segment, read/write, expande para baixo
			dw 0ffffh
			dw 0
			db 0
			db 10010010b
			db 11001111b
			db 0
gdt_end:                ; fim da gdt, marca endereco para calcular tamanho da gdt


;----------------------------------------------------------------------------
; descriptor da gdt
;----------------------------------------------------------------------------
gdt_desc:                       ; descritor da gdt
        dw gdt_end - gdt - 1    ; limite (tamanho)
        dd gdt                  ; endereco da gdt



;----------------------------------------------------------------------------
;boot setup
;----------------------------------------------------------------------------
times 510 - ($ - $$) db 0		; completa o programa todo com 0 ate 512 bytes
dw 0xaa55						; adiciona a assinatura de boot no final do arquivo
