.data 
  Welcome:.asciiz "\t\t\t\tFirst Project – dictionary-based compression and decompression tool"
  Names: .asciiz "\t\t\t\tRasha Dar Abu Zidan 1190547 | Nour Naji 1190270 \n"
  dictionaryfile : .asciiz "C:\\Users\\hp\\Desktop\\project1\\dictionary.txt"
  enter_path_from_user: .asciiz "\nPlease enter the full path of the dictionary "
  enter_path_compression_file: "\n >>Please enter the path for the compression result "
  enter_path_decompression_file: "\n>>Phlease enter the path for the decompression result "
  menu: .asciiz "\n1)Enter c if you want to compress the file \n2)Enter d if you want decompress the file \n3)Enter q if you want to exit\n Enter your Choice:"
  compress_file: .asciiz "\nPlease enter the full path of the compress file "
  file_not_exist: .asciiz "File does not exist !!!"
  filecreated:      .asciiz "--------------------File created successfully-------------------"
  invalid_input: .asciiz "option is not available ,,, Please enter c, d, or q.\n"
  chooseMessage: .asciiz ">>choose if the file is exist (y , Y) or not exist (any char):"
  hex: .asciiz "0123456789ABCDEF"
  new_line: .asciiz "\n"
  size: .byte 1
  number_of_line: .byte 0
  size_uncompressed: .word 0
  size_compressed: .word 0
  ratio: .asciiz "\n---------------Compression is done--------------------\nCompression ratio is: "
  error_in_decomp: .asciiz "A code in the decompression file doesn't exist, hence, exiting with error\n"
  #--------------------------------------------
  buffer: .space 32768
  dict: .space 32768
  codes: .space 32768
  ans: .space 7
  temp: .space 1
  operations_buffer: .space 8192
  path: .space 64
  compressed_data: .space 8192
  counter_dic: .word 0x0000
  decompressed_text: .space 8192
  data_to_decompress: .space 8192
.text
.globl main
#-------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------
main:

#===================print welcome message and our names===================================================   		
	li $v0,4                  		    # code call print string message 
   	la $a0, Welcome		 	            # Welcome message
   	syscall
   	
#print new line
	li $v0, 11				    # code to call print  character 
	li $a0, 10 				    # print new line exit (terminate execution)
        syscall

   	li $v0,4                 		    # code call print string message 
   	la $a0, Names		  		    # message print names
   	syscall	
#======================================================================   	

  	li $v0,4
  	la $a0, ans
  	syscall
  
  	li $v0, 4
  	la $a0, chooseMessage
  	syscall
  
  	li $v0, 12
  	syscall
  	move $t0, $v0 
  
  	li $v0, 4
  	la $a0, new_line
  	syscall
  
  	li $t1, 'y'
  	li $t2, 'Y'
  	beq $t0, $t1, path_of_dect
  	beq $t0, $t2, path_of_dect
  	j empty_file

    
path_of_dect:
 
  	li $v0, 4
  	la $a0, enter_path_from_user
  	syscall 
  
  	li $v0, 8
  	la $a0, path
  	li $a1, 64
  	syscall
  	
  	la $a2, path
  	jal remove
  
  	li $v0, 13
  	la $a0, path
  	li $a1, 0  # 0 ->reading  mode 
  	li $a2, 0
  	syscall 
  	
  	bltz $v0, file_does_not_exist
 	move $s6, $v0
  	la $s1, dict
  	xor $s5, $s5, $s5
  
reading: 
	# Initialize counter 
    	xor $t1, $t1, $t1
    	addiu $t1, $t1, 7
  
ignore: 
	 # Read a char from the file
    	li $v0, 14
    	move $a0, $s6
    	la $a1, temp
    	li $a2, 1
        syscall
        
        # Decrement count
    	subiu $t1, $t1, 1
    	beqz $t1, reading_string
    	j ignore
    	
#===========================Creatr Dic =========================================    	
    
reading_string: 
	# Initialize variables
    	li $t0, '\n'
    	li $t4, 0
    	la $a3, buffer
  
