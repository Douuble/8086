;��дһ�������÷ֳ��򡣹���7����ί�����ٷ��ƴ�֣�
;�Ʒ�ԭ����ȥ��һ����߷ֺ�һ����ͷ֣���ƽ��ֵ��Ҫ��
   ;��1����ί�Ĵ����ʮ���ƴӼ������롣
   ;��2���ɼ���ʮ���Ƹ�����������1λС����
   ;��3���������ʱ��Ļ��Ҫ����Ӧ��ʾ��
;
crlf macro
 MOV DX,0AH;�س�
	MOV AH,02H
	INT 21H
	MOV DX,0DH
	MOV AH,02H
	INT 21H
	endm
	
DATAS SEGMENT
    ;�˴��������ݶδ���  
    TIP_HUNDRED DB 'PLEASE ENTER THE CORRECT SCORE (PERCENTILE SYSTEM)!$'
    TIP_INPUT DB 'PLEASE ENTER YOUR SCORE!$'
    TIP_TOATAL DB 'THE FINAL SCORE IS :$'
    TIP_ERROR DB 'YOUR SCORE IS ILLEGAL!$'     
   SCORE_TRUE DW 0   
   flag db 0   
    SCORE DB 30H 
    DB 0 
    DB 30H DUP('$')
    
    SCOREALL DW 0;�ܷ�
DATAS ENDS

STACKS SEGMENT para stack
    ;�˴������ջ�δ���
     DW 40H DUP(0)
    TOP LABEL WORD
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;�˴��������δ���
    
  
;��ʼ
THE_F:
	MOV AX,0 
	MOV SCOREALL,AX	
	
	;���������ʾ
	LEA  DX,TIP_HUNDRED
	MOV AH,09H
	INT 21H
	CRLF
	MOV CX,5;�ظ�5��
FIRST:
	MOV SCORE_TRUE,0;ÿ�ζ���Ҫ���
	;��ʾ����
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
	
	LEA DX,SCORE;������ķ������浽SCORE��
	MOV AH,0AH
	INT 21H
  
CRLF
    
    ;�ж�������Ƿ�Ϸ�
    CALL CMPAB
    
	LOOP FIRST;ѭ��5�κ����
	
	JMP NOLONGHAIR
	
	
CMPAB PROC
	PUSH CX
	  MOV AL,SCORE+1
	;�ж��Ƿ����3λ
    CMP AL,03H
    JA ERROR_TIP
    ;�ж�ÿ���ַ��ǲ���ʮ����,�Ǿ�ת����ֵ�����Ǿͱ���
    MOV SI,2    
    MOV CL,SCORE+1;ѭ��
   NEXT:
   	XOR AX,AX
    MOV AL,SCORE[SI]   
     ;0~9
    CMP AL,'0'
    JB ERROR_TIP    
    CMP AL,'9'
    JA ERROR_TIP   
    SUB AL,30H;ת����ֵ      
    PUSH AX;����AX    
    XOR AX,AX
    MOV AX,10
    MUL SCORE_TRUE
    MOV SCORE_TRUE,AX    
    POP AX    ;�ָ�AX
   	ADD SCORE_TRUE,AX;��λ�����    
    INC SI;SI++ 
    LOOP NEXT
    
  GH:   
	XOR DX,DX
   	XOR AX,AX
    MOV AX,SCORE_TRUE
    
    ;�ж����ֵ�ǲ��ǰٷ���
    CMP AX,100
    JA  ERROR_TIP
    ;���ϰٷ��ƾͼӵ��ܷ���
    ADD SCOREALL,AX;�ӵ��ܷ���
    
RECHARGE:
    POP CX;�ָ�ѭ������
    ;����
    RET
CMPAB ENDP	
	
NOLONGHAIR:
	
	LEA DX,TIP_TOATAL
	MOV AH,09H
	INT 21H

	XOR DX,DX
	;�����������������˳�
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






