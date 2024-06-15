;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2022/2023
;--------------------------------------------------------------
; Demostra��o da navega��o do cursor do Ecran 
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'


		STR12	 		DB 		"            "	; String para 12 digitos
		jogador1 		db      'Digite o nome do jogador 1:$',0
		jogador2		db      'Digite o nome do jogador 2:$',0
        vencedor1 		db      'O X GANHOU O JOGO$',0
		vencedor2		db      'A O GANHOU O JOGO$',0
		Pjogador		db		'Jogador 1 -- X $',0
		Sjogador		db		'Jogador 2 -- 0 $',0
		nome_jogador1 	db 		20 dup('$') ; 
		nome_jogador2 	db		20 dup('$') ;
        nova_string     db      20 dup('$')
		Max_letters 	db 		'(Limite -> 10 letras)','$'
		Logo 			db		"           								  	      ",0AH,0DH
						db 		"	  &&&&&		   Tic Tac Toe GAME	   &&&&& 		  ",0AH,0DH
						db		"	  &&&&&		   Tic Tac Toe GAME	   &&&&&   	      ",0AH,0DH
						db		"	  &&&&&		   Tic Tac Toe GAME	   &&&&&		 $"
		menu1 			db 		"Acesso ao menu:$"
		menu2 			db 		"1 Jogar:$"
		menu3 			db 		"2 Info / Credits$"
		menu4 			db 		"0 Sair$"				
		Credits         db       "                 TIC TAC TOE                    $", 0AH, 0DH               
        Credits2        db      " Para jogar:", 0AH, 0DH
                        db      " - Teclas direccionais para jogar", 0AH, 0DH
                        db      " - Tecla n passa de nivel de forma a testar o jogo mais rapidamente", 0AH, 0DH
                        db      " - Tecla s ou esc permite sair do jogo", 0AH, 0DH
                        db      " - Tecla p para pausar o tempo$"
        Credits3        db      " Trabalho realizado em contexto academico para a disciplina de TAC$"
        Credits4        db      " Realizado por Vitor e Diogo Coelho$"
		str_num         db      5 dup(?),'$'
		ultimo_num_al   dw      0
        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'jogo.TXT',0
        HandleFich      dw      0
        car_fich        db      ?
	    ChangePlayer	db		0

        
		TABULEIRO1     DB       9 dup(?)
		TABULEIRO2     DB       9 dup(?)
		TABULEIRO3     DB       9 dup(?)
		TABULEIRO4     DB       9 dup(?)
		TABULEIRO5     DB       9 dup(?)
		TABULEIRO6     DB       9 dup(?)
		TABULEIRO7     DB       9 dup(?)
		TABULEIRO8     DB       9 dup(?)
		TABULEIRO9     DB       9 dup(?)
		TABULEIRO10    DB       9 dup(?)

        
		JogadorX		db		'Jogador X Ganhou o 1o Jogo!$'
		Jogador0		db 		'Jogador O Ganhou o 1o Jogo!$'
		JogadorX2		db		'Jogador X Ganhou o 2o Jogo!$'
		Jogador02		db 		'Jogador O Ganhou o 2o Jogo!$'
		JogadorX3		db		'Jogador X Ganhou o 3o Jogo!$'
		Jogador03		db 		'Jogador O Ganhou o 3o Jogo!$'
		JogadorX4		db		'Jogador X Ganhou o 4o Jogo!$'
		Jogador04		db 		'Jogador O Ganhou o 4o Jogo!$'
		JogadorX5		db		'Jogador X Ganhou o 5o Jogo!$'
		Jogador05		db 		'Jogador O Ganhou o 5o Jogo!$'
		JogadorX6		db		'Jogador X Ganhou o 6o Jogo!$'
		Jogador06		db 		'Jogador O Ganhou o 6o Jogo!$'
		JogadorX7		db		'Jogador X Ganhou o 7o Jogo!$'
		Jogador07		db 		'Jogador O Ganhou o 7o Jogo!$'
		JogadorX8		db		'Jogador X Ganhou o 8o Jogo!$'
		Jogador08		db 		'Jogador O Ganhou o 8o Jogo!$'
		JogadorX9		db		'Jogador X Ganhou o 9o Jogo!$'
		Jogador09		db 		'Jogador O Ganhou o 9o Jogo!$'

		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	2	; a linha pode ir de [1 .. 25]
		POSx			db	4	; POSx pode ir [1..80]
		buffer			db		'                                               ',13,10
						db 		'_______________________________________________',13,10
						db		'_______________________________________________',13,10
						db 		'_______________________________________________',13,10
						db		'_______________________________________________',13,10
						db		'_______________________________________________',13,10	

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

MOSTRA MACRO STR
			mov	    AH,09H
			LEA	    DX,STR
			int	    21H
ENDM

;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp

CalcAleat proc near

			sub		sp,2
			push	bp
			mov		bp,sp
			push	ax
			push	cx
			push	dx
			mov		ax,[bp+4]
			mov		[bp+2],ax

			mov		ah,00h
			int		1ah

			add		dx,ultimo_num_al
			add		cx,dx
			mov		ax,65521
			push	dx
			mul		cx
			pop		dx
			xchg	dl,dh
			add		dx,32749
			add		dx,ax

			mov		ultimo_num_al,dx

			mov		[BP+4],dx

			pop		dx
			pop		cx
			pop		ax
			pop		bp
			ret
CalcAleat endp

impnum proc near
			push	bp
			mov		bp,sp
			push	ax
			push	bx
			push	cx
			push	dx
			push	di
			mov		ax,[bp+4] ;param3
			lea		di,[str_num+5]
			mov		cx,2 ; numero de digitos CHANGE FOR TP


	prox_dig:
			xor		dx,dx
			mov		bx,10
			div		bx
			add		dl,'0' ; dh e' sempre 0
			dec		di
			mov		[di],dl
			loop	prox_dig

			mov		ah,02h
			mov		bh,00h
			mov		dl,[bp+7] ;param1
			mov		dh,[bp+6] ;param2
			int		10h


			mov		dx,di

			pop		di
			pop		dx
			pop		cx
			pop		bx
			pop		ax
			pop		bp
			ret		4 ;limpa parametros (4 bytes) colocados na pilha
impnum endp
;########################################################################
; Avatar


AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
CICLO:		
			call	WinnigCond1		;verifica se ganhou alguém
			call	WinnigCond2
			call	WinnigCond3
			call	WinnigCond4		
			call	WinnigCond5
			call	WinnigCond6
			call	WinnigCond7		
			call	WinnigCond8
			call	WinnigCond9
            call    WinnigCond10
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h		
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
		
			goto_xy	78,0			; Mostra o caractr que estava na posi��o do AVATAR
			mov		ah, 02h			;cor
			mov		dl, Car			; IMPRIME caracter da posi��o no canto
			int		21H			
	
			goto_xy	POSx,POSy	; Vai para posi��o do cursor

