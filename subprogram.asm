CRLF MACRO        ;回车换行宏定义
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
ENDM

OUTPUT MACRO      ;输出宏定义
    MOV AH,09H
    INT 21H
ENDM

;数据段
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
    BUFFER db 20,?,20 dup(0)		;定义键盘接收字符缓冲区，最多接收19个字符
    ff db ?               		;输出的判断前导0的标志  
    OP1 dw ?              		;定义两个操作数(16位) 
    OP2 dw ?              	
    hex_BUFFER db 4 dup(30h),'H'	;这是一个字符串的结尾符号,紧跟在缓冲区后可形成字符串,丢失后会产生
              
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;此处输入代码段代码
    
	
MENU:        
    LEA DX,WELCOME				;显示欢迎语
    OUTPUT
    CRLF
    LEA DX,FUNCTION
    OUTPUT
    CRLF
    LEA DX,INPUT				;提示输入
    OUTPUT
    CRLF
    MOV AH,01H           	    ;读取输入
    INT 21H
    
JUDGE:                  		;判断执行哪个功能
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
    LEA DX,AGAIN				;选择错误重新选择
    OUTPUT
	CRLF
    JMP MENU
    
A1:                  			;加法模块
    CRLF        				
    CALL ASCNUM      			
    CMP FLAG,1					;由于错误输入跳回A1重新进行加法操作
    JE A1            
    CMP FLAG,2					;由于溢出跳回A1重新输入
    JE A1            
    CALL ADDI        			
    CALL NUMASC
    JMP MENU         			
    
A2:                           ;减法模块
    CRLF   
    CALL ASCNUM      
    CMP FLAG,1
    JE A2                    
    CMP FLAG,2
    JE A2                      
    CALL SUBI
    CALL NUMASC
    JMP MENU        

A3:                 ;乘法模块
    CRLF
    CALL ASCNUM      ;调用输入的子程序
    CMP FLAG,1
    JE A3            ;由于错误输入跳回A1重新进行加法操作
    CMP FLAG,2
    JE A3            ;由于溢出跳回A1重新输入
    CALL MULTI
    
    MOV AX,OP1
    ;将十进制转化为十六进制
    CALL to16str
    MOV DX,offset hex_BUFFER
    MOV AX,OP2
    ;将十进制转化为十六进制
    CALL to16str
    MOV DX,offset hex_BUFFER
	CALL NUMASC

    JMP MENU        

A4:                    ;除法模块
	CRLF
    CALL ASCNUM        
    CMP FLAG,1
    JE A4            
    CMP FLAG,2 
    JE A4              
     
    CALL DIVI
    CMP FLAG,1
    JE A4              ;由于除数可能输0导致重新输入
    CALL NUMASC
    JMP MENU           

EXIT:                  ;结束程序
	CRLF
    LEA DX,STOP
    OUTPUT
    MOV AH,4CH
    INT 21H


ASCNUM PROC            ;完成asc-数值转换
    LEA DX,NOTICE
    OUTPUT
    CRLF
    MOV FLAG,0         ;初始化FLAG
    LEA DX,BUFFER        
    MOV AH,10
    INT 21H
	CRLF
    MOV CL,BUFFER+1       ;获取实际键入字符数，置于CX寄存器中
    XOR CH,CH          ;CX高位清零
 
    XOR DI,DI		   ;累加器清0
    XOR DX,DX          ;DX寄存器清0
    MOV BX,1           ;由于从个位数开始算起，因而将所乘权值设为1
    
    LEA SI,BUFFER+2       ;将SI指向接收到的第1个字符位置
    ADD SI,CX          ;因为从个位算起，所以将SI指向最后1个接收到的个位数
    DEC SI             ;往回减1使其指向字串最后一个元素
    
COV: 				   ;COV是检测并生成第2个数字的步骤
	MOV AL,[SI]        ;取出SI指向的位数给AL
    CMP AL,' '        
    JZ NEXT1           ;遇见空格则跳转
    CMP AL,'0'         ;边界检查：如果输入不是0-9的数字，就报错
    JB WRONG
    CMP AL,'9'
    JA WRONG
    SUB AL,30h         ;将AL中的ascii码转为数字
    XOR AH,AH
    MUL BX             ;乘以所处数位的权值
    CMP DX,0           ;判断结果是否超出16位数范围，如超出则报错
    JNE YICHU 
    ADD DI,AX          ;将形成的数值叠加放在累加器DI中
    JC YICHU           ;当运算产生进位标志时，即CF=1时，跳转到YICHU处
    MOV AX,BX          ;将BX中的数位权值扩大10倍
    MOV BX,10
    MUL BX
    MOV BX,AX
    DEC SI             ;SI指针减1，指向前一数位
    LOOP COV           ;按CX中的字符个数计数循环
       

NEXT1:                 ;跳到此处表明第2个数字已经生成，接着去检测第1个数字    
    MOV OP1,DI         ;将结果储存在OP1中
    XOR AX,AX
    XOR DI,DI          ;累加器清0
    XOR BX,BX		   ;权值清0
    MOV BX,1           ;由于从个位数开始算起，因而将所乘权值设为1
    DEC SI             ;向前移动一格位置
    DEC CX             ;遇到空格CX相应的减少1

