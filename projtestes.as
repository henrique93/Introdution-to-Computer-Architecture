;LAB 8	GRUPO 5
;#77459 Henrique Lourenco
;#78215 José Touret
;#78579 Pedro Cruz
;/////////////////////////////////////////////////////////////////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\CONSTANTES\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;/////////////////////////////////////////////////////////////////////////
SP_INICIAL	EQU	FDFFh
IO_CONTROLO	EQU	FFFCh
IO_WRITE	EQU	FFFEh
INT_PORT	EQU	FFFAh 			;Tabela de interrupcoes
INT_MASK	EQU	1000110000000011b	;Mascara de interrupcoes
PAUSE_MASK	EQU	1000010000000000b	;Mascara pausa
RANDOM_MASK	EQU	1000000000010110b	;Mascara aleatorio
COUNT_TIMER	EQU	FFF6h
CONTROLO_TIMER	EQU	FFF7h
CONTROLO_LCD	EQU	FFF4h
WRITE_LCD	EQU	FFF5h
WRITE_LED	EQU	FFF8h
LED_1		EQU	FFF0h
LED_2		EQU	FFF1h
LED_3		EQU	FFF2h
LED_4		EQU	FFF3h

;/////////////////////////////////////////////////////////////////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\VARIAVEIS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;/////////////////////////////////////////////////////////////////////////
		ORIG	8000h
OBS_ELIMINADOS	WORD	0
NR_MOVIMENTOS	WORD	0
NR_OBSTACULOS	WORD	0

CONT_LED	WORD	1
CONT_LED_2	WORD	1
CONT_LED_3	WORD	1
CONT_LED_4	WORD	1

;Velocidades
CURRENT_SPEED	WORD	5
SPEED_LV1	WORD	5
SPEED_LV2	WORD	4
SPEED_LV3	WORD	3

;Posicoes Bicicleta
POS_BIKE_0	WORD	1528h
POS_BIKE_1	WORD	1628h
POS_BIKE_2	WORD	1728h

;Interruptores
int0		WORD	0
intB		WORD	0
int1		WORD	0
intT		WORD	0
intA		WORD	0

RANDOM_INICIAL	WORD	0

;Tabela
TABELA		TAB	4
VECTOR_TAB_MOV	WORD	0
VECTOR_TAB_DES	WORD	0
RESET_TAB	WORD	0

;Simbolos Bicicleta
SIMBOLO_1	STR	'|'		;Parte da Parede e Bicicleta
SIMBOLO_2	STR	'+'		;Parte da Parede
SIMBOLO_3	STR	'0'		;Parte da Bicicleta
SIMBOLO_4	STR	' '		;Clear

;Simbolos Obstaculo
SIMBOLO_5	STR	'***', FIM_TEXTO ;Obstaculo
SIMBOLO_6	STR	'   ', FIM_TEXTO ;Apaga Obstaculo

FIM_TEXTO	STR	'@'		 ;Verificador do final do texto
LIMPA_TUDO	STR	'                                                                               ',FIM_TEXTO

;Mensagens Boas Vindas
BEM_VINDO_1	STR	'Bem-vindo a Corrida de Bicicleta!', FIM_TEXTO
BEM_VINDO_2	STR	'Prima I1 para comecar', FIM_TEXTO

;Mensagens Final do Jogo
FIM_JOGO_1	STR	'Fim do Jogo', FIM_TEXTO
FIM_JOGO_2	STR	'Prima o Interruptor I1 para recomecar', FIM_TEXTO

PAUSA		STR	'PAUSA', FIM_TEXTO

;Distancia Actual e Maxima
DIST_LCD	STR	'Distancia:00000m', FIM_TEXTO
MAX_LCD		STR	'Maxima:00000m', FIM_TEXTO

;Simbolos para limpar as distancias e reiniciar os contadores das mesmas
DIST_CLEAR	STR	'/', FIM_TEXTO
DIST_RESET	STR	'0', FIM_TEXTO

