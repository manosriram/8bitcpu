; Memory 256 bytes
; Registers A, B, C, D
MOV A, 200
MOV C, 255
MOV [C], A
MOV D, [C]
MOV B, 100
CMP B, [C]