start_read:
 	# Read a character from the file
    	li $v0, 14
    	move $a0, $s6
    	la $a1, temp
    	li $a2, 1
    	syscall
    	# Accumulate read characters count
    	add $t4, $t4, $v0
    	  # Check if end of file or buffer is full
    	beqz $t4, read_dect
    	beqz $v0, copy_bufer
    	  # Read character is not '\n', copy to buffer
    	lb $t1, temp
    	beq $t1, $t0, copy_to_buffer_new_line
    	sb $t1, ($a3)
    	addiu $a3, $a3, 1
    	j start_read
    
copy_to_buffer_new_line:  
 	# Copy '\n' to buffer
    	la $a0, buffer
    	move $a1, $s1
    	jal strcpy
    	move $a1, $s2
    	addiu $s1, $s1, 32 
    	addiu $s5, $s5, 1
    	la $t0, buffer  
    	li $t1, 32
    	jal zero_loop
    	j reading
    
copy_bufer:
# Copy buffer to dictionary
    	la $a0, buffer
    	move $a1, $s1
    	jal strcpy
    	  # Increment dictionary index
    	addiu $s5, $s5, 1
    	  # Reset buffer pointer
    	la $t0, buffer  
    	  # Set buffer size to 32
    	li $t1, 32
    	 # Jump to zero_loop
    	jal zero_loop
    
read_dect:
 # Load address of dictionary
    	la $a0, dict
    	
    	# Move dictionary index to $t4
    	move $t4, $s5
   
removing:  
# Check if $t4 is zero
    	beqz $t4, end_removing
    	  # Call removing function
    	jal removing
    	# Increment dictionary address by 32
    	addiu $a0, $a0, 32
    	 # Decrement $t4 by 1
    	subiu $t4, $t4, 1
    	 # Jump to removing
    	j removing
  
end_removing: 
	 # Jump to create_codes
   
   	j start_creating_code

#=================================  Create File ========================================
empty_file:  
  # Open  in write mode
  	li $v0, 13
  	la $a0, dictionaryfile
  	li $a1, 1  # 1 -> writting mode
  	li $a2, 0  # open  file for write 
  	syscall
  	
  #Save descriptor for the file 
  	move $s0, $v0

  #Close file
  	li $v0, 16
  	move $a0, $s0
  	syscall
   	li   $v0, 4				
    	la   $a0,  filecreated
    	syscall
#=======================================================================================
#--------------------------Menue-----------------------------------------------------
#=======================================================================================  
start_creating_code:
# Load addresses of 'codes' into $t3 and $t4
  	la $t3, codes
  	la $t4, codes
  	addiu $t4, $t4, 8192
        
creating:
 # Check if $t3 reached $t4 (end of codes array)
    	beq $t3, $t4, goto_menu
    	# Load the address of 'count' into $a0
    	la $a0, counter_dic     
    	  # Load the word at the address in $a0 into $t0
    	lw $t0, 0($a0)  
    	# Load the address of 'hexString' into $a0
    	la $a0, ans 
    	  # Call hex_to_string function
    	jal hex_to_string
    	  # Load the address of 'output' into $a0
    	la $a0, ans
    	  # Copy the content of $t3 to 'output' (strcpy)
    	move $a1, $t3
    	jal strcpy
    	  # Increment $t3 by 32 (move to the next code)
    	addiu $t3, $t3, 32 
    	 # Load the address of 'count' into $a0
    	la $a0, counter_dic
    	 # Load the word at the address in $a0 into $t0
    	lw $t0, ($a0)
    	  # Increment $t0 by 1 (increment count)
    	addiu $t0, $t0, 1
    	 # Store the updated count back to memory
    	sb $t0, ($a0)
    	  # Jump to creating
    	j creating

goto_menu: 
 # Display the menu
  	li $v0, 4
  	la $a0, menu
  	syscall
    # Read user input
  	li $v0, 8
  	la $a0, buffer
  	li $a1, 2
  	syscall
  	
  # Load the first character of the user's input
  	lb $t0, buffer

  # Convert to lowercase if necessary (ASCII 'a' - 'A' = 32)
  	li $t1, 'A'
  	li $t2, 'Z'
  	bgt $t0, $t1, check_uppercase
  	blt $t0, $t2, check_uppercase
  	addi $t0, $t0, 32  # convert to lowercase