MOSTRARMENSAGENS:
            cmp ChangePLAYER, 0  ; Compara ChangeJogador com 0
            je MostrarMensagemX   ; Salta para MostrarMensagemX se for igual a 0

            cmp ChangePLAYER, 1
            je MostrarMensagemO ; Salta para MostrarMensagemO se for diferente de 0

MostrarMensagemX:
	        goto_xy 16,16
            MOSTRA  SJOGADOR

            goto_xy POSx,POSy
            jmp LER_SETA
MostrarMensagemO:
	        goto_xy 16,16
            MOSTRA  PJOGADOR
          
            goto_xy POSx,POSy
            jmp LER_SETA	
LER_SETA:
			call LE_TECLA
			cmp ah, 1
			je ESTEND
			cmp al, 27 ; ESCAPE
			JE FIM
			cmp		AL, '1'
			JE		FIM
			cmp		AL, '2'
			JE		FIM
			

			goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			mov		CL, Car
			cmp		CL, 32		; S� escreve se for espa�o em branco
			JNE 	LER_SETA
			mov		ah, 02h		; coloca o caracter lido no ecra
			;inc     POSx
			mov		dl, al
			goto_xy	POSx,POSy



continua:	
            goto_xy	POSx,POSy 	; verifica se pode escrever o caracter no ecran
			mov		CL, Car
			cmp		CL, 32		; So escreve se for espa�o em branco
			JNE 	LER_SETA
			cmp		al,13	;SELECIONAR ENTER JOGA
			JE		PRINT_JOGADOR
			mov		ah, 02h		; coloca o caracter lido no ecra
			mov		dl, al
			int		21H	
			goto_xy	POSx,POSy
			
			
			jmp		LER_SETA

PRINT_JOGADOR:		
			cmp		CHANGEPLAYER,0
			JE		PRINT_JOGADOR0
			JNE		PRINT_JOGADORX
			

PRINT_JOGADOR0:
			mov 	ah,2
			mov 	dl,'O' ;carater imprimir
			call	GUARDAINFORMACAO
			int 	21h
			inc		CHANGEPLAYER		
			jmp 	CICLO

PRINT_JOGADORX:
			mov 	ah,2
			mov 	dl,'X' ;carater imprimir
			call	GUARDAINFORMACAO
			int 	21h
			dec		CHANGEPLAYER
			jmp		CICLO

