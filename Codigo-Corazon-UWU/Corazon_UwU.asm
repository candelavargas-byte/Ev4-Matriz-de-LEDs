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

	clr figura ; inicializa la variable en 0 

main:

    sbis PINB, PB0
    ldi figura, 0 


    sbis PINB, PB1
    ldi figura, 1


   cpi figura, 1         ; Lee el estado guardado para
    breq mostrar_corazon ; decidir qué figura mantener en pantalla
    rjmp mostrar_cara


mostrar_cara:

    ; Repetimos el barrido para mantener la imagen
    ldi indice, 0

bucle_cara:

    rcall mostrar_fila_cara

    inc indice

    cpi indice, 8
    brlo bucle_cara

    rjmp main


mostrar_corazon:

    ldi indice, 0

bucle_corazon:

    rcall mostrar_fila_corazon

    inc indice

    cpi indice, 8
    brlo bucle_cara

    rjmp main


;Filas Cara

mostrar_fila_cara:

    ldi temp, 0xFF
    out PORTD, temp

    ldi temp, 0x00
    out PORTC, temp

    in temp, PORTB
    andi temp, 0b11110011
    out PORTB, temp

    ldi mascara, 1
    mov temp, indice

desplaza_cara:

    tst temp
    breq fila_cara_lista

    lsl mascara
    dec temp

    rjmp desplaza_cara


fila_cara_lista:

    in temp, PORTD
    com mascara
    and temp, mascara
    out PORTD, temp


    ldi ZH, HIGH(uwu*2)
    ldi ZL, LOW(uwu*2)

    add ZL, indice
    clr temp
    adc ZH, temp

    lpm dato, Z

    rcall escribir_columnas
    rcall delay
    ret

	;Filas corazon

mostrar_fila_corazon:

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

desplaza_corazon:

    tst temp
    breq fila_corazon_lista

    lsl mascara
    dec temp

    rjmp desplaza_corazon


fila_corazon_lista:

    in temp, PORTD
    com mascara
    and temp, mascara
    out PORTD, temp

;Patron del corazon

    ldi ZH, HIGH(corazon*2)
    ldi ZL, LOW(corazon*2)

    add ZL, indice
    clr temp
    adc ZH, temp

    lpm dato, Z


    rcall escribir_columnas

    rcall DELAY

    ret

escribir_columnas:

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

uwu:
    .db 0b00000000, 0b00110110, 0b00110110, 0b00000000, 0b01001001, 0b01001001, 0b00110110, 0b00000000

;Corazon

corazon:
    .db 0b00000000, 0b01100110, 0b11111111, 0b11111111, 0b01111110, 0b00111100, 0b00011000, 0b00000000


delay:

    ldi r21, 30

D1:
    ldi r22, 50

D2:
    dec r22
    brne D2

    dec r21
    brne D1

    ret
