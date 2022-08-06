DATAS SEGMENT
    ;此处输入数据段代码  
    OUTPUT DB 'The aim numbers are listed bolow:$'
    flag DB 0
DATAS ENDS

STACKS SEGMENT PARA STACK
    ;此处输入堆栈段代码
    DW 20H DUP(0)
STACKS ENDS

CRLF MACRO       ;回车换行宏定义
    MOV DL,0DH   ;CR回车
    MOV AH,02H
    INT 21H
    MOV DL,0AH   ;LF换行
    MOV AH,02H
    INT 21H
ENDM

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;此处输入代码段代码 
    MOV CX,1000   
    ;输出INPUT提示
    LEA DX,OUTPUT
    MOV AH,09H
    INT 21H
    CRLF                   ;回车换行宏调用
      
FUNCTION: 
	MOV DX,0               ;高位清零
    CMP CX,9999            ;边界判断
    JA FINAL
    MOV AX,CX
    MOV BX,100             ;获得abcd中ab和cd
    DIV BX
    ADD AX,DX
    MOV BX,AX
    MUL BX  
    CMP AX,CX              ;实现等式计算和比较
    JNE NOTSATISFY
    
	PUSH CX                
    CALL NUMASC
    POP CX                 ;压栈用于保护CX
    
NOTSATISFY:
    INC CX
    JMP FUNCTION 
    
FINAL:
    MOV AH,4CH
    INT 21H 

NUMASC PROC
	mov DX,0
    MOV BX,1000  		;初始数位权值为1000

COV:		
	DIV BX
	MOV CX,DX			;余数备份到CX寄存器中
	
	CMP flag,0			;检测是否曾遇到非0商值
	JNE NOR1			;如遇到过，则不管商是否为0都输出显示
	CMP AX,0			;如未遇到过，则检测商是否为0
	JE CONT				;为0则不输出显示
	
NOR1:
	ADD AL,30h
	MOV DL,AL			;将商转换为ascii码输出显示
	MOV AH,02H
	INT 21H
	MOV flag,1			;曾遇到非0商，则将标志置1
	
CONT:
	CMP BX,10			;检测权值是否已经修改到十位了
	JE OUTER			;如果相等，则完成最后的个位数输出显示
	
	XOR DX,DX			;将数位权值除以10
	MOV AX,BX
	MOV BX,10
    DIV BX
    MOV BX,AX
    
    MOV AX,CX			;将备份的余数送入AX
    JMP COV    			;继续循环
   
OUTER:
	MOV DL,CL			;最后的个位数变为ascii码输出显示
	ADD DL,30H
	MOV AH,02H
	INT 21H   

    CRLF
        
RET
NUMASC ENDP	


    
CODES ENDS
    END START

























