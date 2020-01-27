 # The American University in Cairo (AUC) 
 # Copyrights Ali Ghazal, Omer Hassan
 # March, 2019, All Rights Reserves
 

.data
#input string
sprintf:.space 20001
#registers hold only 32 bits (4bytes)
bin: .space 10
oct: .space 10 
hexu: .space 10
hexl: .space 10
dec: .space 10
udec: .space 10
Bin: .space 10
char: .space 10
string: .asciiz "hello, world xD "

.align 2
var:.space 400
operation: .space 400
converted :.space 400

#final output
format:.space 2000
result:.space 2000
resultlength :.word
.text

.globl main 

main:
#initialize t5 to t9

li $t5,-17 #a
li $t6,99 #b
li $t7, 99#c
li $t8, 36#d
la $t9,	string#e		# li $t9, 95


la $s5, var #s5 with the var array array 
la $s6,operation #s6 operation array

li $t1,'\0'
sw $t1,0($s6)



la $a0,sprintf # read the input string
li $a1,2000 # at most 2000 chars + 1 null char
li $v0,8
syscall

jal str_fn
add $a1,$a0,$v0 #a1 hold the add of the last char in the input string
move $k1,$s5
addi $k1,$k1,-4

jal slice
move $a1,$v0
move $a2, $s5
move $a3,$s6
jal dooperation
move $s0,$v1 #s0 points to the converted array
move $a1,$s0
la $a0,format
la $a2,result
jal join
la $a0,result # get the length of the result by sending it to str function  
#get str-fn
jal str_fn 
move $t3,$v0 #t3 is the length of the string
la $t2,resultlength
sw $t3,0($t2) # store the val of str length

#output

li $v0,4
la $a0,result
syscall
	
#terminate
li $v0,10
syscall



slice:
	addi $sp,$sp,-4
	sw $s5, 0($sp)
	move $k0,$ra #hold ra just in case it's needed
	lp:
	#moving 1 by one from the end of the string
		lb $s2,0($a1)
		beq $s2,'"', done_taking_var
		bge $s2,'a', take_var
		addi $a1,$a1,-1
		j lp
	take_var:
		beq $s2,'a',storea
		beq $s2,'b',storeb
		beq $s2,'c',storec
		beq $s2,'d',stored
		beq $s2,'e',storee
			storea:
				sw $t5,0($s5)
				addi $s5,$s5,4
				addi $a1,$a1,-1
				j lp
			storeb:
				sw $t6,0($s5)
				 addi $s5,$s5,4
				 addi $a1,$a1,-1
				j lp
			storec:
				sw $t7,0($s5)
				addi $s5,$s5,4
				addi $a1,$a1,-1
				j lp
			stored:
				sw $t8,0($s5)
				addi $s5,$s5,4
				addi $a1,$a1,-1
				j lp
			storee:
				sw $t9,0($s5)
				addi $s5,$s5,4
				addi $a1,$a1,-1
		
			j lp
				
				
	done_taking_var:	
		move $v1,$a1
		addi $a1,$a1,-1	
		
		addloop:
			lb $s2,0($a1)
			beq $s2,'"', done_slicing
			beq $s2,'%',take_operation
			addi $a1,$a1,-1
			j addloop
		take_operation:
			
			addi $a1,$a1,1 #store the operation in the array of s6
			lb $t3,0($a1)
			sb $t3,0($s6)
			addi $s6,$s6,1
			addi $a1,$a1,-2 #move a1 to whats after % and store it
			j addloop
		done_slicing:
			addi $a1,$a1,1 #last address of the wanted string
			move $v0,$a1	
			##we want to jump to a function to manage converting the var array according to the operations and then process the result string with the stack addresses and the converted array
		
		add $t3,$0,$v0	#t3 srart add of the format str
		la $s3,format
		move $t4,$s3
		getformat:
		#consider storing half word to read \n as one char
			lb $t2,0($t3)
			sb $t2,0($t4)
			addi $t3,$t3,1
			addi $t4,$t4,1
			beq $t3,$v1,gomain
			j getformat
		
		gomain:
			#add null char at the end of format
			addi $t2,$0,'\0'
			sb $t2,0($t4)
			move $v0,$s3
			jr $ra
				
			 
	#restore  ra from the sp		
	

