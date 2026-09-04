.include "m328pdef.inc"          ; Definiciones del ATmega328P

.org 0x0000                     ; Direccion de inicio
    rjmp inicio                 ; Salto al programa


inicio:

    ; Configuro el Stack porque uso RCALL y RET

    ldi r16, HIGH(RAMEND)       ; Parte alta del Stack
    out SPH, r16                ; La guardo

    ldi r16, LOW(RAMEND)        ; Parte baja del Stack
    out SPL, r16                ; La guardo


    ; PB0 a PB5 son las primeras 6 filas

    ldi r16, 0b00111111         ; PB0-PB5 como salida
    out DDRB, r16               ; Configuro PORTB


    ; PORTD completo son las 8 columnas

    ldi r16, 0b11111111         ; Todos los bits como salida
    out DDRD, r16               ; Configuro PORTD


    ; PC0 y PC1 son las ultimas dos filas
    ; PC2 y PC3 son los botones

    ldi r16, 0b00000011         ; PC0-PC1 salida, PC2-PC3 entrada
    out DDRC, r16               ; Configuro PORTC


    ; Apago las primeras filas

    ldi r16, 0b00000000         ; Todo en cero
    out PORTB, r16              ; Filas apagadas


    ; Activo pull-up de los dos botones

    ldi r16, 0b00001100         ; PC2 y PC3 quedan en 1
    out PORTC, r16              ; Activo pull-up


    ; Apago las columnas al empezar

    ldi r16, 0b11111111         ; Todas las columnas en alto
    out PORTD, r16              ; Ningun LED prende


    clr r17                     ; r17 = 0
                                ; 0 = sonrisa
                                ; 1 = guiño


main:

    sbis PINC, PC2              ; Reviso boton de sonrisa
    clr r17                     ; Si se apreta pongo sonrisa


    sbis PINC, PC3              ; Reviso boton del guiño
    ldi r17, 1                  ; Si se apreta pongo guiño


    tst r17                     ; Veo si r17 vale cero
    breq mostrar_sonrisa        ; Si vale 0 voy a sonrisa


    rcall carita_guinando       ; Si vale 1 muestro guiño
    rjmp main                   ; Vuelvo al principio


mostrar_sonrisa:

    rcall carita_sonriendo      ; Muestro la sonrisa
    rjmp main                   ; Vuelvo a mirar botones



carita_sonriendo:

    ; Voy armando la cara fila por fila

    ldi r18, 0                  ; Fila 1
    ldi r20, 0b00111100         ; ..1111..
    rcall mostrar_fila


    ldi r18, 1                  ; Fila 2
    ldi r20, 0b01000010         ; .1....1.
    rcall mostrar_fila


    ldi r18, 2                  ; Fila 3
    ldi r20, 0b10100101         ; 1.1..1.1
    rcall mostrar_fila


    ldi r18, 3                  ; Fila 4
    ldi r20, 0b10000001         ; 1......1
    rcall mostrar_fila


    ldi r18, 4                  ; Fila 5
    ldi r20, 0b10100101         ; 1.1..1.1
    rcall mostrar_fila


    ldi r18, 5                  ; Fila 6
    ldi r20, 0b10011001         ; 1..11..1
    rcall mostrar_fila


    ldi r18, 6                  ; Fila 7
    ldi r20, 0b01000010         ; .1....1.
    rcall mostrar_fila


    ldi r18, 7                  ; Fila 8
    ldi r20, 0b00111100         ; ..1111..
    rcall mostrar_fila


    ret                         ; Termine la sonrisa



carita_guinando:

    ; Es la misma cara pero cambio el ojo

    ldi r18, 0                  ; Fila 1
    ldi r20, 0b00111100         ; ..1111..
    rcall mostrar_fila


    ldi r18, 1                  ; Fila 2
    ldi r20, 0b01000010         ; .1....1.
    rcall mostrar_fila


    ldi r18, 2                  ; Fila 3
    ldi r20, 0b10101101         ; 1.1.11.1
                                ; Aca esta el guiño
    rcall mostrar_fila


    ldi r18, 3                  ; Fila 4
    ldi r20, 0b10000001         ; 1......1
    rcall mostrar_fila


    ldi r18, 4                  ; Fila 5
    ldi r20, 0b10100101         ; 1.1..1.1
    rcall mostrar_fila


    ldi r18, 5                  ; Fila 6
    ldi r20, 0b10011001         ; 1..11..1
    rcall mostrar_fila


    ldi r18, 6                  ; Fila 7
    ldi r20, 0b01000010         ; .1....1.
    rcall mostrar_fila


    ldi r18, 7                  ; Fila 8
    ldi r20, 0b00111100         ; ..1111..
    rcall mostrar_fila


    ret                         ; Termine el guiño



mostrar_fila:

    rcall filas_off             ; Primero apago las filas


    ; Yo dibujo con 1 = LED prendido
    ; pero la columna activa trabaja en 0

    com r20                     ; Invierto los bits
    out PORTD, r20              ; Mando las 8 columnas


    ; Las primeras 6 filas estan en PORTB

    cpi r18, 6                  ; Comparo numero de fila con 6
    brsh fila_portc             ; Las ultimas dos van por PORTC


    ldi r21, 0b00000001         ; Empiezo con un solo 1
    mov r22, r18                ; Copio el numero de fila


mover_fila:

    tst r22                     ; Veo si ya llegue a la fila
    breq fila_lista             ; Si llegue la prendo


    lsl r21                     ; Muevo el 1 a la izquierda
    dec r22                     ; Resto una posicion
    rjmp mover_fila             ; Repito


fila_lista:

    out PORTB, r21              ; Activo una sola fila

    rcall delay_corto           ; La dejo prendida un momento

    rcall filas_off             ; La vuelvo a apagar

    ret                         ; Sigo con la proxima fila



fila_portc:

    ; Quedan solamente fila 7 y fila 8

    cpi r18, 6                  ; Veo si es fila 7
    breq fila_7                 ; Si r18 = 6 uso PC0


    ; Si no, es la fila 8

    in r21, PORTC               ; Leo PORTC
    ori r21, 0b00000010         ; Pongo PC1 en 1
    out PORTC, r21              ; Prendo fila 8

    rcall delay_corto           ; Espero un poco
    rcall filas_off             ; La apago

    ret



fila_7:

    in r21, PORTC               ; Leo PORTC
    ori r21, 0b00000001         ; Pongo PC0 en 1
    out PORTC, r21              ; Prendo fila 7

    rcall delay_corto           ; Espero un poco
    rcall filas_off             ; La apago

    ret



filas_off:

    clr r21                     ; r21 = 0
    out PORTB, r21              ; Apago las primeras 6 filas


    in r21, PORTC               ; Leo PORTC
    andi r21, 0b11111100        ; Apago PC0 y PC1
                                ; No toco los botones

    out PORTC, r21              ; Guardo el cambio

    ret



delay_corto:

    ; Retardo corto para el multiplexado

    ldi r24, 20                 ; Primer contador


delay_1:

    ldi r25, 250                ; Segundo contador


delay_2:

    dec r25                     ; Voy restando
    brne delay_2                ; Mientras no sea cero sigo


    dec r24                     ; Resto el contador grande
    brne delay_1                ; Si falta sigo


    ret                         ; Termino el retardo