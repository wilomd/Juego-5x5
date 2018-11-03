; FORMATO DEL PANEL
;		     0	 1   2   3   4 bits puertoB
;0	A   a	     1,  2,  3,  4,  5	
;1	B   b	     6,  7,  8,  9, 10
;2	C   c	    11, 12, 13, 14, 15
;3	D   d	    16, 17, 18, 19, 20
;4	E   e	    21, 22, 23, 24, 25
;puerto c	
	
; 1ra columna Animales solo bombillos 
; 
	
; 2da Columna Preguntas solo bombillos
	
; 25 bombillos no manejables en este programa por los momentos
	
; 25 pulsadores panel de Respuesta del teclado matricial
	
; 1 Pulsador de inicio del Sistema	

; 1 Salida de Audio para los Tonos (de acierto o respuesta Errada)

; comunicacion con un expansor de puertos o otro pic16f887

; Utilizando los bits 0, 1, 3, 4, 5 para encender los bombillos de los animales

	    
	List p=16f887
	#include <p16f887.inc>
	
	__CONFIG H'2007', H'3FFC' & H'3FF7' & H'3FFF' & H'3FFF' & H'3FFF' & H'3FFF' & H'3CFF' & H'3BFF' & H'37FF' & H'2FFF' & H'3FFF'
	__CONFIG H'2008', H'3EFF' & H'3FFF'	
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
ACTVSW	    EQU 0X40
CONTA_3	    EQU 0X41
	    
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
    
	ORG H'01'
	GOTO INICIO
	
	ORG 04H
	;HACER INT de reinicio o WD funcione....
		
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; esta trabajando cada fila es un animal y las columnas corresponden al valor 	
; numerico de c/u de las 5 respuestas correspondientes del animal, en el ejemplo
; se ve las posiciones de las respuestas de la matriz principal. solo esta primer
; animal con sus 5 posibles respuestas.	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ROTACIONPTOC
	ADDWF PCL,F
	DT 0X00, B'11111010', B'11111001',B'11110011',B'11101011',B'11011011'   
END_ROTACIONPTOC	
		
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
; ANIMAL1			
	DT  .1,	 .7,  .13, .19,  .25  ;Probar con estas respuestas solamente
; ANIMAL2
	DT  .4,	 .8,  .11,  .20,  .21
; ANIMAL3	
	DT  .0,	 .0,  .0,  .0,  .0
; ANIMAL4	
	DT  .0,	 .0,  .0,  .0,  .0
; ANIMAL5	
	DT  .0,	 .0,  .0,  .0,  .0
END_RESPUESTAS_1
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
;		    inicio de las Rutinas (call)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		

;===============================================================================
;			    RETARDO DE 20MS
;===============================================================================
;CONTA_2    EQU 0x20
;CONTA_1    EQU 0x21
	
RETARDO_20MS
;	RETURN       ; HABILITADO SOLO PARA DEBUG
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
; Calcula el OffSet, para calcular el desplazamiento en la matriz de respuesta y
; luego verificar si la respuesta es valida, si es correcta continuara el proceso
; en caso de no ser la respuesta se quedara esperando que sea oprimida la correcta
;debe llevar un contador para que realice este proceso N veces si nadie sigue con
;el juego debe reiniciarse y esperar a ser pulsado el inicio
;===============================================================================
	
OFFSETR
	MOVF	CONTAFIL,W	;CONTADOR DE NUMERO DE FILAS QUE AVANZO RESPUESTA
	MOVWF	FILNUM		;VARIABLE PARA CALCULAR POSICION DE LA RESPUESTA
	CLRF	NVECES		;INICIALIZA VARIABLE CONTEO

	MOVF	NVECES,W