GUARDAINFORMACAO:
    cmp posx,4
    je  posx4
    cmp posx,6
    je  posx6
    cmp posx,8
    je  posx8
    cmp posx,13
    je  posx13
    cmp posx,15
    je  posx15
    cmp posx,17
    je  posx17
    cmp posx,22
    je  posx22
    cmp posx,24
    je  posx24
    cmp posx,26
    je  posx26

    cmp posx,55
    je  posx55
    cmp posx,57
    je  posx57
    cmp posx,59
    je  posx59
    ret
    
    posx4:
        cmp posy,2
        je pos42
        cmp posy,3
        je pos43
        cmp posy,4
        je pos44
        cmp posy,6
        je pos46
        cmp posy,7
        je pos47
        cmp posy,8
        je pos48
        cmp posy,10
        je pos410
        cmp posy,11
        je pos411
        cmp posy,12
        je pos412
        ret
    posx6:
        cmp posy,2
        je pos62
        cmp posy,3
        je pos63
        cmp posy,4
        je pos64
        cmp posy,6
        je pos66
        cmp posy,7
        je pos67
        cmp posy,8
        je pos68
        cmp posy,10
        je pos610
        cmp posy,11
        je pos611
        cmp posy,12
        je pos612
        ret
    posx8:
        cmp posy,2
        je pos82
        cmp posy,3
        je pos83
        cmp posy,4
        je pos84
        cmp posy,6
        je pos86
        cmp posy,7
        je pos87
        cmp posy,8
        je pos88
        cmp posy,10
        je pos810
        cmp posy,11
        je pos811
        cmp posy,12
        je pos812
        ret
    posx13:
        cmp posy,2
        je pos132
        cmp posy,3
        je pos133
        cmp posy,4
        je pos134
        cmp posy,6
        je pos136
        cmp posy,7
        je pos137
        cmp posy,8
        je pos138
        cmp posy,10
        je pos1310
        cmp posy,11
        je pos1311
        cmp posy,12
        je pos1312
        ret
    posx15:
        cmp posy,2
        je pos152
        cmp posy,3
        je pos153
        cmp posy,4
        je pos154
        cmp posy,6
        je pos156
        cmp posy,7
        je pos157
        cmp posy,8
        je pos158
        cmp posy,10
        je pos1510
        cmp posy,11
        je pos1511
        cmp posy,12
        je pos1512
        ret
    posx17:
        cmp posy,2
        je pos172
        cmp posy,3
        je pos173
        cmp posy,4
        je pos174
        cmp posy,6
        je pos176
        cmp posy,7
        je pos177
        cmp posy,8
        je pos178
        cmp posy,10
        je pos1710
        cmp posy,11
        je pos1711
        cmp posy,12
        je pos1712
        ret
    posx22:
        cmp posy,2
        je pos222
        cmp posy,3
        je pos223
        cmp posy,4
        je pos224
        cmp posy,6
        je pos226
        cmp posy,7
        je pos227
        cmp posy,8
        je pos228
        cmp posy,10
        je pos2210
        cmp posy,11
        je pos2211
        cmp posy,12
        je pos2212
        ret
    posx24:
        cmp posy,2
        je pos242
        cmp posy,3
        je pos243
        cmp posy,4
        je pos244
        cmp posy,6
        je pos246
        cmp posy,7
        je pos247
        cmp posy,8
        je pos248
        cmp posy,10
        je pos2410
        cmp posy,11
        je pos2411
        cmp posy,12
        je pos2412
        ret
    posx26:
        cmp posy,2
        je pos262
        cmp posy,3
        je pos263
        cmp posy,4
        je pos264
        cmp posy,6
        je pos266
        cmp posy,7
        je pos267
        cmp posy,8
        je pos268
        cmp posy,10
        je pos2610
        cmp posy,11
        je pos2611
        cmp posy,12
        je pos2612
        ret
    posx55:
        cmp		posy,6
		je	    pos556
		cmp		posy,7
	    je		pos557
	    cmp 	posy,8
		je		pos558
        ret
    posx57:
        cmp		posy,6
		je	    pos576
		cmp		posy,7
	    je		pos577
	    cmp 	posy,8
		je		pos578
        ret
    posx59:
        cmp		posy,6
		je	    pos596
		cmp		posy,7
	    je		pos597
	    cmp 	posy,8
		je		pos598
        ret

        pos42:
            mov di,offset tabuleiro1
            mov [di],dl
            ret
        pos62:
            mov di,offset tabuleiro1
            add di,1
            mov [di],dl
            ret
        pos82:
            mov di,offset tabuleiro1
            add di,2
            mov [di],dl
            ret
        pos43:
            mov di,offset tabuleiro1
            add di,3
            mov [di],dl
            ret
        pos63:
            mov di,offset tabuleiro1
            add di,4
            mov [di],dl
            ret
        pos83:
            mov di,offset tabuleiro1
            add di,5
            mov [di],dl
            ret
        pos44:
            mov di,offset tabuleiro1
            add di,6
            mov [di],dl
            ret
        pos64:
            mov di,offset tabuleiro1
            add di,7
            mov [di],dl
            ret
        pos84:
            mov di,offset tabuleiro1
            add di,8
            mov [di],dl
            ret

        pos132:
            mov di,offset tabuleiro2
            mov [di],dl
            ret
        pos152:
            mov di,offset tabuleiro2
            add di,1
            mov [di],dl
            ret
        pos172:
            mov di,offset tabuleiro2
            add di,2
            mov [di],dl
            ret
        pos133:
            mov di,offset tabuleiro2
            add di,3
            mov [di],dl
            ret
        pos153:
            mov di,offset tabuleiro2
            add di,4
            mov [di],dl
            ret
        pos173:
            mov di,offset tabuleiro2
            add di,5
            mov [di],dl
            ret
        pos134:
            mov di,offset tabuleiro2
            add di,6
            mov [di],dl
            ret
        pos154:
            mov di,offset tabuleiro2
            add di,7
            mov [di],dl
            ret
        pos174:
            mov di,offset tabuleiro2
            add di,8
            mov [di],dl
            ret

        pos222:
            mov di,offset tabuleiro3
            mov [di],dl
            ret
        pos242:
            mov di,offset tabuleiro3
            add di,1
            mov [di],dl
            ret
        pos262:
            mov di,offset tabuleiro3
            add di,2
            mov [di],dl
            ret
        pos223:
            mov di,offset tabuleiro3
            add di,3
            mov [di],dl
            ret
        pos243:
            mov di,offset tabuleiro3
            add di,4
            mov [di],dl
            ret
        pos263:
            mov di,offset tabuleiro3
            add di,5
            mov [di],dl
            ret
        pos224:
            mov di,offset tabuleiro3
            add di,6
            mov [di],dl
            ret
        pos244:
            mov di,offset tabuleiro3
            add di,7
            mov [di],dl
            ret
        pos264:
            mov di,offset tabuleiro3
            add di,8
            mov [di],dl
            ret

        pos46:
            mov di,offset tabuleiro4
            mov [di],dl
            ret
        pos66:
            mov di,offset tabuleiro4
            add di,1
            mov [di],dl
            ret
        pos86:
            mov di,offset tabuleiro4
            add di,2
            mov [di],dl
            ret
        pos47:
            mov di,offset tabuleiro4
            add di,3
            mov [di],dl
            ret
        pos67:
            mov di,offset tabuleiro4
           add di,4
            mov [di],dl
            ret
        pos87:
            mov di,offset tabuleiro4
            add di,5
            mov [di],dl
            ret
        pos48:
            mov di,offset tabuleiro4
            add di,6
            mov [di],dl
            ret
        pos68:
            mov di,offset tabuleiro4
            add di,7
            mov [di],dl
            ret
        pos88:
            mov di,offset tabuleiro4
            add di,8
            mov [di],dl
            ret

        pos136:
            mov di,offset tabuleiro5
            mov [di],dl
            ret
        pos156:
            mov di,offset tabuleiro5
            add di,1
            mov [di],dl
            ret
        pos176:
            mov di,offset tabuleiro5
            add di,2
            mov [di],dl
            ret
        pos137:
            mov di,offset tabuleiro5
            add di,3
            mov [di],dl
            ret
        pos157:
            mov di,offset tabuleiro5
            add di,4
            mov [di],dl
            ret
        pos177:
            mov di,offset tabuleiro5
            add di,5
            mov [di],dl
            ret
        pos138:
            mov di,offset tabuleiro5
            add di,6
            mov [di],dl
            ret
        pos158:
            mov di,offset tabuleiro5
            add di,7
            mov [di],dl
            ret
        pos178:
            mov di,offset tabuleiro5
            add di,8
            mov [di],dl
            ret

        pos226:
            mov di,offset tabuleiro6
            mov [di],dl
            ret
        pos246:
            mov di,offset tabuleiro6
            add di,1
            mov [di],dl
            ret
        pos266:
            mov di,offset tabuleiro6
            add di,2
            mov [di],dl
            ret
        pos227:
            mov di,offset tabuleiro6
            add di,3
            mov [di],dl
            ret
        pos247:
            mov di,offset tabuleiro6
            add di,4
            mov [di],dl
            ret
        pos267:
            mov di,offset tabuleiro6
            add di,5
            mov [di],dl
            ret
        pos228:
            mov di,offset tabuleiro6
            add di,6
            mov [di],dl
            ret
        pos248:
            mov di,offset tabuleiro6
            add di,7
            mov [di],dl
            ret
        pos268:
            mov di,offset tabuleiro6
            add di,8
            mov [di],dl
            ret

        pos410:
            mov di,offset tabuleiro7
            mov [di],dl
            ret
        pos610:
            mov di,offset tabuleiro7
            add di,1
            mov [di],dl
            ret
        pos810:
            mov di,offset tabuleiro7
            add di,2
            mov [di],dl
            ret
        pos411:
            mov di,offset tabuleiro7
            add di,3
            mov [di],dl
            ret
        pos611:
            mov di,offset tabuleiro7
            add di,4
            mov [di],dl
            ret
        pos811:
            mov di,offset tabuleiro7
            add di,5
            mov [di],dl
            ret
        pos412:
            mov di,offset tabuleiro7
            add di,6
            mov [di],dl
            ret
        pos612:
            mov di,offset tabuleiro7
            add di,7
            mov [di],dl
            ret
        pos812:
            mov di,offset tabuleiro7
            add di,8
            mov [di],dl
            ret

        pos1310:
            mov di,offset tabuleiro8
            mov [di],dl
            ret
        pos1510:
            mov di,offset tabuleiro8
            add di,1
            mov [di],dl
            ret
        pos1710:
            mov di,offset tabuleiro8
            add di,2
            mov [di],dl
            ret
        pos1311:
            mov di,offset tabuleiro8
            add di,3
            mov [di],dl
            ret
        pos1511:
            mov di,offset tabuleiro8
            add di,4
            mov [di],dl
            ret
        pos1711:
            mov di,offset tabuleiro8
            add di,5
            mov [di],dl
            ret
        pos1312:
            mov di,offset tabuleiro8
            add di,6
            mov [di],dl
            ret
        pos1512:
            mov di,offset tabuleiro8
            add di,7
            mov [di],dl
            ret
        pos1712:
            mov di,offset tabuleiro8
            add di,8
            mov [di],dl
            ret

        pos2210:
            mov di,offset tabuleiro9
            mov [di],dl
            ret
        pos2410:
            mov di,offset tabuleiro9
            add di,1
            mov [di],dl
            ret
        pos2610:
            mov di,offset tabuleiro9
            add di,2
            mov [di],dl
            ret
        pos2211:
            mov di,offset tabuleiro9
            add di,3
            mov [di],dl
            ret
        pos2411:
            mov di,offset tabuleiro9
            add di,4
            mov [di],dl
            ret
        pos2611:
            mov di,offset tabuleiro9
            add di,5
            mov [di],dl
            ret
        pos2212:
            mov di,offset tabuleiro9
            add di,6
            mov [di],dl
            ret
        pos2412:
            mov di,offset tabuleiro9
            add di,7
            mov [di],dl
            ret
        pos2612:
            mov di,offset tabuleiro9
            add di,8
            mov [di],dl
            ret
		;tabuleiro10
        pos556:
            mov     di,offset tabuleiro10	
            mov		[di],dl
            ret

        pos576:
            mov     di,offset tabuleiro10
            add		di,1	
            mov		[di],dl
            ret

        pos596:
            mov     di,offset tabuleiro10
            add		di,2	
            mov		[di],dl
            ret

        pos557:
            mov     di,offset tabuleiro10
            add		di,3	
            mov		[di],dl
            ret

        pos577:
            mov     di,offset tabuleiro10
            add		di,4	
            mov		[di],dl
            ret

        pos597:
            mov     di,offset tabuleiro10
            add		di,5	
            mov		[di],dl
            ret

        pos558:
            mov     di,offset tabuleiro10
            add		di,6	
            mov		[di],dl
            ret

        pos578:
            mov     di,offset tabuleiro10
            add		di,7	
            mov		[di],dl
            ret

        pos598:
            mov     di,offset tabuleiro10
            add		di,8	
            mov		[di],dl
            ret