COV2:                  ;COV2是检测并生成第1个数字
    MOV AL,[SI]        ;取出个位数给AL
    CMP AL,'0'         ;边界检查：如果输入不是0-9的数字，就报错
    JB WRONG
    CMP AL,'9'
    JA WRONG
    SUB AL,30h         ;将AL中的ascii码转为数字
    XOR AH,AH
    MUL BX             ;乘以所处数位的权值
    CMP DX,0           ;判断结果是否超出16位数范围，如超出则报错
    JNE YICHU
    ADD DI,AX          ;将形成的数值放在累加器DI中
    JC YICHU           ;当运算产生进位标志时，即CF=1时，跳转到YICHU处
    MOV AX,BX          ;将BX中的数位权值扩大10倍
    MOV BX,10
    MUL BX
    MOV BX,AX
    DEC SI             ;SI指针减1，指向前一数位
    LOOP COV2          ;按CX中的字符个数计数循环
NEXT2:
    MOV OP2,DI         ;将结果储存在OP2中
    JMP RETURN         ;结束后跳到RETURN部分
    
WRONG:
    LEA DX,ERR			;显示错误
    OUTPUT
    MOV FLAG,1			;FLAG置为1
    JMP RETURN			;子程序调用结束
YICHU:
    MOV FLAG,2
    LEA DX,OVER
    OUTPUT
    
RETURN:
    RET
ASCNUM ENDP

ADDI PROC    			;加法子程序（16位数相加）
    XOR BX,BX
    XOR CX,CX
    MOV BX,OP2
    MOV CX,OP1
    ADD BX,CX
    JMP ADDRET

ADDRET:
    RET
    
ADDI ENDP 

SUBI PROC    			;减法子程序（16位数相减）
    XOR BX,BX
    XOR CX,CX
    MOV BX,OP2
    MOV CX,OP1
    CMP BX,CX        	;比较大小
    JB FUHAO
    SUB BX,CX        	;结果储存在BX中        
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

MULTI PROC    			;乘法子程序（16位数相乘）
    XOR AX,AX
    XOR CX,CX
    MOV AX,OP2
    MOV CX,OP1
    MUL CX    			;结果存在DX:AX里面
    MOV OP1,DX
    MOV OP2,AX			;暂存在OP1和OP2
    RET
MULTI ENDP 

DIVI PROC    			;除法子程序（16位数除以8位数）
    XOR BX,BX			;注意 该程序的除数不能超过255 并且商也不能超过255 他们的承载能力只有8位
    XOR CX,CX
    XOR AX,AX
    MOV CX,OP1			;实际上存在CL中
    CMP CX,255   		;让CX的值处于0~255之间（因为寄存器是8位的）
    JA DIVWRONG
    CMP CL,0
    JE DIVWRONG
    MOV AL,255     		;让255和OP1相乘，与OP2比较，若小于OP2则会发生DIVIde ERRor因此判断非法
    MUL CL
    CMP AX,OP2
    JB OVERFLOW
    
    MOV AX,OP2
    DIV CL         		;字除以1字节型除法,商存在AL中
    MOV AH,0            ;清除AH中的内容
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
    MOV AX,BX           ;待输出的数先存在BX里面，在给AX
    MOV BX,10000        ;初始数位权值为10000
    MOV ff,0            ;每次都赋初值0
    
COV1:XOR DX,DX          ;将DX:AX中的数值除以权值
    DIV BX
    MOV CX,DX           ;余数备份到CX寄存器中
    
    CMP ff,0            ;检测是否曾遇到非0商值
    JNE NOR1            ;如遇到过，则不管商是否为0都输出显示
    CMP AX,0            ;如未遇到过，则检测商是否为0
    JE CONT             ;为0则不输出显示    
NOR1:
    MOV DL,AL           ;将商转换为ascii码输出显示
    ADD DL,30h
    MOV AH,2
    INT 21H
    
    MOV ff,1            ;曾遇到非0商，则将标志置1
CONT:
    CMP BX,10           ;检测权值是否已经修改到十位了
    JE OUTER            ;如果相等，则完成最后的个位数输出显示
    
    XOR DX,DX           ;将数位权值除以10
    MOV AX,BX
    MOV BX,10
    DIV BX
    MOV BX,AX
 
    MOV AX,CX            ;将备份的余数送入AX
    JMP COV1             ;继续循环 
OUTER:
    MOV DL,CL            ;最后的个位数变为ascii码输出显示
    ADD DL,30h
    MOV AH,2
    INT 21H   
	CRLF
	
	CRLF
	
RET
NUMASC ENDP

to16str PROC			;功能：将十进制转化为十六进制
    MOV BX,AX			;将待转换的十进制数赋值给BX
    MOV SI,offset hex_BUFFER;将字符串的首地址赋值给SI

    MOV CH,4 			;将10进制转为4位16进制数，每次操作1位,CH为当前还需要转换的位数
    LOOP_trans:
    MOV CL,4
    rol BX,CL			;此处CL的值为4，代表将BX中的值循环左移4位，BX中做该4位移动到最低4位
    
    MOV AL,BL			;从高到低提取四位二进制数送入AL,和0fh进行与操作得bl中低4位
    AND AL,0FH
    
    ADD AL,30H			;AL=0~9,加30h转化为ascii码
    CMP AL,3AH
    jl NEXT_trans
    ADD AL,7  			;AL>9,加37h转化为ascii码，转换为字母A~F
    
    NEXT_trans:
    MOV [SI],AL    		;将转换好的ascii码赋值给字符串的SI位置处
    inc SI    			;SI向后移动一位
    DEC CH    			;代表还需转换的位数减1
    jnz LOOP_trans		;注意，这儿只能用DEC运算对标志位的设置来判断循环与否
    					;因为CL被用来存放位移数了
	RET
	to16str ENDP
	
CODES ENDS
    END START






















