#####################################################################
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Aabid Anas, 1007187982
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the number of lives remaining
# 2. After final player death, display gameover/retry screen. Restart the game if the
#    “retry” option is chosen.
# 3. Make the frog point in the direction that it’s traveling.
# 4. Add sound effects for movement, losing lives, collisions, and reaching the goal.
# 5. Displaying a pause screen or image when the ‘p’ key is pressed, and returning to
#    the game when ‘p’ is pressed again.
# 6. Hard feature: Display the player’s score at the top of the screen.
#
# Any additional information that the TA needs to know:
# - Collisions only work correctly for the bottom two cars
#
#####################################################################
.data
displayAddress: .word 0x10008000
rect_x:	        .word 1024
rect_y:		.word 0
wait_time:	.word 17	 # sleeping for 17 milliseconds --> We need to update screen 60 times per second, and 1 ms = 1/1000 s
log_x:		.word 0
log_y:		.word 1024
log_row1:	.space 512
log_row2:	.space 512
car_row1:	.space 512
car_row2:	.space 512
gameOver:	.asciiz "You died. Click ok to replay.\n"
youWin:		.asciiz "You won! Click ok to replay.\n"

.text
addi $s7, $0, 3 # Number of lives remaining. This number goes down everytime you die.
startedFromTheBottom:
lw $t0, displayAddress # $t0 stores the base address for display
addi $s1, $t0, 3584 #set $s1 to (0, 3584) i.e., top left corner of start zone
addi $a1, $0, 0 # y location of frog <-- 0 <= y <= 28
addi $s3, $0, 16 # x location of frog <-- 0 <= x <= 28
addi $a2, $0, 0 # How much to move bottom row of logs/cars
addi $s4, $0, 0 #Check if we've reached left/right limit for first row of logs/cars
addi $s2, $0, 0 #Check if we've reached left/right limit for second row of logs/cars
addi $s5, $0, 0 #Boolean to see if we're moving logs forward or backwards
addi $s6, $zero, 0
process_loop:
lw $t9, 0xffff0000            # Get the status for the input keys
lw $t0, displayAddress # $t0 stores the base address for display
#####################################################################

paint8:
paintEndZone:
li $t4, 0x00ff00 # $t4 stores the green colour code
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 32 # set $t6 to 32
jal paint8Rectangle

display_lives:
li $t4, 0xE13102 # $t4 is red now
beq $s7, 3, display_three_lives
beq $s7, 2, display_two_lives
beq $s7, 1, display_one_life

display_three_lives:
sw $t4, 116($t0)

display_two_lives:
sw $t4, 108($t0)

display_one_life:
sw $t4, 100($t0)
j display_score

display_score:
li $t4, 0xFFFFFF
beq $a1, 0, paintWater
beq $a1, 4, one
beq $a1, 8, two
beq $a1, 12, three
beq $a1, 16, four
beq $a1, 20, five
beq $a1, 24, six

one:
sw $t4, -124($t0)
sw $t4, 4($t0)
sw $t4, 132($t0)
beq $a1, 24, won
j paintWater

two:
sw $t4, -116($t0)
sw $t4, 12($t0)
sw $t4, 140($t0)
j one

three:
sw $t4, -108($t0)
sw $t4, 20($t0)
sw $t4, 148($t0)
j two

four:
sw $t4, -100($t0)
sw $t4, 28($t0)
sw $t4, 156($t0)
j three

five:
sw $t4, 0($t0)
sw $t4, 8($t0)
sw $t4, 16($t0)
sw $t4, 24($t0)
sw $t4, 32($t0)
j four

six:
sw $t4, -88($t0)
sw $t4, 40($t0)
sw $t4, 168($t0)
j five

############################DRAWING BACKGROUND###################################
paintWater:
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 32 # set $t6 to 32
li $t4, 0x0000ff # update colour value to blue
addi $t0, $t0, 896
jal paint8Rectangle

