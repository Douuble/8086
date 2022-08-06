DATAS SEGMENT
    ;�˴��������ݶδ��� 
    INtRODUCTION DB 'This program can generate a spiral matrix.$'
    INPUT DB 'Please input the order number(3~6): $'
    TIPS DB 'Out of range!$'
    BUFFER DB 6*6 DUP(?)     ;6�׾��󻺳���
    FACT DB ?                ;ʵ�ʾ������
     
    S DB 1          ;�ñ�־λ��ȷ�����������򼰶���
    ORIX DB 1       ;1������� 0������
    ORIH DB 1       ;1������� 0�ݼ������
    ORIL DB 1       ;1������� 0�ݼ������
    H DB ?
    L DB ?
    H2 DB ?
    L2 DB ?
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

OUTPUT MACRO                         ;����궨��
    MOV AH,09H
    INT 21H
ENDM

CRLF MACRO                           ;�س����к궨��
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
ENDM

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;�˴��������δ���
    LEA DX, INTRODUCTION
    OUTPUT
    CRLF
    LEA DX,INPUT
    OUTPUT
    MOV CX, 2
    
IN_BEGIN:
    MOV AH,07H               ;�������
    INT 21H
    CMP AL, 13               ;�س����
    JZ IN_END
    CMP AL, '0'
    JB IN_BEGIN
    CMP AL, '9'
    JA IN_BEGIN
    MOV DL, AL               ;����
    MOV AH, 02H              
    INT 21H
    MOV AL, DL
    AND AL, 15
    XCHG AL, FACT
    MOV BL, 10
    MUL BL
    ADD FACT, AL
    LOOP IN_BEGIN
      
IN_END:                         ;�߽��ж�
    CMP FACT, 3
    JB EXITS
    CMP FACT, 6
    JA EXITS
    CRLF
    
    MOV AL, FACT     ;�ý�����ʼ����������
    MOV H, AL      
    DEC AL
    MOV H2, AL     
    MOV L, AL      
    MOV L2, AL     
    MOV BX, 0        ;�����е���ţ���ά�����±꣩
    MOV DI, 0        
    MOV S, 1        
    
LOOPS:
    MOV AL, S       
    MOV BUFFER[BX][DI], AL  ;ȡ��������
    TEST ORIX, 1
    JZ LX
    CALL H_HH        ;��(����)���BX�仯���Ӽ�1
    JMP NEXT
LX:
    CALL L_LL        ;��(����)���DI�仯���Ӽ�����
NEXT:
    INC S           ;��һ������
    MOV AL, FACT
    MUL FACT           ;���������ƽ��
    CMP AL, S
    JNC LOOPS        ;���ڵ��ڵ�ǰ������ѭ��
      
    MOV SI, OFFSET BUFFER   ;��ʾ�������
    MOV CH, FACT
    CALL DISPLAY
    
EXIT:
    MOV AH,4CH
    INT 21H

H_HH:                ;�޸������
    TEST ORIH, 1
    JZ H_SUB
H_ADD:               ;����ŵ���
    INC BX
    JMP H_NEXT
H_SUB:               ;����ŵݼ�
    DEC BX
H_NEXT:
    DEC H2
    CMP H2, 0
    JNZ E_H
    DEC H
    MOV AL, H
    MOV H2, AL
    INC ORIH
    INC ORIX
E_H:
    RET

L_LL:                 ;�޸������
    TEST ORIL, 1
    JZ L_SUB
L_ADD:               ;����ŵ���
    MOV AL, FACT
    MOV AH, 0
    ADD DI, AX
    JMP L_NEXT
L_SUB:               ;����ŵݼ�
    MOV AL, FACT
    MOV AH, 0
    SUB DI, AX
L_NEXT:
    DEC L2
    CMP L2, 0
    JNZ E_LL
    DEC L
    MOV AL, L
    MOV L2, AL
    INC ORIL
    INC ORIX
E_LL:
      RET

DISPLAY:           ;��ʾ����
    MOV S, CH
DP0:MOV CL, CH
DP1:MOV AL, [SI]
    CALL DISP3
    INC SI
    DEC CL
    CMP CL, 0
    JNZ DP1
    CRLF
    DEC S
    CMP S, 0
    JNZ DP0
    RET
DISP3:                 ;��ʾ�����е�����
    MOV AH, 0
    MOV BL, 100
    DIV BL
    ADD AL, 30H
    MOV DL, AL       ;��λ
    MOV AL, AH       ;ʮλ��λ
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AX, 3030H
    MOV BX, AX
    MOV AH, 2
    CMP DL, '0'
    JNZ D_ALL
    MOV DL, ' '      ;������Ч��
    INT 21H
    CMP BL, '0'
    JNZ D_SG
    MOV BL, ' '      ;������Ч��
    JMP D_SG
D_ALL:
    INT   21H
D_SG:
    MOV   DL, BL       ;��ʾʮλ��
    INT   21H
    MOV   DL, BH       ;��ʾ��λ��
    MOV   AH, 2
    INT   21H
    MOV   DL, ' '      ;��ʾ�ո�
    INT   21H
    RET

EXITS:  
    CRLF
    LEA DX,TIPS
    OUTPUT
    JMP EXIT
    
CODES ENDS
    END START