;Digitos da distancia actual
DIST		STR	'0', FIM_TEXTO
DIST_2		STR	'0', FIM_TEXTO
DIST_3		STR	'0', FIM_TEXTO
DIST_4		STR	'0', FIM_TEXTO
DIST_5		STR	'0', FIM_TEXTO

;Digitos da distancia maxima
DIST_MAX	STR	'0', FIM_TEXTO
DIST_MAX_2	STR	'0', FIM_TEXTO
DIST_MAX_3	STR	'0', FIM_TEXTO
DIST_MAX_4	STR	'0', FIM_TEXTO
DIST_MAX_5	STR	'0', FIM_TEXTO

;/////////////////////////////////////////////////////////////////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\INTERRUPCOES\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;/////////////////////////////////////////////////////////////////////////
		ORIG	FE00h
INT_0		WORD	MOVE_ESQ
INT_1		WORD	start
		ORIG	FE0Ah
INT_A		WORD	pausa
INT_b		WORD	MOVE_DT
		ORIG	FE0Fh
INT_T		WORD	TIMER

start:		INC	M[int1]
		RTI
MOVE_ESQ:	INC	M[int0]
		RTI
MOVE_DT:	INC	M[intB]
		RTI
pausa:		INC	M[intA]
		RTI
TIMER:		INC	M[intT]
		MOV	R7, M[CURRENT_SPEED]
		MOV	M[COUNT_TIMER], R7
		MOV	R7, 1
		MOV	M[CONTROLO_TIMER], R7
		RTI

;/////////////////////////////////////////////////////////////////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\INICIO CODIGO DE JOGO\\\\\\\\\\\\\\\\\\\\\\\\\\
;/////////////////////////////////////////////////////////////////////////

		ORIG	0000h
		MOV	R7, SP_INICIAL
		MOV	SP, R7
		MOV	R7, FFFFh
		MOV	M[IO_CONTROLO], R7
		MOV	R1, INT_MASK
		MOV	M[INT_PORT], R1
		MOV	R2, 8000h
		MOV	M[CONTROLO_LCD], R2
		MOV	R7, M[CURRENT_SPEED]
		MOV	M[COUNT_TIMER], R7
		MOV	R7, 1
		MOV	M[CONTROLO_TIMER], R7
		MOV	R7, TABELA

;/////////////////////////////////////////////////////////////////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\CODIGO DE JOGO\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;/////////////////////////////////////////////////////////////////////////

INICIO:		CALL	BEM_VINDO
		CALL	LCD
INICIO_JOGO:	CALL	RESET_DIST
		CALL	DESENHA_JOGO
		CALL	REINICIA_JOGO
MAIN_L1:	MOV	M[int0], R0
		MOV	M[intB], R0
		MOV	M[intT], R0
		MOV	M[intA], R0
JOGO:		CMP	M[int0], R0
		BR.NZ	MOVE_ESQ_MAIN
		CMP	M[intB], R0
		BR.NZ	MOVE_DT_MAIN
		CMP	M[intT], R0
		BR.NZ	MOVE_OBS_MAIN
		CMP	M[intA], R0
		CALL.NZ	PAUSE
		BR	JOGO
MOVE_ESQ_MAIN:	CALL	MOVE_ESQUERDA
		BR	MAIN_L1
MOVE_DT_MAIN:	CALL	MOVE_DIREITA
		BR	MAIN_L1
MOVE_OBS_MAIN:	MOV	M[intT],R0
		CALL	DISTANCIAS_LCD
		CALL	MOVE_OBS
		JMP	MAIN_L1

;/////////////////////////////////////////////////////////////////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\SUB INSTRUCOES\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;/////////////////////////////////////////////////////////////////////////

;BEM_VINDO:	Escreve no ecra a mensagem inicial de boas vindas, de inicio do jogo e inicia o jogo
;		Entradas: R2 Posicao onde e escrita a string
;			  R3 String que se quer escrever (BEM_VINDO_1 e BEM_VINDO_2)
;		Saidas:
;		Efeitos: Escreve a Mensagem de boas vindas e inicia o jogo quando premido I1
BEM_VINDO:	ENI
		MOV	R3, BEM_VINDO_1
		MOV	R2, 0C16h
		CALL	STRING
		MOV	R3, BEM_VINDO_2
		MOV	R2, 0E1Bh
		CALL	STRING
