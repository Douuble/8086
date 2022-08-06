DATAS SEGMENT
    ;此处输入数据段代码  
    INPUT   DB 'Please input a string:$'
    OUTPUT  DB 'The password is:$'              ;输入输出提示
    BUFFER  DB 20H
            DB ?
            DB 20H DUP(0)         ;表示定义了10个重复数据存储单元（输入缓冲区）
DATAS ENDS

STACKS SEGMENT PARA STACK
    ;此处输入堆栈段代码
     DW 20H DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX 
    ;此处输入代码段代码
    
    ;输出INPUT输入提示 
    LEA DX, INPUT               
    MOV AH, 9                   
    INT 21H
        
    ;输入字符串到缓冲区
    LEA DX, BUFFER
    MOV AH, 0AH                
    INT 21H
    
    MOV DL,0DH   ;CR回车
    MOV AH,02H
    INT 21H
    MOV DL,0AH   ;LF换行
    MOV AH,02H
    INT 21H
    
    ;输出OUTPUT提示
    LEA DX,OUTPUT
    MOV AH,09H           
    INT 21H
    
    MOV DX,0
    MOV SI,2
    MOV AX,0

CIRCLE:
    MOV AL,BUFFER[SI]     ;取字符串里指针指向的字符  
    CMP AL,0DH             ;回车结束输入
    JE FINAL
     
    CMP AL,'Z'             ;与LESSZ共同实现边界判定
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
    SUB AL,26             ;与TEMP一起实现WXYZ末位的循环

NORMAL:
	ADD AL,4              ;核心功能ASCII码加4	
	
LOP:                      
	MOV DL,AL             ;传送字符
 	MOV AH,02H            ;单字符输出
 	INT 21H
	INC SI                ;指针自加1
	JMP CIRCLE
      
FINAL:MOV AH,4CH          ;退出程序
      INT 21H
      
CODES ENDS
    END START


        
  














