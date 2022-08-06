CRLF MACRO        ;�س����к궨��
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
ENDM

OUTPUT MACRO      ;����궨��
    MOV AH,09H
    INT 21H
ENDM

;���ݶ�
DATAS SEGMENT
    WELCOME DB 'Welcome to a SImple calculator!$'
    FUNCTION DB '1-add, 2-SUB, 3-mul, 4-div, 5-exit$'
    INPUT DB 'Please choose the function you want:$'
    AGAIN DB 'Out of range!Try again'
    NOTICE DB 'Please enter two numbers(use blank to separate):$'
    STOP DB 'Exiting program!$'
    OVER DB 'Over flow!Please try again:'
    ERR db 'Illegal input! Please Try again:$'
    ERR1 db'The result is overflowed!Please try again$'
    
    FLAG db ?
    
    temp dw 0
    BUFFER db 20,?,20 dup(0)		;������̽����ַ���������������19���ַ�
    ff db ?               		;������ж�ǰ��0�ı�־  
    OP1 dw ?              		;��������������(16λ) 
    OP2 dw ?              	
    hex_BUFFER db 4 dup(30h),'H'	;����һ���ַ����Ľ�β����,�����ڻ���������γ��ַ���,��ʧ������
              
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;�˴��������δ���
    
	
MENU:        
    LEA DX,WELCOME				;��ʾ��ӭ��
    OUTPUT
    CRLF
    LEA DX,FUNCTION
    OUTPUT
    CRLF
    LEA DX,INPUT				;��ʾ����
    OUTPUT
    CRLF
    MOV AH,01H           	    ;��ȡ����
    INT 21H
    
JUDGE:                  		;�ж�ִ���ĸ�����
    CMP AL,'1'
    JE A1
    CMP AL,'2'
    JE A2
    CMP AL,'3'
    JE A3
    CMP AL,'4'
    JE A4
    CMP AL,'5'
    JE EXIT
    LEA DX,AGAIN				;ѡ���������ѡ��
    OUTPUT
	CRLF
    JMP MENU
    
A1:                  			;�ӷ�ģ��
    CRLF        				
    CALL ASCNUM      			
    CMP FLAG,1					;���ڴ�����������A1���½��мӷ�����
    JE A1            
    CMP FLAG,2					;�����������A1��������
    JE A1            
    CALL ADDI        			
    CALL NUMASC
    JMP MENU         			
    
A2:                           ;����ģ��
    CRLF   
    CALL ASCNUM      
    CMP FLAG,1
    JE A2                    
    CMP FLAG,2
    JE A2                      
    CALL SUBI
    CALL NUMASC
    JMP MENU        

A3:                 ;�˷�ģ��
    CRLF
    CALL ASCNUM      ;����������ӳ���
    CMP FLAG,1
    JE A3            ;���ڴ�����������A1���½��мӷ�����
    CMP FLAG,2
    JE A3            ;�����������A1��������
    CALL MULTI
    
    MOV AX,OP1
    ;��ʮ����ת��Ϊʮ������
    CALL to16str
    MOV DX,offset hex_BUFFER
    MOV AX,OP2
    ;��ʮ����ת��Ϊʮ������
    CALL to16str
    MOV DX,offset hex_BUFFER
	CALL NUMASC

    JMP MENU        

A4:                    ;����ģ��
	CRLF
    CALL ASCNUM        
    CMP FLAG,1
    JE A4            
    CMP FLAG,2 
    JE A4              
     
    CALL DIVI
    CMP FLAG,1
    JE A4              ;���ڳ���������0������������
    CALL NUMASC
    JMP MENU           

EXIT:                  ;��������
	CRLF
    LEA DX,STOP
    OUTPUT
    MOV AH,4CH
    INT 21H


ASCNUM PROC            ;���asc-��ֵת��
    LEA DX,NOTICE
    OUTPUT
    CRLF
    MOV FLAG,0         ;��ʼ��FLAG
    LEA DX,BUFFER        
    MOV AH,10
    INT 21H
	CRLF
    MOV CL,BUFFER+1       ;��ȡʵ�ʼ����ַ���������CX�Ĵ�����
    XOR CH,CH          ;CX��λ����
 
    XOR DI,DI		   ;�ۼ�����0
    XOR DX,DX          ;DX�Ĵ�����0
    MOV BX,1           ;���ڴӸ�λ����ʼ�������������Ȩֵ��Ϊ1
    
    LEA SI,BUFFER+2       ;��SIָ����յ��ĵ�1���ַ�λ��
    ADD SI,CX          ;��Ϊ�Ӹ�λ�������Խ�SIָ�����1�����յ��ĸ�λ��
    DEC SI             ;���ؼ�1ʹ��ָ���ִ����һ��Ԫ��
    