paintRoad:
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 32 # set $t6 to 32
li $t4, 0x808080 # update colour value to grey
addi $t0, $t0, 1408 # should be 1280
jal paint8Rectangle
j paintSafeZone

paint8Rectangle:
beq $t5, $t6, end8_rect

sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 128 # Move to the first unit on the second row
sw $t4, 0($t0) # Paint the first unit of the second row green
addi $t0, $t0, 128 # Move to the first unit on the third row
sw $t4, 0($t0) # Paint the first unit of the third row green
addi $t0, $t0, 128 # Move to the first unit on the fourth row
sw $t4, 0($t0) # Paint the first unit of the fourth row green
addi $t0, $t0, 128 # Move to the first unit on the fifth row
sw $t4, 0($t0) # Paint the first unit of the fifth row green
addi $t0, $t0, 128 # Move to the first unit on the sixth row
sw $t4, 0($t0) # Paint the first unit of the sixth row green
addi $t0, $t0, 128 # Move to the first unit on the seventh row
sw $t4, 0($t0) # Paint the first unit of the seventh row green
addi $t0, $t0, 128 # Move to the first unit on the eight row
sw $t4, 0($t0) # Paint the first unit of the eigth row green

addi $t0, $t0, -892 # Move up to the first row ((6*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j paint8Rectangle

end8_rect:
jr $ra 			# jump back to the calling program

paint4:
paintSafeZone:
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 32 # set $t6 to 32
li $t4, 0xff0000 #Update colour value to red
addi $t0, $t0, -640
jal paint4Rectangle

paintStartZone:
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 32 # set $t6 to 32
li $t4, 0x00ff00 # Update colour value to green
addi $t0, $t0, 1408
jal paint4Rectangle
beq $s5, $0, moveForward1
bne $s5, $0, moveBack1

paint4Rectangle:
beq $t5, $t6, end4_rect # Branch to end4_rect if $t5 == 32
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 128 # Move to the first unit on the second row
sw $t4, 0($t0) # Paint the first unit of the second row green
addi $t0, $t0, 128 # Move to the first unit on the third row
sw $t4, 0($t0) # Paint the first unit of the third row green
addi $t0, $t0, 128 # Move to the first unit on the fourth row
sw $t4, 0($t0) # Paint the first unit of the fourth row green

addi $t0, $t0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j paint4Rectangle

end4_rect:
jr $ra 			# jump back to the calling program

#########################################DRAWING TOP ROW OF LOGS######################
reached_end1:
not $s5, $s5
beq $s5, $0, moveForward1
bne $s5, $0, moveBack1

moveForward1:
beq $s4, 9, reached_end1 #moveBack
addi $s6, $s6, 4
add $t0, $t0, $s6
addi $s4, $s4, 1
j drawLogs1

moveBack1:
beq $s4, 1, reached_end1 #moveForward
addi $s6, $s6, -4
add $t0, $t0, $s6
addi $s4, $s4, -1
j drawLogs1

drawLogs1: #drawing the logs
addi $t0, $t0, -132 
li $t4, 0x964b00 #set the colour of the logs to brown

row1Log1:
addi $t7, $0, 0 #initialize a temporary variable to indicate which log we're on
addi $t0, $t0, -2560 #set position of first log to top left corner of water
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 8 # set $t6 to 8
addi $s0, $t0, 0

drawRow1Log1:
beq $t5, $t6, row1Log2
sw $t4, 0($s0) # Paint the first unit of the first row brown
addi $s0, $s0, 128 # Move to the first unit on the second row
sw $t4, 0($s0) # Paint the first unit of the second row brown
addi $s0, $s0, 128 # Move to the first unit on the third row
sw $t4, 0($s0) # Paint the first unit of the third row brown
addi $s0, $s0, 128 # Move to the first unit on the fourth row
sw $t4, 0($s0) # Paint the first unit of the fourth row brown

addi $s0, $s0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j drawRow1Log1

