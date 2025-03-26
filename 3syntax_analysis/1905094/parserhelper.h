#include<bits/stdc++.h>

#include "symbol_table.h"

using namespace std;

class Parserhelper {

public:
    string data;
    string token;
    vector<SymbolInfo*> var_list;
    vector<string> arg_list;
    string type;
    string code;
    int start_line;
    int end_line;
    vector<SymbolInfo*> children;

    
};

// extern ofstream plog;
// extern ofstream perror;
// extern ofstream llog;
// extern ofstream ltok;
// extern SymbolTable symbol_table;
// extern int yylineno;
// extern int error_count;
// extern void yyerror(string str);



// void print_parser_grammer(string left, string right){
//     plog<<"Line: "<<yylineno<<": "<< left << ": "<<right<<"\n"<<endl;
// }

// void print_parser_text(string data){
//     plog << data << "\n" <<endl;
// }


