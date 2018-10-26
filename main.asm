; FORMATO DEL PANEL
;		     0	 1   2   3   4 bits puertoB
;0	A   a	     1,  2,  3,  4,  5	
;1	B   b	     6,  7,  8,  9, 10
;2	C   c	    11, 12, 13, 14, 15
;3	D   d	    16, 17, 18, 19, 20
;4	E   e	    21, 22, 23, 24, 25
;puerto c	
	
; 1ra columna Animales solo bombillos 
	
; 2da Columna Preguntas solo bombillos
	
; 25 bombillos no manejables en este programa por los momentos
	
; 25 pulsadores panel de Respuesta del teclado matricial
	
; 1 Pulsador de inicio del Sistema	

; 1 Salida de Audio para los Tonos (de acierto o respuesta Errada)

; comunicacion con un expansor de puertos o otro pic16f887
	
	    
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
TEMP0	    EQU	0X28
TEMP1	    EQU	0X29

ANIMALES    EQU 0X30
PREGUNTA    EQU 0X31
TEMP	    EQU 0X32
CONTPRGTA   EQU 0X33	    
PUERTOD	    EQU	0X34	   
CONTAFIL    EQU	0X35
CONTACOL    EQU	0X36    
ACTVTKLA    EQU	0X37
NVECES	    EQU 0X38
FILNUM	    EQU 0X39	    
 
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
    
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
	
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; esta trabajando cada fila es un animal y las columnas corresponden al valor 	
; numerico de c/u de las 5 respuestas correspondientes del animal, en el ejemplo
; se ve las posiciones de las respuestas de la matriz principal. solo esta primer
; animal con sus 5 posibles respuestas.	
RESPUESTAS_1 
	ADDWF PCL,F	
			
	DT  .1,	 .7,  .14, .19,  .23  ;Probar con estas respuestas solamente
	DT  .0,	 .0,  .0,  .0,  .0
	DT  .0,	 .0,  .0,  .0,  .0
	DT  .0,	 .0,  .0,  .0,  .0
	DT  .0,	 .0,  .0,  .0,  .0
END_RESPUESTAS_1
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
;		    inicio de las Rutinas (call)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		

;===============================================================================
;			    RETARDO DE 20MS
;===============================================================================
RETARDO_20MS
	RETURN       ; HABILITADO SOLO PARA DEBUG
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

;===============================================================================
;		RUTINA DE ENCENDER LUCES DE PREGUNTAS Y ANIMALES
		;USANDO 5 BITS PUERTO A y D 
;===============================================================================
VERIFICA1	    CALL CNTCOL
		    BCF	STATUS,C
		    RLF	PREGUNTA,F   ; ROTA A LA IZQUIERDA BIT PRENDER BOMBILLO 
		    MOVF PREGUNTA,W ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
		    SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO REINICIA PROGRAMA
		    BTFSS STATUS,Z
		    GOTO ENCENDER
		   ; RETURN
		    ;GOTO SIGUIENTE ANIMAL
		    
		    MOVLW .1          ;inicializa las preguntas para proximo animal
		    MOVWF PREGUNTA
		    
VERIFICA	    CALL CNTFIL
		    BCF	STATUS,C
		    RLF	ANIMALES,F   ; ROTA A LA IZQUIERDA BIT PRENDER BOMBILLO 
		    MOVF ANIMALES,W ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
		    SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO REINICIA PROGRAMA
		    BTFSS STATUS,Z
		    GOTO ENCENDER
		    CALL INICIA     ; DEBERIA SER EL PROGRAMA A RESET 		    

ENCENDER	
		    MOVF PREGUNTA,W
		    MOVWF PORTD
		    MOVF ANIMALES,W 
		    MOVWF PORTA
		    RETURN

;==============================================================================
;			LEER EL VALOR EN TECLADO 5x5
; asigna un valor a la tecla pulsada entre 1 y 25 con la tabla CONVERT_HEX
;==============================================================================
READ_HEX
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
;	BANK0
;	MOVLW 0x1F
;	MOVWF PORTB
	
Teclado_SigueEsperando
	CALL RETARDO_20MS

	MOVF PORTB,W
	SUBLW 0x1F      

	BTFSS STATUS,Z
	GOTO Teclado_SigueEsperando
	CLRF PORTC
	RETURN
;===============================================================================
; LEE SI SE PULSO UNA TECLAS EN SELECION DE LA RESPUESTA, Y VERIFICA CUAL DE LAS 
;25 TECLAS FUE PULSADA PARA COMPARAR CON SU RESPUESTA, CON EL PUERTO B EN PULL UP
;AL PRESIONAR EL PULSADOR SE DEBE LEER UNA CERO LOGICO
;===============================================================================