FIM_BEM_VINDO:	INC	M[RANDOM_INICIAL]
		CMP	M[int1], R0
		BR.Z	FIM_BEM_VINDO
		CALL	CLEAR
		RET


;CLEAR:		Limpa o ecra
;		Entradas: R2 com o valor da posicao (R0 = 0)
;			  R3 com uma string de espacos para simular o apagar de caracteres
;		Saidas:
;		Efeitos: Apaga tudo o que esta escrito no ecra
CLEAR:		MOV	R2, 0000h
		MOV	R3, LIMPA_TUDO
CLEAR_AGAIN:	CALL	STRING
		ADD	R2, 0100h
		CMP	R2, 1800h
		BR.NZ	CLEAR_AGAIN
		RET

;CLEAR_LCD:	Limpa o LCD
;		Entradas: R1 com o valor 8020h
;		Saidas:
;		Efeitos: Apaga tudo o que esta escrito no LCD
CLEAR_LCD:	MOV	R1, 8020h
		MOV	M[CONTROLO_LCD], R1
		RET

;STRING:	Funcao auxiliar para escrever mensagens no ecra
;		Entradas:
;		Saidas:
;		Efeitos:
;R2 controlo R3 mensagem para escrever. R4 para fim ('@')
STRING:		PUSH	R2
		PUSH	R3
		MOV	R4, FIM_TEXTO
CICLO_STR:	MOV	R5, M[R3]
		CMP	R4, R5
		BR.Z	FIM_STR
		CALL	CARACTER
		INC	R2
		INC	R3
		BR	CICLO_STR
FIM_STR:	POP	R3
		POP	R2
		RET

;CARACTER:
;		Entradas:
;		Saidas:
;		Efeitos:
CARACTER:	MOV	M[IO_CONTROLO], R2
		MOV	M[IO_WRITE], R5
		RET

;STRING_LCD:	Funcao auxiliar para escrever mensagens no LCD
;		Entradas:
;		Saidas:
;		Efeitos:
STRING_LCD:	MOV	R4, FIM_TEXTO
CICLO_STR_LCD:	MOV	R5, M[R6]
		CMP	R4, R5
		BR.Z	FIM_STR_LCD
		CALL	CARACTER_LCD
		INC	R7
		INC	R6
		BR	CICLO_STR_LCD
FIM_STR_LCD:	RET

;CARACTER_LCD:
;		Entradas:
;		Saidas:
;		Efeitos:
CARACTER_LCD:	MOV	M[CONTROLO_LCD], R7
		MOV	M[WRITE_LCD], R5
		RET

;DESENHA_JOGO:	Desenha o ambiente do jogo (paredes e bicicleta)
;		Entradas:
;		Saidas:
;		Efeitos: Desenha no ecra as paredes e a bicicleta
DESENHA_JOGO:	MOV	R2, 001Ch		;Posicao inicial "+"
		MOV	R4, 001Dh		;Posicao inicial "|"
PAREDE_ESQ:	MOV	R1, M[SIMBOLO_2]
		MOV	M[IO_CONTROLO], R2
		MOV	M[IO_WRITE], R1
		ADD	R2, 0100h
		MOV	R3, M[SIMBOLO_1]
		MOV	M[IO_CONTROLO], R4
		MOV	M[IO_WRITE], R3
		ADD	R4, 0100h
		CMP	R2, 191Ch
		BR.NZ	PAREDE_ESQ
INICIO_DT:	MOV	R2, 0034h		;Posicao inicial "|"
		MOV	R4, 0035h		;Posicao inicial "+"
PAREDE_DT:	MOV	R1, M[SIMBOLO_1]
		MOV	M[IO_CONTROLO], R2
		MOV	M[IO_WRITE], R1
		ADD	R2, 0100h
		MOV	R3, M[SIMBOLO_2]
		MOV	M[IO_CONTROLO], R4
		MOV	M[IO_WRITE], R3
		ADD	R4, 0100h
		CMP	R2, 1934h
		BR.NZ	PAREDE_DT
		CALL 	DESENHA_BIKE
		CALL	CRIA_OBS
		RET