row1Log2:
addi $t8, $0, 0 #create another temporary variable, which like $t7, should be 0 on the first run
addi $t7, $t7, 4 #increase $t7 so that next time, $t7 != $t8 and so we're done for this row
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 8 # set $t6 to 8
addi $s0, $t0, 64 #make the next object on the same row 64 bits to the right of the current object

drawRow1Log2:
beq $t5, $t6, drawCars
sw $t4, 0($s0) # Paint the first unit of the first row brown
addi $s0, $s0, 128 # Move to the first unit on the second row
sw $t4, 0($s0) # Paint the first unit of the second row brown
addi $s0, $s0, 128 # Move to the first unit on the third row
sw $t4, 0($s0) # Paint the first unit of the third row brown
addi $s0, $s0, 128 # Move to the first unit on the fourth row
sw $t4, 0($s0) # Paint the first unit of the fourth row brown

addi $s0, $s0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j drawRow1Log2
#########################################DRAWING TOP ROW OF CARS#######################
drawCars: #drawing the cars
li $t4, 0xffd700 #set the colour of the cars to gold

row1Car1:
addi $t7, $0, 0 #initialize a temporary variable to indicate which car we're on
addi $t0, $t0, 1536 #set position of first car to top left corner of road
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 8 # set $t6 to 8
addi $s0, $t0, 0


drawRow1Car1:
beq $s0, $s1, died
beq $t5, $t6, row1Car2
sw $t4, 0($s0) # Paint the first unit of the first row brown
addi $s0, $s0, 128 # Move to the first unit on the second row
sw $t4, 0($s0) # Paint the first unit of the second row brown
addi $s0, $s0, 128 # Move to the first unit on the third row
sw $t4, 0($s0) # Paint the first unit of the third row brown
addi $s0, $s0, 128 # Move to the first unit on the fourth row
sw $t4, 0($s0) # Paint the first unit of the fourth row brown

addi $s0, $s0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j drawRow1Car1

row1Car2:
addi $t8, $0, 0 #create another temporary variable, which like $t7, should be 0 on the first run
addi $t7, $t7, 4 #increase $t7 so that next time, $t7 != $t8 and so we're done for this row
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 8 # set $t6 to 8
addi $s0, $t0, 64 #make the next object on the same row 64 bits to the right of the current object

drawRow1Car2:
beq $s0, $s1, died
beq $t5, $t6, row2
sw $t4, 0($s0) # Paint the first unit of the first row brown
addi $s0, $s0, 128 # Move to the first unit on the second row
sw $t4, 0($s0) # Paint the first unit of the second row brown
addi $s0, $s0, 128 # Move to the first unit on the third row
sw $t4, 0($s0) # Paint the first unit of the third row brown
addi $s0, $s0, 128 # Move to the first unit on the fourth row
sw $t4, 0($s0) # Paint the first unit of the fourth row brown

addi $s0, $s0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j drawRow1Car2

#################################DRAWING BOTTOM ROW OF LOGS######################################################
row2:
beq $s5, $0, moveBack2
bne $s5, $0, moveForward2

reached_end2:
not $s5, $s5
beq $s5, $0, moveForward2
bne $s5, $0, moveBack2

moveForward2:
beq $s2, 1, reached_end2 #moveBack
addi $a2, $a2, 8 #Move 8 units to right (NOT 4 because if it were 4, it would be stuck with opposite direction)
add $t0, $t0, $a2 #Add the distance to move to right to $t0
addi $s2, $s2, -1
j drawLogs2

moveBack2:
beq $s2, 9, reached_end2 #moveForward
addi $a2, $a2, -8
add $t0, $t0, $a2
addi $s2, $s2, 1
j drawLogs2

drawLogs2: #drawing the logs
addi $t0, $t0, -984 #-128
li $t4, 0x964b00 #set the colour of the logs to brown

