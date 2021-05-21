# Adv-Processors_UserInputValidityCheck
Using MIPS Assembly, this program checks for validity of a user-inputted expression via I/O window. The following requirements were met for this project:

The syntax for the expression should follow Matlab rules. Your program should display the prompt “>>>” for entering an expression of up to 64 symbols.  Expressions should include only parentheses, digits from 0 to 9, and letters from a to z (both upper and lower cases), operators +, -, *, /, and “=”. If there is error in an expression, display “Invalid input” in the I/O window; if there is no error, display “Valid input” in the I/O window.
Your program should loop so that users can enter new expressions without re-assembling the program. Your code should be commented.


Error Check List

In the expression entered by users,
1.	Check for allowed symbols
2.	Check for space(s) between digits of a number
3.	Check for uneven number of parentheses
4.	Check for the following errors:

4.1	(/

4.2	(*

4.3	()

4.4	No operator between operand and open parenthesis. Ex: 2(

4.5	No operator between close parenthesis and operand. Ex: )2

4.6	/)

4.7	//

4.8	/*

4.9	+/

4.10	+*

4.11	+)

4.12	-/

4.13	-*

4.14	-)

4.15	**

4.16	*/

4.17	*)

4.18	*/

4.19	*)