check_uppercase:
  # Compare the user's choice to 'c', 'd', and 'q'
  	li $t1, 'c'
  	beq $t0, $t1, compression
  	li $t1, 'd'
  	beq $t0, $t1, decompress
  	li $t1, 'q'
  	beq $t0, $t1, exit

  # If we get here, the user's choice was invalid
  	li $v0, 4
  	la $a0, invalid_input
  	syscall
  	# Repeat the prompt
  	j main  

#=======================================================================================
#--------------------------Compress-----------------------------------------------------
#=======================================================================================  
compression:
  # Print the file prompt to the user
  	li $v0, 4
  	la $a0, compress_file
  	syscall 
  	
 # Clear the path variable
  	la $t0, path  
  	li $t1, 64
  	jal zero_loop
  
# Read the user's input for the file path
  	li $v0, 8
  	la $a0, path
  	li $a1, 64
  	syscall
  	
# Remove trailing newline from the file path 	  
  	la $a2, path
  	jal remove
  	
 # Print a new line 	
  	li $v0, 4
  	la $a0, new_line
  	syscall
    
  # Open the input file in read mode
  	li $v0, 13
  	la $a0, path
  	li $a1, 0  # 0 ==> read mode
  	li $a2, 0
  	syscall
  	bltz $v0, file_does_not_exist
  	move $s6, $v0  # save file 

  # Read the file content into operations_buffer
  	li $v0, 14
  	move $a0, $s6  # file descriptor
  	la $a1, operations_buffer  # address of the buffer
  	li $a2, 8192  # length of the buffer
  	syscall 
  
 #------------------------------------SIZE-------------------------------------- 		
  # Get the size of the uncompressed data 	
  	li $v0, 16
        move $a0, $s6      # file descriptor
  	syscall
  	la $a2, compressed_data
  	move $s3, $a2
  	la $s3, compressed_data
  	la $t5, buffer
  	la $a3, operations_buffer
  
  
compression_case_loop:
  # Load a byte from the buffer into $t0 
  	lb $t0, 0($a3)
  	
  # Check for the end of the string
  	beqz $t0, to_compress
  	
  # Increment the size of the uncompressed data 	  	
  	lw $t7, size_uncompressed
  	addiu $t7, $t7, 1
  	sw $t7, size_uncompressed
  	
  # Check if the character is a lower-case letter
  	sge $t1, $t0, 'a'
  	sle $t2, $t0, 'z'
  	and  $t1, $t1, $t2
  	bnez $t1, alpha
  	
  # Check if the character is an upper-case letter
  	sge $t1, $t0, 'A'
  	sle $t2, $t0, 'Z'
  	and  $t1, $t1, $t2
  	bnez $t1, alpha

  # If the character is not a letter, perform compression
  	xor $t6, $t6, $t6
  	sb $t0, temp
  	la $a0, buffer
  	la $a1, dict
  	la $s0, codes

  	jal do_compression
  	la $t0, buffer
  	li $t1, 32
  	jal zero_loop
  	la $t5, buffer
  	j different_case 

alpha:
  	sb $t0, 0($t5)
  	addiu $t5, $t5, 1
  	j the_next

different_case: 
  # Store non-alphabetical characters in the buffer
  	lb $t0, temp
  	la $a0, buffer 
  	sb $t0, ($a0)
  	la $a1, dict
  	la $s0, codes
  	jal do_compression
  
the_next:
  	addiu $a3, $a3, 1
  	j compression_case_loop

to_compress:
    # Perform compression on the last character
  	xor $t6, $t6, $t6
  	sb $t0, temp
  	la $a0, buffer
  	la $a1, dict
  	la $s0, codes
  	jal do_compression


writ_to_file:   
  # Clear the path variable 
  	la $t0, path
  	li $t1, 64
  	jal zero_loop

  # Prompt the user for the compression file path
  	li $v0, 4
  	la $a0, enter_path_compression_file
  	syscall

  # Read the user's input for the compression file path
  	li $v0, 8
  	la $a0, path
  	li $a1, 64
  	syscall

  # Remove trailing newline from the compression file path  
  	la $a2, path
  	jal remove
 
  # Open the compression file in write mode 
  	li $v0, 13
  	la $a0, path
  	li $a1, 1
  	li $a2, 0
  	syscall
 
  # Write the compressed data to the compression file 
  	move $s0, $v0
  	la $a3, compressed_data
  	la $t0, compressed_data
  	xor $t1, $t1, $t1
  	