#do operations
dooperation:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	la $s3,converted
	move $v1,$s3
	goloop:
		addi $a2,$a2,-4
		addi $a3,$a3,-1
		lw $s1,0($a2) 
		lb $s2,0($a3)
		beq $a2,$k1, doneconverting
	convert:
		#check  which op to execute
		move $a0,$s1
		beq $s2,'d',dodec
		beq $s2,'x',dohexl
		beq $s2,'X',dohexu
		beq $s2,'b',dobin
		beq $s2,'o',dooct
		beq $s2,'u',doudec
		beq $s2,'c',dochar
		beq $s2,'s',dostring

		j goloop
	dodec:
		#send the address of the space to store in in a1, and the value to convert in a0
		la $a1,dec
		jal todec
		j storeloop
		
	dohexu:
		la $a1,hexu
		jal tohexu
		j storeloop
	dohexl:
		la $a1, hexl
		jal tohexl
		j storeloop
	dooct:
		la $a1, oct
		jal toOct
		j storeloop
	doudec:
		la $a1, udec
		jal toudec
		j storeloop
	dobin:
		la $a1,bin
		jal toBin
		j storeloop
	dochar:
		la $a1,char
		jal toChar
		j storeloop
	dostring:
		la $a1, string
		jal toString
		j storeloop

	storeloop:
	#loop byte by byte to store it in the output
		lb $s7,0($v0)
		sb $s7,0($s3)
		addi $v0,$v0,1
		addi $s3,$s3,1
		beq $s7,'\0',back
		j storeloop
		back:
			j goloop
	
	doneconverting:
		#move $v1,$s3
		lw $ra, 0($sp)
		addi $sp,$sp,4
		jr $ra
			
	
			
#this is the join function which have some errors :

join:
	
	move $t0, $a0
	move $t1,$a1
	move $t2,$a2
	lb $t4, 0($t0)

		L2:
			beq $t4,'\0', ext # exit when reaching the null char
			beq $t4,'%',addfromArray #take operation from the array converted
			beq $t4,92,endl #if the byte is \ make endline because it reads \n as two chars
			sb $t4,0($t2) #store char by char
			addi $t0,$t0,1 #advance both pointers
			addi $t2,$t2,1
			lb $t4,0($t0)
			j L2
		endl:
			#store the char \n in the result and advance the pointer of the format by 2 to skip 'n'
			addi $t0,$t0,1
			lb $t4,0($t0)
			bne $t4,110, bktol
			li $t4,'\n'
			sb $t4,0($t2)
			addi $t0,$t0,1
			addi $t2,$t2,1
			lb $t4,0($t0)
			j L2
		bktol:
			j L2
		addfromArray:
			
			looop:
				#take byte by byte till reaching null
				lb $t3,0($t1)
				beq $t3,'\0',backtoL2 
				sb $t3, 0($t2)
				addi $t1,$t1,1
				addi $t2,$t2,1
				j looop
				
				
			backtoL2:
			#advance t0 by 2 to skio % and what follows it
			addi $t1,$t1,1
			addi $t0,$t0,2
			lb $t4,0($t0) 
			j L2
			
	ext:
		move $v0,$a2 #return the address of result in v0
		jr $ra

#convert to binary

toBin:
	addi $t1, $0, '0'
	li $s0, 0
	#while (x > 0) 
	
loopb:
	beq $a0, 0, exit
	#rem = x % 2;
	remu $t0, $a0, 2
	
	addu $t2, $t1, $t0 	#if (rem == 1)
	addu $sp, $sp, -1	#stk.push(1);
	sb $t2, 0($sp)		#else stk.push(0);
	
	addiu $s0, $s0, 1
	
	srl $a0, $a0, 1		#x = x / 2;
	
	j loopb
	
