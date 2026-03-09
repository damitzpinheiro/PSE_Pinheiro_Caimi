;=============================================================
; Partida Estrela-Triangulo - 8051 - 12 MHz
;
; P1.0 = K1  Contator principal
; P1.1 = K4  Contator reversao
; P1.2 = K2  Contator estrela
; P1.3 = K3  Contator triangulo
;
; P2.0, P2.1, P2.2 = tempo Y->D (1 a 8s)
; P2.3 = botao partida  (ativo em 0)
; P2.4 = botao reversao (ativo em 0)
;
; Saidas de P1:
;   Desligado      : FFh  (todos apagados)
;   Estrela normal : FAh  (K1=0, K2=0 -> LED0 e LED2 acesos)
;   Delta normal   : F6h  (K1=0, K3=0 -> LED0 e LED3 acesos)
;   Estrela reverso: F8h  (K1=0, K2=0, K4=0 -> LED0, LED1, LED2)
;   Delta reverso  : F4h  (K1=0, K3=0, K4=0 -> LED0, LED1, LED3)
;
; R2 = contador de overflows
; R6 = sentido: 0=normal, 1=reverso
;=============================================================
    ORG  0000H

    MOV  P1,   #0FFH    ; Todos os reles desligados (LEDs apagados)
    MOV  TMOD, #01H     ; Timer 0 modo 1 (16 bits)
    MOV  R6,   #00H     ; Sentido inicial: normal

; Aguarda botao de partida
INICIO:
    JB   P2.3, INICIO

; Le tempo das chaves P2.0-2 e busca na tabela
PARTIDA:
    MOV  A,   P2
    CPL  A
    ANL  A,   #07H
    MOV  DPTR, #TABELA
    MOVC A,   @A+DPTR
    MOV  R2,  A

; Liga estrela (normal ou reverso)
    MOV  A,  R6
    JNZ  EST_REV
    MOV  P1, #0FAH      ; K1 + K2 (estrela normal)
    SJMP CONTA_EST
EST_REV:
    MOV  P1, #0F8H      ; K1 + K2 + K4 (estrela reverso)

; Conta o tempo em estrela com Timer 0
CONTA_EST:
    LCALL T0_START
LOOP_EST:
    LCALL T0_TICK
    DJNZ R2, LOOP_EST

; Pausa de seguranca e liga delta
    CLR  TR0
    MOV  P1, #0FFH      ; Desliga tudo
    LCALL PAUSA

    MOV  A,  R6
    JNZ  DEL_REV
    MOV  P1, #0F6H      ; K1 + K3 (delta normal)
    SJMP LOOP_DEL
DEL_REV:
    MOV  P1, #0F4H      ; K1 + K3 + K4 (delta reverso)

; Aguarda botao de reversao
LOOP_DEL:
    JB   P2.4, LOOP_DEL

; Desliga e aguarda 3 segundos
    MOV  P1, #0FFH
    MOV  R2, #60
    LCALL T0_START
LOOP_3S:
    LCALL T0_TICK
    DJNZ R2, LOOP_3S

; Inverte sentido e reinicia ciclo
    CLR  TR0
    MOV  A,  R6
    CPL  A
    ANL  A,  #01H
    MOV  R6, A
    LJMP PARTIDA

;--------------------------------------------------------------
; T0_START: carrega e dispara Timer 0 (50ms)
;--------------------------------------------------------------
T0_START:
    CLR  TR0
    MOV  TH0, #03CH
    MOV  TL0, #0B0H
    CLR  TF0
    SETB TR0
    RET
;--------------------------------------------------------------
; T0_TICK: aguarda um overflow de 50ms e recarrega
;--------------------------------------------------------------
T0_TICK:
    JNB  TF0, T0_TICK
    CLR  TF0
    MOV  TH0, #03CH
    MOV  TL0, #0B0H
    RET
;--------------------------------------------------------------
; PAUSA: espera curta de seguranca na comutacao Y->D
;--------------------------------------------------------------
PAUSA:
    MOV  R7, #0FFH
P_LOOP:
    DJNZ R7, P_LOOP
    RET
;--------------------------------------------------------------
; TABELA: overflows de 50ms por tempo selecionado
;   000 -> 20 x 50ms = 1s  ...  111 -> 160 x 50ms = 8s
;--------------------------------------------------------------
TABELA:
    DB  20, 40, 60, 80, 100, 120, 140, 160

    END