COV: 				   ;COV�Ǽ�Ⲣ���ɵ�2�����ֵĲ���
	MOV AL,[SI]        ;ȡ��SIָ���λ����AL
    CMP AL,' '        
    JZ NEXT1           ;�����ո�����ת
    CMP AL,'0'         ;�߽��飺������벻��0-9�����֣��ͱ���
    JB WRONG
    CMP AL,'9'
    JA WRONG
    SUB AL,30h         ;��AL�е�ascii��תΪ����
    XOR AH,AH
    MUL BX             ;����������λ��Ȩֵ
    CMP DX,0           ;�жϽ���Ƿ񳬳�16λ����Χ���糬���򱨴�
    JNE YICHU 
    ADD DI,AX          ;���γɵ���ֵ���ӷ����ۼ���DI��
    JC YICHU           ;�����������λ��־ʱ����CF=1ʱ����ת��YICHU��
    MOV AX,BX          ;��BX�е���λȨֵ����10��
    MOV BX,10
    MUL BX
    MOV BX,AX
    DEC SI             ;SIָ���1��ָ��ǰһ��λ
    LOOP COV           ;��CX�е��ַ���������ѭ��
       

NEXT1:                 ;�����˴�������2�������Ѿ����ɣ�����ȥ����1������    
    MOV OP1,DI         ;�����������OP1��
    XOR AX,AX
    XOR DI,DI          ;�ۼ�����0
    XOR BX,BX		   ;Ȩֵ��0
    MOV BX,1           ;���ڴӸ�λ����ʼ�������������Ȩֵ��Ϊ1
    DEC SI             ;��ǰ�ƶ�һ��λ��
    DEC CX             ;�����ո�CX��Ӧ�ļ���1

COV2:                  ;COV2�Ǽ�Ⲣ���ɵ�1������
    MOV AL,[SI]        ;ȡ����λ����AL
    CMP AL,'0'         ;�߽��飺������벻��0-9�����֣��ͱ���
    JB WRONG
    CMP AL,'9'
    JA WRONG
    SUB AL,30h         ;��AL�е�ascii��תΪ����
    XOR AH,AH
    MUL BX             ;����������λ��Ȩֵ
    CMP DX,0           ;�жϽ���Ƿ񳬳�16λ����Χ���糬���򱨴�
    JNE YICHU
    ADD DI,AX          ;���γɵ���ֵ�����ۼ���DI��
    JC YICHU           ;�����������λ��־ʱ����CF=1ʱ����ת��YICHU��
    MOV AX,BX          ;��BX�е���λȨֵ����10��
    MOV BX,10
    MUL BX
    MOV BX,AX
    DEC SI             ;SIָ���1��ָ��ǰһ��λ
    LOOP COV2          ;��CX�е��ַ���������ѭ��
NEXT2:
    MOV OP2,DI         ;�����������OP2��
    JMP RETURN         ;����������RETURN����
    
WRONG:
    LEA DX,ERR			;��ʾ����
    OUTPUT
    MOV FLAG,1			;FLAG��Ϊ1
    JMP RETURN			;�ӳ�����ý���
YICHU:
    MOV FLAG,2
    LEA DX,OVER
    OUTPUT
    
RETURN:
    RET
ASCNUM ENDP

ADDI PROC    			;�ӷ��ӳ���16λ����ӣ�
    XOR BX,BX
    XOR CX,CX
    MOV BX,OP2
    MOV CX,OP1
    ADD BX,CX
    JMP ADDRET

ADDRET:
    RET
    
ADDI ENDP 

SUBI PROC    			;�����ӳ���16λ�������
    XOR BX,BX
    XOR CX,CX
    MOV BX,OP2
    MOV CX,OP1
    CMP BX,CX        	;�Ƚϴ�С
    JB FUHAO
    SUB BX,CX        	;���������BX��        
    JMP SUBRET
FUHAO:    
    MOV DX,'-'
    MOV AH,02H
    INT 21H
    SUB CX,BX
    MOV BX,CX
SUBRET:
    RET
SUBI ENDP

MULTI PROC    			;�˷��ӳ���16λ����ˣ�
    XOR AX,AX
    XOR CX,CX
    MOV AX,OP2
    MOV CX,OP1
    MUL CX    			;�������DX:AX����
    MOV OP1,DX
    MOV OP2,AX			;�ݴ���OP1��OP2
    RET