exit:


li $t3, 0
move $s1, $a1
addi $s0, $s0, -1

Sloop:

bgt $t3,$s0 , S_exit

# position in array base + index
addu $s1, $a1, $t3
#storing value from stack
lb $s2, 0($sp)
#poping the stack
addi $sp, $sp, 1

#storing the value 
sb $s2, 0($s1)
#advancing the index
addi $t3, $t3, 1 

j Sloop

S_exit:

add $s1, $a1, $t3
addi $s4, $0, '\0'
sb $s4, 0($s1)

la $v0, bin

jr $ra


#convert to oct

toOct:
	addi $t1, $0, '0'
	li $s0, 0
	#while (x > 0) 
	
oloop:
	beq $a0, 0, oexit
	#rem = x % 8;
	remu $t0, $a0, 8
	
	addu $t2, $t1, $t0 	#if (rem == 1)
	add $sp, $sp, -1	#stk.push(1);
	sb $t2, 0($sp)		#else stk.push(0);
	
	addiu $s0, $s0, 1
	
	srl $a0, $a0, 3	#x = x / 8;
	
	j oloop
	
oexit:


li $t3, 0
move $s1, $a1
addi $s0, $s0, -1

oSloop:

bgt $t3,$s0 , oS_exit

# position in array base + index
add $s1, $a1, $t3
#storing value from stack
lb $s2, 0($sp)
#poping the stack
addi $sp, $sp, 1

#storing the value 
sb $s2, 0($s1)
#advancing the index
addi $t3, $t3, 1 

j oSloop

oS_exit:

add $s1, $a1, $t3
addi $s4, $0, '\0'
sb $s4, 0($s1)

la $v0, oct

jr $ra


#convert to hexu
tohexu:
	addi $t1, $0, '0'
	li $s0, 0
	#while (x > 0) 
	
huloop:
	beq $a0, 0, huexit
	#rem = x % 16;
	remu $t0, $a0, 16
	bge $t0,10,bgten
	addu $t2, $t1, $t0 	#if (rem == 1)
	add $sp, $sp, -1	#stk.push(1);
	sb $t2, 0($sp)		#else stk.push(0);
	
	addi $s0, $s0, 1
	
	srl $a0, $a0, 4	#x = x / 16;
	
	j huloop
bgten:
	addi $t0,$t0,'A' #ascii of A
	addi $t0,$t0,-58 #to store the value of A -10
	add $t2, $t1, $t0 	
	add $sp, $sp, -1	
	sb $t2, 0($sp)		
	
	addi $s0, $s0, 1
	
	srl $a0, $a0, 4
	j huloop
	
huexit:


li $t3, 0
move $s1, $a1
addi $s0, $s0, -1

huSloop:

bgt $t3,$s0 , huS_exit

# position in array base + index
add $s1, $a1, $t3
#storing value from stack
lb $s2, 0($sp)
#poping the stack
addi $sp, $sp, 1

#storing the value 
sb $s2, 0($s1)
#advancing the index
addi $t3, $t3, 1 

j huSloop

huS_exit:

add $s1, $a1, $t3
addi $s4, $0, '\0'
sb $s4, 0($s1)

la $v0, hexu

jr $ra

#convert to hexl
tohexl:
	addi $t1, $0, '0'
	li $s0, 0
	#while (x > 0) 
	
hlloop:
	beq $a0, 0, hlexit
	#rem = x % 16;
	remu $t0, $a0, 16
	bge $t0,10,bgtenl
	addu $t2, $t1, $t0 	#if (rem == 1)
	add $sp, $sp, -1	#stk.push(1);
	sb $t2, 0($sp)		#else stk.push(0);
	
	addiu $s0, $s0, 1
	
	srl $a0, $a0, 4	#x = x / 16;
	
	j hlloop
