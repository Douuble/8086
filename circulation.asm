DATAS SEGMENT
    ;�˴��������ݶδ���  
    OUTPUT DB 'The aim numbers are listed bolow:$'
    flag DB 0
DATAS ENDS

STACKS SEGMENT PARA STACK
    ;�˴������ջ�δ���
    DW 20H DUP(0)
STACKS ENDS

CRLF MACRO       ;�س����к궨��
    MOV DL,0DH   ;CR�س�
    MOV AH,02H
    INT 21H
    MOV DL,0AH   ;LF����
    MOV AH,02H
    INT 21H
ENDM

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;�˴��������δ��� 
    MOV CX,1000   
    ;���INPUT��ʾ
    LEA DX,OUTPUT
    MOV AH,09H
    INT 21H
    CRLF                   ;�س����к����
      
FUNCTION: 
	MOV DX,0               ;��λ����
    CMP CX,9999            ;�߽��ж�
    JA FINAL
    MOV AX,CX
    MOV BX,100             ;���abcd��ab��cd
    DIV BX
    ADD AX,DX
    MOV BX,AX
    MUL BX  
    CMP AX,CX              ;ʵ�ֵ�ʽ����ͱȽ�
    JNE NOTSATISFY
    
	PUSH CX                
    CALL NUMASC
    POP CX                 ;ѹջ���ڱ���CX
    
NOTSATISFY:
    INC CX
    JMP FUNCTION 
    
FINAL:
    MOV AH,4CH
    INT 21H 

NUMASC PROC
	mov DX,0
    MOV BX,1000  		;��ʼ��λȨֵΪ1000

COV:		
	DIV BX
	MOV CX,DX			;�������ݵ�CX�Ĵ�����
	
	CMP flag,0			;����Ƿ���������0��ֵ
	JNE NOR1			;�����������򲻹����Ƿ�Ϊ0�������ʾ
	CMP AX,0			;��δ���������������Ƿ�Ϊ0
	JE CONT				;Ϊ0�������ʾ
	
NOR1:
	ADD AL,30h
	MOV DL,AL			;����ת��Ϊascii�������ʾ
	MOV AH,02H
	INT 21H
	MOV flag,1			;��������0�̣��򽫱�־��1
	
CONT:
	CMP BX,10			;���Ȩֵ�Ƿ��Ѿ��޸ĵ�ʮλ��
	JE OUTER			;�����ȣ���������ĸ�λ�������ʾ
	
	XOR DX,DX			;����λȨֵ����10
	MOV AX,BX
	MOV BX,10
    DIV BX
    MOV BX,AX
    
    MOV AX,CX			;�����ݵ���������AX
    JMP COV    			;����ѭ��
   
OUTER:
	MOV DL,CL			;���ĸ�λ����Ϊascii�������ʾ
	ADD DL,30H
	MOV AH,02H
	INT 21H   

    CRLF
        
RET
NUMASC ENDP	


    
CODES ENDS
    END START

