row2Log1:
addi $t7, $0, 0 #initialize a temporary variable to indicate which log we're on
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 8 # set $t6 to 8
addi $s0, $t0, 0

drawRow2Log1:
beq $t5, $t6, row2Log2
sw $t4, 0($s0) # Paint the first unit of the first row brown
addi $s0, $s0, 128 # Move to the first unit on the second row
sw $t4, 0($s0) # Paint the first unit of the second row brown
addi $s0, $s0, 128 # Move to the first unit on the third row
sw $t4, 0($s0) # Paint the first unit of the third row brown
addi $s0, $s0, 128 # Move to the first unit on the fourth row
sw $t4, 0($s0) # Paint the first unit of the fourth row brown

addi $s0, $s0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j drawRow2Log1

row2Log2:
addi $t8, $0, 0 #create another temporary variable, which like $t7, should be 0 on the first run
addi $t7, $t7, 4 #increase $t7 so that next time, $t7 != $t8 and so we're done for this row
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 8 # set $t6 to 8
addi $s0, $t0, 64 #make the next object on the same row 64 bits to the right of the current object

drawRow2Log2:
beq $s0, $s1, died
beq $t5, $t6, drawCars2
sw $t4, 0($s0) # Paint the first unit of the first row brown
addi $s0, $s0, 128 # Move to the first unit on the second row
sw $t4, 0($s0) # Paint the first unit of the second row brown
addi $s0, $s0, 128 # Move to the first unit on the third row
sw $t4, 0($s0) # Paint the first unit of the third row brown
addi $s0, $s0, 128 # Move to the first unit on the fourth row
sw $t4, 0($s0) # Paint the first unit of the fourth row brown

addi $s0, $s0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j drawRow2Log2

#####################################DRAWING BOTTOM ROW OF CARS###############################
drawCars2: #drawing the cars
li $t4, 0xffd700 #set the colour of the cars to gold

row2Car1:
addi $t7, $0, 0 #initialize a temporary variable to indicate which car we're on
addi $t0, $t0, 1536 #set position of first car to top left corner of road
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 8 # set $t6 to 8
addi $s0, $t0, 0

drawRow2Car1:
beq $s0, $s1, died
beq $t5, $t6, row2car2
sw $t4, 0($s0) # Paint the first unit of the first row brown
addi $s0, $s0, 128 # Move to the first unit on the second row
sw $t4, 0($s0) # Paint the first unit of the second row brown
addi $s0, $s0, 128 # Move to the first unit on the third row
sw $t4, 0($s0) # Paint the first unit of the third row brown
addi $s0, $s0, 128 # Move to the first unit on the fourth row
sw $t4, 0($s0) # Paint the first unit of the fourth row brown

addi $s0, $s0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j drawRow2Car1

row2car2:
addi $t8, $0, 0 #create another temporary variable, which like $t7, should be 0 on the first run
addi $t7, $t7, 4 #increase $t7 so that next time, $t7 != $t8 and so we're done for this row
add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 8 # set $t6 to 8
addi $s0, $t0, 64 #make the next object on the same row 64 bits to the right of the current object

drawRow2Car2:
beq $s0, $s1, died
beq $t5, $t6, drawFrog
sw $t4, 0($s0) # Paint the first unit of the first row brown
addi $s0, $s0, 128 # Move to the first unit on the second row
sw $t4, 0($s0) # Paint the first unit of the second row brown
addi $s0, $s0, 128 # Move to the first unit on the third row
sw $t4, 0($s0) # Paint the first unit of the third row brown
addi $s0, $s0, 128 # Move to the first unit on the fourth row
sw $t4, 0($s0) # Paint the first unit of the fourth row brown

addi $s0, $s0, -380 # Move up to the first row ((2*-128) -124)

addi $t5, $t5, 1 # increment $t5 by 1
j drawRow2Car2

#############################LOSE A LIFE###########################
died:
addi $a1, $a1, 500
li $v0, 31
la $a0, 1
la $a3, 127
syscall
addi $a1, $a1, -500