write_loop_compress_case:
  # Write a new line to the compression file
  	lb $t1, ($t0)
  	beqz $t1, write_line_compress_case
  	sb $t1, temp
  	move $a0, $s0
  	li $v0, 15
  	la $a1, temp
  	li $a2, 1
  	syscall
  	li $t1, '\0'
  	sb $t1, ($t0)
  	addiu $t0, $t0, 1
	j write_loop_compress_case
  
write_line_compress_case:
  	lw $t7, size_compressed
  	addiu $t7, $t7, 1
  	sw $t7, size_compressed
  	move $a0, $s0
  	li $v0, 15
  	la $a1, new_line
  	li $a2, 1
  	syscall
  
  	addiu $a3, $a3, 32
  	lb $t1, ($a3)
  	beqz $t1, compress_done
  	move $t0, $a3
  	j write_loop_compress_case
  
compress_done:
  # Close the compression file
  	li $v0, 16
  	move $a0, $s0
  	syscall
  	
  # Write the dictionary to a file
  	jal write_dictionary_to_file
  
  # Print the compression ratio
  	li $v0, 4
  	la $a0, ratio
  	syscall
  
  # Calculate and print the compression ratio
    	la $t0, size_uncompressed
    	lwc1 $f0, 0($t0) # Load first number into $f0
    	la $t1, size_compressed
    	lwc1 $f1, 0($t1) # Load second number into $f1

  
  	div.s $f12, $f0, $f1 # Calculate the compression ratio
  
  	li $v0, 2
  	syscall

#=======================================================================================
#--------------------------decompress---------------------------------------------------
#=======================================================================================    
# Clear the decompressed text, data to decompress, and compressed data variables
  	la $t0, decompressed_text  
  	li $t1, 8192
  	jal zero_loop
  	la $t0, data_to_decompress  
  	li $t1, 8192
  	jal zero_loop
  	la $t0, compressed_data  
  	li $t1, 8192
  	jal zero_loop
  	j goto_menu

decompress:

  # Print the file prompt to the user
  	li $v0, 4
  	la $a0, compress_file
  	syscall 
  	
  # Prompt the user to enter the file path
  	la $t0, path  
  	li $t1, 64
  	jal zero_loop
  
  # Read the user's input
  	li $v0, 8
  	la $a0, path
  	li $a1, 64
  	syscall
 
 # Remove newline character from the file path
  	la $a2, path
  	jal remove

  	li $v0, 4
  	la $a0, new_line
  	syscall
    
  # Open the input file in read mode
  	li $v0, 13
  	la $a0, path
  	li $a1, 0  # read mode
  	li $a2, 0
  	syscall
  
  # Check if the file exists
  	bltz $v0, file_does_not_exist
  
  	move $s6, $v0  # save file descriptor
  	
# Initialize variables for decompression
  	la $a3, data_to_decompress
  	move $t2, $a3
  	
read_file_d:  
  # Read a byte from the input file
  	li $v0, 14
  	move $a0, $s6
  	la $a1, temp
  	li $a2, 1
  	syscall
  	
  # Check if the byte is null character  	
  	xor $t3, $t3, $t3
  	xor $t4, $t4, $t4
  	lb $t3, temp
  	beqz $t3, done_reading_d
  	
 # Check if the byte is newline character  	
  	li $t4, '\n'
  	beq $t3, $t4, next_line_d
  	
 # Store the byte in decompressed data 	
  	sb $t3, ($t2)
  	sb $0, number_of_line
  	addiu $t2, $t2, 1
  	j read_file_d
  
next_line_d:
  # Increment the number of newlines encountered
    	xor $t3, $t3, $t3
    	addiu $t3, $t3, 1
    	xor $t4, $t4, $t4
    	lb $t4,number_of_line
    	add $t3, $t3, $t4
    	bgt $t3, 2, done_reading_d

 # Store the number of newlines in the decompressed data
    	sb $t3, number_of_line
    	
 # Move to the next line in the decompressed data   
    	addiu $a3, $a3, 32
    	move $t2, $a3
    	j read_file_d
    	