WinnigCond1:
			lea di , tabuleiro1

			checklinha1x:
                mov al,[di]
                cmp al,'X'
                jne checklinha2x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha2x
                mov al,[di+2]
                cmp al,'X'
                je  vitoriaX

			checklinha2x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha3x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha3x
                mov al,[di+5]
                cmp al,'X'
                je  vitoriaX

			checklinha3x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha1O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha1O
                mov al,[di+8]
                cmp al,'X'
                je  vitoriaX
			
			checklinha1O:
                mov al,[di]
                cmp al,'O'
                jne checklinha2O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha2O
                mov al,[di+2]
                cmp al,'O'
                je  vitoriaO

			checklinha2O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha3O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha3O
                mov al,[di+5]
                cmp al,'O'
                je  vitoriaO

			checklinha3O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna1X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna1X
                mov al,[di+8]
                cmp al,'X'
                je vitoriaO



			check_coluna1X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna2X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna2X
                mov al,[di+6]
                cmp al,'X'
                je  vitoriaX

			check_coluna2X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna3X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna3X
                mov al,[di+7]
                cmp al,'X'
                je vitoriaX

			check_coluna3X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna1O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna1O
                mov al,[di+8]
                cmp al,'X'
                je  vitoriaX

			check_coluna1O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna2O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna2O
                mov al,[di+6]
                cmp al,'O'
                je  vitoriaO

			check_coluna2O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna3O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna3O
                mov al,[di+7]
                cmp al,'O'
                je  vitoriaO

			check_coluna3O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal1X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal1X
                mov al,[di+8]
                cmp al,'O'
                je vitoriaO

			check_diagonal1X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal2X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal2X
                mov al,[di+6]
                cmp al,'X'
                je  vitoriaX

			check_diagonal2X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal1O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal1O
                mov al,[di+8]
                cmp al,'X'
                je  vitoriaX
			
			check_diagonal1O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal2O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal2O
                mov al,[di+6]
                cmp al,'O'
                je  vitoriaO

			check_diagonal2O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO1
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO1
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO1
                jmp  vitoriaO
   
            vitoriaO:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 6 * 160 + 55 * 2  

				mov al, 'O'   ; Caractere 'O'
				mov ah, 0Bh   
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaO
				
			vitoriaX:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 6 * 160 + 55 * 2  

				mov al, 'X'   ; Caractere 'X'
				mov ah, 0Ah   
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaX
     
            exibir_vitoriaX:
			
                goto_xy 50,11
                Mostra JogadorX
                jmp FIMTABULEIRO1
			
            exibir_vitoriaO:
	
                goto_xy 50,11
                Mostra Jogador0
                jmp FIMTABULEIRO1


			FIMTABULEIRO1:
            call    verificatab1
	ret

verificatab1:

WinnigCond2:
			lea di , tabuleiro2

			checklinha21x:
                mov al,[di]
                cmp al,'X'
                jne checklinha22x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha22x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria2X

			checklinha22x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha23x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha23x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria2X

			checklinha23x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha21O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha21O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria2X
			
			checklinha21O:
                mov al,[di]
                cmp al,'O'
                jne checklinha22O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha22O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria2O

			checklinha22O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha23O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha23O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria2O

			checklinha23O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna21X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna21X
                mov al,[di+8]
                cmp al,'X'
                je vitoria2O



			check_coluna21X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna22X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna22X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria2X

			check_coluna22X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna23X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna23X
                mov al,[di+7]
                cmp al,'X'
                je vitoria2X

			check_coluna23X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna21O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna21O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria2X

			check_coluna21O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna22O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna22O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria2O

			check_coluna22O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna23O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna23O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria2O

			check_coluna23O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal21X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal21X
                mov al,[di+8]
                cmp al,'O'
                je vitoria2O

			check_diagonal21X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal22X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal22X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria2X

			check_diagonal22X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal21O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal21O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria2X
			
			check_diagonal21O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal22O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal22O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria2O

			check_diagonal22O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO2
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO2
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO2
                jmp  vitoria2O
   
            vitoria2X:
			mov ax, 0B800h  ; Endereço base da memória de vídeo
			mov es, ax
			mov di, 6 * 160 + 57 * 2  ; Cálculo do deslocamento para a posição (57, 6)

			mov al, 'X'   ; Caractere 'X'
			mov ah, 0Ah   ;
			mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

			jmp exibir_vitoriaX2


			vitoria2O:
			mov ax, 0B800h  ; Endereço base da memória de vídeo
			mov es, ax
			mov di, 6 * 160 + 57 * 2  ; Cálculo do deslocamento para a posição (57, 6)

			mov al, 'O'   ; Caractere 'O'
			mov ah, 0Bh   ; Atributo de cor (background preto e foreground amarelo)
			mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

			jmp exibir_vitoriaO2
			
			exibir_vitoriaX2:
			
	          goto_xy 50,12
	          Mostra JogadorX2
	          jmp FIMTABULEIRO2
			
            exibir_vitoriaO2:
	
	          goto_xy 50,12
	          Mostra Jogador02
	         jmp FIMTABULEIRO2

			FIMTABULEIRO2:

			ret



