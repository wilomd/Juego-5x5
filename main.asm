; FORMATO DEL PANEL
	
;	A   a	     1,  2,  3,  4,  5	
;	B   b	     6,  7,  8,  9, 10
;	C   c	    11, 12, 13, 14, 15
;	D   d	    16, 17, 18, 19, 20
;	E   e	    21, 22, 23, 24, 25
	
	
; 1ra columna Animales solo bombillos 
	
; 2da Columna Preguntas solo bombillos
	
; 25 bombillos y 25 pulsadores panel de Respuesta

; 1 Pulsador de inicio del Sistema	

; 1 Salida de Audio para Tono (acierto o respuesta Errada
	    
	
	List p=16f887
	#include <p16f887.inc>
	
	__CONFIG H'2007', H'3FFC' & H'3FF7' & H'3FFF' & H'3FFF' & H'3FFF' & H'3FFF' & H'3CFF' & H'3BFF' & H'37FF' & H'2FFF' & H'3FFF'
	__CONFIG H'2008', H'3EFF' & H'3FFF'	

;ver 01.1
;===============================================================================
;             Definicion de las macros para cambiar de bancos
;===============================================================================

BANK0	MACRO
	BCF STATUS,5
	BCF STATUS,6
	ENDM
	
BANK1	MACRO
	BSF STATUS,5
	BCF STATUS,6
	ENDM
	
BANK2	MACRO
	BCF STATUS,5
	BSF STATUS,6
	ENDM
	
BANK3	MACRO
	BSF STATUS,5
	BSF STATUS,6
	ENDM
	
ClSPort MACRO
	BANK0
	CLRF PORTC
	CLRF PORTB
	CLRF PORTA
	CLRF PORTD
	CLRF PORTE
	ENDM
	
DigPort MACRO
	BANK3
 	CLRF ANSEL
	CLRF ANSELH
	ENDM
	
	
CONTA_2	    EQU 0x20
CONTA_1	    EQU 0x21
BIT	    EQU 0x22
TECLA	    EQU 0x23
LAST_TECLA  EQU 0x24
RESPUESTA   EQU 0x25
CORRECTO    EQU 0x26
CONT_WIN    EQU 0x27
    
ANIMALES    EQU 0X30
PREGUNTA    EQU 0X31
TEMP	    EQU 0X32
CONTPRGTA   EQU 0X33	    
PUERTOD	    EQU	0X34	   
CONTAFIL    EQU	0X35	    
 
	
	ORG H'01'
	GOTO INICIO
	
	ORG 04H
	;HACER INT de reinicio o WD funcione....
	
CONVERT_HEX
	ADDWF PCL,F
	DT  .1,  .2, .3, .4, .5
	DT  .6,  .7, .8, .9,.10
	DT .11, .12,.13,.14,.15
	DT .16, .17,.18,.19,.20
	DT .21, .22,.23,.24,.25
END_CONVERT_HEX
	 
RESPUESTAS_1 
	ADDWF PCL,F
	DT .1,.7,.23,.14,.25
	DT .21,.17,.3,.24,.10
	DT .16,.22,.3,.9,.5
	DT .16,.22,.3,.9,.5
	DT .16,.22,.3,.9,.5
END_RESPUESTAS_1
	
RETARDO_20MS
	BANK0
	MOVLW .20
	MOVWF CONTA_2
	MOVLW .250
	MOVWF CONTA_1
	NOP
	DECFSZ CONTA_1,F
	GOTO $-.2
	DECFSZ CONTA_2,F
	GOTO $-.6
	RETURN 
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	
;       		inicia parametros para el programa	
	
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&	

INICIO
	
	DigPort			;inicializa los puertos en digital  

	BANK1
	MOVLW 01FH	     
	MOVWF TRISE	    ;PUERTO E ENTRADA para Pulsador de Inicio Programa
	MOVWF TRISB	    ;PUERTO B ENTRADA PARA EL TECLADO
	CLRF TRISC	    ;PUERTO C SALIDA 

	CLRF TRISA	    ;PUERTO A SALIDA BOMBILLOS ANIMAL
	CLRF TRISD	    ;PUERTO D SALIDA BOMBILLOS PREGUNTA
	
; RECOMENDABLE EN EL TECLADO PUERTO B ENTRADA PARA USAR PULL UP
	
	BANK0
	
	CLRF CONT_WIN
	
	MOVLW .1
	MOVWF ANIMALES
	MOVWF PREGUNTA
	MOVWF PUERTOD
	
	MOVLW .25
	MOVWF CONTPRGTA
	MOVWF LAST_TECLA
	
	MOVLW 00H
	MOVWF CONTAFIL

	ClSPort	    ; MACRO DE INICIALIZAR PUERTOS
	
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&	
	
	
INICIA		
    ;CALL GUSANOPANT     ;INICIALIZA SECUENCIA PARA LLAMAR LA ATENCION DEL JUEGO
	
	CALL RETARDO_20MS   ;USAR INT RB CAMBIO ESTADO PARA QUE SALTE AL INICIO?
	BTFSS PORTE,0	    ; BOTON DE INICIO SISTEMA  PREGUNTA SI ESTA EN CERO
	GOTO INICIA
	
; cambiar esto con uno de los botones de Puerto B para trabajar con la int
; de cambio de estado y dejar el PIC en Sleep 	
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
;			    ANIMALES Y PREGUNTAS	

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
	BSF PORTA,0       ;PRIMER ANIMAL
	BSF PORTD,0	  ;PRIMERA PREGUNTA ACTIVA
	
SISTPREG
	;CALL ESPERAR POR TECLA CORRECTA DE LA PREGUNTA X
	;TONO DE CORRECTO O INCORRECTO ESTA EN LA ESPERA DE LA TECLA 
	
	;TABLA DE 25 DATOS CON EL VALOR DE LA RESPUESTA CORRECTA
	;PARA FUNCIONAR CON EN CONTADOR DE PREGUNTAS
	
	;LIMPIAR EL WD PARA QUE NO REINICIE EL PROGRAMA
	
	
	DECFSZ CONTPRGTA,F  ;DECREMENTA  CONTADOR PARA LAS 25 PREGUNTAS
	GOTO PROXIMO
	GOTO INICIA
	
PROXIMO
	CALL VERIFICA1	;SIGUIENTE PREGUNTA Y/O ANIMAL
			;PREGUNTA SI ES EL FINAL DEL CONTADOR DE LAS PREGUNTAS EN CASO 
			; DE NO SER REPITE BUCLE PARA LA PROXIMA PREGUNTA
	GOTO SISTPREG
	
	;COMPLETAR LAS 25 PREGUNTAS
	

	
	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
	;mejorar estas  rutinas de preguntas en las filas
	; por esto es mejor usar INT de cambio de estado en puerto B
	
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::	
LOOP	
	; Fila 1 de Preguntas
	BTFSC PORTB,0    ; mismo valor de pregunta
	GOTO LOOP
	CALL VALIDATE_ANSWER
	BCF STATUS,Z
	MOVLW .1
	SUBWF CORRECTO
	
	BTFSS STATUS,Z
	GOTO LOOP	;falta tono de error
	
	CLRF CORRECTO
	INCF CONT_WIN    ;falta tono de bueno
	MOVLW B'00000001'
	MOVWF PORTD
	
	;estas 5 preguntas son muy parecidas hacer una sola generica 
	; que funcione igual las 5 veces del  programa
	
LOOP2
	; Fila 2 de Preguntas
	BTFSC PORTB,1
	GOTO LOOP2
	CALL VALIDATE_ANSWER
	BCF STATUS,Z
	MOVLW .1
	SUBWF CORRECTO
	BTFSS STATUS,Z
	GOTO LOOP2
	CLRF CORRECTO
	INCF CONT_WIN
	MOVLW B'00000011'
	MOVWF PORTD
	
LOOP3
	; Fila 3 de Preguntas
	BTFSC PORTB,2
	GOTO LOOP3
	CALL VALIDATE_ANSWER
	BCF STATUS,Z
	MOVLW .1
	SUBWF CORRECTO
	BTFSS STATUS,Z
	GOTO LOOP3
	CLRF CORRECTO
	INCF CONT_WIN
	MOVLW B'00000111'
	MOVWF PORTD

LOOP4
	; Fila 4 de Preguntas
	BTFSC PORTB,3
	GOTO LOOP4
	CALL VALIDATE_ANSWER
	BCF STATUS,Z
	MOVLW .1
	SUBWF CORRECTO
	BTFSS STATUS,Z
	GOTO LOOP4
	CLRF CORRECTO
	INCF CONT_WIN
	MOVLW B'00001111'
	MOVWF PORTD	
LOOP5
	; Fila 5 de Preguntas
	BTFSC PORTB,4
	GOTO LOOP5
	CALL VALIDATE_ANSWER
	BCF STATUS,Z
	MOVLW .1
	SUBWF CORRECTO
	BTFSS STATUS,Z
	GOTO LOOP5
	CLRF CORRECTO
	INCF CONT_WIN
	MOVLW B'00011111'
	MOVWF PORTD

CLEAR
	CLRF PORTD
	GOTO LOOP
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
;		    inicio de las Rutinas (call)
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
;		RUTINA DE ENCENDER LUCES DE PREGUNTAS Y ANIMALES
		;USANDO 5 BITS PUERTO A y D 
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
VERIFICA1	    BCF	STATUS,C
		    RLF	PREGUNTA,F   ; ROTA A LA IZQUIERDA BIT PRENDER BOMBILLO 
		    MOVF PREGUNTA,W ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
		    SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO REINICIA PROGRAMA
		    BTFSS STATUS,Z
		    GOTO ENCENDER
		   ; RETURN
		    ;GOTO SIGUIENTE ANIMAL
		    
		    MOVLW .1          ;inicializa las preguntas para proximo animal
		    MOVWF PREGUNTA
		    
VERIFICA	    BCF	STATUS,C
		    RLF	ANIMALES,F   ; ROTA A LA IZQUIERDA BIT PRENDER BOMBILLO 
		    MOVF ANIMALES,W ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
		    SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO REINICIA PROGRAMA
		    BTFSS STATUS,Z
		    GOTO ENCENDER
		    CALL INICIA   ; DEBERIA SER EL PROGRAMA A RESET 		    

ENCENDER	
		    MOVF PREGUNTA,W
		    MOVWF PORTD
		    MOVF ANIMALES,W 
		    MOVWF PORTA
		    RETURN

;==============================================================================
;                   VALIDA SI LA RESPUESTA ES CORRECTA
;==============================================================================

VALIDATE_ANSWER	
	CALL READ_HEX
	MOVWF RESPUESTA
	CALL Teclado_EsperaDejePulsar
	MOVF CONT_WIN,W
	CALL RESPUESTAS_1
	SUBWF RESPUESTA
	BTFSS STATUS,Z
	RETURN
	MOVLW .1
	MOVWF CORRECTO
	RETURN
;==============================================================================
;LEER EL VALOR EN TECLADO 5x5
;==============================================================================

READ_HEX
	CALL Teclado_LeeOrdenTecla
	BTFSS STATUS,C
	GOTO READ_HEX_END
	CALL CONVERT_HEX
	BSF STATUS,C
READ_HEX_END
	RETURN
;===============================================================================
;                      ANTIREBOTE PARA LOS PULSADORES
;===============================================================================
Teclado_EsperaDejePulsar
	BANK0
	MOVLW 0x1F
	MOVWF PORTB
	
Teclado_SigueEsperando
	CALL RETARDO_20MS
	MOVF PORTB,W
	SUBLW 0x1F
	BTFSS STATUS,Z
	GOTO Teclado_SigueEsperando
	CLRF PORTC
	RETURN
;===============================================================================
;               SCAN TECLAS PARA SELECION DE LA RESPUESTA
;===============================================================================

Teclado_LeeOrdenTecla
	BANK0
	CLRF TECLA
	MOVLW B'11111110'
CHECK_ROW
	MOVWF PORTC
CHECK_COL_1
	BTFSS PORTB,0
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_COL_2
	BTFSS PORTB,1
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_COL_3
	BTFSS PORTB,2
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_COL_4
	BTFSS PORTB,3
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_COL_5
	BTFSS PORTB,4
	GOTO SAVE_VALUE
	INCF TECLA,F	
END_COL
	MOVLW LAST_TECLA
	SUBWF TECLA,W
	BTFSC STATUS,C
	GOTO TECLA_NO_PULSE
	BSF STATUS,C
	RLF PORTC,W
	GOTO CHECK_ROW
	
TECLA_NO_PULSE
	BCF STATUS,C
	GOTO KEYBOARD_END
SAVE_VALUE
	MOVF TECLA,W
	BSF STATUS,C
KEYBOARD_END
	RETURN
		
	
	END

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	
; rutinas a cambiar o mejorar antes de subirlas al programa general

	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	GUSANOPANT
	
	; rutina de encendido de los bombillos para llamar la atencion del
	; publico
	
	
encendolinea
	
	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
	; Automatizando la rutina
	 
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::	

; variable que inicie en 0 hasta 4 para el bit de pregunta
; o a partir de el call hacer el llamado	
	
LOOP	
	; Fila 1 de Preguntas

	
	BTFSC   PORTB,0    ; mimo valor de pregunta
	GOTO    LOOP
	
	
; hacer un llamado aqui ? y todo es la rutina ?
teclafila
	
	CALL VALIDATE_ANSWER
	BCF STATUS,Z
	MOVLW .1
	SUBWF CORRECTO
	BTFSS STATUS,Z

	GOTO LOOP	;retorna si no es la tecla / falta tono de error
	
	CLRF CORRECTO
	INCF CONT_WIN    ;falta tono de bueno
	GOTO SIGFILA
RETORNA	MOVF PUERTOD,W
	MOVWF PORTD

	GOTO LOOP

	

SIGFILA BSF	STATUS,C
	RLF	PUERTOD,F   ; ROTA A LA IZQUIERDA BIT  
	MOVF PUERTOD,W	    ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
	SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO 
	BTFSS STATUS,Z
	GOTO RETORNA 
CLEAR	CLRF PORTD
	GOTO LOOP	    ;inicia las preguntas nueva mente
	
	
; la  rutina terminaria aqui ojo
	
;problemas de no cerrar el ciclo del llamado ojo
	    