done_reading_d:
    	move $a0, $s6      # Close the input file
    	li $v0, 16
    	syscall
 
  # Perform decompression       
    	la $a2, data_to_decompress
    	la $a3, decompressed_text
    	la $t0, dict
    	la $t1, codes
    	jal do_decompression
    	
  # Prompt the user to enter the decompression file path    	
    	li $v0, 4
    	la $a0, enter_path_decompression_file
    	syscall
    
     	la $t0, path  
  	li $t1, 64
  	jal zero_loop
  
  # Read the user's input
  	li $v0, 8
  	la $a0, path
  	li $a1, 64
  	syscall
  
  	la $a2, path
  	jal remove

  	li $v0, 4
  	la $a0, new_line
  	syscall
    
  # Open the input file in read mode
  	li $v0, 13
  	la $a0, path
  	li $a1, 1 
  	li $a2, 0
  	syscall
  
  	move $s6, $v0  # save file descriptor
  
  	la $t0, decompressed_text
  	move $t2, $t0
  	xor $t1, $t1, $t1

 #The code writes each character from the compressed data to a file until it encounters a zero byte. 
 #After that, it zeros out the memory buffers and prepares for further operations  	
write_decompression_to_file:
    	lb $t1, ($t2)    # Load a character from the compressed data
    
    	beqz $t1, next_index  # If the character is zero, go to the next index
    	sb $t1, temp          # Store the character in a temporary location
    	
  # Write the character to the file   	
    	li $v0, 15               # Load the system call number for writing to a file
    	move $a0, $s6            # Move the file descriptor to $a0
    	la $a1, temp           # Load the address of the character to write to $a1
    	li $a2, 1            # Set the length of the data to write to 1 byte
    	syscall               # Perform the system call
    	
    	 # Increment the compressed data index
    	addiu $t2, $t2, 1
    	j write_decompression_to_file
    
next_index:
      	addiu $t0, $t0, 32     # Increment the decompressed data index by 32
      	move $t2, $t0          # Set the compressed data index to the new value
      	lb $t1, ($t2)         # Load a character from the compressed data
      	
      	# If the character is not zero, go back to writing
      	bnez $t1, write_decompression_to_file
      
  	la $t0, decompressed_text  
  	li $t1, 8192
  	jal zero_loop
  	la $t0, data_to_decompress  
  	li $t1, 8192
  	jal zero_loop
  	la $t0, compressed_data  
  	li $t1, 8192
  	jal zero_loop
  	j goto_menu
  
file_does_not_exist:
  	li $v0, 4
  	la $a0, file_not_exist
  	syscall
  	j exit

exit:
  	li $v0, 10
  	syscall
 
  # Zero out the memory buffers 
zero_loop: 
    	sb $zero, 0($t0) # Store byte of zero at memory location
    	addiu $t0, $t0, 1  # Increment memory address
    	addiu $t1, $t1, -1 # Decrement count
    	bnez $t1, zero_loop  # If count not zero, loop again
    	jr $ra
    
strcpy: 
    	lbu $t1, 0($a0)        # Load a byte from the source string
    	sb $t1, 0($a1)         # Store the byte in the destination string
    	beqz $t1, end_strcpy   # If the byte is zero, go to the end
    	addiu $a0, $a0, 1      # Increment the source string address
    	addiu $a1, $a1, 1     # Increment the destination string address
    	j strcpy              # Go back to copying

end_strcpy:
    	jr $ra