SUM1	ADDLW	.5	    ; SUMA 5 POR CADA FILA DE DESPLAZAMIENTO EN MATRIZ
	DECFSZ	FILNUM,F
	GOTO	SUM1
	SUBLW	.5	    ; RESTA 5 PARA EL OFF SET EN CERO
	ADDWF	CONTACOL,W
	MOVWF	FILNUM
	MOVLW	.1	    ;RESTA 1 PARA EL OFF SET EN CERO
	SUBWF	FILNUM,W
	RETURN
			    ; SE DESPLAZARA W VECES EN LA TABLA Y VERIFICA
			    ; SI LA TECLA PULSADA CORRESPONDE A LA RESPUESTA
	
;===============================================================================
;	RUTINA DE ENCENDER LA SECUENCIA DE LUCES DE ANIMALES y PREGUNTAS
;       USANDO 5 BITS PUERTO A y D 
;===============================================================================
;ANIMALES    EQU 0X30
;PREGUNTA    EQU 0X31
;CONTAFIL    EQU 0X35
;CONTACOL    EQU 0X36		
			    
VERIFICA1   
	CALL CNTCOL	    ;llamado al contador de columnas para off set
	BCF	STATUS,C
	RLF	PREGUNTA,F   ; ROTA A LA IZQUIERDA BIT PRENDER BOMBILLO 
	MOVF PREGUNTA,W ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
	SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO REINICIA PROGRAMA
	BTFSS STATUS,Z
	GOTO ENCENDER

	MOVLW .1          ;inicializa las preguntas para proximo animal
	MOVWF PREGUNTA
		    
VERIFICA	
	CALL CNTFIL
	BCF	STATUS,C
	RLF	ANIMALES,F   ; ROTA A LA IZQUIERDA BIT PRENDER BOMBILLO 
	MOVF ANIMALES,W ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
	SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO REINICIA PROGRAMA
	BTFSS STATUS,Z
	GOTO ENCENDER
	    ;CALL INICIA     ; DEBERIA SER EL PROGRAMA A RESET 		    

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
	
;==============================================================================	
; rutinas para calcular la posicion de la respuesta x pregunta y fila 
;con una variable, estas rutinas se activan al cambiar la pregunta o el 
;animal.
	
;==============================================================================	
	
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
;TECLA	    EQU 0x23
Teclado_LeeOrdenTecla      
	BANK0
	MOVLW .1
	MOVWF TECLA
	MOVWF ACTVSW
	MOVF ACTVTKLA,W	    ; PRIMERA COLUMNA CON CERO PARA MATRIZ DEL TECLADO
			    ; B'11111010' 0FAH VALOR ENVIADO POR LA FILA
			    ; por el pull up se activa con cero logico
CHECK_ROW
			    
	MOVWF PORTC	    ;ENVIA EL VALOR DE W POR EL PUERTO

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
	MOVF	LAST_TECLA,W	; VALOR DE LA VARIABLE ES 25
	SUBWF	TECLA,W		; RESTA 26 MENOS LA TECLA PULSADA
	BTFSC	STATUS,C	; SI X < 25 NO SE PULSO LA ULTIMA TECLA
	GOTO	TECLA_NO_PULSE
	INCF	ACTVSW	
	MOVF	ACTVSW,W
	CALL	ROTACIONPTOC 
	GOTO CHECK_ROW
	
TECLA_NO_PULSE
	GOTO Teclado_LeeOrdenTecla

SAVE_VALUE
	MOVF TECLA,W           ; Variable TECLA contiene el valor pulsado	
	MOVWF RESPUESTA		; W trae el valor de TECLA

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

	CALL OFFSETR	
	CALL RESPUESTAS_1   ; SE DESPLAZA EN LA TABLA Y SE TRAE EL EN DATO
	SUBWF RESPUESTA	    ;
	
	BTFSC STATUS,Z
	goto tklbuena
	GOTO tklmala
			    ;RETORNA SI LA RESPUESTA ES ERRADA y espera la 
			    ;correcta x tiempo
tklbuena
	CLRF  PORTB	 
	MOVLW .1	    
	MOVWF CORRECTO

	CALL TONOBUENO

	BANK0		    ; SE AGREGA UN RETARDO PARA QUE SUELTE LA TECLA PULSADA
	MOVLW .80
	MOVWF CONTA_3
	CALL RETARDO_20MS
	NOP
	DECFSZ CONTA_3,F
	GOTO $-.3
	RETURN

