## How to use the makefile:
### 1) make setup
"make setup" sets up a new directory called code_output.

### 2) make 
"make" runs each program and stores the output obtained in the code_output folder. 

### 3) make diff
"make diff" compares the difference between the expected outputs and computed outputs

## Added Features:
Necessary code written:
1) compiler.l
2) Makefile

Compared {correctly} to expected output:
1) fibonacci.out
2) loop.out
3) nested.out
4) sqrt.out

## Known issues:
1) In case the linking does not work, (this is a possibility on Linux Machines)
Change the LLFLAG to -lfl. (MacOS Big Sur requires it to be -ll, still investigating the issue.)


## Acknowledgements:
# Code : Qifan Chang and Zixian Lai
# Comments : Mehul Bose (170030010), Shivam Chaturvedi (180010032), Rutik Dadhania (180010013), Brinal Savsaviya (180010030), Akhilesh Bharadwaj (180010029)