addi $s7, $s7, -1
bne $s7, 0, startedFromTheBottom
lw $t0, displayAddress
li $t4, 0x00ff00 # $t4 stores the green colour code
sw $t4, 228($t0)
li $v0, 55
la $a0, gameOver
li $a1, 1

syscall
addi $s7, $0, 3 # Number of lives remaining. This number goes down everytime you die.
j startedFromTheBottom

####################################WON GAME##############################
won:
li $v0, 33
la $a0, 75
li $a1, 1000
la $a3, 127
syscall

lw $t0, displayAddress
li $t4, 0x00ff00 # $t4 stores the green colour code
sw $t4, 228($t0)
li $v0, 55
la $a0, youWin
li $a1, 1

syscall
addi $s7, $0, 3 # Number of lives remaining. This number goes down everytime you die.
j startedFromTheBottom

#####################################DRAWING FROG##################################
drawFrog:
li $t4, 0xcc8899 #set the colour of frog to purple

movement:
beq $t9, 0, redraw
beq $t9, 1, keyboard_input    # If the value is 1, then the ASCII value of the key that was pressed will be found in the next integer in memory

keyboard_input:
lw $t1, 0xffff0004
beq $t1, 0x77, moveFrogUp
beq $t1, 0x73, moveFrogDown
beq $t1, 0x64, moveFrogRight
beq $t1, 0x61, moveFrogLeft
beq $t1, 0x70, pause
j endOfLoop

startDrawFrog:
bne $a1, $0, movement
#The next few lines initialize the starting position of the frog
redraw:
beq $t1, 0x77, redrawUp
beq $t1, 0x73, redrawDown
beq $t1, 0x64, redrawRight
beq $t1, 0x61, redrawLeft

redrawUp:
sw $t4, 64($s1)
sw $t4, 76($s1)
sw $t4, 192($s1)
sw $t4, 196($s1)
sw $t4, 200($s1)
sw $t4, 204($s1)
sw $t4, 324($s1)
sw $t4, 328($s1)
sw $t4, 448($s1)
sw $t4, 452($s1)
sw $t4, 456($s1)
sw $t4, 460($s1)

j endOfLoop

redrawDown:
sw $t4, 64($s1)
sw $t4, 68($s1)
sw $t4, 72($s1)
sw $t4, 76($s1)
sw $t4, 196($s1)
sw $t4, 200($s1)
sw $t4, 320($s1)
sw $t4, 324($s1)
sw $t4, 328($s1)
sw $t4, 332($s1)
sw $t4, 448($s1)
sw $t4, 460($s1)

j endOfLoop

redrawRight:
sw $t4, 64($s1)
sw $t4, 72($s1)
sw $t4, 76($s1)
sw $t4, 192($s1)
sw $t4, 196($s1)
sw $t4, 200($s1)
sw $t4, 320($s1)
sw $t4, 324($s1)
sw $t4, 328($s1)
sw $t4, 448($s1)
sw $t4, 456($s1)
sw $t4, 460($s1)

j endOfLoop

redrawLeft:
sw $t4, 64($s1)
sw $t4, 68($s1)
sw $t4, 76($s1)
sw $t4, 196($s1)
sw $t4, 200($s1)
sw $t4, 204($s1)
sw $t4, 324($s1)
sw $t4, 328($s1)
sw $t4, 332($s1)
sw $t4, 448($s1)
sw $t4, 452($s1)
sw $t4, 460($s1)

j endOfLoop


moveFrogUp:
addi $s1, $s1, -512
sw $t4, 64($s1)
sw $t4, 76($s1)
sw $t4, 192($s1)
sw $t4, 196($s1)
sw $t4, 200($s1)
sw $t4, 204($s1)
sw $t4, 324($s1)
sw $t4, 328($s1)
sw $t4, 448($s1)
sw $t4, 452($s1)
sw $t4, 456($s1)
sw $t4, 460($s1)

