%option noyywrap

%x CHAR_STATE
%x STRING_STATE
%x SINGLE_COMMENT_STATE
%x SINGLE_COMMENT_STATE2
%x MULTI_COMMENT_STATE

%{
#include<bits/stdc++.h>
#include"symbol_table.h"

using namespace std;

ofstream tokenout;
ofstream logout;

int line_count = 1;
int line_count_start = 1;
int error_count = 0;
string get_char ;
string get_actual_char;
string get_str;
string get_actual_str;
string get_comment;
int flag_quotation = 1;
string str_type = "";

string Upper(string s)
{
    for(int i=0;i<s.size();i++)
    {
        if(s[i]<='z' && s[i]>='a')
        {
            s[i] += ('A' - 'a');
        }
    }
    return s;
}
int buckets = 10;
SymbolTable* symbol_table = new SymbolTable(10);


%}

WHITESPACE [ \t\f\r\v]+
DIGIT [0-9]
LETTER [_A-Za-z]
ID {LETTER}({LETTER}|{DIGIT})*
NUMBER {DIGIT}+(\.{DIGIT}+)?(E[+-]?{DIGIT}+)?
NEWLINE \n

%%

{WHITESPACE} {}

{NEWLINE} {
      
    line_count++;    
}


if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue   {

    tokenout<<"<"<<Upper(yytext)<<", "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<"<<Upper(yytext)<<">"<<" Lexeme "<<yytext<<" found"<<endl;

}


{DIGIT}+    {
    tokenout<<"<CONST_INT, "<<Upper(yytext)<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<CONST_INT>"<<" Lexeme "<<yytext<<" found"<<endl;
}

{NUMBER}  {
    tokenout<<"<CONST_FLOAT, "<<Upper(yytext)<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<CONST_FLOAT>"<<" Lexeme "<<yytext<<" found"<<endl;
}

{DIGIT}*(\.{DIGIT}+)\.[+-E0-9]*(\.)* {
    error_count++;
    //tokenout<<"<CONST_INT,"<<Upper(yytext)<<">";
    logout<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;    
}

([0-9]*(\.[0-9]*)?[E][+-]?[0-9]*[0-9\.E+-]*(\.)*)|([0-9]+\.) {
	error_count++;
	logout<<"Error at line# "<< line_count <<": ILLFORMED_NUMBER "<<yytext<<endl;
}

{NUMBER}{ID} {
    error_count++;
    logout<<"Error at line# "<< line_count <<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;

} 

\/\/ {
    
    get_comment = "";
    line_count_start = line_count;
    BEGIN SINGLE_COMMENT_STATE;

}

\/\* {
    get_comment = "";
    line_count_start = line_count;
    BEGIN MULTI_COMMENT_STATE;
}

"++"|"--" {
    tokenout<<"<INCOP, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<INCOP>"<<" Lexeme "<<yytext<<" found"<<endl;

}

"+"|"-"  {
    tokenout<<"<ADDOP, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<ADDOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"*"|"/"|"%"  {
    tokenout<<"<MULOP, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<MULOP>"<<" Lexeme "<<yytext<<" found"<<endl;}

"<"|"<="|">"|">="|"=="|"!="  {
    tokenout<<"<RELOP, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<RELOP>"<<" Lexeme "<<yytext<<" found"<<endl;}

"=" {
    tokenout<<"<ASSIGNOP, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<ASSIGNOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"&&"|"||" { 
    tokenout<<"<LOGICOP, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<LOGICOP>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"&"|"|"|"^"|"<<"|">>" {
    tokenout<<"<BITOP, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<BITOP>"<<" Lexeme "<<yytext<<" found"<<endl;}

"!" {
    tokenout<<"<NOT, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<NOT>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"(" {
    tokenout<<"<LPAREN, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<LPAREN>"<<" Lexeme "<<yytext<<" found"<<endl;
}


")" {
    tokenout<<"<RPAREN, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<RPAREN>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"{" {
    tokenout<<"<LCURL, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<LCURL>"<<" Lexeme "<<yytext<<" found"<<endl;
    //new scopetable
    symbol_table->Enter_Scope();
}

"}" {
    tokenout<<"<RCURL, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<RCURL>"<<" Lexeme "<<yytext<<" found"<<endl;
    symbol_table->Exit_Scope();
    symbol_table->print_all_scope(logout);
}

"[" {
    tokenout<<"<LSQUARE, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<LSQUARE>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"]" {
    tokenout<<"<RSQUARE, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<RSQUARE>"<<" Lexeme "<<yytext<<" found"<<endl;
}

"," {
    tokenout<<"<COMMA, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<COMMA>"<<" Lexeme "<<yytext<<" found"<<endl;
}

";" {
    tokenout<<"<SEMICOLON, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<SEMICOLON>"<<" Lexeme "<<yytext<<" found"<<endl;
}

{ID} {


// have to write codes here ...
// debug about corner cases (if present)
    tokenout<<"<ID, "<<yytext<<">\n";
    logout<<"Line# "<<line_count<<": Token "<<"<ID>"<<" Lexeme "<<yytext<<" found"<<endl;

    SymbolInfo sym(yytext,"ID");
    bool status ;
    status =  symbol_table->insert(sym,logout);
    if(status){
        symbol_table->print_all_scope(logout);
    }
}




\' {

    get_char = "";
    get_actual_char = "";
    BEGIN CHAR_STATE;

}

