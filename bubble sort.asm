DATAS SEGMENT
SINPUT DB 'welecome and please input the number of numbers N:$'
SINPUTNUM DB 'please input the number with index number $'
SSHOWNUMDATA DB 'The contents of the array are: $'
SSHOWSORTNUM DB 'The contents of the sorted array are: $'
BUF1 DB 20H
     DB  0
     DB 20H DUP(0)
NUM  DW  ?
N	 DW  ?
NUMDATA DW 0FFH DUP(-1);�������256
;�����ע���ǲ�����
;N	 DW  8
;NUMDATA DW 0201H;�������256
;		DW 0403H
;		DW 0605H
;		DW 6A07H;��λ��ǰ����λ�ں��������ڴ�����01,02,03,04,05,FF
DATAS ENDS
   
STACKS SEGMENT PARA STACK
   DW 30H DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    MOV AH,09H
    LEA DX,SINPUT
    INT 21H
    
  	MOV AH,0AH;�������뵽������
    LEA DX,BUF1
    INT 21H
    CALL STOI;�������봦���ӳ���
    
    ;����AX�����������NUMת��N
    MOV AX,NUM;
    MOV N,AX;
    
    ;һ��ѭ����ʵ�������ȡ
    MOV CX,N;����ѭ������
L1:
	;��һ����ʾ��ʾ����
	MOV AH,09H;��ʾ�ַ���
    LEA DX,SINPUTNUM;ȡ����ƫ�Ƶ�ַ
    INT 21H;����ϵͳdos�ж�
    
    
    MOV BX,N;��ѭ������
    SUB BX,CX;���
    INC BX;��һ
    ;��ʱBXΪ��ǰѭ������
    MOV NUM,BX;��ǰ���ִ��ȥ
    CALL SHOWNUM;������ʾ�����ӳ���
    MOV DL,' ';�����ַ�
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
    MOV DL,':';�����ַ�
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
	
	MOV AH,0AH;�������뵽������
    LEA DX,BUF1;ȡ����ƫ�Ƶ�ַ
    INT 21H;����ϵͳdos�ж�
    CALL STOI;�������봦���ӳ���
    
    ;����AX�����������NUMת��NUMDATA
    MOV BX,N;��ѭ������
    SUB BX,CX;���
    ;��ʱBXΪ��ǰѭ������
    MOV AX,NUM;��ǰ���ִ��ȥ
    MOV NUMDATA[BX],AX;�Ž�������
LOOP L1;ѭ��

	MOV AH,09H;��ʾ�ַ���
    LEA DX,SSHOWNUMDATA;ȡ����ƫ�Ƶ�ַ
    INT 21H;����ϵͳdos�ж�
	CALL SHOWNUMDATA;�����ӳ�����ʾ��������
	
;ð�������㷨
	MOV CX,N;���ô�ѭ������
	DEC CX;�ܴ�����һ
	MOV DX,2;����Сѭ������ֹ������,��ʼ��Ϊ2�����ʼ������
L3:
	PUSH CX;��ѭ���ļ��������ջ
	
	;һ��ѭ����һ������
	MOV CX,N;����ѭ������
L2:
	MOV BX,CX;���ݴ���
	MOV AX,NUMDATA[BX-2];���ݴ���,����ƫ�������ֽڣ����Եõ����Ҷ˵���������
	CMP AL,AH;�ٽ��������Ƚϣ�AH���Ҷ˵ģ�AL����˵�
	JA LESS;�޷���С������ת
	JMP CONTINUE;��С���򲻱䣬ִ����һ��
LESS:
	XCHG AH,AL;;ʵ����������������
	MOV NUMDATA[BX-2],AX;�������ٴ��ȥ;
CONTINUE:;ֱ�ӽ�����һ��ѭ��
	CMP CX,DX;��ѭ����DXʱ���˳�ѭ��
LOOPNZ L2;����ֹ������Сѭ��
    
    POP CX;��ѭ���ļ����Ӷ�ջȡ��
    INC DX;Сѭ������ֹ�������Լ�1