bgtenl:
	addi $t0,$t0,'a'
	addi $t0,$t0,-58
	add $t2, $t1, $t0 	
	add $sp, $sp, -1	#s
	sb $t2, 0($sp)	
	
	addi $s0, $s0, 1
	
	srl $a0, $a0, 4
	j hlloop
	
hlexit:


li $t3, 0
move $s1, $a1
addi $s0, $s0, -1

hlSloop:

bgt $t3,$s0 , hlS_exit

# position in array base + index
add $s1, $a1, $t3
#storing value from stack
lb $s2, 0($sp)
#poping the stack
addi $sp, $sp, 1

#storing the value 
sb $s2, 0($s1)
#advancing the index
addi $t3, $t3, 1 

j hlSloop

hlS_exit:

add $s1, $a1, $t3
addi $s4, $0, '\0'
sb $s4, 0($s1)

la $v0, hexl

jr $ra

#to decimal
todec:
	addi $t1, $0, '0'
	li $s0, 0
	bge $a0,$0,dloop
	li $t3,'-'
	sb $t3, 0($a1)
	addi $a1,$a1,1
	neg $a0,$a0
dloop:
	beq $a0, 0, dexit
	#rem = x % 10;
	rem $t0, $a0, 10
	add $t2, $t1, $t0 	#if (rem == 1)
	add $sp, $sp, -1	#stk.push(1);
	sb $t2, 0($sp)		#else stk.push(0);
	
	addi $s0, $s0, 1
	
	div $a0, $a0, 10	#x = x / 10;
	
	j dloop

dexit:


li $t3, 0
move $s1, $a1
addi $s0, $s0, -1

dSloop:

bgt $t3,$s0 , dS_exit

# position in array base + index
add $s1, $a1, $t3
#storing value from stack
lb $s2, 0($sp)
#poping the stack
addi $sp, $sp, 1

#storing the value 
sb $s2, 0($s1)
#advancing the index
addi $t3, $t3, 1 

j dSloop

dS_exit:

add $s1, $a1, $t3
addi $s4, $0, '\0'
sb $s4, 0($s1)

la $v0, dec

jr $ra
	

	

#to unsinged decimal
toudec:
	
	addiu $t1, $0, '0'
	li $s0, 0
	#while (x > 0) 
	
udloop:
	beq $a0, 0, udexit
	#rem = x % 10;
	remu $t0, $a0, 10
	addu $t2, $t1, $t0 	
	addu $sp, $sp, -1	
	sb $t2, 0($sp)		
	
	addiu $s0, $s0, 1
	
	divu $a0, $a0, 10	#x = x / 10;
	
	j udloop

	
udexit:


li $t3, 0
move $s1, $a1
addi $s0, $s0, -1

udSloop:

bgt $t3,$s0 , udS_exit

# position in array base + index
add $s1, $a1, $t3
#storing value from stack
lb $s2, 0($sp)
#poping the stack
addi $sp, $sp, 1

#storing the value 
sb $s2, 0($s1)
#advancing the index
addi $t3, $t3, 1 

j udSloop

udS_exit:

add $s1, $a1, $t3
addi $s4, $0, '\0'
sb $s4, 0($s1)

la $v0, udec

jr $ra

toChar:

andi  $t1, $a0, 255

sb $t1, 0($a1)

move $v0, $a1

jr $ra   

toString:

move $v0, $a1

jr $ra   

	

#string length
		


#print v0 which is the length of the string
str_fn:
	li $t1,'\0' #NULL value
	li $s3,0 #i=0
	move $t2,$a0
	li $s2,'\0' #load the null char
	L:
		
		lb $s4,0($t2) #load char by char
		beq $s2,$s4,exitstr #if it's null exit
		addi $s3,$s3,1 # increment counter
		addi $t2,$t2,1 #advance the pointer
		j L 
	exitstr:
		add $v0,$0,$s3# return the value of i
		jr $ra

	
	







