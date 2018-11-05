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
;===============================================================================
	;                VARIABLES DEL PROGRAMA
;===============================================================================	
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

;===============================================================================
;			RUTINAS USADAS EN EL SOFTWARE
;===============================================================================
	    
	    
	    
;===============================================================================	    
;       		inicia parametros para el programa	
;===============================================================================	    
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
	
	RETURN
	    
	    
	    
	    
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