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
NUMDATA DW 0FFH DUP(-1);最大容量256
;下面的注释是测试用
;N	 DW  8
;NUMDATA DW 0201H;最大容量256
;		DW 0403H
;		DW 0605H
;		DW 6A07H;高位在前，低位在后，这样在内存里是01,02,03,04,05,FF
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
    
  	MOV AH,0AH;键盘输入到缓冲区
    LEA DX,BUF1
    INT 21H
    CALL STOI;调用输入处理子程序
    
    ;借用AX将键盘输入的NUM转给N
    MOV AX,NUM;
    MOV N,AX;
    
    ;一个循环，实现数组读取
    MOV CX,N;设置循环次数
L1:
	;这一段显示提示文字
	MOV AH,09H;显示字符串
    LEA DX,SINPUTNUM;取段内偏移地址
    INT 21H;调用系统dos中断
    
    
    MOV BX,N;总循环次数
    SUB BX,CX;相减
    INC BX;加一
    ;此时BX为当前循环次数
    MOV NUM,BX;当前数字存进去
    CALL SHOWNUM;调用显示数字子程序
    MOV DL,' ';传送字符
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
    MOV DL,':';传送字符
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
	
	MOV AH,0AH;键盘输入到缓冲区
    LEA DX,BUF1;取段内偏移地址
    INT 21H;调用系统dos中断
    CALL STOI;调用输入处理子程序
    
    ;借用AX将键盘输入的NUM转给NUMDATA
    MOV BX,N;总循环次数
    SUB BX,CX;相减
    ;此时BX为当前循环次数
    MOV AX,NUM;当前数字存进去
    MOV NUMDATA[BX],AX;放进数组中
LOOP L1;循环

	MOV AH,09H;显示字符串
    LEA DX,SSHOWNUMDATA;取段内偏移地址
    INT 21H;调用系统dos中断
	CALL SHOWNUMDATA;调用子程序显示数组内容
	
;冒泡排序算法
	MOV CX,N;设置大循环次数
	DEC CX;总次数减一
	MOV DX,2;设置小循环的终止下限数,初始化为2，即最开始的两个
L3:
	PUSH CX;大循环的计数存入堆栈
	
	;一个循环，一遍排序
	MOV CX,N;设置循环次数
L2:
	MOV BX,CX;数据传送
	MOV AX,NUMDATA[BX-2];数据传送,往后偏移两个字节，可以得到最右端的两个数字
	CMP AL,AH;临近两个数比较，AH是右端的，AL是左端的
	JA LESS;无符号小于则跳转
	JMP CONTINUE;不小于则不变，执行下一个
LESS:
	XCHG AH,AL;;实现两个数交换功能
	MOV NUMDATA[BX-2],AX;交换完再存回去;
CONTINUE:;直接进入下一个循环
	CMP CX,DX;当循环到DX时，退出循环
LOOPNZ L2;有终止条件的小循环
    
    POP CX;大循环的计数从堆栈取出
    INC DX;小循环的终止下限数自加1
LOOP L3;大循环	
	
	MOV AH,09H;显示字符串
    LEA DX,SSHOWSORTNUM;取段内偏移地址
    INT 21H;调用系统dos中断
	CALL SHOWNUMDATA;调用子程序显示数组内容
    
    ;程序终止代码
    MOV AX,0
    MOV AH,4CH
    INT 21H
    
;这是一段子程序，用来输入数字
STOI PROC 
	;初始化
	MOV DX,0
	MOV BX,10
	MOV SI,2
	MOV NUM,0
	MOV AX,0
LOP:
    MOV AL,BUF1[SI];寄存器相对寻址，从缓冲区取一个字符
    CMP AL,0DH;是否是CR
    JE  FINAL;等于就跳转，JNE相反
    SUB AL,30H;减48，从ASCII码转数字
    CMP NUM,0;与0比较，相当于判断初始化
    JE  DO_DEAL;等于就跳转，JNE相反
    PUSH AX;当前数字压入栈中
    MOV AX,NUM;当前数送入运算寄存器中
    MUL BX ;隐含寻址，在AX中，相当于NUM乘以10
    MOV  NUM,AX;运算结果存进NUM中  
    POP AX;之前的数据弹出
DO_DEAL:
    ADD NUM,AX;加上之前的数据
    MOV AX,0;清零
    INC SI;自加1
    JMP LOP;跳转，处理下一个
FINAL: 
	;换行
	MOV DL,0DH;CR
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
 	MOV DL,0AH;LF
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
RET;子程序退出重置堆栈
STOI ENDP

;这是一段子程序，用来显示数字NUM
SHOWNUM PROC 
	;第一位
	MOV BL,100;%先除100
	MOV AX,NUM;送入运算寄存器
	DIV BL;除法，AX隐含寻址
	ADD AL,30H;商转换为ASCII码
	PUSH AX;将余数先压入栈中
	CMP AL,30H;看一看首位是不是0
	JE BITTWO;若是，则不显示直接跳转到下一个
	MOV DL,AL;传送字符
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
BITTWO:	
	POP AX;将余数取出
	
	;第二位
	MOV AL,AH;送入运算寄存器
	MOV AH,0;高位清零
	MOV BL,10;%再除以10
	DIV BL;除法，AX隐含寻址
	ADD AL,30H;商转换为ASCII码
	PUSH AX;将余数先压入栈中
	CMP NUM,10;看一看数是不是小于10
	JB BITTTHREE;若是，则不显示第二位直接跳转到末位
	MOV DL,AL;传送字符
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
BITTTHREE:
 	POP AX;将余数取出
 	
 	;第三位
 	ADD AH,30H;余数转换为ASCII码
 	MOV DL,AH;传送字符
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
 	
RET;子程序退出重置堆栈
SHOWNUM ENDP


;这是一段子程序，用来显示数组NUMDATA
SHOWNUMDATA PROC 
	MOV CX,N;设置循环次数为数组大小
	MOV BX,0;循环计数
L4:
	PUSH BX;将循环计数存入堆栈
	MOV AX,NUMDATA[BX];从数组中读取当前数字，一次取一个字，两个字节
	MOV AH,0;高位清零
	MOV NUM,AX;将AX低位数据传送到NUM
	CALL SHOWNUM;调用子程序显示数字
	MOV DL,',';传送字符
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
 	POP BX;将循环计数从堆栈中取出
 	INC BX;计数自加1
LOOP L4;;循环
	;换行
	MOV DL,0DH;CR
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
 	MOV DL,0AH;LF
 	MOV AH,2;显示一个字符
 	INT 21H;调用系统dos中断
RET;子程序退出重置堆栈
SHOWNUMDATA ENDP


CODES ENDS
    END START