#--------------------------------------------            
hex_to_string:
    
    	li $v0, 0x30      # Store '0' ASCII code
    	sb $v0, 0($a0)    # Store '0' at hexString[0]

    	li $v0, 0x78      # Store 'x' ASCII code
    	sb $v0, 1($a0)    # Store 'x' at hexString[1]

    	la $a1, hex  	  # Load the address of 'hexChars' into $a1

    	srl $t1, $t0, 12  # Shift the count 12 bits to the right
    	andi $t1, $t1, 0xf # Mask the lower four bits
    	addu $t1, $a1, $t1 # Calculate the address of the corresponding hex char
    	lbu $v0, 0($t1)   # Load the corresponding hex char
    	sb $v0, 2($a0)    # Store the first hex digit

    	srl $t1, $t0, 8   # Shift the count 8 bits to the right
    	andi $t1, $t1, 0xf # Mask the lower four bits
    	addu $t1, $a1, $t1 # Calculate the address of the corresponding hex char
    	lbu $v0, 0($t1)   # Load the corresponding hex char
    	sb $v0, 3($a0)    # Store the second hex digit

    	srl $t1, $t0, 4   # Shift the count 4 bits to the right
    	andi $t1, $t1, 0xf # Mask the lower four bits
    	addu $t1, $a1, $t1 # Calculate the address of the corresponding hex char
    	lbu $v0, 0($t1)   # Load the corresponding hex char
    	sb $v0, 4($a0)    # Store the third hex digit

    	andi $t1, $t0, 0xf # Mask the lower four bits
    	addu $t1, $a1, $t1 # Calculate the address of the corresponding hex char
    	lbu $v0, 0($t1)   # Load the corresponding hex char
    	sb $v0, 5($a0)    # Store the fourth hex digit

    	li $v0, 0x0       # Store null terminator
    	sb $v0, 6($a0)    # Store null terminator at hexString[6]
    	jr $ra
#---------------------------------------------
remove:
    	lb $a3, ($a2)    # Load character at index
    	addi $a2,$a2,1      # Increment index
    	bnez $a3,remove     # Loop until the end of string is reached
    	beq $a1,$a2,skip    # Do not remove \n when string = maxlength
    	subiu $a2,$a2,2     # If above not true, Backtrack index to '\n'
    	sb $0, ($a2)    # Add the terminating character in its place
    	
skip:
    	jr $ra 


remove_trail:  
  	addiu   $sp, $sp, -4 # Prepare stack
  	sw      $ra, 0($sp)  # Save return address
  	addu    $t0, $a0, $zero # Copy the string address

# Find the end of the string
loop1:
    	lbu     $t1, 0($t0)  # Load byte
    	beqz    $t1, end_loop1 # If byte is 0 (end of string), exit loop
    	addiu   $t0, $t0, 1  # Move to the next character
    	j       loop1
    	
end_loop1:
    	addiu   $t0, $t0, -1  # Go back one character (to the last non-null character)

# Remove trailing '0x000000d' characters
loop2:
    	lbu     $t1, 0($t0)  # Load byte
    	bne     $t1, 13, end_loop2 # If byte is not '0x000000d', exit loop
    	sb      $zero, 0($t0) # Replace character with null
    	addiu   $t0, $t0, -1  # Move to the previous character
    	j       loop2
end_loop2:
    	lw      $ra, 0($sp)  # Restore return address
    	addiu   $sp, $sp, 4  # Restore stack pointer
    	jr      $ra          # Return to caller

do_compression: 
  	move $t0, $s5
  	move $s1, $a0
  	beqz $t0, add_new_data
  
dictionary_loop:
    	lb $t1, ($a0)
    	lb $t2, ($a1)
    # Check if we've reached the end of both strings
    	or $t3, $t1, $t2
    		beqz $t3, equal
    
    	sub $t3, $t1, $t2
    	bnez $t3, not_equal
    
    	addiu $a0, $a0, 1
    	addiu $a1, $a1, 1
    
    	j dictionary_loop
    
equal:
  
      	xor $t6, $t6, $t6
      	addiu $t6, $t6, 6
      	move $t7, $a2
      	move $t8, $s0
      	li $v0, 4
      	move $a0, $s0
      	syscall
      
copy_code:
        beqz $t6, copy_done
        lb $t9, ($t8)
        sb $t9, ($t7)
        subiu $t6, $t6, 1
        addiu $t7, $t7, 1
        addiu $t8, $t8, 1
        j copy_code
                  
copy_done:
     
        addiu $s0, $s0, 32
        addiu $a2, $a2, 32
      	jr $ra
    
not_equal:
      	addiu $a1, $a1, 32
      	addiu $s0, $s0, 32
      	subiu $t0, $t0, 1
      	beqz $t0, add_new_data
      
      	move $a0, $s1
      	j dictionary_loop
      
add_new_data:
     	move $a0, $s1
     	move $t7, $a0
     	move $t8, $a1
     
