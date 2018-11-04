;Programa del pic esclavo I2C
;Se manejan interrupciones I2C
	

;FALTANTE!!!!
	;DEFINIR PINES DE SALIDA PARA CADA PREGUNTA
	;DEFINIR LA TABLA DE COMPARACION DE CADA PREGUNTA PARA PRENDER LOS BOMBILLOS
	;MANEJAR LOS ERRORES EN I2C
	
	LIST   P=PIC16F887
	;List p=16f887
	#include <p16f887.inc>
	;
	
	
	__CONFIG H'2007', H'3FFC' & H'3FF7' & H'3FFF' & H'3FFF' & H'3FFF' & H'3FFF' & H'3CFF' & H'3BFF' & H'37FF' & H'2FFF' & H'3FFF'
	__CONFIG H'2008', H'3EFF' & H'3FFF'	

;===============================================================================
;             Definicion de las macros para cambiar de bancos
;===============================================================================
BANK0	MACRO
	BCF STATUS,5 ;PUERTO DPUERTO D
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
	
ROTABOM	    EQU  0X20
	    
DATO	    EQU	 0X21	    
DATO1	    EQU  0X22
DATO2	    EQU  0X23
DATO4	    EQU  0X24	    
 
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	ORG H'0'
	GOTO INICIO
	
	ORG 0x04
	BANK0
	BTFSS PIR1,SSPIF    ;INTERRUPCIÓN I2C?
	GOTO END_INT	
	BCF PIR1,SSPIF	    ;LIMPIAR FLAG DE INTERRUPCION
	
	
	
	
;===============================================================================
;             MANEJO DE INTERRUPCIÓN I2C COMO ESCLAVO
;===============================================================================
I2C_INT
	BANK1
	BTFSC SSPSTAT,R_W   ;ES LECTURA O ESCRITURA?
	GOTO END_INT
	BTFSS SSPSTAT,BF    ;EL BUFFER TIENE DATOS?
	GOTO END_INT	    
	BTFSS SSPSTAT,D_A   ;ES DIRECCIÓN O DATO?
	GOTO I2C_ADDRESS    ;RUTINA DE LECTURA DE DIRECCIÓN
	BANK0
	MOVF SSPBUF,W	    ;SE LEE EL DATO
	MOVWF PORTD
	BANK1
	BCF SSPSTAT,BF	    ; SE LIMPIA BANDERA Y ENVÍA ACK
	GOTO END_INT
I2C_ADDRESS
	BANK0
	MOVF SSPBUF,W
END_INT
	RETFIE

;Equivalencia numerica de los bombillos	
 
BombilloResp
	ADDWF PCL,F
	DT  .0,  .1,  .2,   .3, .4 
	    ;RA0 RA1  RA2  RA3  RA4
	    
	DT  .5,  .6,   .7,  .8, .9 
	    ;RA5 RA6  RA7  RB0  RB1
	    
	DT  .10, .11, .12, .13, .14
	    ;RB2 RB3  RB4  RB5  RB6
	    
	DT .15,  .16, .17, .18, .19
	    ;RB7 RD0  RD1  RD2  RD3
	    
	DT  .20, .21, .22, .23, .24	
	    ;RD4 RD5  RD6  RD7  RE0
END_BombilloResp
	    
	    
GusanoHrztl
	ADDWF PCL,F    
	DT  .00, .01, .02, .03, .04
	DT  .09, .08, .07, .06, .05
	DT  .10, .11, .12, .13, .14	
	DT  .19, .18, .17, .16, .15 
	DT  .20, .21, .22, .23, .24
END_GusanoHrztl
	
GusanoDiagnl
	ADDWF PCL,F
	DT  .00, .01, .05, .10, .06
	DT  .02, .03, .07, .11, .15
	DT  .20, .16, .12, .08, .04
	DT  .09, .13, .17, .21, .22
	DT  .18, .14, .19, .23, .24
END_GusanoDiagnl

GusanoVertcl
	ADDWF PCL,F
	DT  .00, .05, .10, .15, .20
	DT  .01, .06, .11, .16, .21
	DT  .02, .07, .12, .17, .22
	DT  .03, .08, .13, .18, .23
	DT  .04, .09, .14, .19, .24
END_GusanoVertcl	


SALIDAPTO
	ADDWF PCL,F
	DT .01, .02, .04, .08, .10
	
	DT .20, .40, .80, .01, .02
	
	DT .04, .08, .10, .20, .40
	
	DT .80, .01, .02, .04, .08
	
	DT .10, .20, .40, .80, .01