Teclado_LeeOrdenTecla
	BANK0
	MOVLW .1
	MOVWF TECLA
	MOVF ACTVTKLA,W	    ; PRIMERA COLUMNA CON CERO PARA MATRIZ DEL TECLADO
			    ; B'11111110' VALOR ENVIADO POR LA FILA
			    ; por el pull up se activa con cero logico
CHECK_ROW
	MOVWF PORTC	    ;ENVIA EL VALOR DE W POR EL PUERTO

CHECK_COL_1
	BTFSC PORTB,0
	GOTO SAVE_VALUE
	INCF TECLA,F

CHECK_COL_2
	BTFSC PORTB,1
	GOTO SAVE_VALUE
	INCF TECLA,F
	
CHECK_COL_3
	BTFSC PORTB,2
	GOTO SAVE_VALUE
	INCF TECLA,F
	
CHECK_COL_4
	BTFSC PORTB,3
	GOTO SAVE_VALUE
	INCF TECLA,F

CHECK_COL_5
	BTFSC PORTB,4
	GOTO SAVE_VALUE
	INCF TECLA,F	

END_COL
	MOVF  LAST_TECLA,W	; VALOR DE LA VARIABLE ES 25
	SUBWF TECLA,W		; RESTA 25 MENOS LA TECLA PULSADA
	BTFSC STATUS,C		; SI X < 25 NO SE PULSO LA ULTIMA TECLA
	
	GOTO TECLA_NO_PULSE
	
	BSF STATUS,C
	RLF PORTC,W	        ;INCREMENTA PARA LA SIGUENTE FILA
	GOTO CHECK_ROW
	
	
TECLA_NO_PULSE
	
	MOVLW B'11111110'
	MOVF ACTVTKLA,W
	CLRF TECLA
	
	GOTO CHECK_ROW

SAVE_VALUE
	MOVF TECLA,W           ; Variable TECLA contiene el valor pulsado
;	BSF STATUS,C
;	RETURN
;===============================================================================
;==============================================================================
; VALIDA SI LA RESPUESTA ES CORRECTA, CONVIERTE EL VALOR DE LA TECLA PULSADA
; EN UN VALOR EN HEX, PARA COMPARAR CON 
; DEBE VERIFICAR CON RESPECTO AL ANIMAL ASIGNADO LAS RESPUESTA		    
;==============================================================================
;CONTAFIL    EQU	0X35
;CONTACOL    EQU	0X36
;NVECES	     EQU        0X38	
;RESPUESTA   EQU	0x25	
VALIDATE_ANSWER	
	
	MOVWF RESPUESTA		; W trae el valor de TECLA

	MOVF	CONTAFIL,W
	MOVWF	FILNUM
	
	
	MOVLW	.0
	MOVWF	NVECES
	MOVF	NVECES,W
SUM1	ADDLW	.5 
	DECFSZ	FILNUM,F
	GOTO	SUM1
	SUBLW	.5
	ADDWF	CONTACOL,W
	MOVWF	FILNUM
	MOVLW	.1
	SUBWF	FILNUM,W	    
			    ; SE DESPLAZARA W VECES EN LA TABLA Y VERIFICA
			    ; SI LA TECLA PULSADA CORRESPONDE A LA RESPUESTA
	
	CALL RESPUESTAS_1   ; SE DESPLAZA EN LA TABLA Y SE TRAEL EN DATO
	SUBWF RESPUESTA
	BTFSS STATUS,Z
	GOTO Teclado_LeeOrdenTecla
			    ;RETORNA SI LA RESPUESTA ES ERRADA y espera la 
			    ;correcta x tiempo
	
		
	MOVLW .1
	MOVWF CORRECTO
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
	CLRF TRISC	    ;PUERTO C SALIDA PARA EL TECLADO
	CLRF TRISA	    ;PUERTO A SALIDA BOMBILLOS ANIMAL
	CLRF TRISD	    ;PUERTO D SALIDA BOMBILLOS PREGUNTA
	;MOVLW 0XFF	    ; 
	;MOVWF WPUB	    ;BITS DEL PUERTO B CON  PULL UP
	
	
	BANK0
	MOVLW .1
	MOVWF ANIMALES
	MOVWF PREGUNTA
	MOVWF PUERTOD
	MOVWF CONTAFIL  
	MOVWF CONTACOL
	
	MOVLW .25
	MOVWF CONTPRGTA
	
	MOVLW .26
	MOVWF LAST_TECLA
	
	MOVLW 00H
	MOVWF CONT_WIN
	
	MOVLW B'11111110'	;ACTIVA BIT EN CERO PARA ROTAR EN TECLADO
	MOVWF ACTVTKLA

	ClSPort	    ; MACRO DE INICIALIZAR PUERTOS
	
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&	
	
	
INICIA		
	;CALL GUSANOPANT  ;INICIALIZA SECUENCIA PARA LLAMAR LA ATENCION DEL JUEGO
	
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
	