addi $a1, $a1, 4

#Increase the sound by temporarily increasing the $a1 variable
temp_sound_increase:
addi $a1, $a1, 200
li $v0, 31
la $a0, 100
la $a3, 100
syscall
addi $a1, $a1, -200
j endOfLoop

moveFrogDown:
beq $a1, $zero, endOfLoop
addi $s1, $s1, 512
sw $t4, 64($s1)
sw $t4, 68($s1)
sw $t4, 72($s1)
sw $t4, 76($s1)
sw $t4, 196($s1)
sw $t4, 200($s1)
sw $t4, 320($s1)
sw $t4, 324($s1)
sw $t4, 328($s1)
sw $t4, 332($s1)
sw $t4, 448($s1)
sw $t4, 460($s1)

addi $a1, $a1, -4

j temp_sound_increase

moveFrogRight:
beq $s3, 28, endOfLoop
addi $s1, $s1, 16
sw $t4, 64($s1)
sw $t4, 72($s1)
sw $t4, 76($s1)
sw $t4, 192($s1)
sw $t4, 196($s1)
sw $t4, 200($s1)
sw $t4, 320($s1)
sw $t4, 324($s1)
sw $t4, 328($s1)
sw $t4, 448($s1)
sw $t4, 456($s1)
sw $t4, 460($s1)

addi $s3, $s3, 4

j temp_sound_increase

moveFrogLeft:
beq $s3, $zero, endOfLoop
addi $s1, $s1, -16
sw $t4, 64($s1)
sw $t4, 68($s1)
sw $t4, 76($s1)
sw $t4, 196($s1)
sw $t4, 200($s1)
sw $t4, 204($s1)
sw $t4, 324($s1)
sw $t4, 328($s1)
sw $t4, 332($s1)
sw $t4, 448($s1)
sw $t4, 452($s1)
sw $t4, 460($s1)

addi $s3, $s3, -4

j temp_sound_increase

##################################END OF LOOP CYCLE###############################
endOfLoop:

li $v0, 32	# Loading SLEEP to register $v0
add $a0, $zero, $zero	# initializing $a0, which needs to be the length of time to sleep in ms
la $t7, wait_time # loading address of wait_time to helper variable $t7
lw $t8, 0($t7) # assigning the data stored in $t7 into $t8
add $a0, $t8, $a0 # $a0 is now the time to sleep
syscall
j process_loop

Exit:
li $v0, 10 # terminate the program gracefully
syscall

####################################Pause the game################################
pause:
lw $t0, displayAddress

add $t5, $zero, $zero # set $t5 to zero
addi $t6, $zero, 32 # set $t6 to 32