\" {
    get_str = "";
    line_count_start  = line_count;
    str_type = "SINGLE LINE STRING";
    BEGIN STRING_STATE;
}


. {
    get_char = yytext;
    error_count++;
    logout<<"Error at line# "<<line_count<< ": UNRECOGNIZED_CHAR "<<get_char<<endl;

}


<CHAR_STATE>\\\' {
    get_char += "\'";
    get_actual_char += "\\\'";
}

<CHAR_STATE>\\\" {
    get_char += "\"";
    get_actual_char += "\\\"";
}
<CHAR_STATE>\\n {
    get_char += "\n";
    get_actual_char += "\\n";
    flag_quotation = 0;
}

<CHAR_STATE>\\t {
    get_char += "\t";
    get_actual_char += "\\t";
    flag_quotation = 0;
}
<CHAR_STATE>\\\\ {
    get_char += "\\";
    get_actual_char += "\\\\";
}

<CHAR_STATE>\\a {
    get_char += "\a";
    get_actual_char += "\\a";
    flag_quotation = 0;
}
<CHAR_STATE>\\f {
    get_char += "\f";
    get_actual_char += "\\f";
    flag_quotation = 0;
}

<CHAR_STATE>\\r {
    get_char += "\r";
    get_actual_char += "\\r";
    flag_quotation = 0;
}
<CHAR_STATE>\\b {
    get_char += "\b";
    get_actual_char += "\\b";
    flag_quotation = 0;
}

<CHAR_STATE>\\v {
    get_char += "\v";
    get_actual_char += "\\v";
    flag_quotation = 0;
}
<CHAR_STATE>\\0 {
    get_char += "\0";
    get_actual_char += "\\0";
    flag_quotation = 0;
}


<CHAR_STATE>[\r]?\n {
    error_count++;
    //line_count++;
    logout<<"Error at line# "<<line_count<< ": UNFINISHED_CONST_CHAR '"<<get_actual_char<<"\r";
    line_count++;
    get_char = "";
    get_actual_char = "";
    BEGIN INITIAL;
}

<CHAR_STATE>\'  {

    string print_char = "";
    // if(flag_quotation){
    //     print_char += "'";
    //     print_char += get_char;
    //     print_char += "'";
    // }
    // else{
       
        print_char += get_char;
   // }

    //cout<<"It enters1\n";
    cout<<get_char.size()<<endl;
    if(get_char.size()==1){
        //cout<<"It enters2\n";
        if(get_char == "\\"){
            logout<<"Error at line# "<<line_count<< ": UNFINISHED_CONST_CHAR '\\'"<<endl;
            //line_count++;
        }
        else{
            tokenout<<"<CONST_CHAR, "<<print_char<<">\n";
            logout<<"Line# "<<line_count<<": Token "<<"<CONST_CHAR>"<<" Lexeme "<<print_char<<" found"<<endl;
        }
    }
    else if(get_char.size()==0){
        logout<<get_actual_char<<endl;
        if(get_actual_char == "\\0"){

            tokenout<<"<CONST_CHAR, "<<print_char<<">\n";
            logout<<"Line# "<<line_count<<": Token "<<"<CONST_CHAR>"<<" Lexeme "<<print_char<<" found"<<endl;
    
        }
        else{
            error_count++;
            logout<<"Error at line# "<<line_count<< ": EMPTY_CONST_CHAR ''"<<endl;

        }
    }
    else{
        error_count++;
        logout<<"Error at line# "<<line_count<< ": MULTICHAR_CONST_CHAR '"<<get_char<<"'"<<endl;
        get_actual_char = "";
        get_char = "";
        flag_quotation = 1;
        BEGIN INITIAL;

    }
    get_actual_char = "";
    get_char = "";
    flag_quotation = 1;
    BEGIN INITIAL;
} 

<CHAR_STATE>{ID} {
    get_char += yytext;
    get_actual_char += yytext;

}

<CHAR_STATE>\\ {
    //cout<<"It enters backslash\n";
    // get_char += "\\";
    // get_actual_char += "\\";

    error_count++;
    string print_char = "'";
    print_char += get_char;
    logout<<"Error at line# "<<line_count<< ": UNFINISHED_CONST_CHAR '"<<print_char<<endl;

}
<CHAR_STATE><<EOF>> {
    error_count++;
    string print_char = "\'";
    print_char += get_char;
    logout<<"Error at line# "<<line_count<< ": UNFINISHED_CONST_CHAR '"<<print_char<<endl;
    get_char = "";
    flag_quotation = 1;
    BEGIN INITIAL;

}
<CHAR_STATE>. {
    cout<<"It enters any \n";
    get_char += yytext;
    get_actual_char += yytext;
    cout<<yytext<<endl;
      
}
<STRING_STATE>\\\" {
    get_str += "\"";
    get_actual_char += "\\\"";
}