SISTPREG	    ;sistema de preguntas y respuestas

	CALL Teclado_LeeOrdenTecla	;ESPERA HASTA QUE SE PULSE UNA TECLA
	
PROXIMO
	CALL VERIFICA1	;SIGUIENTE PREGUNTA Y/O ANIMAL
			;PREGUNTA SI ES EL FINAL DEL CONTADOR DE LAS PREGUNTAS EN CASO 
			; DE NO SER REPITE BUCLE PARA LA PROXIMA PREGUNTA
	GOTO SISTPREG
	
	
	NOP
	NOP 
	NOP
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
; rutinas para calcular la posicion de la respuesta x pregunta y fila 
;con una variable, estas rutinas se activan al cambiar la pregunta o el 
;animal.
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
CNTFIL	MOVLW  .1			; ANIMALES
	ADDWF CONTAFIL,F
	MOVLW  .6
	SUBWF CONTAFIL,W
	BTFSS STATUS,Z
	RETURN
	MOVLW .0
	MOVWF CONTAFIL
	RETURN

CNTCOL	MOVLW .1			;PREGUNTAS
	ADDWF CONTACOL,F
	MOVLW  .6 
	SUBWF CONTACOL,W
	BTFSS STATUS,Z
	RETURN
	MOVLW .0
	MOVWF CONTACOL
	RETURN
	
	END
	
; ESTE PROGRAMA NO CONTIENE:
	;EL MANEJO DE LOS BOMBILLOS DE LA MATRIZ DE RESPUESTA
	;TONO DE RESPUESTA BUENO O MALO
	;ILUMINACION PARA LLAMAR LA ATENCION DEL PUBLICO
	;USO DE INTERRUPCIONES ni pull up
	;USO DEL PERRO GUARDIAN PARA REINICIAR EL PROGRAMA EN CASO DE FALLA
	;no esta usando bajo consumo con Sleep.
	
	
	
	;todo lo que esta en las proximas lineas se elimino 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	BCF STATUS,Z
	MOVLW .1
	SUBWF CORRECTO
	BTFSS STATUS,Z
	
	;RETFIE
	
	CLRF CORRECTO
	INCF CONT_WIN    ;falta tono de bueno
	GOTO SIGFILA
RETORNA	MOVF PUERTOD,W
	MOVWF PORTD
	CALL CNTCOL
	RETFIE

	

SIGFILA BSF	STATUS,C
	RLF	PUERTOD,F   ; ROTA A LA IZQUIERDA BIT  
	MOVF PUERTOD,W	    ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
	SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO 
	BTFSS STATUS,Z
	GOTO RETORNA 
CLEAR	CLRF PORTD
	CALL CNTFIL
	RETFIE	    ;inicia las preguntas nueva mente
	
	
	;CALL ESPERAR POR TECLA CORRECTA DE LA PREGUNTA X
	;TONO DE CORRECTO O INCORRECTO ESTA EN LA ESPERA DE LA TECLA 
	
	;TABLA DE 25 DATOS CON EL VALOR DE LA RESPUESTA CORRECTA
	;PARA FUNCIONAR CON EN CONTADOR DE PREGUNTAS
	
	;LIMPIAR EL WD PARA QUE NO REINICIE EL PROGRAMA
	
	
	DECFSZ CONTPRGTA,F  ;DECREMENTA  CONTADOR PARA LAS 25 PREGUNTAS
	GOTO PROXIMO
	GOTO INICIA
	
	
	
	
	MOVLW .4
	SUBWF temp,W
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	
; rutinas a cambiar o mejorar antes de subirlas al programa general

	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	GUSANOPANT
	
	; rutina de encendido de los bombillos para llamar la atencion del
	; publico
	
	
encendolinea
	

	
; la  rutina terminaria aqui ojo
	
;problemas de no cerrar el ciclo del llamado ojo
	MOVF	PREGUNTA
	MOVWF	TEMP1
	ANDLW	0X1F	    ;PREGUNTAR POR BITS 0,1,2,3,4
	    
	
	

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
	
	
;############################################################3	
	
	
	
	
	
		movf	PORTB,W
	movwf	TEMP0	    
	SUBWF	PREGUNTA,W
	BTFSS   STATUS,Z    ; SI LA RESPUESTA ES Z ESTA EN LA FILA
	GOTO	TONOERROR
	GOTO	LOOP

	

TONOERROR
	; GENERA TONO DE ERROR
	; VUELVE A ESPERAR PULZAR TECLAS CORRECTA
	NOP
	RETFIE
LOOP	
