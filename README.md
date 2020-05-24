# My UW CS Scripts

This is a collection of some scripts that I use for my CS assignments.

## Marmosub

This script is designed to submit assignments to the marmoset grading system.
Proir to submitting the system converts to the files to LF line endings, adds missing newlines at the end of the file, and clang-formats any C/C++ files, then it builds (using make) and finally tests before submitting to marmoset.

### Using Marmosub

1. Ensure that Runsuite is in your Path
2. Ensure that you have a directory with the word "test" in the name
3. Ensure your suite file is in your test directory
4. Add marmosub to your path and run it to submit your assignment.
    - The format of the command: `marmosub COURSE ASSIGNMENT FILE1 FILE2 FILE3`
    - An example: `marmosub CS246 A1Q1 *.cc`
    - If it isn't clear which test or executable to run marmosub will prompt for you to pick which you wish to use.