WinnigCond3:
			lea di , tabuleiro3

			checklinha31x:
                mov al,[di]
                cmp al,'X'
                jne checklinha32x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha32x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria3X

			checklinha32x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha33x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha33x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria3X

			checklinha33x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha31O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha31O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria3X
			
			checklinha31O:
                mov al,[di]
                cmp al,'O'
                jne checklinha32O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha32O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria3O

			checklinha32O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha33O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha33O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria3O

			checklinha33O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna31X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna31X
                mov al,[di+8]
                cmp al,'X'
                je vitoria3O



			check_coluna31X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna32X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna32X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria3X

			check_coluna32X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna33X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna33X
                mov al,[di+7]
                cmp al,'X'
                je vitoria3X

			check_coluna33X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna31O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna31O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria3X

			check_coluna31O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna32O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna32O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria3O

			check_coluna32O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna33O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna33O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria3O

			check_coluna33O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal31X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal31X
                mov al,[di+8]
                cmp al,'O'
                je vitoria3O

			check_diagonal31X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal32X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal32X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria3X

			check_diagonal32X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal31O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal31O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria3X
			
			check_diagonal31O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal32O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal32O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria3O

			check_diagonal32O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO3
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO3
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO3
                jmp  vitoria3O
   
            vitoria3X:
			mov ax, 0B800h  ; Endereço base da memória de vídeo
			mov es, ax
			mov di, 6 * 160 + 59 * 2  ; Cálculo do deslocamento para a posição (55, 6)

			mov al, 'X'   ; Caractere 'X'
			mov ah, 0Ah   ; Atributo de cor (background preto e foreground verde)
			mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

			jmp exibir_vitoriaX3

			vitoria3O:
			mov ax, 0B800h  ; Endereço base da memória de vídeo
			mov es, ax
			mov di, 6 * 160 + 59 * 2  ; Cálculo do deslocamento para a posição (55, 6)

			mov al, 'O'   ; Caractere 'O'
			mov ah, 0Bh   ; Atributo de cor (background preto e foreground azul claro)
			mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

			jmp exibir_vitoriaO3
			
            exibir_vitoriaX3:
			
                goto_xy 50,13
                Mostra JogadorX3
                jmp FIMTABULEIRO3
			
            exibir_vitoriaO3:
                
                goto_xy 50,13
                Mostra Jogador03
                jmp FIMTABULEIRO3

			FIMTABULEIRO3:

			ret


WinnigCond4:
			lea di , tabuleiro4

			checklinha41x:
                mov al,[di]
                cmp al,'X'
                jne checklinha42x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha42x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria4X

			checklinha42x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha43x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha43x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria4X

			checklinha43x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha41O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha41O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria4X
			
			checklinha41O:
                mov al,[di]
                cmp al,'O'
                jne checklinha42O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha42O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria4O

			checklinha42O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha43O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha43O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria4O

			checklinha43O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna41X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna41X
                mov al,[di+8]
                cmp al,'X'
                je vitoria4O



			check_coluna41X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna42X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna42X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria4X

			check_coluna42X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna43X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna43X
                mov al,[di+7]
                cmp al,'X'
                je vitoria4X

			check_coluna43X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna41O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna41O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria4X

			check_coluna41O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna42O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna42O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria4O

			check_coluna42O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna43O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna43O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria4O

			check_coluna43O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal41X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal41X
                mov al,[di+8]
                cmp al,'O'
                je vitoria4O

			check_diagonal41X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal42X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal42X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria4X

			check_diagonal42X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal41O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal41O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria4X
			
			check_diagonal41O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal42O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal42O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria4O

			check_diagonal42O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO4
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO4
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO4
                jmp  vitoria4O
   
            vitoria4X:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 7 * 160 + 55 * 2  ; Cálculo do deslocamento para a posição (55, 7)

				mov al, 'X'   ; Caractere 'X'
				mov ah, 0Ah   ; Atributo de cor (background preto e foreground verde)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaX4
			vitoria4O:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 7 * 160 + 55 * 2  ; Cálculo do deslocamento para a posição (55, 7)

				mov al, 'O'   ; Caractere 'O'
				mov ah, 0Bh   ; Atributo de cor (background preto e foreground azul claro)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaO4

            exibir_vitoriaX4:
			
                goto_xy 50,14
                Mostra JogadorX4
                jmp FIMTABULEIRO4
			
            exibir_vitoriaO4:
                
                goto_xy 50,14
                Mostra Jogador04
                jmp FIMTABULEIRO4

			FIMTABULEIRO4:

	ret

