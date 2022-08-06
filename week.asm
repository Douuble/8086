CRLF MACRO        ;�س����к궨��
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
ENDM

DATA SEGMENT
    ;�˴��������ݶδ���  
	S_Year 	db 	5,0,5 dup(0)
	S_Month db	3,0,3 dup(0)
	S_Day 	db	3,0,3 dup(0)
	YearIn	db	'please input year:$'
	MonthIn	db	'please	input month:$'
	DayIn	db	'please input day:$'
	WrongInfo db 'your input is illegal,please input again!$'
	year 	dw	0
	month 	db	0
	day 	db	0
	Max_Day db	0,31,28,31,30,31,30,31,31,30,31,30,31
	tmp		dw	0
	week1	db	'Monday$'
	week2	db	'Tuesday$'
	week3	db	'Wednesday$'
	week4	db	'Thursday$'
	week5	db	'Friday$'
	week6	db	'Saturday$'
	week7	db	'Sunday$'
	hint	db	' is $'

DATA ENDS

STACK SEGMENT
    ;�˴������ջ�δ���
	db 256	dup(0)
STACK ENDS

CODE SEGMENT
ASSUME cs:CODE, ds:DATA, ss:STACK 

START:
MAIN PROC
	mov ax,DATA
	mov ds,ax	;��ʼ��
INPUTYEAR:
CRLF
	lea dx, YearIn	;��ʾ����year
	mov ah, 09H
	int 21H
	lea dx, S_Year 	;����year
	mov ah, 0AH
	int 21H

	CRLF;����
	;���Year�Ƿ�Ϸ�
	mov cl, S_Year+1	;��ʵ�ʳ��ȱ��浽cx��
	mov ch, 0
	cmp cx, 4		;��鳤�ȣ�ͬʱ����year��ֵ
	jnz WRONGYEAR
	mov year, 0
	mov si, 2
CHECKYEAR:
	;�ж��Ƿ�������
	mov dl, S_Year[si]
	cmp dl, '0'
	jb	WRONGYEAR
	cmp dl, '9'
	ja	WRONGYEAR
	;�����֣�����year
	mov ax, year
	mov bx, 10
	mul bx
	mov dl, S_Year[si]
	sub dl, '0'
	mov dh, 0
	add ax, dx
	mov year, ax
	inc si
	loop CHECKYEAR
	;year�������
	jp	INPUTMONTH

WRONGYEAR:
	lea dx, WrongInfo	;���������Ϣ
	mov ah, 09H
	int 21H
	CRLF	;����
	jmp	INPUTYEAR		;��������

INPUTMONTH:
	lea dx, MonthIn		;��ʾ����month
	mov ah, 09H
	int 21H
	lea dx, S_Month 	;����month
	mov ah, 0AH
	int 21H

	CRLF	;����
	;���Month�Ƿ�Ϸ�
	mov cl, S_Month+1	;��ʵ�ʳ��ȱ��浽cx��
	mov ch, 0
	cmp cx, 2			;��鳤�ȣ�ͬʱ����month��ֵ
	jnz WRONGMONTH
	mov month, 0
	mov si, 2
CHECKMONTH:
	;�ж��Ƿ�������
	mov dl, S_Month[si]
	cmp dl, '0'
	jb	WRONGMONTH
	cmp dl, '9'
	ja	WRONGMONTH
	;�����֣�����month
	mov al, month
	mov bl, 10
	mul bl
	sub dl, '0'
	add al, dl
	mov month, al
	inc si
	loop CHECKMONTH
	;month�������
	;�ж�month�Ƿ��ںϷ���Χ��
	mov dl, month
	cmp dl, 1
	jb	WRONGMONTH
	cmp dl, 12
	ja	WRONGMONTH
	jmp INPUTDAY

WRONGMONTH:
	lea dx, WrongInfo	;���������Ϣ
	mov ah, 09H
	int 21H
	CRLF	;����
	jmp	INPUTMONTH		;��������

INPUTDAY:
	lea dx, DayIn	;��ʾ����day
	mov ah, 09H
	int 21H
	lea dx, S_Day 	;����day
	mov ah, 0AH
	int 21H

	CRLF;����
	;���day�Ƿ�Ϸ�
	mov cl, S_Day+1	;��ʵ�ʳ��ȱ��浽cx��
	mov ch, 0
	cmp cx, 2		;��鳤�ȣ�ͬʱ����day��ֵ
	jnz WRONGDAY_TMP
	mov si, 2
	mov day, 0
