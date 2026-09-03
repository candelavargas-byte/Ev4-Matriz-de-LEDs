.include "m328pdef.inc"

.def temp  = r16
.def dato  = r17
.def indice = r18
.def figura = r19
.def mascara = r20

.org 0x0000
    rjmp reset

reset:

;Stack Pointer
    ldi temp, HIGH(RAMEND)
    out SPH, temp

    ldi temp, LOW(RAMEND)
    out SPL, temp


    ldi temp, 0xFF
    out DDRD, temp

    ; Todas las filas inicialmente apagadas
    ldi temp, 0xFF
    out PORTD, temp

    ldi temp, 0x3F
    out DDRC, temp

    ; Columnas apagadas
    ldi temp, 0x00
    out PORTC, temp

    ldi temp, 0b00001100
    out DDRB, temp

    ; Pull-up para botones
    ; PB0 y PB1 = 1
    ; PB2 y PB3 = 0
    ldi temp, 0b00000011
    out PORTB, temp


main:

    sbis PINB, PB0
    rjmp SELECCION_CARA


    sbis PINB, PB1
    rjmp SELECCION_CORAZON


    ; Si no se presiona ningun boton
    ; mantenemos la carita
    rjmp MOSTRAR_CARA


SELECCION_CARA:

    ; figura = 0
    ldi figura, 0

    rjmp MOSTRAR_CARA


SELECCION_CORAZON:

    ; figura = 1
    ldi figura, 1

    rjmp MOSTRAR_CORAZON


MOSTRAR_CARA:

    ; Repetimos el barrido para mantener la imagen
    ldi indice, 0

BUCLE_CARA:

    rcall MOSTRAR_FILA_CARA

    inc indice

    cpi indice, 8
    brlo BUCLE_CARA

    rjmp MAIN


MOSTRAR_CORAZON:

    ldi indice, 0

BUCLE_CORAZON:

    rcall MOSTRAR_FILA_CORAZON

    inc indice

    cpi indice, 8
    brlo BUCLE_CORAZON

    rjmp MAIN


;Filas Cara

MOSTRAR_FILA_CARA:

    ldi temp, 0xFF
    out PORTD, temp

    ldi temp, 0x00
    out PORTC, temp

    in temp, PORTB
    andi temp, 0b11110011
    out PORTB, temp


    ldi mascara, 1

    mov temp, indice

DESPLAZA_CARA:

    tst temp
    breq FILA_CARA_LISTA

    lsl mascara
    dec temp

    rjmp DESPLAZA_CARA


FILA_CARA_LISTA:

    ; Fila seleccionada = LOW
    in temp, PORTD
    com mascara
    and temp, mascara
    out PORTD, temp

;Patron cara

    ldi ZH, HIGH(UWU*2)
    ldi ZL, LOW(UWU*2)

    add ZL, indice
    clr temp
    adc ZH, temp

    lpm dato, Z

    rcall ESCRIBIR_COLUMNAS

    ; Pequeño tiempo de encendido
    rcall DELAY

    ret

	;Filas corazon

MOSTRAR_FILA_CORAZON:

    ldi temp, 0xFF
    out PORTD, temp

    ldi temp, 0x00
    out PORTC, temp

    in temp, PORTB
    andi temp, 0b11110011
    out PORTB, temp

	;Seleccion fila

    ldi mascara, 1

    mov temp, indice

DESPLAZA_CORAZON:

    tst temp
    breq FILA_CORAZON_LISTA

    lsl mascara
    dec temp

    rjmp DESPLAZA_CORAZON


FILA_CORAZON_LISTA:

    ; Fila seleccionada = LOW
    in temp, PORTD
    com mascara
    and temp, mascara
    out PORTD, temp

;Patron del corazon

    ldi ZH, HIGH(CORAZON*2)
    ldi ZL, LOW(CORAZON*2)

    add ZL, indice
    clr temp
    adc ZH, temp

    lpm dato, Z


    rcall ESCRIBIR_COLUMNAS

    rcall DELAY

    ret

ESCRIBIR_COLUMNAS:


    mov temp, dato
    andi temp, 0b00111111

    out PORTC, temp

    sbrc dato, 6
    sbi PORTB, PB2

    sbrs dato, 6
    cbi PORTB, PB2


    sbrc dato, 7
    sbi PORTB, PB3

    sbrs dato, 7
    cbi PORTB, PB3

    ret


;Cara uwu

UWU:
    .db 0b00000000
    .db 0b00110110
    .db 0b00110110
    .db 0b00000000
    .db 0b01001001
    .db 0b01001001
    .db 0b00110110
    .db 0b00000000

;Corazon

CORAZON:

    .db 0b00000000
    .db 0b01100110
    .db 0b11111111
    .db 0b11111111
    .db 0b01111110
    .db 0b00111100
    .db 0b00011000
    .db 0b00000000


DELAY:

    ldi r21, 30

D1:
    ldi r22, 50

D2:
    dec r22
    brne D2

    dec r21
    brne D1

    ret
