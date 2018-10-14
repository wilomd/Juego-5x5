	List p=16f887
	#include <p16f887.inc>
	__CONFIG H'2007', H'3FFC' & H'3FF7' & H'3FFF' & H'3FFF' & H'3FFF' & H'3FFF' & H'3CFF' & H'3BFF' & H'37FF' & H'2FFF' & H'3FFF'
	__CONFIG H'2008', H'3EFF' & H'3FFF'	

	
	 
;===============================================================================
;Definicion de las macros para cambiar de bancos
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
	
CONTA_2	 EQU 0x20
CONTA_1	 EQU 0x21
BIT	 EQU 0x22
TECLA	 EQU 0x23
LAST_TECLA EQU 0x24
	ORG H'0'
	GOTO INICIO

CONVERT_HEX
	ADDWF PCL,F
	DT .1,.2,.3,.4,.5
	DT .6,.7,.8,.9,.10
	DT .11,.12,.11,.12
	DT .13,.14,.14,.16
END_CONVERT_HEX
	
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
	
INICIO
	BANK3
	CLRF ANSEL
	CLRF ANSELH
	BANK1
	CLRF TRISD
	BANK0
	CLRF PORTB
	CLRF PORTC
	CLRF PORTA
	CLRF PORTD
	CLRF PORTE
	CALL TecladoInicializa
LOOP	

	BTFSC PORTC,0
	GOTO LOOP
	CALL READ_HEX
	MOVWF PORTD
	CALL Teclado_EsperaDejePulsar
	GOTO LOOP
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
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
	
TecladoInicializa
	BANK1
	MOVLW B'00000000'
	MOVWF TRISB
	MOVLW 0x1F
	MOVWF TRISC
	BANK0
	MOVLW .25
	MOVWF LAST_TECLA
	RETURN

Teclado_EsperaDejePulsar
	BANK0
	MOVLW 0x00
	MOVWF PORTB
Teclado_SigueEsperando
	CALL RETARDO_20MS
	MOVF PORTB,W
	SUBLW 0x00
	BTFSS STATUS,Z
	GOTO Teclado_SigueEsperando
	RETURN

Teclado_LeeOrdenTecla
	
	BANK0
	CLRF TECLA
	MOVLW B'11111110'
CHECK_ROW
	MOVWF PORTB
CHECK_COL_1
	BTFSS PORTC,0
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_COL_2
	BTFSS PORTC,1
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_COL_3
	BTFSS PORTC,2
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_COL_4
	BTFSS PORTC,3
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_COL_5
	BTFSS PORTC,4
	GOTO SAVE_VALUE
	INCF TECLA,F	
END_COL
	MOVLW LAST_TECLA
	SUBWF TECLA,W
	BTFSC STATUS,C
	GOTO TECLA_NO_PULSE
	BSF STATUS,C
	RLF PORTB,W
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