CHECKDAY:
	
	;�ж��Ƿ�������
	mov dl, S_Day[si]
	cmp dl, '0'
	jb	WRONGDAY_TMP
	cmp dl, '9'
	ja	WRONGDAY_TMP
	;�����֣�����day
	mov al, day
	mov bl, 10
	mul bl
	sub dl, '0'
	add al, dl
	mov day, al
	inc si
	loop CHECKDAY
	;day�������
	;���day�Ƿ��ںϷ���Χ��

	mov dl, day
	cmp dl, 1
	jb	WRONGDAY
	mov cl, month
	mov ch, 0
	mov si, cx
	cmp dl, Max_Day[si]	;�����û�и��·�����һ��
	ja	CHECKLEAP		;����ǲ�������

	jmp	INPUTEND		;�������

WRONGDAY_TMP:
	jmp WRONGDAY

CHECKLEAP:
	mov dh, month
	cmp dh, 2
	jne WRONGDAY		;�������2�¾Ϳ϶�����
	;�ж��ǲ�������if(year%4==0 && year%100!=0 || year%400==0) ������
	mov ax, year
	mov dx, 0
	mov bx, 400
	div bx
	cmp dx, 0
	je	ISLEAP 			;���Ա�400����˵��������
	mov ax, year
	mov dx, 0
	mov bx, 4
	div bx
	cmp dx, 0
	jne ISNOTLEAP		;���ܱ�4����˵����������
	mov ax, year
	mov dx, 0
	mov bx, 100
	div bx
	cmp dx, 0
	je 	ISNOTLEAP		;�ܱ�100����˵����������
ISLEAP:
	mov dl, day
	cmp dl, 29			
	ja	WRONGDAY		;��29����
	jmp	INPUTEND		;�������

ISNOTLEAP:
WRONGDAY:
	lea dx, WrongInfo	;���������Ϣ
	mov ah, 09H
	int 21H
	CRLF	;����
	jmp	INPUTDAY		;��������

INPUTEND:				;����Ϸ�����ʼʹ�û�ķ����ɭ��ʽ�����
	mov dl, month
	cmp dl, 1
	je	ADDMONTH
	cmp	dl, 2
	je 	ADDMONTH
	jmp CALCULATE

ADDMONTH:
	mov al, month
	add al, 12
	mov month, al
	mov ax, year
	sub ax, 1
	mov year, ax

CALCULATE:
	mov bl, day
	mov bh, 0			
	add bl, month
	add bl, month 		

	mov al, month
	add al, 1
	mov ah, al
	add al, ah 
	add al, ah 			

	mov ah, 0
	mov cl, 5
	div cl
	mov ah, 0			
	add bx, ax			

	add bx, year 		
	mov ax, year
	mov dx, 0
	mov cx, 4
	div cx
	add bx, ax			
	mov ax, year
	mov dx, 0
	mov cx, 100
	div cx
	sub bx, ax			
	mov ax, year
	mov dx, 0
	mov cx, 400
	div cx
	add bx, ax			

	add bx, 1			
	mov ax, bx
	mov dx, 0
	mov cx, 7
	div cx				
	mov bx, dx

	;��ķ����ɭ��ʽ�������

OUTPUT:
CRLF
	mov al, S_Year+1
	add al, 2
	mov ah, 0
	mov si, ax	
	mov S_Year[si], '$'	;�����ַ����ս��$
	lea dx, S_Year+2	;������
	mov ah, 09H
	int 21H

	mov dl, '\'
	mov ah, 02H
	int 21H

	mov al, S_Month+1
	add al, 2
	mov ah, 0
	mov si, ax	
	mov S_Month[si], '$'
	lea dx, S_Month+2
	mov ah, 09H
	int 21H

	mov dl, '\'
	mov ah, 02H
	int 21H

	mov al, S_Day+1
	add al, 2
	mov ah, 0
	mov si, ax	
	mov S_Day[si], '$'
	lea dx, S_Day+2
	mov ah, 09H
	int 21H

	lea	dx,	hint
	mov ah,	09H
	int 21H

	mov al, bl
	cmp al, 0
	jnz D1
	lea dx, week7
	mov ah, 09H
	int 21H
	jmp	D7

INPUTYEAR_TMP1:
CRLF
	jmp INPUTYEAR

D1:	
	cmp al, 1
	jnz D2
	lea dx, week1
	mov ah, 09H
	int 21H
	jmp	 D7
D2:
	cmp al, 2
	jnz D3
	lea dx, week2
	mov ah, 09H
	int 21H
	jmp	D7 
D3:
	cmp al, 3
	jnz D4
	lea dx, week3
	mov ah, 09H
	int 21H
	jmp	D7 
D4:
	cmp al, 4
	jnz D5
	lea dx, week4
	mov ah, 09H
	int 21H
	jmp	D7 
D5:
	cmp al, 5
	jnz D6
	lea dx, week5
	mov ah, 09H
	int 21H
	jmp	D7 
D6:
	cmp al, 6
	jnz D7
	lea dx, week6
	mov ah, 09H
	int 21H
D7:
CRLF



	mov ax, 4C00H		;�������
	int 21H
MAIN ENDP


CODE ENDS
	     END START




















