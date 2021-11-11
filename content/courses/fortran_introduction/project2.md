---
title: "Project 2"
toc: true
type: book
weight: 45

menu:
    fortran_introduction:
        parent: Project 2
        weight: 45
---

A consultant was given a program that has code to generate a [format string](/courses/fortran_introduction/formatted_io) dynamically.  In particular, it can print items that might be arrays, with the repeat value generated automatically.  
For example, given n1=5, n2=1, n3=3 and a pattern '(#e15.8,#i5,#f8.2)' 
the result would be '(5e15.8,1i5,3f8.2)'. However, it didn’t work if any of the n1, n2, n3 variables were two digits.  
The algorithm was convoluted and hard to understand.  It did work for two 
digits if the programmer
used two hash marks, e.g. ##e15.8, but that required hand-editing the several 
files with output routines to find every place she wanted to write out more 
than 9 array elements.  The author of the original code didn’t use any 
character or string 
functions other than substrings. This would surely be implemented more 
generally with better use of strings.  Your task is to come up with a way to 
do this.  
If you have time, come up with a way to handle a 
0 (i.e. skip printing).
Test your program carefully.

_Hints_.  You do not need to use a variable-length string, but if not, be sure to declare a generously-sized set of strings (32 or even 64 characters, for example).  If using a fixed-length string, remember that you will need to remove blank space.  Test your program for n1=10, n2=2, n3=3.  Try another pattern like 
'(#es12.4,#i2,#f15.7,#i4)'.  Suggestion: use an allocatable array for the coefficients (both numerical and character).  Use array size to make sure they match.    
{{< spoiler text="Sample solution" >}}
{{< code file="/courses/fortran_introduction/solns/formatter.f90" lang="fortran" >}}
{{< /spoiler >}}