END_SALIDAPTO

	
;===============================================================================
;             INICIO
;===============================================================================	
INICIO
	BANK3
	DigPort
	
	BANK1
	CLRF TRISD
	CLRF TRISB
	CLRF TRISA
	MOVLW B'0001'
	MOVWF TRISD
	
	MOVLW B'00011000'
	MOVWF TRISC
	
	BSF PIE1,3	    ;HABILITA INTERRUPCIONES I2C
	
	BANK0
	ClSPort
	
	MOVLW B'11000000'   ;HABILITA INTERRUPCIONES GENERALES
	MOVWF INTCON
	
	MOVLW B'11000000'   ;DIRECCIÓN DEL EESCLAVO I2C
	CALL I2C_INIT_SLAVE
	
	GOTO GUSANO1
LOOP
	SLEEP
	GOTO LOOP
	
	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
	

;ROTACION DE LOS PUERTOS PARA HACER EL LLAMADO DE ATENCION DEL JUEGO HABILITANDO
; LOS RELES DE LOS BOMBILLOS CON 1 LOGICO
	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	

	MOVLW B'11000000'   ;HABILITA INTERRUPCIONES GENERALES
	MOVWF INTCON
	CALL GusanoHrztl
	
	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
; LECTURA DEL PUERTO A ENCENDER EL BOMBILLO POR RANGOS,  SE SELECCIONA EL PUERTO
; CON ESTOS VALORES [0,..7] Pto A, [8,..15] Pto B, [16..23] Pto D, [24] Pto E
; ESTA FUNCION ES PARA ENCENDER EL ACIERTO Y EL LLAMADO DE ATENCION
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
PROGRAMA	
	;MOVLW .16
	MOVWF DATO     ; CARGA EN DATO EL VALOR DE W
	MOVF  DATO,W	
	SUBLW .07	; SI es menor se ejecuta puerto A     
	BTFSS STATUS,C  ; C = 1 W ? k
	GOTO OTROPTO

	MOVF  DATO,W
	CALL SALIDAPTO 
	MOVWF PORTA
	;CALL RETARDO_3SEGUNDOS
	RETURN
	
OTROPTO	
	MOVF  DATO,W
	SUBLW .15	; SI es menor se ejecuta puerto B
	BTFSS STATUS,C  ; C = 1 W ? k
	GOTO OTROPTO1
	CALL SALIDAPTO 
	MOVWF PORTB
	;CALL RETARDO_3SEGUNDOS
	RETURN

OTROPTO1
	MOVF  DATO,W
	SUBLW .23	; SI es menor se ejecuta puerto D
	BTFSS STATUS,C  ; C = 1 W ? k
	GOTO OTROPTO2
	CALL SALIDAPTO 
	MOVWF PORTD
	;CALL RETARDO_3SEGUNDOS
	RETURN

OTROPTO2
	MOVF  DATO,W    ; SI es 24 se ejecuta puerto E
	CALL SALIDAPTO 
	MOVWF PORTE
	;CALL RETARDO_3SEGUNDOS
	RETURN

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
GUSANO1
	CLRF DATO1
OTRO	MOVF  DATO,W
	CALL GusanoHrztl
	CALL PROGRAMA
	INCF DATO
	GOTO OTRO
	
GUSANO2 	
	MOVLW .24 
	MOVWF DATO
OTRO1	MOVF  DATO,W
	CALL GusanoHrztl
	CALL PROGRAMA
	DECF DATO
	GOTO OTRO1
	
GUSANO3
	CLRF DATO1
OTRO2	MOVF  DATO,W
	CALL GusanoDiagnl
	CALL PROGRAMA
	INCF DATO
	GOTO OTRO2
	
GUSANO4 	
	MOVLW .24 
	MOVWF DATO
OTRO3	MOVF  DATO,W
	CALL GusanoDiagnl
	CALL PROGRAMA
	DECF DATO
	GOTO OTRO3	
GUSANO5
	CLRF DATO1
OTRO4	MOVF  DATO,W
	CALL GusanoVertcl
	CALL PROGRAMA
	INCF DATO
	GOTO OTRO4
	
GUSANO6 	
	MOVLW .24 
	MOVWF DATO
OTRO5	MOVF  DATO,W
	CALL GusanoVertcl
	CALL PROGRAMA
	DECF DATO
	GOTO OTRO5
	
	RETURN
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
ON_GANADOR	

	
	
	; DEBE TRAER EN W EL DATO A ENCENDER EN LA MATRIZ 5X5
	MOVF  DATO,W
	CALL PROGRAMA
	RETURN
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
	
	
	
	#include "I2C.INC"
	END