put_word_in_dictionary:
       lb $t6, ($t7)
       beqz $t6, done_put_in_dictionary
       sb $t6, ($t8)
       addiu $t7, $t7, 1
       addiu $t8, $t8, 1
       j put_word_in_dictionary
       
done_put_in_dictionary:
      xor $t6, $t6, $t6
      addiu $t6, $t6, 6
      move $t7, $a2
      move $t8, $s0

copy_code1:
        beqz $t6, copy_done1
        lb $t9, ($t8)
        sb $t9, ($t7)
        subiu $t6, $t6, 1
        addiu $t8, $t8, 1
        addiu $t7, $t7, 1
        j copy_code1
        
copy_done1:
        addiu $a2, $a2, 32
        addiu $s0, $s0, 32
        addiu $s5, $s5, 1
        
        jr $ra

do_decompression: 
  	move $t2, $a2
  	move $t3, $a3
  	move $t4, $t0
  	move $t5, $t1

dictionary_loop1:
  
    	xor $t6,  $t6, $t6
    	xor $t7, $t7, $t7
    
    	lb $t6, ($t4)
    	beqz $t6, error_message
    
    	lb $t6, ($t5)
    	lb $t7, ($t2)
    	or $t8, $t6, $t7
    	beqz $t8, equal_1
    
    	sub $t8, $t6, $t7
    	bnez $t8, not_equal1
    
    	addiu $t5, $t5, 1
    	addiu $t2, $t2, 1
    	j dictionary_loop1
    
equal_1:
    	move $t7, $t4
    	move $t8, $t3
    
copy_d:
      	lb $t6, ($t7)
      	beqz $t6, copy_d_done
      	sb $t6, ($t8)
      	addiu $t7, $t7, 1
      	addiu $t8, $t8, 1
      	j copy_d
      
copy_d_done:
    	move $a0, $a3
    	li $v0, 4
    	syscall
      	move $t4, $t0
      	move $t5, $t1
      	addiu $a2, $a2, 32
      	addiu $a3, $a3, 32
      	move $t2, $a2
      	move $t3, $a3
      	lb $t8, ($t2)
      	beqz $t8, decompression_done
      	j dictionary_loop1
    
not_equal1:
   	addiu $t4, $t4, 32
   	addiu $t5, $t5, 32
   	move $t2, $a2
   	move $t3, $a3
   	subiu $t5, $t5, 5
   	j dictionary_loop1
   
error_message:
      	li $v0, 4
      	la $a0, error_in_decomp
      	syscall
      	j exit
      
decompression_done:
        jr $ra  
    
write_dictionary_to_file:
  	la $s0, codes
  	la $s1, dict
  	la $a0, dictionaryfile
  	li $a1, 1
  	li $a2, 0
  	li $v0, 13
  	syscall
  	move $s2, $v0
  
initialize_t_registers:
    	move $t0, $s0
    	move $t1, $s1
    
write_dictionary_code_loop:
      	lb $t2, ($t0)
      	sb $t2, temp
      	beqz $t2, write_dictionary_string
      	move $a0, $s2
      	la $a1, temp
      	li $a2, 1
      	li $v0, 15
      	syscall
      	addiu $t0, $t0, 1
      	j write_dictionary_code_loop
      
write_dictionary_string:
        li $t2, ' '
        sb $t2, temp
        move $a0, $s2
        la $a1, temp
        li $a2, 1
        li $v0, 15
        syscall
        
write_dictionary_string_loop:
        lb $t2, ($t1)
        sb $t2, temp
        beqz $t2, write_dictionary_done
        move $a0, $s2
        la $a1, temp
        li $a2, 1
        li $v0, 15
        syscall
        addiu $t1, $t1, 1
        j write_dictionary_string_loop
          
write_dictionary_done: 
        li $t2, '\n'
        sb $t2, temp
        move $a0, $s2
        la $a1, temp
        li $a2, 1
        li $v0, 15
        syscall
  	addiu $s0, $s0, 32
  	addiu $s1, $s1, 32
  	lb $t2, ($s1)
  	beqz $t2, writing_dictionary_done
  	j initialize_t_registers
  	
 writing_dictionary_done:
  	jr $ra