WinnigCond5:
			lea di , tabuleiro5

			checklinha51x:
                mov al,[di]
                cmp al,'X'
                jne checklinha52x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha52x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria5X

			checklinha52x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha53x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha53x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria5X

			checklinha53x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha51O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha51O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria5X
			
			checklinha51O:
                mov al,[di]
                cmp al,'O'
                jne checklinha52O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha52O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria5O

			checklinha52O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha53O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha53O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria5O

			checklinha53O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna51X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna51X
                mov al,[di+8]
                cmp al,'X'
                je vitoria5O



			check_coluna51X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna52X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna52X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria5X

			check_coluna52X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna53X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna53X
                mov al,[di+7]
                cmp al,'X'
                je vitoria5X

			check_coluna53X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna51O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna51O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria5X

			check_coluna51O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna52O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna52O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria5O

			check_coluna52O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna53O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna53O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria5O

			check_coluna53O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal51X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal51X
                mov al,[di+8]
                cmp al,'O'
                je vitoria5O

			check_diagonal51X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal52X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal52X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria5X

			check_diagonal52X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal51O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal51O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria5X
			
			check_diagonal51O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal52O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal52O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria5O

			check_diagonal52O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO5
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO5
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO5
                jmp  vitoria5O
   
            vitoria5X:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 7 * 160 + 57 * 2  ; 
	
				mov al, 'X'   ; Caractere 'X'
				mov ah, 0Ah   ; Atributo de cor (background preto e foreground verde)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaX5
			vitoria5O:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 7 * 160 + 57 * 2  ; 

				mov al, 'O'   ; Caractere 'O'
				mov ah, 0Bh   ; Atributo de cor (background preto e foreground azul claro)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaO5
				
			exibir_vitoriaX5:
                goto_xy 50,15
                Mostra JogadorX5
                jmp FIMTABULEIRO5
			
            exibir_vitoriaO5:
                
                goto_xy 50,15
                Mostra Jogador05
                jmp FIMTABULEIRO5

			FIMTABULEIRO5:

			ret



WinnigCond6:
			lea di , tabuleiro6

			checklinha61x:
                mov al,[di]
                cmp al,'X'
                jne checklinha62x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha62x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria6X

			checklinha62x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha63x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha63x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria6X

			checklinha63x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha61O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha61O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria6X
			
			checklinha61O:
                mov al,[di]
                cmp al,'O'
                jne checklinha62O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha62O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria6O

			checklinha62O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha63O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha63O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria6O

			checklinha63O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna61X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna61X
                mov al,[di+8]
                cmp al,'X'
                je vitoria6O



			check_coluna61X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna62X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna62X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria6X

			check_coluna62X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna63X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna63X
                mov al,[di+7]
                cmp al,'X'
                je vitoria6X

			check_coluna63X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna61O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna61O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria6X

			check_coluna61O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna62O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna62O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria6O

			check_coluna62O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna63O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna63O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria6O

			check_coluna63O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal61X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal61X
                mov al,[di+8]
                cmp al,'O'
                je vitoria6O

			check_diagonal61X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal62X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal62X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria6X

			check_diagonal62X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal61O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal61O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria6X
			
			check_diagonal61O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal62O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal62O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria6O

			check_diagonal62O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO6
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO6
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO6
                jmp  vitoria6O
   
            vitoria6X:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 7 * 160 + 59 * 2  

				mov al, 'X'   ; Caractere 'X'
				mov ah, 0Ah   ; Atributo de cor (background preto e foreground verde)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaX6
	
			vitoria6O:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 7 * 160 + 59 * 2  

				mov al, 'O'   ; Caractere 'O'
				mov ah, 0Bh   ; Atributo de cor (background preto e foreground azul claro)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaO6
             
            exibir_vitoriaX6:
			
                goto_xy 50,16
                Mostra JogadorX6
                jmp FIMTABULEIRO6
                        
            exibir_vitoriaO6:
                
                goto_xy 50,16
                Mostra Jogador06
                jmp FIMTABULEIRO6

			FIMTABULEIRO6:

			ret


WinnigCond7:
			lea di , tabuleiro7

			checklinha71x:
                mov al,[di]
                cmp al,'X'
                jne checklinha72x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha72x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria7X

			checklinha72x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha73x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha73x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria7X

			checklinha73x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha71O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha71O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria7X
			
			checklinha71O:
                mov al,[di]
                cmp al,'O'
                jne checklinha72O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha72O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria7O

			checklinha72O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha73O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha73O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria7O

			checklinha73O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna71X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna71X
                mov al,[di+8]
                cmp al,'X'
                je vitoria7O



			check_coluna71X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna72X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna72X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria7X

			check_coluna72X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna73X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna73X
                mov al,[di+7]
                cmp al,'X'
                je vitoria7X

			check_coluna73X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna71O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna71O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria7X

			check_coluna71O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna72O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna72O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria7O

			check_coluna72O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna73O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna73O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria7O

			check_coluna73O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal71X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal71X
                mov al,[di+8]
                cmp al,'O'
                je vitoria7O

			check_diagonal71X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal72X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal72X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria7X

			check_diagonal72X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal71O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal71O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria7X
			
			check_diagonal71O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal72O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal72O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria7O

			check_diagonal72O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO7
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO7
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO7
                jmp  vitoria7O
   
            vitoria7X:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 8 * 160 + 55 * 2  

				mov al, 'X'   ; Caractere 'X'
				mov ah, 0Ah   ; Atributo de cor (background preto e foreground verde)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaX7
	
			vitoria7O:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 8 * 160 + 55 * 2  

				mov al, 'O'   ; Caractere 'O'
				mov ah, 0Bh   ; Atributo de cor (background preto e foreground azul claro)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaO7

            exibir_vitoriaX7:
                        
                goto_xy 50,17
                Mostra JogadorX7
                jmp FIMTABULEIRO7
                        
            exibir_vitoriaO7:
                
                goto_xy 50,17
                Mostra Jogador07
                jmp FIMTABULEIRO7

			FIMTABULEIRO7:

	ret

WinnigCond8:
			lea di , tabuleiro8

			checklinha81x:
                mov al,[di]
                cmp al,'X'
                jne checklinha82x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha82x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria8X

			checklinha82x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha83x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha83x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria8X

			checklinha83x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha81O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha81O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria8X
			
			checklinha81O:
                mov al,[di]
                cmp al,'O'
                jne checklinha82O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha82O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria8O

			checklinha82O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha83O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha83O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria8O

			checklinha83O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna81X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna81X
                mov al,[di+8]
                cmp al,'X'
                je vitoria8O



			check_coluna81X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna82X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna82X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria8X

			check_coluna82X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna83X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna83X
                mov al,[di+7]
                cmp al,'X'
                je vitoria8X

			check_coluna83X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna81O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna81O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria8X

			check_coluna81O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna82O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna82O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria8O

			check_coluna82O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna83O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna83O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria8O

			check_coluna83O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal81X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal81X
                mov al,[di+8]
                cmp al,'O'
                je vitoria8O

			check_diagonal81X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal82X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal82X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria8X

			check_diagonal82X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal81O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal81O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria8X
			
			check_diagonal81O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal82O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal82O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria8O

			check_diagonal82O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO8
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO8
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO8
                jmp  vitoria8O
   
            vitoria8X:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 8 * 160 + 57 * 2  

				mov al, 'X'   ; Caractere 'X'
				mov ah, 0Ah   ; Atributo de cor (background preto e foreground verde)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

			jmp exibir_vitoriaX8
	
			vitoria8O:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 8 * 160 + 57 * 2  

				mov al, 'O'   ; Caractere 'O'
				mov ah, 0Bh   ; Atributo de cor (background preto e foreground azul claro)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaO8
            
            exibir_vitoriaX8:
			
                goto_xy 50,18
                Mostra JogadorX8
                jmp FIMTABULEIRO8
                        
            exibir_vitoriaO8:
                
                goto_xy 50,18
                Mostra Jogador08
                jmp FIMTABULEIRO8

			FIMTABULEIRO8:

			ret