drawPause:
beq $t5, $t6, writePauseLetters
li $t4, 0x82AC85 # Set background colour to teal
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 128 # Move to the first unit on the second row
sw $t4, 0($t0) # Paint the first unit of the second row green
addi $t0, $t0, 128 # Move to the first unit on the third row
sw $t4, 0($t0) # Paint the first unit of the third row green
addi $t0, $t0, 128 # Move to the first unit on the fourth row
sw $t4, 0($t0) # Paint the first unit of the fourth row green
addi $t0, $t0, 128 # Move to the first unit on the fifth row
sw $t4, 0($t0) # Paint the first unit of the fifth row green
addi $t0, $t0, 128 # Move to the first unit on the sixth row
sw $t4, 0($t0) # Paint the first unit of the sixth row green
addi $t0, $t0, 128 # Move to the first unit on the seventh row
sw $t4, 0($t0) # Paint the first unit of the seventh row green
addi $t0, $t0, 128 # Move to the first unit on the eight row
sw $t4, 0($t0) # Paint the first unit of the eigth row green
addi $t0, $t0, 128 # Move to the first unit on the second row
sw $t4, 0($t0) # Paint the first unit of the second row green
addi $t0, $t0, 128 # Move to the first unit on the third row
sw $t4, 0($t0) # Paint the first unit of the third row green
addi $t0, $t0, 128 # Move to the first unit on the fourth row
sw $t4, 0($t0) # Paint the first unit of the fourth row green
addi $t0, $t0, 128 # Move to the first unit on the fifth row
sw $t4, 0($t0) # Paint the first unit of the fifth row green
addi $t0, $t0, 128 # Move to the first unit on the sixth row
sw $t4, 0($t0) # Paint the first unit of the sixth row green
addi $t0, $t0, 128 # Move to the first unit on the seventh row
sw $t4, 0($t0) # Paint the first unit of the seventh row green
addi $t0, $t0, 128 # Move to the first unit on the eight row
sw $t4, 0($t0) # Paint the first unit of the eigth row green
addi $t0, $t0, 128 # Move to the first unit on the second row
sw $t4, 0($t0) # Paint the first unit of the second row green
addi $t0, $t0, 128 # Move to the first unit on the third row
sw $t4, 0($t0) # Paint the first unit of the third row green
addi $t0, $t0, 128 # Move to the first unit on the fourth row
sw $t4, 0($t0) # Paint the first unit of the fourth row green
addi $t0, $t0, 128 # Move to the first unit on the fifth row
sw $t4, 0($t0) # Paint the first unit of the fifth row green
addi $t0, $t0, 128 # Move to the first unit on the sixth row
sw $t4, 0($t0) # Paint the first unit of the sixth row green
addi $t0, $t0, 128 # Move to the first unit on the seventh row
sw $t4, 0($t0) # Paint the first unit of the seventh row green
addi $t0, $t0, 128 # Move to the first unit on the eight row
sw $t4, 0($t0) # Paint the first unit of the eigth row green
addi $t0, $t0, 128 # Move to the first unit on the second row
sw $t4, 0($t0) # Paint the first unit of the second row green
addi $t0, $t0, 128 # Move to the first unit on the third row
sw $t4, 0($t0) # Paint the first unit of the third row green
addi $t0, $t0, 128 # Move to the first unit on the fourth row
sw $t4, 0($t0) # Paint the first unit of the fourth row green
addi $t0, $t0, 128 # Move to the first unit on the fifth row
sw $t4, 0($t0) # Paint the first unit of the fifth row green
addi $t0, $t0, 128 # Move to the first unit on the sixth row
sw $t4, 0($t0) # Paint the first unit of the sixth row green
addi $t0, $t0, 128 # Move to the first unit on the seventh row
sw $t4, 0($t0) # Paint the first unit of the seventh row green
addi $t0, $t0, 128 # Move to the first unit on the eight row
sw $t4, 0($t0) # Paint the first unit of the eigth row green
addi $t0, $t0, 128 # Move to the first unit on the fifth row
sw $t4, 0($t0) # Paint the first unit of the fifth row green
addi $t0, $t0, 128 # Move to the first unit on the sixth row
sw $t4, 0($t0) # Paint the first unit of the sixth row green
addi $t0, $t0, 128 # Move to the first unit on the seventh row
sw $t4, 0($t0) # Paint the first unit of the seventh row green

addi $t0, $t0, -3964 # Move up to the first row to write PAUSE

addi $t5, $t5, 1 # increment $t5 by 1
j drawPause

writePauseLetters:
lw $t0, displayAddress
li $t4, 0xD70E17 # Set PAUSE colour to red

addi $t0, $t0, 132 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 56 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 16 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 64 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 60 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 16 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 16 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 64 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 16 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 8 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green
addi $t0, $t0, 4 # Move to the next tile
sw $t4, 0($t0) # Paint the first (top-left) unit green

lw $t9, 0xffff0000            # Get the status for the input keys
bne $t9, 1, drawPause    # If the value is NOT 1, then the ASCII value of the key that was pressed will be found in the next integer in memory
lw $t1, 0xffff0004
beq $t1, 0x70, endOfLoop # un-pause