LOOP L3;��ѭ��	
	
	MOV AH,09H;��ʾ�ַ���
    LEA DX,SSHOWSORTNUM;ȡ����ƫ�Ƶ�ַ
    INT 21H;����ϵͳdos�ж�
	CALL SHOWNUMDATA;�����ӳ�����ʾ��������
    
    ;������ֹ����
    MOV AX,0
    MOV AH,4CH
    INT 21H
    
;����һ���ӳ���������������
STOI PROC 
	;��ʼ��
	MOV DX,0
	MOV BX,10
	MOV SI,2
	MOV NUM,0
	MOV AX,0
LOP:
    MOV AL,BUF1[SI];�Ĵ������Ѱַ���ӻ�����ȡһ���ַ�
    CMP AL,0DH;�Ƿ���CR
    JE  FINAL;���ھ���ת��JNE�෴
    SUB AL,30H;��48����ASCII��ת����
    CMP NUM,0;��0�Ƚϣ��൱���жϳ�ʼ��
    JE  DO_DEAL;���ھ���ת��JNE�෴
    PUSH AX;��ǰ����ѹ��ջ��
    MOV AX,NUM;��ǰ����������Ĵ�����
    MUL BX ;����Ѱַ����AX�У��൱��NUM����10
    MOV  NUM,AX;���������NUM��  
    POP AX;֮ǰ�����ݵ���
DO_DEAL:
    ADD NUM,AX;����֮ǰ������
    MOV AX,0;����
    INC SI;�Լ�1
    JMP LOP;��ת��������һ��
FINAL: 
	;����
	MOV DL,0DH;CR
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
 	MOV DL,0AH;LF
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
RET;�ӳ����˳����ö�ջ
STOI ENDP

;����һ���ӳ���������ʾ����NUM
SHOWNUM PROC 
	;��һλ
	MOV BL,100;%�ȳ�100
	MOV AX,NUM;��������Ĵ���
	DIV BL;������AX����Ѱַ
	ADD AL,30H;��ת��ΪASCII��
	PUSH AX;��������ѹ��ջ��
	CMP AL,30H;��һ����λ�ǲ���0
	JE BITTWO;���ǣ�����ʾֱ����ת����һ��
	MOV DL,AL;�����ַ�
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
BITTWO:	
	POP AX;������ȡ��
	
	;�ڶ�λ
	MOV AL,AH;��������Ĵ���
	MOV AH,0;��λ����
	MOV BL,10;%�ٳ���10
	DIV BL;������AX����Ѱַ
	ADD AL,30H;��ת��ΪASCII��
	PUSH AX;��������ѹ��ջ��
	CMP NUM,10;��һ�����ǲ���С��10
	JB BITTTHREE;���ǣ�����ʾ�ڶ�λֱ����ת��ĩλ
	MOV DL,AL;�����ַ�
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
BITTTHREE:
 	POP AX;������ȡ��
 	
 	;����λ
 	ADD AH,30H;����ת��ΪASCII��
 	MOV DL,AH;�����ַ�
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
 	
RET;�ӳ����˳����ö�ջ
SHOWNUM ENDP


;����һ���ӳ���������ʾ����NUMDATA
SHOWNUMDATA PROC 
	MOV CX,N;����ѭ������Ϊ�����С
	MOV BX,0;ѭ������
L4:
	PUSH BX;��ѭ�����������ջ
	MOV AX,NUMDATA[BX];�������ж�ȡ��ǰ���֣�һ��ȡһ���֣������ֽ�
	MOV AH,0;��λ����
	MOV NUM,AX;��AX��λ���ݴ��͵�NUM
	CALL SHOWNUM;�����ӳ�����ʾ����
	MOV DL,',';�����ַ�
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
 	POP BX;��ѭ�������Ӷ�ջ��ȡ��
 	INC BX;�����Լ�1
LOOP L4;;ѭ��
	;����
	MOV DL,0DH;CR
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
 	MOV DL,0AH;LF
 	MOV AH,2;��ʾһ���ַ�
 	INT 21H;����ϵͳdos�ж�
RET;�ӳ����˳����ö�ջ
SHOWNUMDATA ENDP


CODES ENDS
    END START