;MOVE_ESQERDA:	Move a bicicleta para a esquerda
;		Entradas:
;		Saidas:
;		Efeitos: Movimenta a Bicicleta no ecra
MOVE_ESQUERDA:	MOV	R3, M[POS_BIKE_2]
		CMP	R3, 171Eh
		BR.Z	MOVE_ESQ_FIM
		CALL	APAGA_BIKE
		DEC	R1
		DEC	R2
		DEC	R3
		MOV	M[POS_BIKE_0], R1
		MOV	M[POS_BIKE_1], R2
		MOV	M[POS_BIKE_2], R3
		CALL	DESENHA_BIKE
MOVE_ESQ_FIM:	RET

;MOVE_ESQERDA:	Move a bicicleta para a direita
;		Entradas:
;		Saidas:
;		Efeitos: Movimenta a Bicicleta no ecra
MOVE_DIREITA:	MOV	R3, M[POS_BIKE_2]
		CMP	R3, 1733h
		BR.Z	MOVE_DIR_FIM
		CALL	APAGA_BIKE
		INC	R1
		INC	R2
		INC	R3
		MOV	M[POS_BIKE_0], R1
		MOV	M[POS_BIKE_1], R2
		MOV	M[POS_BIKE_2], R3
		CALL	DESENHA_BIKE
MOVE_DIR_FIM:	RET

;APAGA_BIKE	Funcao que apaga a bicicleta para que possa ser desenhada noutra posicao
;		Entradas:
;		Saidas:
;		Efeitos: Apaga a bicicleta
;R4 valor do simbolo " ", R3,R2,R1 valor da posicao da bicicleta
APAGA_BIKE: 	MOV	R1, M[POS_BIKE_0]
		MOV	R2, M[POS_BIKE_1]
		MOV	R3, M[POS_BIKE_2]
		MOV	R4, M[SIMBOLO_4]
		MOV	M[IO_CONTROLO], R3
		MOV	M[IO_WRITE], R4
		MOV	M[IO_CONTROLO], R2
		MOV	M[IO_WRITE], R4
		MOV	M[IO_CONTROLO], R1
		MOV	M[IO_WRITE], R4
		RET

;DESENHA_BIKE	Funcao que desenha a bicicleta no ecra
;		Entradas: R1 (Simbolo "0" da bicicleta)
;	   		  R2 (Simbolo "|" da bicicleta)
;	   		  R3 (Simbolo "0" da bicicleta)
;		Saidas:
;		Efeito:	desenha a bicicleta no ecra
DESENHA_BIKE:	MOV	R1, M[POS_BIKE_0]		;Posicao do primeiro "0"
		MOV	R2, M[POS_BIKE_1]		;Posicao do "|"
		MOV	R3, M[POS_BIKE_2]		;Posicao do segundo "0"
		MOV	R4, M[SIMBOLO_1]	;Simbolo "|"
		MOV	R5, M[SIMBOLO_3]	;Simbolo "0"
		MOV	M[IO_CONTROLO], R1
		MOV	M[IO_WRITE], R5
		MOV	M[IO_CONTROLO], R2
		MOV	M[IO_WRITE], R4
		MOV	M[IO_CONTROLO], R3
		MOV	M[IO_WRITE], R5
		RET

;REINICIA_JOGO:	Reinicia o jogo
;		Entradas:
;		Saidas:
;		Efeitos:
REINICIA_JOGO:	MOV	R7, M[SPEED_LV1]
		MOV	M[CURRENT_SPEED], R7
		MOV	M[LED_1], R0
		MOV	M[LED_2], R0
		MOV	M[LED_3], R0
		MOV	M[LED_4], R0
		MOV	R7, F000h
		MOV	M[WRITE_LED], R7
		RET

