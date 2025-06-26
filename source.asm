; Memory 256 bytes
; Registers A, B, C, D
; MOV A, 200
; MOV D, [C]
; MOV B, 100
; CMP B, [C]
; ADD A, B
; MOV A, 100
; MOV B, 50
; MOV C, 255
; MOV [C], A
; ADD A, B
MOV A, 10
MOV C, 254
MOV [C], A
SUB [C], 1
