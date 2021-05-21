#######################################################################
# Advanced Processors: Project 1
# Code Authors: Ellisa Booker & Memuna Sillah

#######################################################################
# Initialize variables
#######################################################################
.data            
inputString: .space 64    # set aside 64 bytes to store the input string
prompt: .asciiz "\n >>> " #prompt the user to enter something
allowedCharacters: .asciiz "()0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/=" # List of allowed characters
allowedOperands: .asciiz "()0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/=" 
invalid: .asciiz "Invalid input"
valid: .asciiz "Valid input "

#######################################################################
# Main Functions
#######################################################################
.text           
main:
    # Display prompt    
    la $a0, prompt  # display the prompt to begin
    li $v0, 4    # system call code to print a string to console
    syscall  #execute the above command

    # get the string from console
    la $a0, inputString    # load $a0 with the address of inputString; procedure: $a0 = buffer,    $a1 = length of buffer
    la $a1, inputString    # maximum number of character/ size
    li $v0, 8    # The system call code to read a string input
    syscall  #execute the above command
          
    move $t0, $a0 # lets move the address of the user input to a temporary location
    
    la $t1,allowedCharacters #moving the address of the allowed characters to register
    la $t0,inputString #moving the address of the user input to a register
    la $t7,allowedCharacters # will be used to reset my allowed character register back to the beginning
    la $t8,inputString #This will be used to reset the inputString
    la $t9,allowedOperands #Stores the allowed operand values
    
    # Begin error checking
    j checkForValidChars
    jal resetInput
        
nextCheck:    
    #Executes after validity check passes
    jal resetInput
    j checkOperatorErrors
      
finalCheck:
	#Executes after operator check passes       
	jal resetInput
    #s1 will track if there are parenthesis or not, and change the path that the checking functions will follow
    # If s1 = 0, theres no parens. If s1 = 1, there are open parens.
    li $s1, 0 
    j checkParens

#######################################################################
# Checking Functions
#######################################################################
checkForValidChars:
    # Make sure all characters in the input string are valid
    lb $t2,($t0)                   # get next char from inputString
    lb $t4,($t1)                   # get next char from allowedCharacters
    
    beq $t2,10,nextCheck        # IF at end of input string, chars are all valid. Move to next check
    
    beq $t2,32,invalidInput        # IF current character equals "space" (ascii 32) it's invalid
    bne $t2, $t4,checkAllowed    # IF current char is not an allowed char, keep cycling through allowed chars
    move $t1,$t7 # reset the allowed character register
    jal nextCharacter        # ELSE, move to next char
    j checkForValidChars        # Keep looping until one of the IF conditions are met
            
checkAllowed:  
    # Lets check the next allowed character
    addi $t1, $t1, 1 # Looking at the next allowed character
    lb $t4, ($t1) #loading a character from the allowed characters list
    j checkForValidChars #Loop back to validity checking function

checkOperatorErrors:
    #This is a 2-part function. The first part checks for an initial operator
    
    beq $t2, 40, checkNextOperator #  checks for "("
    beq $t2, 41, checkNextOperator # checks for ")"
    beq $t2, 42, checkNextOperator # Checking for "*"
    beq $t2, 43, checkNextOperator # Checking for "+"
    beq $t2, 45, checkNextOperator # Checking for "-"
    beq $t2, 47, checkNextOperator # Checking for "/"
    
    #If there's no operators, go to final check
    j finalCheck
    
checkNextOperator:
    #The second part checks for an operator directly following the first (error)
    
    #Increment character and check for invalid combinations
    jal nextCharacter

    li $t5, 40 # Checking for "("
    beq $t2, $t5, invalidInput

    li $t5, 41 # Checking for ")"
    beq $t2, $t5, invalidInput

    li $t5, 42 # Checking for "*"
    beq $t2, $t5, invalidInput

    li $t5, 43   # Checking for "+"
    beq $t2, $t5, invalidInput

    li $t5, 45 # Checking for "-"
    beq $t2, $t5, invalidInput

    li $t5, 47 # Checking for "/"
    beq $t2, $t5, invalidInput

    #If there's no combination errors, go to final check
    j finalCheck
    
checkParens:
    #Check for open and closed parenthesis, as well as operands directly following parenthesis
       
    jal resetInput    
    #Now start checking
    j checkOpen