;LCD:		Inicia o LCD e reinicia a distancia actual
;		Entradas:
;		Saidas:
;		Efeitos:
LCD:		MOV	R6, MAX_LCD
		MOV	R7, 8010h
		CALL	STRING_LCD
RESET_DIST:	MOV	R6, DIST_LCD
		MOV	R7, 8000h
		CALL	STRING_LCD
		RET

;DISTANCIAS_LCD:Escreve a distancia actual no LCD
;		Entradas:
;		Saidas:
;		Efeitos:
DISTANCIAS_LCD:	MOV	R6, M[DIST]
		INC	M[DIST]
		CALL	DIST_AUX
		JMP.Z	DIGITO_2
		MOV	R7, 800Eh
		MOV	R6, DIST
		CALL	STRING_LCD
		JMP	FIM_DIST
DIGITO_2:	MOV	R6, M[DIST_2]
		INC	M[DIST_2]
		CALL	DIST_AUX
		BR.Z	DIGITO_3
		MOV	R5, M[DIST_CLEAR]
		MOV	M[DIST], R5
		MOV	R7, 800Dh
		MOV	R6, DIST_2
		CALL	STRING_LCD
		JMP	DISTANCIAS_LCD
DIGITO_3:	MOV	R6, M[DIST_3]
		INC	M[DIST_3]
		CALL	DIST_AUX
		BR.Z	DIGITO_4
		MOV	R5, M[DIST_CLEAR]
		MOV	M[DIST_2], R5
		MOV	R7, 800Ch
		MOV	R6, DIST_3
		CALL	STRING_LCD
		JMP	DIGITO_2
DIGITO_4:	MOV	R6, M[DIST_4]
		INC	M[DIST_4]
		CALL	DIST_AUX
		BR.Z	DIGITO_5
		MOV	R5, M[DIST_CLEAR]
		MOV	M[DIST_3], R5
		MOV	R7, 800Bh
		MOV	R6, DIST_4
		CALL	STRING_LCD
		JMP	DIGITO_3
DIGITO_5:	MOV	R6, M[DIST_5]
		INC	M[DIST_5]
		CALL	DIST_AUX
		BR.Z	FIM_DIST
		MOV	R5, M[DIST_CLEAR]
		MOV	M[DIST_4], R5
		MOV	R7, 800Ah
		MOV	R6, DIST_5
		CALL	STRING_LCD
		JMP	DIGITO_4
FIM_DIST:	RET

;DIST_AUX:	Funcao auxiliar para verificar quando deve reiniciar o digito da distancia actual
;		Entradas:
;		Saidas:
;		Efeitos:
DIST_AUX:	MOV	R7, '9'
		CMP	R6, R7
		RET

;RANDOM:	Funcao que ira tornar a posicao em que os obstaculos aparecem aleatoria
;		Entradas:
;		Saidas:
;		Efeito:
RANDOM:		MOV	R1, M[RANDOM_INICIAL]
		AND	R1, 0001h
		CMP	R1, R0
		BR.NZ	RANDOM_AUX
		ROR	M[RANDOM_INICIAL], 1
		BR	RANDOM_FIM
RANDOM_AUX:	MOV	R1, RANDOM_MASK
		XOR	M[RANDOM_INICIAL], R1
		ROR	M[RANDOM_INICIAL], 1
RANDOM_FIM:	MOV	R2, M[RANDOM_INICIAL]
		MOV	R3, 0100h
		DIV	R2, R3
		MOV	R3, 13
		DIV	R2, R3
		ADD	R2, 30
		RET

;MOVE_OBS:	Funcao utilizada para mover obstaculos
;		Entradas:
;		Saidas:
;		Efeito:	Desenha e apaga obstaculos no ecra
MOVE_OBS:	MOV	R6, TABELA
		ADD	R6, M[VECTOR_TAB_MOV]
		CALL	LIMPA_OBS
		MOV	R7, 0100h
		ADD	M[R6],R7
		MOV	R7, 1800h
		CMP	M[R6],R7
		BR.P	NAO_DESENHA
		CALL	DESENHA_OBS