MULTI ENDP 

DIVI PROC    			;�����ӳ���16λ������8λ����
    XOR BX,BX			;ע�� �ó���ĳ������ܳ���255 ������Ҳ���ܳ���255 ���ǵĳ�������ֻ��8λ
    XOR CX,CX
    XOR AX,AX
    MOV CX,OP1			;ʵ���ϴ���CL��
    CMP CX,255   		;��CX��ֵ����0~255֮�䣨��Ϊ�Ĵ�����8λ�ģ�
    JA DIVWRONG
    CMP CL,0
    JE DIVWRONG
    MOV AL,255     		;��255��OP1��ˣ���OP2�Ƚϣ���С��OP2��ᷢ��DIVIde ERRor����жϷǷ�
    MUL CL
    CMP AX,OP2
    JB OVERFLOW
    
    MOV AX,OP2
    DIV CL         		;�ֳ���1�ֽ��ͳ���,�̴���AL��
    MOV AH,0            ;���AH�е�����
    MOV BX,AX
    JMP DIVRET
DIVWRONG:
    LEA DX,ERR
    OUTPUT
    MOV FLAG,1
OVERFLOW:
    LEA DX,ERR1
    OUTPUT
    MOV FLAG,1
DIVRET:
    RET
DIVI ENDP 

NUMASC PROC
    MOV AX,BX           ;����������ȴ���BX���棬�ڸ�AX
    MOV BX,10000        ;��ʼ��λȨֵΪ10000
    MOV ff,0            ;ÿ�ζ�����ֵ0
    
COV1:XOR DX,DX          ;��DX:AX�е���ֵ����Ȩֵ
    DIV BX
    MOV CX,DX           ;�������ݵ�CX�Ĵ�����
    
    CMP ff,0            ;����Ƿ���������0��ֵ
    JNE NOR1            ;�����������򲻹����Ƿ�Ϊ0�������ʾ
    CMP AX,0            ;��δ���������������Ƿ�Ϊ0
    JE CONT             ;Ϊ0�������ʾ    
NOR1:
    MOV DL,AL           ;����ת��Ϊascii�������ʾ
    ADD DL,30h
    MOV AH,2
    INT 21H
    
    MOV ff,1            ;��������0�̣��򽫱�־��1
CONT:
    CMP BX,10           ;���Ȩֵ�Ƿ��Ѿ��޸ĵ�ʮλ��
    JE OUTER            ;�����ȣ���������ĸ�λ�������ʾ
    
    XOR DX,DX           ;����λȨֵ����10
    MOV AX,BX
    MOV BX,10
    DIV BX
    MOV BX,AX
 
    MOV AX,CX            ;�����ݵ���������AX
    JMP COV1             ;����ѭ�� 
OUTER:
    MOV DL,CL            ;���ĸ�λ����Ϊascii�������ʾ
    ADD DL,30h
    MOV AH,2
    INT 21H   
	CRLF
	
	CRLF
	
RET
NUMASC ENDP

to16str PROC			;���ܣ���ʮ����ת��Ϊʮ������
    MOV BX,AX			;����ת����ʮ��������ֵ��BX
    MOV SI,offset hex_BUFFER;���ַ������׵�ַ��ֵ��SI

    MOV CH,4 			;��10����תΪ4λ16��������ÿ�β���1λ,CHΪ��ǰ����Ҫת����λ��
    LOOP_trans:
    MOV CL,4
    rol BX,CL			;�˴�CL��ֵΪ4������BX�е�ֵѭ������4λ��BX������4λ�ƶ������4λ
    
    MOV AL,BL			;�Ӹߵ�����ȡ��λ������������AL,��0fh�����������bl�е�4λ
    AND AL,0FH
    
    ADD AL,30H			;AL=0~9,��30hת��Ϊascii��
    CMP AL,3AH
    jl NEXT_trans
    ADD AL,7  			;AL>9,��37hת��Ϊascii�룬ת��Ϊ��ĸA~F
    
    NEXT_trans:
    MOV [SI],AL    		;��ת���õ�ascii�븳ֵ���ַ�����SIλ�ô�
    inc SI    			;SI����ƶ�һλ
    DEC CH    			;������ת����λ����1
    jnz LOOP_trans		;ע�⣬���ֻ����DEC����Ա�־λ���������ж�ѭ�����
    					;��ΪCL���������λ������
	RET
	to16str ENDP
	
CODES ENDS
    END START






