WinnigCond9:
			lea di , tabuleiro9

			checklinha91x:
                mov al,[di]
                cmp al,'X'
                jne checklinha92x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha92x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria9X

			checklinha92x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha93x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha93x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria9X

			checklinha93x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha91O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha91O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria9X
			
			checklinha91O:
                mov al,[di]
                cmp al,'O'
                jne checklinha92O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha92O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria9O

			checklinha92O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha93O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha93O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria9O

			checklinha93O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna91X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna91X
                mov al,[di+8]
                cmp al,'X'
                je vitoria9O



			check_coluna91X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna92X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna92X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria9X

			check_coluna92X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna93X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna93X
                mov al,[di+7]
                cmp al,'X'
                je vitoria9X

			check_coluna93X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna91O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna91O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria9X

			check_coluna91O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna92O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna92O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria9O

			check_coluna92O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna93O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna93O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria9O

			check_coluna93O:
			
				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal91X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal91X
                mov al,[di+8]
                cmp al,'O'
                je vitoria9O

			check_diagonal91X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal92X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal92X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria9X

			check_diagonal92X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal91O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal91O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria9X
			
			check_diagonal91O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal92O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal92O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria9O

			check_diagonal92O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO9
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO9
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO9
                jmp  vitoria9O
             
              jmp exibir_vitoriaX9
			  
			  vitoria9X:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 8 * 160 + 59 * 2  

				mov al, 'X'   ; Caractere 'X'
				mov ah, 0Ah   ; Atributo de cor (background preto e foreground verde)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaX9
	
			vitoria9O:
				mov ax, 0B800h  ; Endereço base da memória de vídeo
				mov es, ax
				mov di, 8 * 160 + 59 * 2  

				mov al, 'O'   ; Caractere 'O'
				mov ah, 0Bh   ; Atributo de cor (background preto e foreground azul claro)
				mov es:[di], ax  ; Armazena o caractere e o atributo na memória de vídeo

				jmp exibir_vitoriaO9

            exibir_vitoriaX9:
			
                goto_xy 50,19
                Mostra JogadorX9
                jmp FIMTABULEIRO9
                        
            exibir_vitoriaO9:
                
                goto_xy 50,19
                Mostra Jogador09
                jmp FIMTABULEIRO9

			FIMTABULEIRO9:

			ret

WinnigCond10:
lea di , tabuleiro10

			checklinha101x:

                mov al,[di]
                cmp al,'X'
                jne checklinha102x
                mov al,[di+1]
                cmp al,'X'
                jne checklinha102x
                mov al,[di+2]
                cmp al,'X'
                je  vitoria10X

			checklinha102x:
                mov al,[di+3]
                cmp al,'X'
                jne checklinha103x
                mov al,[di+4]
                cmp al,'X'
                jne checklinha103x
                mov al,[di+5]
                cmp al,'X'
                je  vitoria10X

			checklinha103x:
                mov al,[di+6]
                cmp al,'X'
                jne checklinha101O
                mov al,[di+7]
                cmp al,'X'
                jne checklinha101O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria10X
			
			checklinha101O:
                 mov al,[di]
                cmp al,'O'
                jne checklinha102O
                mov al,[di+1]
                cmp al,'O'
                jne checklinha102O
                mov al,[di+2]
                cmp al,'O'
                je  vitoria10O

			checklinha102O:
                mov al,[di+3]
                cmp al,'O'
                jne checklinha103O
                mov al,[di+4]
                cmp al,'O'
                jne checklinha103O
                mov al,[di+5]
                cmp al,'O'
                je  vitoria10O

			checklinha103O:
                mov al,[di+6]
                cmp al,'X'
                jne check_coluna101X
                mov al,[di+7]
                cmp al,'X'
                jne check_coluna101X
                mov al,[di+8]
                cmp al,'X'
                je vitoria10O



			check_coluna101X:
				mov al,[di]
                cmp al,'X'
                jne check_coluna102X
                mov al,[di+3]
                cmp al,'X'
                jne check_coluna102X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria10X

			check_coluna102X:

				mov al,[di+1]
                cmp al,'X'
                jne check_coluna103X
                mov al,[di+4]
                cmp al,'X'
                jne check_coluna103X
                mov al,[di+7]
                cmp al,'X'
                je vitoria10X

			check_coluna103X:
			
				mov al,[di+2]
                cmp al,'X'
                jne check_coluna101O
                mov al,[di+5]
                cmp al,'X'
                jne check_coluna101O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria10X

			check_coluna101O:
				mov al,[di]
                cmp al,'O'
                jne check_coluna102O
                mov al,[di+3]
                cmp al,'O'
                jne check_coluna102O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria10O

			check_coluna102O:

				mov al,[di+1]
                cmp al,'O'
                jne check_coluna103O
                mov al,[di+4]
                cmp al,'O'
                jne check_coluna103O
                mov al,[di+7]
                cmp al,'O'
                je  vitoria10O

			check_coluna103O:
                mov al,[di+2]
                cmp al,'O'
                jne check_diagonal101X
                mov al,[di+5]
                cmp al,'O'
                jne check_diagonal101X
                mov al,[di+8]
                cmp al,'O'
                je vitoria10O

			check_diagonal101X:

				mov al,[di+2]
                cmp al,'X'
                jne check_diagonal102X
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal102X
                mov al,[di+6]
                cmp al,'X'
                je  vitoria10X

			check_diagonal102X:

				mov al,[di]
                cmp al,'X'
                jne check_diagonal101O
                mov al,[di+4]
                cmp al,'X'
                jne check_diagonal101O
                mov al,[di+8]
                cmp al,'X'
                je  vitoria10X
			
			check_diagonal101O:

				mov al,[di+2]
                cmp al,'O'
                jne check_diagonal102O
                mov al,[di+4]
                cmp al,'O'
                jne check_diagonal102O
                mov al,[di+6]
                cmp al,'O'
                je  vitoria10O

			check_diagonal102O:

				mov al,[di]
                cmp al,'O'
                jne FIMTABULEIRO10
                mov al,[di+4]
                cmp al,'O'
                jne FIMTABULEIRO10
                mov al,[di+8]
                cmp al,'O'
                jne FIMTABULEIRO10
                jmp  vitoria10O
   
            vitoria10O:

              goto_xy 50,11
              MOSTRA vencedor1
			  goto_xy POSx,POSy
			  jmp FIMTABULEIRO10

			vitoria10X:
              goto_xy 50,11
              MOSTRA  vencedor2
			  goto_xy POSx,POSy


			FIMTABULEIRO10:

			ret