NAO_DESENHA:	MOV	R4, M[NR_OBSTACULOS]
		CMP	M[VECTOR_TAB_MOV], R4
		BR.Z	MOVE_OBS_FIM
		INC	M[VECTOR_TAB_MOV]
		BR	MOVE_OBS
MOVE_OBS_FIM:	MOV	M[VECTOR_TAB_MOV], R0
		INC	M[NR_MOVIMENTOS]
		MOV	R1, 0006h
		CMP	M[NR_MOVIMENTOS], R1
		CALL.Z	CRIA_OBS_INICIO
		RET

;CRIA_OBS_INICIO:
;		Entradas:
;		Saidas:
;		Efeitos:
CRIA_OBS_INICIO:MOV	M[NR_MOVIMENTOS], R0
		MOV	R1, 2
		CMP	M[NR_OBSTACULOS], R1
		CALL.P	LEDS
		CALL	QUANTIDADE_OBS
CRIA_OBS:	MOV	R6, TABELA
		ADD	R6, M[VECTOR_TAB_DES]
		CALL	RANDOM
		MOV	R3, SIMBOLO_5
		MOV	M[R6], R2
		CALL	STRING
		INC	M[VECTOR_TAB_DES]
		MOV	R4, 4
		CMP	M[VECTOR_TAB_DES], R4
		BR.NZ	CRIA_OBS_FIM
		MOV	M[VECTOR_TAB_DES], R0
CRIA_OBS_FIM:	RET

;QUANTIDADE_OBS:
;		Entradas:
;		Saidas:
;		Efeitos:
QUANTIDADE_OBS: MOV	R1, 3
		CMP	M[NR_OBSTACULOS], R1
		BR.Z	NAO_INCREMENTA
		INC	M[NR_OBSTACULOS]
		RET

;NAO_INCREMENTA:
;		Entradas:
;		Saidas:
;		Efeitos:
NAO_INCREMENTA:	INC	M[OBS_ELIMINADOS]
		MOV	R7, M[OBS_ELIMINADOS]
		CMP	R7, 3
		BR.NP	NOT_LV2
		MOV	R5, FF00h
		MOV	M[WRITE_LED], R5
		MOV	R5, M[SPEED_LV2]
		MOV	M[CURRENT_SPEED], R5
NOT_LV1:	CMP	R7,7
		BR.NP	NOT_LV2
		MOV	R5, FFF0h
		MOV	M[WRITE_LED], R5
		MOV	R5, M[SPEED_LV3]
		MOV	M[CURRENT_SPEED], R5
NOT_LV2:	RET

;DESENHA_OBS:	Funcao utilizada para desenhar obstaculos
;		Entradas:
;		Saidas:
;		Efeitos:
DESENHA_OBS:	MOV	R3, SIMBOLO_5
		MOV	R2, M[R6]
		CALL	STRING_OBS
		RET

;LIMPA_OBS:	Funcao utilizada para apagar obstaculos
;		Entradas:
;		Saidas:
;		Efeitos:
LIMPA_OBS:	MOV	R3, SIMBOLO_6
		MOV	R2, M[R6]
		CALL	STRING_OBS
		RET

;STRING_OBS:
;		Entradas:
;		Saidas:
;		Efeitos:
STRING_OBS:	PUSH	R2
		PUSH	R3
		MOV	R4, FIM_TEXTO
CICLO_STR_OBS:	MOV	R5, M[R3]
		CMP	R4, R5
		BR.Z	FIM_STR_OBS
		CMP	M[POS_BIKE_0], R2
		JMP.Z	FIM_JOGO
		CMP	M[POS_BIKE_1], R2
		JMP.Z	FIM_JOGO
		CMP	M[POS_BIKE_2], R2
		JMP.Z	FIM_JOGO
		CALL	CARACTER
		INC	R2
		INC	R3
		BR	CICLO_STR_OBS
FIM_STR_OBS:	POP	R3
		POP	R2
		RET