<STRING_STATE>\\\' {
    get_str += "\'";
    get_actual_str += "\\\'";
}

<STRING_STATE>\\n {
    get_str += "\n";
    get_actual_str += "\\n";
    flag_quotation = 0;
}

<STRING_STATE>\\t {
    get_str += "\t";
    get_actual_str += "\\t";
    flag_quotation = 0;
}
<STRING_STATE>\\\\ {
    get_str += "\\";
    get_actual_str += "\\\\";
}

<STRING_STATE>\\a {
    get_str += "\a";
    get_actual_str += "\\a";
    flag_quotation = 0;
}
<STRING_STATE>\\f {
    get_str += "\f";
    get_actual_str += "\\f";
    flag_quotation = 0;
}

<STRING_STATE>\\r {
    get_str += "\r";
    get_actual_str += "\\r";
    flag_quotation = 0;
}
<STRING_STATE>\\b {
    get_str += "\b";
    get_actual_str += "\\b";
    flag_quotation = 0;
}

<STRING_STATE>\\v {
    get_str += "\v";
    get_actual_str += "\\v";
    flag_quotation = 0;
}
<STRING_STATE>\\0 {
    get_str += "\0";
    get_actual_str += "\\0";
    flag_quotation = 0;
}




<STRING_STATE>\" {
    string print_str = "";
    print_str += get_str;
    print_str += "";
    tokenout<<"<"<<str_type<<", "<<print_str<<">\n";
    logout<<"Line# "<<line_count_start <<": Token <"<<str_type<<"> Lexeme \""<<print_str<<"\" found"<<endl;
    BEGIN INITIAL;

}

<STRING_STATE>\\[\r]?\n {
    cout<<"enter string stage\n";
    line_count++;
    get_str+="\\\n";
    str_type = "MULTI LINE STRING";

    //get_str += "\n";
    //get_actual_str += "\n";
}

<STRING_STATE>\n {
    
    error_count++;

    logout<<"Error at line# "<<line_count<< ": UNFINISHED_STRING \""<<get_str<<endl;
    line_count++;
    BEGIN INITIAL;
}
<STRING_STATE><<EOF>> {
    error_count++;
    string print_str = "\"";
    print_str += get_str;
    logout<<"Error at line# "<<line_count<< ": UNFINISHED_STR "<<print_str<<endl;
    get_str = "";
    BEGIN INITIAL;

}

<STRING_STATE>. {
    get_str += yytext;
    get_actual_str += yytext;
}

<SINGLE_COMMENT_STATE>\\[\r]?\n {

    cout<<"enter comment stage?\n";
    
    get_comment += "\\\r\n";
    line_count++;

}



<SINGLE_COMMENT_STATE>[\r]?\n {
    line_count++;

    string print_str = "//";
    print_str += get_comment;

    logout<<"Line# "<<line_count_start <<": Token "<<"<SINGLE LINE COMMENT>"<<" Lexeme "<<print_str<<" found"<<endl;
    BEGIN INITIAL;
}

<SINGLE_COMMENT_STATE>. {
    get_comment += yytext;
}


<MULTI_COMMENT_STATE>\n {
    line_count++;
    get_comment += "\n";
}

<MULTI_COMMENT_STATE>\*\/ {

    string print_str = "/*";
    print_str += get_comment;
    print_str += "*/";
    logout<<"Line# "<<line_count_start <<": Token "<<"<MULTI LINE COMMENT>"<<" Lexeme "<<print_str<<" found"<<endl;

    BEGIN INITIAL;
}

<MULTI_COMMENT_STATE><<EOF>> {
    error_count++;
    string print_comment = "/*";
    print_comment += get_comment;
    logout<<"Error at line# "<<line_count<< ": UNFINISHED_COMMENT "<<print_comment<<endl;
    get_comment = "";
    symbol_table->print_all_scope(logout);
    BEGIN INITIAL;
    
}

<MULTI_COMMENT_STATE>. {
    get_comment += yytext;
}


 



%%

int main(int argc, char *argv[])
{
    if(argc!=2)
    {
        cout<<"Not valid file name\n";
        return 0;
    }

    FILE *file_input = fopen(argv[1],"r");
    
    if(file_input == NULL)
    {
        cout<<"Null file\n";
    }

    tokenout.open("token.txt");
    logout.open("log.txt");

    yyin = file_input;
    yylex();
    logout<<"Total lines: "<<line_count<<endl;
    logout<<"Total errors: "<<error_count<<endl;
    fclose(yyin);

    tokenout.close();
    logout.close();


    return 0;

}