tklmala
	CALL TONOERROR
	GOTO Teclado_LeeOrdenTecla
	
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	
;       		inicia parametros para el programa	
	
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&	

INICIO
	
	DigPort			;inicializa los puertos en digital  
	BANK1
	MOVLW B'10011111'
	MOVWF TRISB	    ;Puerto B ENTRADA PARA EL TECLADO y Boton de inicio
	
	CLRF TRISC	    ;PUERTO C SALIDA PARA EL TECLADO
	CLRF TRISA	    ;PUERTO A SALIDA BOMBILLOS ANIMAL
	CLRF TRISD	    ;PUERTO D SALIDA BOMBILLOS PREGUNTA
	
	ClSPort		    ; MACRO DE INICIALIZAR PUERTOS
	MOVLW 0XFF	    ; 
	BANK1
	MOVWF WPUB	    ;HABILITANDO EL PUERTO B CON  PULL UP
	
	
	
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
	
	MOVLW B'11111010'	;ACTIVA BIT EN CERO PARA ROTAR EN TECLADO
	MOVWF ACTVTKLA

	
	
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&	
INICIA		
	;CALL GUSANOPANT  ;INICIALIZA SECUENCIA PARA LLAMAR LA ATENCION DEL JUEGO
	
	CALL RETARDO_20MS   ;USAR INT RB CAMBIO ESTADO PARA QUE SALTE AL INICIO?
;	BTFSC PORTB,7	    ; BOTON DE INICIO SISTEMA  PREGUNTA SI ESTA EN CERO
;	GOTO INICIA
	
; cambiar esto con uno de los botones de Puerto B para trabajar con la int
; de cambio de estado y dejar el PIC en Sleep 	
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
;			    ANIMALES Y PREGUNTAS	

; Inicia el ciclo de preguntas de cada uno de los animales	

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
	BSF PORTA,0       ;PRIMER ANIMAL
	BSF PORTD,0	  ;PRIMERA PREGUNTA ACTIVA
	
SISTPREG	    ;sistema de preguntas y respuestas

	CALL Teclado_LeeOrdenTecla	;ESPERA HASTA QUE SE PULSE UNA TECLA
					;REPITE HASTA QUE SE PULSE LA TECLA 
					;CORRECTA PARA AVANZAR A LA SIGUIENTE
					;PREGUNTA
PROXIMO
	CLRF PORTB				
	CALL VERIFICA1	;SIGUIENTE PREGUNTA Y/O ANIMAL
			;PREGUNTA SI ES EL FINAL DEL CONTADOR DE LAS PREGUNTAS 
			;EN CASO DE NO SER REPITE BUCLE PARA LA PROXIMA PREGUNTA
	GOTO SISTPREG

; ESTE PROGRAMA NO CONTIENE:
	;EL MANEJO DE LOS BOMBILLOS DE LA MATRIZ DE RESPUESTA
	;TONO DE RESPUESTA BUENO O MALO
	;ILUMINACION PARA LLAMAR LA ATENCION DEL PUBLICO (gusano)
	;USO DE INTERRUPCIONES 
	;USO DEL PERRO GUARDIAN PARA REINICIAR EL PROGRAMA EN CASO DE FALLA
	;no esta usando bajo consumo con Sleep.
	
;==============================================================================
TONOERROR
	; GENERA TONO DE ERROR
	; VUELVE A ESPERAR PULZAR TECLAS CORRECTA