;LEDS:		Funcao que executa o contador nos leds
;		Entradas: R1 com o valor Ah (valor que se segue ao 9 em hexadecimal)
;			  R2 com o valor do contador do respectivo led
;		Saidas:
;		Efeitos:
LEDS:		MOV	R1, Ah
		CMP	M[CONT_LED], R1
		BR.Z	LEDS_2
		MOV	R2, M[CONT_LED]
		MOV	M[LED_1], R2
		INC	M[CONT_LED]
		JMP	FIM_LED
LEDS_2:		MOV	M[CONT_LED], R0
		CMP	M[CONT_LED_2], R1
		BR.Z	LEDS_3
		MOV	R2, M[CONT_LED_2]
		MOV	M[LED_2], R2
		INC	M[CONT_LED_2]
		BR	LEDS
LEDS_3:		MOV	M[CONT_LED_2], R0
		CMP	M[CONT_LED_3], R1
		BR.Z	LEDS_4
		MOV	R2, M[CONT_LED_3]
		MOV	M[LED_3], R2
		INC	M[CONT_LED_3]
		BR	LEDS_2
LEDS_4:		MOV	M[CONT_LED_3], R0
		CMP	M[CONT_LED_4], R1
		BR.Z	FIM_LED
		MOV	R2, M[CONT_LED_4]
		MOV	M[LED_3], R2
		INC	M[CONT_LED_4]
FIM_LED:	RET

;FIM_JOGO:	Mensagem de fim do jogo quando o jogador perde
;		Entradas:
;		Saidas:
;		Efeito: Escreve a mensagem de Game Over no ecra
FIM_JOGO:	MOV	M[int1], R0
		CALL	DIST_MAXIMA
		CALL	CLEAR
		CALL	DIST_MAXIMA
		MOV	R3, FIM_JOGO_1
		MOV	R2, 0C22h
		CALL	STRING
		MOV	R3, FIM_JOGO_2
		MOV	R2, 0E11h
		CALL	STRING
RECOMECAR:	CMP	M[int1], R0
		BR.Z	RECOMECAR
		CALL	CLEAR
		MOV	M[int1], R0
		MOV	M[int0], R0
		MOV	M[intB], R0
		MOV	M[intT], R0
		MOV	R1, 1528h
		MOV	M[POS_BIKE_0], R1
		MOV	R1, 1628h
		MOV	M[POS_BIKE_1], R1
		MOV	R1, 1728h
		MOV	M[POS_BIKE_2], R1
		MOV	M[NR_OBSTACULOS], R0
		MOV	M[NR_MOVIMENTOS], R0
		MOV	M[OBS_ELIMINADOS], R0
		CALL	RESET_TABELA
		CALL	DIST_MAXIMA
		CALL	RESET_COUNTERS
		JMP	INICIO_JOGO

;RESET_TABELA:	Funcao auxiliar para recomecar o jogo
;		Entradas:
;		Saidas:
;		Efeitos:
RESET_TABELA:	MOV	M[VECTOR_TAB_MOV], R0
		MOV	M[VECTOR_TAB_DES], R0
		MOV	R6, TABELA
		MOV	R1, 5
RESET_CICLO:	MOV	M[R6], R0
		CMP	M[RESET_TAB], R1
		BR.NZ	INCREMENTA
		MOV	M[RESET_TAB], R0
		RET
INCREMENTA:	INC	M[RESET_TAB]
		INC	M[R6]
		BR	RESET_CICLO
		RET

;RESET_COUNTERS:
;		Entradas:
;		Saidas:
;		Efeitos:
RESET_COUNTERS:	MOV	R1, M[DIST_RESET]
		MOV	M[DIST], R1
		MOV	M[DIST_2], R1
		MOV	M[DIST_3], R1
		MOV	M[DIST_4], R1
		MOV	M[DIST_5], R1
		MOV	R1, 1
		MOV	M[CONT_LED],R1
		MOV	M[CONT_LED_2],R1
		MOV	M[CONT_LED_3],R1
		MOV	M[CONT_LED_4],R1
		RET

;DIST_MAXIMA:
;		Entradas:
;		Saidas:
;		Efeitos:
DIST_MAXIMA:	MOV	R1, M[DIST_MAX_5]
		CMP	M[DIST_5], R1
		JMP.P	SUBSTITUI
		CMP	M[DIST_5], R1
		JMP.N	DIST_MAX_FIM
