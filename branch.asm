DATAS SEGMENT
    ;�˴��������ݶδ���  
    INPUT   DB 'Please input a string:$'
    OUTPUT  DB 'The password is:$'              ;���������ʾ
    BUFFER  DB 20H
            DB ?
            DB 20H DUP(0)         ;��ʾ������10���ظ����ݴ洢��Ԫ�����뻺������
DATAS ENDS

STACKS SEGMENT PARA STACK
    ;�˴������ջ�δ���
     DW 20H DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX 
    ;�˴��������δ���
    
    ;���INPUT������ʾ 
    LEA DX, INPUT               
    MOV AH, 9                   
    INT 21H
        
    ;�����ַ�����������
    LEA DX, BUFFER
    MOV AH, 0AH                
    INT 21H
    
    MOV DL,0DH   ;CR�س�
    MOV AH,02H
    INT 21H
    MOV DL,0AH   ;LF����
    MOV AH,02H
    INT 21H
    
    ;���OUTPUT��ʾ
    LEA DX,OUTPUT
    MOV AH,09H           
    INT 21H
    
    MOV DX,0
    MOV SI,2
    MOV AX,0

CIRCLE:
    MOV AL,BUFFER[SI]     ;ȡ�ַ�����ָ��ָ����ַ�  
    CMP AL,0DH             ;�س���������
    JE FINAL
     
    CMP AL,'Z'             ;��LESSZ��ͬʵ�ֱ߽��ж�
    JBE LESSZ1               
    CMP AL,'z'
    JBE LESSZ2 
    JMP LOP
    
LESSZ1:                       
    CMP AL,'A'
    JAE TEMP1
    JMP LOP

LESSZ2:
    CMP AL,'a'
    JAE TEMP2
    JMP LOP
    
TEMP1:                 
    CMP AL,'V'
    JA SPECIAL
    JB NORMAL
    JMP LOP

TEMP2:
    CMP AL,'v'
    JA SPECIAL
    JB NORMAL
    JMP LOP
    
SPECIAL:
    SUB AL,26             ;��TEMPһ��ʵ��WXYZĩλ��ѭ��

NORMAL:
	ADD AL,4              ;���Ĺ���ASCII���4	
	
LOP:                      
	MOV DL,AL             ;�����ַ�
 	MOV AH,02H            ;���ַ����
 	INT 21H
	INC SI                ;ָ���Լ�1
	JMP CIRCLE
      
FINAL:MOV AH,4CH          ;�˳�����
      INT 21H
      
CODES ENDS
    END START


        
  