;==============================================================================
;Se generan 3 tonos 
;Con 4MHz de frequencia la frecuencia mínima de PWM es de 244 Hz, que se ubica 
;entre las notas musicales de la octava 4 (ni an graves ni tan agudas)
;PWM en modo Simple Output solo es posible en el pin P1A (RC2)
;==============================================================================
INIT_FRQ
	BANK1
	MOVLW .212 
	MOVWF PR2	    ;CARGA LA FRECUENCIA INICIAL DEL PWM (212 HZ) NOTA RE(4)
	
	CALL CONFIG_PWM	    ;PARAMETROS PARA EL MODO PWM
	CALL INIT_PWM	    ;INICIA EL PWM

	MOVLW .255	    
	CALL RETARDO_NOTAS_20MS
	
	MOVLW .224	    
	CALL LOAD_FREQ	    ;NOTA DO#(4)
	
	MOVLW .255
	CALL RETARDO_NOTAS_20MS   
	
	MOVLW .238	    
	CALL LOAD_FREQ	    ;NOTA DO(4)
	
	MOVLW .255
	CALL RETARDO_NOTAS_20MS
	MOVLW .255
	CALL RETARDO_NOTAS_20MS
	
	CALL DISABLE_PWM
	
	RETURN
	
;==============================================================================
;			CONFIGURA EL MODO PWM
;==============================================================================
CONFIG_PWM
	BANK1
	BSF TRISC,2	    ;PONE EL PIN P1A COMO ENTRADA PARA MANTENER NACTIVO EL PWM
	BANK0
	MOVLW B'00111100'   
	MOVWF CCP1CON	    ;MODO PWM CON P1A,P1B,P1C,P1D ACTIVOS EN ALTO
	
	MOVLW B'00111111'
	MOVWF CCPR1L	    ;DUTY CYCLE AL 25%(?)
	
	BCF PIR1,TMR2IF	    ;SE LIMPIA BANDERA DEL TIMER2
	
	MOVLW B'00000011'
	MOVWF T2CON	    ;PREESCALADOR A 16

	RETURN

;==============================================================================
;			INICIA EL PWM
;==============================================================================
INIT_PWM
	BANK1
	BCF TRISC,2	    ;PIN PIA COMO SALIDA PARA EL PWM
	BSF T2CON,TMR2ON    ;SE INICIA EL TIMER
	RETURN
	
;==============================================================================
;			DESACTIVA EL PWM
;==============================================================================
DISABLE_PWM
	BANK1
	BSF TRISC,2
	RETURN 

;==============================================================================
;		CARGA UN VALOR EN PR2 PARA EL CAMBIO DE FREQ
;==============================================================================
LOAD_FREQ
	BANK1
	MOVWF PR2
	RETURN

RETARDO_NOTAS_20MS
	BANK0
	MOVWF CONTA_2
	MOVLW .250
	MOVWF CONTA_1
	NOP
	DECFSZ CONTA_1,F
	GOTO $-.2
	DECFSZ CONTA_2,F
	GOTO $-.6
	RETURN 

TONOBUENO

	BANK1
	MOVLW .238 
	MOVWF PR2	    ;CARGA LA FRECUENCIA INICIAL DEL PWM (212 HZ) NOTA DO(4)
	
	CALL CONFIG_PWM	    ;PARAMETROS PARA EL MODO PWM
	CALL INIT_PWM	    ;INICIA EL PWM

	MOVLW .255	    
	CALL RETARDO_NOTAS_20MS
	
	MOVLW .212	    
	CALL LOAD_FREQ	    ;NOTA RE (4)
	
	MOVLW .255
	CALL RETARDO_NOTAS_20MS   
	
	MOVLW .188	    
	CALL LOAD_FREQ	    ;NOTA MI (4)
	
	MOVLW .255
	CALL RETARDO_NOTAS_20MS
	MOVLW .150
	CALL RETARDO_NOTAS_20MS
	
	MOVLW .238	    
	CALL LOAD_FREQ	    ;NOTA DO (4)
	
	MOVLW .80
	CALL RETARDO_NOTAS_20MS
	
	MOVLW .188	    
	CALL LOAD_FREQ	    ;NOTA MI(4)
	
	MOVLW .255
	CALL RETARDO_NOTAS_20MS
	MOVLW .150
	CALL RETARDO_NOTAS_20MS
	
	CALL DISABLE_PWM
	
	RETURN	
	
	END
	
	
	
	
	