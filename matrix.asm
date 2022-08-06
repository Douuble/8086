DATAS SEGMENT
    ;此处输入数据段代码 
    INtRODUCTION DB 'This program can generate a spiral matrix.$'
    INPUT DB 'Please input the order number(3~6): $'
    TIPS DB 'Out of range!$'
    BUFFER DB 6*6 DUP(?)     ;6阶矩阵缓冲器
    FACT DB ?                ;实际矩阵阶数
     
    S DB 1          ;置标志位以确定操作、方向及对象
    ORIX DB 1       ;1横向填充 0竖向填
    ORIH DB 1       ;1递增填充 0递减填充行
    ORIL DB 1       ;1递增填充 0递减填充列
    H DB ?
    L DB ?
    H2 DB ?
    L2 DB ?
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

OUTPUT MACRO                         ;输出宏定义
    MOV AH,09H
    INT 21H
ENDM

CRLF MACRO                           ;回车换行宏定义
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
    ;此处输入代码段代码
    LEA DX, INTRODUCTION
    OUTPUT
    CRLF
    LEA DX,INPUT
    OUTPUT
    MOV CX, 2
    
IN_BEGIN:
    MOV AH,07H               ;输入阶数
    INT 21H
    CMP AL, 13               ;回车输出
    JZ IN_END
    CMP AL, '0'
    JB IN_BEGIN
    CMP AL, '9'
    JA IN_BEGIN
    MOV DL, AL               ;回显
    MOV AH, 02H              
    INT 21H
    MOV AL, DL
    AND AL, 15
    XCHG AL, FACT
    MOV BL, 10
    MUL BL
    ADD FACT, AL
    LOOP IN_BEGIN
      
IN_END:                         ;边界判断
    CMP FACT, 3
    JB EXITS
    CMP FACT, 6
    JA EXITS
    CRLF
    
    MOV AL, FACT     ;用阶数初始化行数列数
    MOV H, AL      
    DEC AL
    MOV H2, AL     
    MOV L, AL      
    MOV L2, AL     
    MOV BX, 0        ;行与列的序号（二维数组下标）
    MOV DI, 0        
    MOV S, 1        
    
LOOPS:
    MOV AL, S       
    MOV BUFFER[BX][DI], AL  ;取数填充矩阵
    TEST ORIX, 1
    JZ LX
    CALL H_HH        ;行(横向)序号BX变化，加减1
    JMP NEXT
LX:
    CALL L_LL        ;列(竖向)序号DI变化，加减阶数
NEXT:
    INC S           ;下一个数字
    MOV AL, FACT
    MUL FACT           ;矩阵阶数的平方
    CMP AL, S
    JNC LOOPS        ;大于等于当前数字则循环
      
    MOV SI, OFFSET BUFFER   ;显示结果矩阵
    MOV CH, FACT
    CALL DISPLAY
    
EXIT:
    MOV AH,4CH
    INT 21H

H_HH:                ;修改行序号
    TEST ORIH, 1
    JZ H_SUB
H_ADD:               ;行序号递增
    INC BX
    JMP H_NEXT
H_SUB:               ;行序号递减
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

L_LL:                 ;修改列序号
    TEST ORIL, 1
    JZ L_SUB
L_ADD:               ;列序号递增
    MOV AL, FACT
    MOV AH, 0
    ADD DI, AX
    JMP L_NEXT
L_SUB:               ;列序号递减
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

DISPLAY:           ;显示矩阵
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
DISP3:                 ;显示矩阵中的数字
    MOV AH, 0
    MOV BL, 100
    DIV BL
    ADD AL, 30H
    MOV DL, AL       ;百位
    MOV AL, AH       ;十位个位
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AX, 3030H
    MOV BX, AX
    MOV AH, 2
    CMP DL, '0'
    JNZ D_ALL
    MOV DL, ' '      ;消除无效零
    INT 21H
    CMP BL, '0'
    JNZ D_SG
    MOV BL, ' '      ;消除无效零
    JMP D_SG
D_ALL:
    INT   21H
D_SG:
    MOV   DL, BL       ;显示十位数
    INT   21H
    MOV   DL, BH       ;显示个位数
    MOV   AH, 2
    INT   21H
    MOV   DL, ' '      ;显示空格
    INT   21H
    RET

EXITS:  
    CRLF
    LEA DX,TIPS
    OUTPUT
    JMP EXIT
    
CODES ENDS
    END START








