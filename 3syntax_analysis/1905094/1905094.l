%option noyywrap yylineno

%x CHAR_STATE
%x STRING_STATE
%x SINGLE_COMMENT_STATE
%x SINGLE_COMMENT_STATE2
%x MULTI_COMMENT_STATE

%{
#include<bits/stdc++.h>

#include"parserhelper.h"
#include"y.tab.h"

using namespace std;

ofstream tokenout;
//ofstream logout;

int line_count = 1;
int line_count_start = 1;
//int error_count = 0;
string get_char ;
string get_actual_char;
string get_str;
string get_actual_str;
string get_comment;
int flag_quotation = 1;
string str_type = "";


extern YYSTYPE yylval;
extern SymbolTable* symbol_table;
extern Parserhelper* helper;
extern ofstream logout;
extern ofstream errorout;
extern ofstream parsetree;
extern int error_count;

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

void parse_value_init(SymbolInfo* symbol){
    symbol->start_line = line_count;
    symbol->end_line = line_count;
    symbol->isLeaf = true;
}
int buckets = 10;
//SymbolTable* symbol_table = new SymbolTable(10);


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




if {
    yylval.symbol_info = new SymbolInfo(yytext,"IF");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <IF> Lexeme "<<yytext <<" found" <<endl;
    return IF;
}
else {
    yylval.symbol_info = new SymbolInfo(yytext,"ELSE");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <ELSE> Lexeme "<<yytext <<" found" <<endl;
    return ELSE;
}
for {
    yylval.symbol_info = new SymbolInfo(yytext,"FOR");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <FOR> Lexeme "<<yytext <<" found" <<endl;
    return FOR;
}
while {
    yylval.symbol_info = new SymbolInfo(yytext,"WHILE");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <WHILE> Lexeme "<<yytext <<" found" <<endl;
    return WHILE;
}
do {
    yylval.symbol_info = new SymbolInfo(yytext,"DO");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <DO> Lexeme "<<yytext <<" found" <<endl;
    return DO;
}
break {
    yylval.symbol_info = new SymbolInfo(yytext,"BREAK");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <BREAK> Lexeme "<<yytext <<" found" <<endl;
    return BREAK;
}
int {
    yylval.symbol_info = new SymbolInfo(yytext,"INT");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <INT> Lexeme "<<yytext <<" found" <<endl;
    //parsetree<<"Line: <"<<line_count<<">"<<endl;
    return INT;
}
char {
    yylval.symbol_info = new SymbolInfo(yytext,"CHAR");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <CHAR> Lexeme "<<yytext <<" found" <<endl;
    return CHAR;
}
float {
    yylval.symbol_info = new SymbolInfo(yytext,"FLOAT");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <FLOAT> Lexeme "<<yytext <<" found" <<endl;
    return FLOAT;
}
double {
    yylval.symbol_info = new SymbolInfo(yytext,"DOUBLE");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <DOUBLE> Lexeme "<<yytext <<" found" <<endl;
    return DOUBLE;
}
void {
    yylval.symbol_info = new SymbolInfo(yytext,"VOID");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <VOID> Lexeme "<<yytext <<" found" <<endl;
    return VOID;
}
return {
    yylval.symbol_info = new SymbolInfo(yytext,"RETURN");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <RETURN> Lexeme "<<yytext <<" found" <<endl;
    return RETURN;
}
switch {
    yylval.symbol_info = new SymbolInfo(yytext,"SWITCH");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <SWITCH> Lexeme "<<yytext <<" found" <<endl;
    return SWITCH;
}
case {
    yylval.symbol_info = new SymbolInfo(yytext,"CASE");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <CASE> Lexeme "<<yytext <<" found" <<endl;
    return CASE;
}
default {
    yylval.symbol_info = new SymbolInfo(yytext,"DEFAULT");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <DEFAULT> Lexeme "<<yytext <<" found" <<endl;
    return DEFAULT;
}
continue {
    yylval.symbol_info = new SymbolInfo(yytext,"CONTINUE");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <CONTINUE> Lexeme "<<yytext <<" found" <<endl;
    return CONTINUE;
}


{DIGIT}+    {
    //tokenout<<"<CONST_INT, "<<Upper(yytext)<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<CONST_INT>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"CONST_INT");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <CONST_INT> Lexeme "<<yytext <<" found" <<endl;
    return CONST_INT;
}

{NUMBER}  {
    //tokenout<<"<CONST_FLOAT, "<<Upper(yytext)<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<CONST_FLOAT>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"CONST_FLOAT");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <CONST_FLOAT> Lexeme "<<yytext <<" found" <<endl;
    return CONST_FLOAT;
}

{DIGIT}*(\.{DIGIT}+)\.[+-E0-9]*(\.)* {
    error_count++;
    //tokenout<<"<CONST_INT,"<<Upper(yytext)<<">";
    //logout<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;    
}

([0-9]*(\.[0-9]*)?[E][+-]?[0-9]*[0-9\.E+-]*(\.)*)|([0-9]+\.) {
	error_count++;
	//logout<<"Error at line# "<< line_count <<": ILLFORMED_NUMBER "<<yytext<<endl;
}

{NUMBER}{ID} {
    error_count++;
    //logout<<"Error at line# "<< line_count <<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;

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

"++" {
    //tokenout<<"<INCOP, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<INCOP>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"INCOP");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <INCOP> Lexeme "<<yytext <<" found" <<endl;

    return INCOP;
}

"--" {
    //tokenout<<"<INCOP, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<INCOP>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"DECOP");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <DECOP> Lexeme "<<yytext <<" found" <<endl;
    return DECOP;
}


"+"|"-"  {
    //tokenout<<"<ADDOP, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<ADDOP>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"ADDOP");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <ADDOP> Lexeme "<<yytext <<" found" <<endl;
    return ADDOP;
}

"*"|"/"|"%"  {
    //tokenout<<"<MULOP, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<MULOP>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"MULOP");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <MULOP> Lexeme "<<yytext <<" found" <<endl;
    return MULOP;
}

"<"|"<="|">"|">="|"=="|"!="  {
    //tokenout<<"<RELOP, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<RELOP>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"RELOP");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <RELOP> Lexeme "<<yytext <<" found" <<endl;
    return RELOP;
}

"=" {
    //tokenout<<"<ASSIGNOP, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<ASSIGNOP>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"ASSIGNOP");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <ASSINGOP> Lexeme "<<yytext <<" found" <<endl;
    return ASSIGNOP;
}

"&&"|"||" { 
    //tokenout<<"<LOGICOP, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<LOGICOP>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"LOGICOP");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <LOGICOP> Lexeme "<<yytext <<" found" <<endl;
    return LOGICOP;
}

"&"|"|"|"^"|"<<"|">>" {
    //tokenout<<"<BITOP, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<BITOP>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"BITOP");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <BITOP> Lexeme "<<yytext <<" found" <<endl;
    return BITOP;
}

"!" {
    //tokenout<<"<NOT, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<NOT>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"NOT");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <NOT> Lexeme "<<yytext <<" found" <<endl;
    return NOT;
}

"(" {
    //tokenout<<"<LPAREN, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<LPAREN>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"LPAREN");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <LPAREN> Lexeme "<<yytext <<" found" <<endl;
    return LPAREN;
}


")" {
    //tokenout<<"<RPAREN, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<RPAREN>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"RPAREN");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <RPAREN> Lexeme "<<yytext <<" found" <<endl;
    return RPAREN;
}

"{" {
    //tokenout<<"<LCURL, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<LCURL>"<<" Lexeme "<<yytext<<" found"<<endl;
    //new scopetable
    //symbol_table->Enter_Scope();
    yylval.symbol_info = new SymbolInfo(yytext,"LCURL");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <LCURL> Lexeme "<<yytext <<" found" <<endl;
    return LCURL;
}

"}" {
    //tokenout<<"<RCURL, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<RCURL>"<<" Lexeme "<<yytext<<" found"<<endl;
    //symbol_table->Exit_Scope();
    //symbol_table->print_all_scope(logout);
    yylval.symbol_info = new SymbolInfo(yytext,"RCURL");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <RCURL> Lexeme "<<yytext <<" found" <<endl;
    return RCURL;
}

"[" {
    //tokenout<<"<LSQUARE, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<LSQUARE>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"LSQUARE");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <LSQUARE> Lexeme "<<yytext <<" found" <<endl;
    return LSQUARE;
}

"]" {
    //tokenout<<"<RSQUARE, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<RSQUARE>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"RSQUARE");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <RSQUARE> Lexeme "<<yytext <<" found" <<endl;
    return RSQUARE;
}

"," {
    //tokenout<<"<COMMA, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<COMMA>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"COMMA");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <COMMA> Lexeme "<<yytext <<" found" <<endl;

    return COMMA;
}

";" {
    //tokenout<<"<SEMICOLON, "<<yytext<<">\n";
    //logout<<"Line# "<<line_count<<": Token "<<"<SEMICOLON>"<<" Lexeme "<<yytext<<" found"<<endl;
    yylval.symbol_info = new SymbolInfo(yytext,"SEMICOLON");
    parse_value_init(yylval.symbol_info);
    logout<<"Line# "<<line_count <<": Token <SEMICOLON> Lexeme "<<yytext <<" found" <<endl;

    return SEMICOLON;
}

{ID} {


// have to write codes here ...
// debug about corner cases (if present)
    //1tokenout<<"<ID, "<<yytext<<">\n";
    //1logout<<"Line# "<<line_count<<": Token "<<"<ID>"<<" Lexeme "<<yytext<<" found"<<endl;

    yylval.symbol_info = new SymbolInfo(yytext,"ID");
    parse_value_init(yylval.symbol_info);
  
    //yylval.symbol_info = sym;
    logout<<"Line# "<<line_count <<": Token <ID> Lexeme "<<yytext <<" found" <<endl;

    return ID;
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
   
    //1logout<<"Error at line# "<<line_count<< ": UNFINISHED_CONST_CHAR '"<<get_actual_char<<"\r";
    line_count++;
    get_char = "";
    get_actual_char = "";
    BEGIN INITIAL;
}

<CHAR_STATE>\'  {

    string print_char = "";

       
        print_char += get_char;

    cout<<get_char.size()<<endl;
    if(get_char.size()==1){
       
        if(get_char == "\\"){
            //1logout<<"Error at line# "<<line_count<< ": UNFINISHED_CONST_CHAR '\\'"<<endl;
            
        }
        else{
            //1tokenout<<"<CONST_CHAR, "<<print_char<<">\n";
            //1logout<<"Line# "<<line_count<<": Token "<<"<CONST_CHAR>"<<" Lexeme "<<print_char<<" found"<<endl;
            
        }
    }
    else if(get_char.size()==0){
        //1logout<<get_actual_char<<endl;
        if(get_actual_char == "\\0"){

            //1tokenout<<"<CONST_CHAR, "<<print_char<<">\n";
            //1logout<<"Line# "<<line_count<<": Token "<<"<CONST_CHAR>"<<" Lexeme "<<print_char<<" found"<<endl;
    
        }
        else{
            error_count++;
            //1logout<<"Error at line# "<<line_count<< ": EMPTY_CONST_CHAR ''"<<endl;

        }
    }
    else{
        error_count++;
        //1logout<<"Error at line# "<<line_count<< ": MULTICHAR_CONST_CHAR '"<<get_char<<"'"<<endl;
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
   

    error_count++;
    string print_char = "'";
    print_char += get_char;
    //1logout<<"Error at line# "<<line_count<< ": UNFINISHED_CONST_CHAR '"<<print_char<<endl;

}
<CHAR_STATE><<EOF>> {
    error_count++;
    string print_char = "\'";
    print_char += get_char;
    //1logout<<"Error at line# "<<line_count<< ": UNFINISHED_CONST_CHAR '"<<print_char<<endl;
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
    //1tokenout<<"<"<<str_type<<", "<<print_str<<">\n";
    //1logout<<"Line# "<<line_count_start <<": Token <"<<str_type<<"> Lexeme \""<<print_str<<"\" found"<<endl;
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

    //1logout<<"Error at line# "<<line_count<< ": UNFINISHED_STRING \""<<get_str<<endl;
    line_count++;
    BEGIN INITIAL;
}
<STRING_STATE><<EOF>> {
    error_count++;
    string print_str = "\"";
    print_str += get_str;
    //1logout<<"Error at line# "<<line_count<< ": UNFINISHED_STR "<<print_str<<endl;
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

   //1 logout<<"Line# "<<line_count_start <<": Token "<<"<SINGLE LINE COMMENT>"<<" Lexeme "<<print_str<<" found"<<endl;
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
    //1logout<<"Line# "<<line_count_start <<": Token "<<"<MULTI LINE COMMENT>"<<" Lexeme "<<print_str<<" found"<<endl;

    BEGIN INITIAL;
}


<MULTI_COMMENT_STATE><<EOF>> {
    error_count++;
    string print_comment = "/*";
    print_comment += get_comment;
    //1logout<<"Error at line# "<<line_count<< ": UNFINISHED_COMMENT "<<print_comment<<endl;
    get_comment = "";
    //1symbol_table->print_all_scope(logout);
    BEGIN INITIAL;
    
}

<MULTI_COMMENT_STATE>. {
    get_comment += yytext;
}


 



%%

// int main(int argc, char *argv[])
// {
//     if(argc!=2)
//     {
//         cout<<"Not valid file name\n";
//         return 0;
//     }

//     FILE *file_input = fopen(argv[1],"r");
    
//     if(file_input == NULL)
//     {
//         cout<<"Null file\n";
//     }

//     tokenout.open("token.txt");
//     logout.open("log.txt");

//     yyin = file_input;
//     yylex();
//     logout<<"Total lines: "<<line_count<<endl;
//     logout<<"Total errors: "<<error_count<<endl;
//     fclose(yyin);

//     tokenout.close();
//     logout.close();


//     return 0;

// }