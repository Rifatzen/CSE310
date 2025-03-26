#!/bin/bash

# yacc -d -y simplecalc.y
# echo 'Generated the parser C file as well the header file'
# g++ -w -c -o y.o y.tab.c
# echo 'Generated the parser object file'
# flex simplecalc.l
# echo 'Generated the scanner C file'
# g++ -w -c -o l.o lex.yy.c
# # if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
# echo 'Generated the scanner object file'
# g++ y.o l.o -lfl -o simplecalc
# echo 'All ready, running'
# ./simplecalc


yacc -d -y 1905094.y 
g++ -w -c -o y.o y.tab.c
flex 1905094.l
g++ -w -c -o l.o lex.yy.c 
g++ y.o l.o -lfl -o parser 
# ./parser sserror.c
#./parser noerror.c
./parser loop.c
g++ optimize.cpp
./a.out