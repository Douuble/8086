;编写一个比赛得分程序。共有7个评委，按百分制打分，
;计分原则是去掉一个最高分和一个最低分，求平均值。要求：
   ;（1）评委的打分以十进制从键盘输入。
   ;（2）成绩以十进制给出，并保留1位小数。
   ;（3）输入输出时屏幕上要有相应提示。
;
crlf macro
 MOV DX,0AH;回车
	MOV AH,02H
	INT 21H
	MOV DX,0DH
	MOV AH,02H
	INT 21H
	endm
	
DATAS SEGMENT
    ;此处输入数据段代码  
    TIP_HUNDRED DB 'PLEASE ENTER THE CORRECT SCORE (PERCENTILE SYSTEM)!$'
    TIP_INPUT DB 'PLEASE ENTER YOUR SCORE!$'
    TIP_TOATAL DB 'THE FINAL SCORE IS :$'
    TIP_ERROR DB 'YOUR SCORE IS ILLEGAL!$'     
   SCORE_TRUE DW 0   
   flag db 0   
    SCORE DB 30H 
    DB 0 
    DB 30H DUP('$')
    
    SCOREALL DW 0;总分
DATAS ENDS

STACKS SEGMENT para stack
    ;此处输入堆栈段代码
     DW 40H DUP(0)
    TOP LABEL WORD
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;此处输入代码段代码
    
  
;开始
THE_F:
	MOV AX,0 
	MOV SCOREALL,AX	
	
	;输入规则提示
	LEA  DX,TIP_HUNDRED
	MOV AH,09H
	INT 21H
	CRLF
	MOV CX,5;重复5次
FIRST:
	MOV SCORE_TRUE,0;每次都需要清空
	;提示输入
	MOV DX,CX
	ADD DX,30H
	MOV AH,02H
	INT 21H
	MOV DX,':'
	MOV AH,02H
	INT 21H
	
	LEA  DX,TIP_INPUT
	MOV AH,09H
	INT 21H
	

CRLF
	
	LEA DX,SCORE;将输入的分数保存到SCORE中
	MOV AH,0AH
	INT 21H
  
CRLF
    
    ;判断输入的是否合法
    CALL CMPAB
    
	LOOP FIRST;循环5次后结束
	
	JMP NOLONGHAIR
	
	
CMPAB PROC
	PUSH CX
	  MOV AL,SCORE+1
	;判断是否大于3位
    CMP AL,03H
    JA ERROR_TIP
    ;判断每个字符是不是十进制,是就转成真值，不是就报错
    MOV SI,2    
    MOV CL,SCORE+1;循环
   NEXT:
   	XOR AX,AX
    MOV AL,SCORE[SI]   
     ;0~9
    CMP AL,'0'
    JB ERROR_TIP    
    CMP AL,'9'
    JA ERROR_TIP   
    SUB AL,30H;转成真值      
    PUSH AX;保护AX    
    XOR AX,AX
    MOV AX,10
    MUL SCORE_TRUE
    MOV SCORE_TRUE,AX    
    POP AX    ;恢复AX
   	ADD SCORE_TRUE,AX;按位数相加    
    INC SI;SI++ 
    LOOP NEXT
    
  GH:   
	XOR DX,DX
   	XOR AX,AX
    MOV AX,SCORE_TRUE
    
    ;判断这个值是不是百分制
    CMP AX,100
    JA  ERROR_TIP
    ;符合百分制就加到总分里
    ADD SCOREALL,AX;加到总分中
    
RECHARGE:
    POP CX;恢复循环次数
    ;结束
    RET
CMPAB ENDP	
	
NOLONGHAIR:
	
	LEA DX,TIP_TOATAL
	MOV AH,09H
	INT 21H

	XOR DX,DX
	;计算最后结果，输出后退出
	MOV AX,SCOREALL
	
	
   call numtoasc
   jmp doend
    
 numtoasc proc
 mov bx,10000		
cov:
xor dx,dx			
div bx
	mov cx,dx			
	cmp flag,0			
	jne nor1			
	cmp ax,0			
	je cont				
nor1:
	mov dl,al			
	add dl,30h
	mov ah,2
	int 21h
	mov flag,1			
cont:	
cmp bx,10			
	je outer			
	xor dx,dx			
	mov ax,bx
	mov bx,10
    div bx
    mov bx,ax
    mov ax,cx			
    jmp cov    			
outer:
	mov flag,0
	mov dl,cl			
	add dl,30h
	mov ah,2
	int 21h   
ret
numtoasc endp

ERROR_TIP:
	CRLF
	
  LEA DX,TIP_ERROR
  MOV AH,09H
  INT 21H
  
 
  
  JMP THE_F

doend:MOV AH,4CH
    INT 21H

CODES ENDS
    END START