DIST_MAXIMA_4:	MOV	R1, M[DIST_MAX_4]
		CMP	M[DIST_4], R1
		JMP.P	SUBSTITUI
		CMP	M[DIST_4], R1
		BR.N	DIST_MAX_FIM
DIST_MAXIMA_3:	MOV	R1, M[DIST_MAX_3]
		CMP	M[DIST_3], R1
		JMP.P	SUBSTITUI
		CMP	M[DIST_3], R1
		BR.N	DIST_MAX_FIM
DIST_MAXIMA_2:	MOV	R1, M[DIST_MAX_2]
		CMP	M[DIST_2], R1
		JMP.P	SUBSTITUI
		CMP	M[DIST_2], R1
		BR.N	DIST_MAX_FIM
DIST_MAXIMA_1:	MOV	R1, M[DIST_MAX]
		CMP	M[DIST], R1
		JMP.P	SUBSTITUI
		CMP	M[DIST], R1
		BR.N	DIST_MAX_FIM
DIST_MAX_FIM:	RET

;SUBSTITUI:
;		Entradas:
;		Saidas:
;		Efeitos:
SUBSTITUI:	MOV	R2, M[DIST]
		MOV	M[DIST_MAX], R2
		MOV	R7, 801Bh
		MOV	R6, DIST_MAX
		CALL	STRING_LCD
SUBSTITUI_2:	MOV	R2, M[DIST_2]
		MOV	M[DIST_MAX_2], R2
		MOV	R7, 801Ah
		MOV	R6, DIST_MAX_2
		CALL	STRING_LCD
SUBSTITUI_3:	MOV	R2, M[DIST_3]
		MOV	M[DIST_MAX_3], R2
		MOV	R7, 8019h
		MOV	R6, DIST_MAX_3
		CALL	STRING_LCD
SUBSTITUI_4:	MOV	R2, M[DIST_4]
		MOV	M[DIST_MAX_4], R2
		MOV	R7, 8018h
		MOV	R6, DIST_MAX_4
		CALL	STRING_LCD
SUBSTITUI_5:	MOV	R2, M[DIST_5]
		MOV	M[DIST_MAX_5], R2
		MOV	R7, 8017h
		MOV	R6, DIST_MAX_5
		CALL	STRING_LCD
		RET

;PAUSE:
;		Entradas:
;		Saidas:
;		Efeitos:
PAUSE:		MOV	M[intA], R0
		CALL	CLEAR_LCD
		MOV	R7, 8007h
		MOV	R6, PAUSA
		CALL	STRING_LCD
PAUSE_CICLO:	CMP	M[intA], R0
		BR.Z	PAUSE_CICLO
		CALL	CLEAR_LCD
		CALL	LCD
		MOV	R7, 800Eh
		MOV	R6, DIST
		CALL	STRING_LCD
		MOV	R7, 800Dh
		MOV	R6, DIST_2
		CALL	STRING_LCD
		MOV	R7, 800Ch
		MOV	R6, DIST_3
		CALL	STRING_LCD
		MOV	R7, 800Bh
		MOV	R6, DIST_4
		CALL	STRING_LCD
		MOV	R7, 800Ah
		MOV	R6, DIST_5
		CALL	STRING_LCD
		MOV	R7, 801Bh
		MOV	R6, DIST_MAX
		CALL	STRING_LCD
		MOV	R7, 801Ah
		MOV	R6, DIST_MAX_2
		CALL	STRING_LCD
		MOV	R7, 8019h
		MOV	R6, DIST_MAX_3
		CALL	STRING_LCD
		MOV	R7, 8018h
		MOV	R6, DIST_MAX_4
		CALL	STRING_LCD
		MOV	R7, 8017h
		MOV	R6, DIST_MAX_5
		CALL	STRING_LCD
		MOV	M[intA], R0
		RET

;/////////////////////////////////////////////////////////////////////////
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\FIM\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;/////////////////////////////////////////////////////////////////////////