checkOpen:
    # IF at end of input string, there's no open parenthesis. Check to make sure there's no closed parens (error)
    beq $t2,10,noOpenParens        
    
    #If s=1, this is our 2nd time in this loop, and there are open and closed parens. We just need to get the value where t2 = ( so we can check for operands to left
    beq $s1, 1, savePrevCharandCheck
    
    #Check if there's an open parenthesis for this char. If so, check for a closing parenthesis next
    beq $t2, 40, checkClosed #  checks for "("    
    
    #If not, check the next character
    jal nextCharacter
    
    j checkOpen #Loop until a condition is met

noOpenParens:
    # If s1=0, there's no open parens and we need to reset the input before checking for closed parens
    jal resetInput   
    j noOpenParensCheckClosed 
    
noOpenParensCheckClosed:
	
    # IF at end of input string, there's no closed parenthesis, all checks are done. Valid string
    beq $t2,10,validInput        
    
    #Check if there's a closed parenthesis for this char. If so, this is invalid since there's no open parens
    beq $t2, 41, invalidInput
    
    #If not, check the next character
    jal nextCharacter
    
    j noOpenParensCheckClosed #Loop until a condition is met
            
checkClosed:
    #If we reach this function, there are open parenthesis and s1=1
    li $s1, 1
	
    # IF at end of input string, there's no closed parenthesis. Invalid string.
    beq $t2,10,invalidInput        
    
    #Check if there's a closed parenthesis for this char. If so, move to next parenthesis check
    beq $t2, 41, saveNextCharandCheck
    
    #If not, check the next character
    jal nextCharacter
    
    j checkClosed #Loop until a condition is met

checkOperandsBehind:    
    # get next char from allowedOperands
    lb $s0,($t9)                   
    
    # IF at end of input string, there's no operand errors for closed parens, check for operands in front of open parens
    beq $t2,10,checkParens      
    
    # checks for operand immediatedly to left of parenthesis. If it exists, invalid input
    beq $t2, $s0, invalidInput
    
    #If not, keep cycling through possible operands
    addi $t9, $t9, 1 #shift right
        
    j checkOperandsBehind #Loop until a condition is met    
    
checkOperandsFront:
    # get next char from allowedOperands
    lb $s0,($t9)                   
    
    # IF at end of input string, there's no operand errors for open parens. All checks are complete. Valid string.
    beq $t2,10,validInput  
    
    # checks for operand immediatedly to right of parenthesis. If it exists, invalid input
    beq $t2, $s0, invalidInput
    
    #If not, keep cycling through possible operands
    addi $t9, $t9, 1 #shift right
        
    j checkOperandsFront #Loop until a condition is met
    
#######################################################################
# General Functions
#######################################################################
prevCharacter:
    #The general function that checks the next character of the input string
    addi $t0, $t0, -1 #shift left
    move $t1,$t7 # reset the allowed character register
    move $t9,$s0 # reset the allowed operand register
    lb $t2, ($t0) # Loading that character
    jr $ra    # end of loop. Go back to last jal call

nextCharacter:
    #The general function that checks the next character of the input string
    addi $t0, $t0, 1 #shift right
    move $t1,$t7 # reset the allowed character register
    move $t9,$s0 # reset the allowed operand register
    lb $t2, ($t0) # Loading that character
    jr $ra    # end of loop. Go back to last jal call

saveNextCharandCheck:
    #Set char in t2 = char at t2 + 1
    jal nextCharacter
    #Check the operands surrounding this char
    j checkOperandsBehind
        
savePrevCharandCheck:
    #Set char in t2 = char at t2 - 1
    jal prevCharacter
    #Check the operands surrounding this char
    j checkOperandsBehind
                
resetInput:
    #Resets the input string index after it's been altered from another function
    move $t0, $t8  # reset t2 character
    lb $t2, ($t0) #load a character from the user input
    jr $ra

#######################################################################
# Final Outputs
#######################################################################
invalidInput:
    # Print "Invalid input" to console
    la $a0, invalid   
    li $v0, 4
    syscall
    j main
       
 validInput:
    # Print "Valid input" to console
    la $a0, valid   
    li $v0, 4
    syscall
    j main


