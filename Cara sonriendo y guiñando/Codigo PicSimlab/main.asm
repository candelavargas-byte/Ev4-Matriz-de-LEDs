.include "m328pdef.inc"          ; Definiciones del ATmega328P

.org 0x0000                     ; Donde empieza el programa
    rjmp inicio                 ; Voy al inicio


inicio:

    ; Configuro el Stack porque uso RCALL y RET

    ldi r16, HIGH(RAMEND)       ; Cargo parte alta del Stack
    out SPH, r16                ; La guardo en SPH

    ldi r16, LOW(RAMEND)        ; Cargo parte baja del Stack
    out SPL, r16                ; La guardo en SPL


    ; Pines que usa la matriz de PICSimLab

    sbi DDRB, PB2               ; D10 = CS como salida
    sbi DDRB, PB3               ; D11 = DIN como salida
    sbi DDRB, PB5               ; D13 = CLK como salida


    ; Configuro los dos botones como entrada

    cbi DDRD, PD2               ; D2 como entrada
    cbi DDRD, PD3               ; D3 como entrada

    sbi PORTD, PD2              ; Activo pull-up del boton 1
    sbi PORTD, PD3              ; Activo pull-up del boton 2


    ; Estado inicial de las señales

    sbi PORTB, PB2              ; CS empieza en 1
    cbi PORTB, PB5              ; CLK empieza en 0


    ; Configuro el controlador de la matriz

    ldi r18, 0x09               ; Registro Decode Mode
    ldi r19, 0x00               ; Sin decodificacion
    rcall enviar_registro       ; Envio los datos


    ldi r18, 0x0A               ; Registro de brillo
    ldi r19, 0x03               ; Brillo bajo
    rcall enviar_registro


    ldi r18, 0x0B               ; Scan Limit
    ldi r19, 0x07               ; Uso las 8 filas
    rcall enviar_registro


    ldi r18, 0x0F               ; Display Test
    ldi r19, 0x00               ; Test apagado
    rcall enviar_registro


    ldi r18, 0x0C               ; Registro Shutdown
    ldi r19, 0x01               ; Enciendo la matriz
    rcall enviar_registro


    rcall carita_sonriendo      ; Arranca mostrando sonrisa



main:

    sbis PIND, PD2              ; Reviso boton de sonrisa
    rjmp boton_sonrisa          ; Si esta apretado voy a sonrisa


    sbis PIND, PD3              ; Reviso boton del guiño
    rjmp boton_guino            ; Si esta apretado voy al guiño


    rjmp main                   ; Si no apreto nada sigo revisando



boton_sonrisa:

    rcall carita_sonriendo      ; Cargo la cara sonriente
    rcall delay_boton           ; Espero un poco por el rebote
    rjmp main                   ; Vuelvo a revisar botones



boton_guino:

    rcall carita_guinando       ; Cargo la cara guiñando
    rcall delay_boton           ; Espero un poco por el rebote
    rjmp main                   ; Vuelvo a revisar botones



carita_sonriendo:

    ; Cada byte representa una fila de la matriz

    ldi r18, 1                  ; Fila 1
    ldi r19, 0b00111100         ; ..1111..
    rcall enviar_registro


    ldi r18, 2                  ; Fila 2
    ldi r19, 0b01000010         ; .1....1.
    rcall enviar_registro


    ldi r18, 3                  ; Fila 3
    ldi r19, 0b10100101         ; 1.1..1.1
    rcall enviar_registro


    ldi r18, 4                  ; Fila 4
    ldi r19, 0b10000001         ; 1......1
    rcall enviar_registro


    ldi r18, 5                  ; Fila 5
    ldi r19, 0b10100101         ; 1.1..1.1
    rcall enviar_registro


    ldi r18, 6                  ; Fila 6
    ldi r19, 0b10011001         ; 1..11..1
    rcall enviar_registro


    ldi r18, 7                  ; Fila 7
    ldi r19, 0b01000010         ; .1....1.
    rcall enviar_registro


    ldi r18, 8                  ; Fila 8
    ldi r19, 0b00111100         ; ..1111..
    rcall enviar_registro


    ret                         ; Termine de cargar la sonrisa



carita_guinando:

    ; Es casi la misma cara
    ; Solo cambio la zona de los ojos

    ldi r18, 1                  ; Fila 1
    ldi r19, 0b00111100         ; ..1111..
    rcall enviar_registro


    ldi r18, 2                  ; Fila 2
    ldi r19, 0b01000010         ; .1....1.
    rcall enviar_registro


    ldi r18, 3                  ; Fila 3
    ldi r19, 0b10101101         ; 1.1.11.1
                                ; Un ojo abierto y otro guiñando
    rcall enviar_registro


    ldi r18, 4                  ; Fila 4
    ldi r19, 0b10000001         ; 1......1
    rcall enviar_registro


    ldi r18, 5                  ; Fila 5
    ldi r19, 0b10100101         ; 1.1..1.1
    rcall enviar_registro


    ldi r18, 6                  ; Fila 6
    ldi r19, 0b10011001         ; 1..11..1
    rcall enviar_registro


    ldi r18, 7                  ; Fila 7
    ldi r19, 0b01000010         ; .1....1.
    rcall enviar_registro


    ldi r18, 8                  ; Fila 8
    ldi r19, 0b00111100         ; ..1111..
    rcall enviar_registro


    ret                         ; Termine de cargar el guiño



enviar_registro:

    ; Envio primero la direccion de fila
    ; y despues los 8 bits del dibujo

    cbi PORTB, PB2              ; CS en 0 para empezar


    mov r20, r18                ; Copio numero de registro
    rcall enviar_byte           ; Lo envio


    mov r20, r19                ; Copio el patron de LEDs
    rcall enviar_byte           ; Lo envio


    sbi PORTB, PB2              ; CS en 1 para guardar los datos

    ret                         ; Vuelvo



enviar_byte:

    ldi r21, 8                  ; Tengo que mandar 8 bits


enviar_bit:

    lsl r20                     ; Corro un bit a la izquierda
                                ; El bit que sale queda en Carry


    brcs bit_uno                ; Si Carry vale 1 voy a bit_uno


    cbi PORTB, PB3              ; DIN = 0
    rjmp pulso_clock            ; Voy a generar el pulso



bit_uno:

    sbi PORTB, PB3              ; DIN = 1



pulso_clock:

    sbi PORTB, PB5              ; CLK en 1
    cbi PORTB, PB5              ; CLK vuelve a 0


    dec r21                     ; Resto un bit enviado
    brne enviar_bit             ; Si faltan bits sigo enviando


    ret                         ; Termine de mandar el byte



delay_boton:

    ; Retardo simple para evitar rebote del pulsador

    ldi r22, 80                 ; Primer contador


delay_b1:

    ldi r23, 255                ; Segundo contador


delay_b2:

    dec r23                     ; Voy restando
    brne delay_b2               ; Mientras no llegue a 0 repito


    dec r22                     ; Resto el contador grande
    brne delay_b1               ; Si falta sigo esperando


    ret                         ; Termino el retardo