ESTEND:		cmp 	al,48h
			je		Cima
			cmp		al,50h
			je		BAIXO
			cmp		al,4Bh
			je		ESQUERDA
			cmp		al,4Dh
			je		DIREITA

CIMA:		
			dec		Posy
			cmp		Posy,2
			JL		CIMALIM	
			cmp		Posy,5
			JE		CIMA1
			cmp		Posy,9
			JE		CIMA2
			jmp		CICLO
			
CIMALIM:
			mov		Posy,2
			jmp 	CICLO

CIMA1:
			mov 	POSy,4
			jmp		CICLO


CIMA2:
			mov 	POSy,8
			jmp		CICLO


BAIXO:	
			inc		Posy		;Baixo
			cmp		Posy, 12
			JG		BAIXOLIM
			cmp		Posy,5
			JE		BAIXO1
			cmp		Posy,9
			JE		BAIXO2
			jmp		CICLO

BAIXOLIM:
			mov		POSy, 12
			jmp		CICLO

BAIXO1:
			mov		POSy,6
			jmp		CICLO

BAIXO2:
			mov		POSy,10
			jmp		CICLO


ESQUERDA:
			sub		POSx,2		;Esquerda
			cmp		POSx,4
			JL		ESQUERDALIM
			cmp		POSx,11
			JE		ESQUERDA1
			cmp		POSx,20
			JE		ESQUERDA2
			jmp		CICLO

ESQUERDALIM:
			mov 	POSx,4
			jmp		CICLO

ESQUERDA1:
			mov		POSx,8
			jmp		CICLO

ESQUERDA2:
			mov		POSx,17
			jmp		CICLO


DIREITA:
			add		POSx,2
			cmp		POSx,26
			JG		DIREITALIM
			cmp		POSx,10
			je		DIREITA1
			cmp		POSx,19
			je		DIREITA2
			jmp		CICLO

DIREITALIM:
			mov		POSx,26
			jmp		CICLO

DIREITA1:
			mov		POSx,13
			jmp		CICLO

DIREITA2:
			mov		POSx,22
			jmp		CICLO

fim:		
	call apaga_ecran
	jmp  main
    RET		
			
AVATAR		endp
PLAYER_NAME PROC  ;; Para a coisa dos nomes? 
			
			GOTO_XY	10,16	
			mov 	AH,9
			LEA 	DX,Max_letters
			int 	21H
			goto_xy 0,0
			MOSTRA	Logo


; Agora a nova string contém o mesmo conteúdo da string original

	play_msg:

			GOTO_XY	10,10		
			mov 	AH,9
			LEA 	DX,jogador1
			int 	21H
			
            mov ah, 0Ah ; Função 0Ah da interrupção 21h para ler a entrada do teclado
            lea dx, nome_jogador1; Endereço da string nome_jogador2
            int 21h
                        
				
			
	play_msg2:

			GOTO_XY	10,12		
			mov 	AH,9
			LEA 	DX,jogador2
			int 	21H
			
			;ENTER PLAYER 2 NAME
			mov 	ah,0AH        ;Read from keyboard
			LEA 	dx, nome_jogador2                 
			int 	21h 
			
			GOTO_XY	10,8	  
			xor 	si, si		

	copy_ciclep2:
			;mov 	al, nome_jogador2[si]
			;cmp 	al, 32
			
				;copy str1 to str2
			
            ;mov 	buffer[si], al
			;inc 	si;increment source and destination
			;cmp 	si, 10
			;jne 	copy_ciclep2		
	
	ret		

PLAYER_NAME Endp

;########################################################################
Main  proc		
			mov		ax, dseg
			mov		ds,ax

			mov		ax,0B800h
			mov		es,ax
			
ciclo_menu:
			call	apaga_ecran   
			mov     ah, 06h		;Paints first row
			xor     CX, CX     	;Upper left corner CH=row, CL=column
			mov     CH, 0H     ;Upper CH=row
			mov     CL, 1H      ;Upper CL=column
			xor     DX, DX     	;Upper left corner CH=row, CL=column
			mov     DH, 5H  	;lower DH=row
			mov     DL, 80H  	;lower DL=column
			mov     BH,07H    	;Color
			int 	10h
			mov     ah, 06h		;Paints first row
			xor     CX, CX     	;Upper left corner CH=row, CL=column
			mov     CH, 4H     ;Upper CH=row
			mov     CL, 0H      ;Upper CL=column
			xor     DX, DX     	;Upper left corner CH=row, CL=column
			mov     DH, 7H  	;lower DH=row
			mov     DL, 80H  	;lower DL=column
			mov     BH, 09H    	;Color
			int 	10h
					
			goto_xy 0,0
			MOSTRA	Logo
			GOTO_XY	10,6
			MOSTRA	Menu1
			GOTO_XY	10,8
			MOSTRA	Menu2
			GOTO_XY	10,10
			MOSTRA	Menu3
			GOTO_XY	10,12
			MOSTRA	Menu4
			GOTO_XY	10,14
			call 	LE_TECLA

			cmp     AL, "0"
			je      EXIT
			cmp     AL, "1"
			je      Jogar
			cmp     AL, "2"
			je      Sobre_nos
			jmp 	ciclo_menu


    Sobre_nos:
			call	apaga_ecran
			goto_xy	0,1
			MOSTRA	Credits
			goto_xy	0,9
			MOSTRA	Credits2
			goto_xy	0,17
			MOSTRA	Credits3
			goto_xy	0,19
			MOSTRA	Credits4
			call	LE_TECLA
			call	ciclo_menu
    EXIT:
			call	apaga_ecran
			mov		AX, 4C00H
			int		21H

    Jogar:
;---------------------------------------------------Start change for TP--------------------------------------------------- Coloring
			call	apaga_ecran
			call    PLAYER_NAME
			call	apaga_ecran
				
	CICLO_MAIN:
			
			
			goto_xy	0,0
			call	IMP_FICH
			Call 	AVATAR
			
			goto_xy	0,22
			jmp		CICLO_MAIN
			
			mov		ah,4CH
			int		21H
Main	endp
Cseg	ends
end	Main


		
