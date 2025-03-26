%{
#include<bits/stdc++.h>
#include "parserhelper.h"
using namespace std;



ofstream logout;
ofstream errorout;
ofstream place_holder ;
ofstream parsetree;
ofstream asmout;

extern int line_count;
int error_count = 0;
int SP;

bool void_expr = false;

extern FILE *yyin;

void yyerror(string s){
    // logout<<"Error at line "<<line_count<<" : "<<s<<endl;
    // errorout<<"Error at line "<<line_count<<": "<<s<<endl;
    // error_count++;
}

int yyparse(void);
int yylex(void);

int table_size = 17;

int stack_offset = 0;

int label = 0;

vector<string> endLabelAll;
string elseLabel;

string condition_for;
string body_for;
string update_for;
string end_for;
string condition_while;
string body_while;
string end_while;
string returnLabel;

string newLabel(){
    return "    L"+to_string(label++);
}


SymbolTable* symbol_table = new SymbolTable(table_size);


vector<SymbolInfo*>function_parameter_list;
vector<SymbolInfo> global_var_list;

bool _is_function = false;
bool _is_function_definition = false;
string current_function_asm;

string imp_typecast(string left, string right){
    if(left == "NULL" || right == "NULL"){
        return "NULL";
    }
    if(left == "VOID" || right == "VOID"){
        return "ERROR";
    }
    if((left == "FLOAT" || left == "FLOAT_ARRAY") && (right == "FLOAT" || right == "FLOAT_ARRAY")){
        return "FLOAT";
    }
    if((left == "FLOAT" || left == "FLOAT_ARRAY") && (right == "INT" || right == "INT_ARRAY")){
        return "FLOAT";
    }
    if((left == "INT" || left == "INT_ARRAY") && (right == "FLOAT" || right == "FLOAT_ARRAY")){
        return "FLOAT";
    }
    if((left == "INT" || left == "INT_ARRAY") && (right == "INT" || right == "INT_ARRAY")){
        return "INT";
    }


    return "ERROR";   
}

string Upper_yacc(string s)
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
bool parameter_typecast(){
    // has to implement
}

bool assignop_match(string left, string right){
    if(left == "NULL" || right == "NULL"){
        return true;
    }
    if(left == "void" || right == "void"){
        return false;
    }
    if(left == "" || right == ""){
        return false;
    }
    if((left == "int" || left == "int_array") && (right == "int" || right == "int_array") ){
        return true;
    }
    
    if((left == "float" || left == "float_array") && (right != "void") ){
        return true;
    }

    return false;
}


void print_grammer_rule(string left , string right){
    logout<<left<<" : "<<right<<endl; 

}

void print_log(string lexeme, string token){
    logout<<"Line# "<<line_count <<": Token <" <<token <<"> Lexeme "<<lexeme <<" found" <<endl;
}
void print_log(string log){
    ;
}

string find_data_type(string name){
    SymbolInfo* temp = symbol_table->LookUp(name);
    return temp->data_type;
}

void error_many_dec(string error){
    //logout<<"Error at line "<<line_count<<": Multiple declaration of "<<error<<endl;
    errorout<<"Line# "<<line_count<<": Redefinition of parameter '"<<error<<"'"<<endl;
    error_count++;
}

void error_different_definition(string error){
    errorout<<"Line# "<<line_count<<": '"<<error<<"' redeclared as different kind of symbol"<<endl;
    error_count++;
}

// void error_nonintsize_arr(){
//     logout<<"Error at line "<<line_count<<": Non-integer Array Size\n"<<endl;
//     errorout<<"Error at line "<<line_count<<": Non-integer Array Size\n"<<endl;
//     error_count++;
// }

// void error_invalid_arrayindex(){
//     logout<<"Error at line "<<line_count<<": Expression inside third brackets not an integer\n"<<endl;
//     errorout<<"Error at line "<<line_count<<": Expression inside third brackets not an integer\n"<<endl;
//     error_count++;
// }


// void error_typecast(){
//     logout<<"Error at line "<<line_count<<": Incompatible Operand\n"<<endl;
//     errorout<<"Error at line "<<line_count<<": Incompatible Operand\n"<<endl;
//     error_count++;
// }


// void error_typecast_voidfunc()
// {
//     logout<<"Error at line "<<line_count<<": Void function used in expression\n"<<endl;
//     errorout<<"Error at line "<<line_count<<": Void function used in expression\n"<<endl;
//     error_count++;
// }


// void error_typecast_nonint_mod()
// {
//     logout<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator\n"<<endl;
//     errorout<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator\n"<<endl;
//     error_count++;
// }

// void error_typecast_zero_mod()
// {
//     logout<<"Error at line "<<line_count<<": Modulus by Zero\n"<<endl;
//     errorout<<"Error at line "<<line_count<<": Modulus by Zero\n"<<endl;
//     error_count++;
// }


void error_undeclared_variable(string error)
{
    //logout<<"Error at line "<<line_count<<": Undeclared variable "<<str<<endl;
    errorout<<"Line# "<<line_count<<": Undeclared variable '"<<error<<"'"<<endl;
    error_count++;
}


void error_undeclared_function(string error)
{
    //logout<<"Error at line "<<line_count<<": Undeclared variable "<<str<<endl;
    errorout<<"Line# "<<line_count<<": Undeclared function '"<<error<<"'"<<endl;
    error_count++;
}


void error_functype_conflict(string str)
{
    //logout<<"Error at line "<<line_count<<": Type mismatch "<<str<<endl;
    errorout<<"Line# "<<line_count<<": Conflicting types for '"<<str<<"'"<<endl;
    error_count++;
}

void error_conflict_types(string error){
    errorout<<"Line# "<<line_count<<": Conflicting types for '"<<error<<"'"<<endl;
    error_count++;
}


void error_function_parameter_type(int p_id,string str)
{
    logout<<"Error at line "<<line_count<<": "<<p_id<<"th argument mismatch in function "<<str<<endl;
    errorout<<"Error at line "<<line_count<<": "<<p_id<<"th argument mismatch in function "<<str<<endl;
    error_count++;
}

void error_too_few_args(string error){
    errorout<<"Line# "<<line_count<<": Too few arguments to function '"<<error<<"'"<<endl;
    error_count++;
}

void error_too_much_args(string error){
    errorout<<"Line# "<<line_count<<": Too much arguments to function '"<<error<<"'"<<endl;
    error_count++;
}

void error_type_mismatch(int index, string error){
    errorout<<"Line# "<<line_count<<": Type mismatch for argument "<<index<<" of function '"<<error<<"'"<<endl;
    error_count++;    
}

void error_not_array(string error){
    errorout<<"Line# "<<line_count<<":  '"<<error<<"' is not an array"<<endl;
    error_count++;    
}

void error_nonint_array(){
    errorout<<"Line# "<<line_count<<": Array subscript is not an integer"<<endl;
    error_count++; 
}

void error_void_expr(){
    
    errorout<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
    error_count++; 
}

void warning_precision(string x, string y){
    errorout<<"Line# "<<line_count<<": Warning: possible loss of data in assignment of "<<x<<" to "<<y<<endl;
    error_count++; 
}

void warning_divide_by_zero(){
    errorout<<"Line# "<<line_count<<": Warning: division by zero i=0f=1Const=0 "<<endl;
    error_count++; 
}

void error_modulus_non_int(){
    errorout<<"Line# "<<line_count<<": Operands of modulus must be integers "<<endl;
    error_count++; 
}
// void error_function_parameter_number(){

// }

// void error_conflict_definition(string str)
// {
//     logout<<"Error at line "<<line_count<<": conflict definition "<<str<<endl;
//     errorout<<"Error at line "<<line_count<<": conflict definition "<<str<<endl;
//     error_count++;
// }

void error_void_type(string error){
    //logout<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl;
    errorout<<"Line# "<<line_count<<": Variable or field '"<<error<<"' declared void"<<endl;
    error_count++;
}

//more errors tobe implemented later...



//funct to global

void insert_func_definition(SymbolInfo* sym, SymbolInfo* type){   // ID , type_spcifier
    //sym->set_type(type);
    sym->isFunction = true;
    sym->data_type = type->name;

    //cout<<"this is "<<sym->name<<endl;

    //cout<<sym->name<<endl;
    //cout<<sym->type<<endl;

    for(int i=0;i<function_parameter_list.size();i++){
        //cout<<"func parameter check start.\n";
        sym->parameter_list.push_back(function_parameter_list[i]);
        //cout<<function_parameter_list[i].id_name<<endl;
        //cout<<sym->parameter_list[i]
        //cout<<"func parameter check end.\n";
        //cout<<sym->name<<" : "<<function_parameter_list[i].get_name()<<endl;
    }

    //cout<<"Is before segmentation falult?1\n";

    //cout<<"Function name(sym): "<<sym->name<<endl;
    //cout<<"Parameter size(sym): "<<sym->parameter_list.size()<<endl;
    //cout<<"Is is function?(sym): "<<sym->isFunction<<endl;    

    bool status = symbol_table->insert(*sym , place_holder);

    // this is testing

    SymbolInfo* tmp = symbol_table->LookUp(sym->name);

    //cout<<"Function name: "<<tmp->name<<endl;
    //cout<<"Parameter size: "<<tmp->parameter_list.size()<<endl;
    //cout<<"Is is function?: "<<tmp->isFunction<<endl; 

    
    

    //cout<<"Is before segmentation falult?2\n";

    if(!status){
        SymbolInfo* temp = symbol_table->LookUp(sym->name);
        //cout<<sym->name<<endl;
        //cout<<"Is before segmentation falult?3\n";
        if(temp == NULL){
            //cout<<"temp is null\n";
        }
        if(temp->isFunction == false){
            //cout<<temp->get_name()<<endl;
            //cout<<temp->get_type()<<endl;
            error_different_definition(temp->get_name());
        }
        else{
            if(temp->data_type != sym->data_type){
                //cout<<"error_functype_conflict\n";
                //cout<<temp->data_type<<endl;
                //cout<<sym->data_type<<endl;
                error_functype_conflict(temp->get_name());
            }
            else if(temp->parameter_list.size()!= sym->parameter_list.size()){
                //error_function_parameter_number(temp->get_name());
                error_functype_conflict(temp->get_name());
            }
            else{
                for(int i=0 ;i<temp->parameter_list.size();i++){
                    if(temp->parameter_list[i]->data_type != sym->parameter_list[i]->data_type){
                        error_function_parameter_type(i+1,sym->get_name());
                        break;
                    }
                }
            }

        }
    }
    else{

    }
}

void print_parse_tree(SymbolInfo* symbol_info , int depth){

    for(int i=0;i<depth;i++){
        parsetree<<" ";
    }
    // if(symbol_info->isLeaf){
    //     parsetree<<symbol_info->type<<" : ";
    //     for(int i=0;i<symbol_info->children.size();i++){
    //         parsetree<<((symbol_info->children)[i])->type<<" ";
    //     }
    //     parsetree<<"\n";
    // }


    

    if(symbol_info->isLeaf){
        parsetree<<symbol_info->type<<" : "<<symbol_info->name<<"\t";
        parsetree<<"<Line: "<<symbol_info->start_line<<">"<<endl;
    }
    else{
        parsetree<<symbol_info->type<<" : "<<symbol_info->name<<" \t";
        parsetree<<"<Line: "<<symbol_info->start_line<<"-"<<symbol_info->end_line << ">"<<endl;
    }
    // for(int i=0;i<symbol_info->children.size();i++){
    //     parsetree<<((symbol_info->children)[i])->type<<" ";
    // }
    // parsetree<<"\n";

    for(int i=0;i<symbol_info->children.size();i++){
        print_parse_tree(symbol_info->children[i],depth+1);
    }


}

 



void erase_sym_pointer(SymbolInfo* sym){
    //cout<<"does it enter?";
    if(sym!= NULL){
        //free(sym);
    }
}

void erase_helper_pointer(SymbolInfo* ph){
    if(ph!= NULL){
        //free(ph);
    }
}



//assembly function


void init_asm(){
    asmout<<".MODEL SMALL\n";
    asmout<<".STACK 1000H\n";
    asmout<<".DATA\n";
    asmout<<"   CR EQU 0DH\n";
    asmout<<"   LF EQU 0AH\n";
    asmout<<"   number DB \"00000$\"\n";

}
void init_asm2(){
    asmout<<".CODE\n";
}

void init_var_dec(){
    for(int i=0;i<global_var_list.size();i++){
        asmout<<"   "<<global_var_list[i].name<<" DW 1 DUP (0000H)"<<endl;
    }
    init_asm2();
}

void print_asm()
{
    asmout<<"new_line proc"<<endl;
    asmout<<"   push ax"<<endl;
    asmout<<"   push dx"<<endl;
    asmout<<"   mov ah,2"<<endl;
    asmout<<"   mov dl,cr"<<endl;
    asmout<<"   int 21h"<<endl;
    asmout<<"   mov ah,2"<<endl;
    asmout<<"   mov dl,lf"<<endl;
    asmout<<"   int 21h"<<endl;
    asmout<<"   pop dx"<<endl;
    asmout<<"   pop ax"<<endl;
    asmout<<"   ret"<<endl;
    asmout<<"new_line endp"<<endl;

    // asmout<<"new_line proc"<<endl;
    // asmout<<"   PUSH DX"<<endl;
    // asmout<<"   PUSH AX"<<endl;
    // asmout<<"   MOV AH,2"<<endl;
    // asmout<<"   MOV DL, 0DH"<<endl;
    // asmout<<"   INT 21H"<<endl;
    // asmout<<"   POP DX"<<endl;
    // asmout<<"   POP AX"<<endl;
    // asmout<<"   RET"<<endl;
    // asmout<<"new_line ENDP"<<endl;
    


    //print output proc

    asmout<<"print_output proc"<<endl;
    // asmout<<"   push ax"<<endl;
    // asmout<<"   mov ah,2"<<endl;
    // asmout<<"   INT 21H"<<endl;
    // asmout<<"   pop ax"<<endl;
    // asmout<<"   ret"<<endl;


    asmout<<"   push ax"<<endl;
    asmout<<"   push bx"<<endl;
    asmout<<"   push cx"<<endl;
    asmout<<"   push dx"<<endl;
    asmout<<"   push si"<<endl;
    asmout<<"   lea si, number"<<endl;
    asmout<<"   mov bx, 10"<<endl;
    asmout<<"   add si, 4"<<endl;
    asmout<<"   cmp ax, 0"<<endl;
    asmout<<"   jnge negate"<<endl;
    asmout<<"   print:"<<endl;
    asmout<<"   xor dx,dx"<<endl;
    asmout<<"   div bx"<<endl;
    asmout<<"   mov [si],dl"<<endl;
    asmout<<"   add [si],'0'"<<endl;
    asmout<<"   dec si"<<endl;
    asmout<<"   cmp ax,0"<<endl;
    asmout<<"   jne print"<<endl;
    asmout<<"   inc si"<<endl;
    asmout<<"   lea dx, si"<<endl;
    asmout<<"   mov ah,9"<<endl;
    asmout<<"   int 21h"<<endl;
    asmout<<"   pop si"<<endl;
    asmout<<"   pop dx"<<endl;
    asmout<<"   pop cx"<<endl;
    asmout<<"   pop bx"<<endl;
    asmout<<"   pop ax"<<endl;
    asmout<<"   ret"<<endl;
    asmout<<"   negate:"<<endl;
    asmout<<"   push ax"<<endl;
    asmout<<"   mov ah,2"<<endl;
    asmout<<"   mov dl,'-'"<<endl;
    asmout<<"   int 21h"<<endl;
    asmout<<"   pop ax"<<endl;
    asmout<<"   neg ax"<<endl;
    asmout<<"   jmp print"<<endl;
    asmout<<"print_output endp"<<endl;
    asmout<<"END main"<<endl;

}


void init_asm_parsetree(SymbolInfo* symbol_info){
    
}





%}



%error-verbose

%union{
    SymbolInfo* symbol_info;
    string* symbol_info_str;
    string* temp_str;
    Parserhelper* helper;
}

%token<symbol_info> IF ELSE LOWER_THAN_ELSE FOR WHILE DO BREAK CHAR DOUBLE RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN INCOP DECOP BITOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON
%token<symbol_info> ID INT FLOAT VOID ADDOP MULOP RELOP LOGICOP CONST_INT CONST_FLOAT ERROR_FLOAT 
%type <symbol_info> expression factor unary_expression term simple_expression rel_expression statement statements compound_statement logic_expression expression_statement arguments argument_list declaration_list
%type <symbol_info> start unit func_declaration func_definition parameter_list program var_declaration type_specifier
%type <symbol_info> variable pseudo

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%destructor {
    erase_helper_pointer($$);
} <helper>
%destructor {
    erase_sym_pointer($$);
} <symbol_info>



%%

start: program
    {
    print_grammer_rule("start", "program");

    $$ = new SymbolInfo("program","start");
    
    $$->data = $1->data;

    $$->start_line = $1->start_line;
    $$->end_line = $1->end_line;
    $$->children.push_back($1);
    
    print_parse_tree($$,0);

    // assembly code

    //$$->code = $1->code;


    erase_helper_pointer($1);
    }
    ;
program: program unit {
       

        $$ = new SymbolInfo("program unit","program");
        $$->data = $1->data;
        $$->data +=" : ";
        $$->data += $2->data;

        $$->start_line = $1->start_line;
        $$->end_line = $2->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        //print_log($$->data);
        print_grammer_rule("program", "program unit");
        
        
        //assembly code

        // $$->code = $1->code;
        // $$->code += $2->code;

        // $$->temp_var = $1->temp_var;
        // $$->stack_offset =$1->stack_offset;
        
        
        erase_helper_pointer($1);
        erase_helper_pointer($2); 
    }
    | unit {
        

        $$ = new SymbolInfo("unit","program");
        $$->data = $1->data;

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);


        //print_log($$->data);
        print_grammer_rule("program", "unit");

        //assembly
        // $$->code = $1->code;
        // $$->temp_var = $1->temp_var;
        // $$->stack_offset = $1->stack_offset;

        erase_helper_pointer($1);
    }
    ;

unit: var_declaration {
        

        $$ = new SymbolInfo("var_declaration","unit");
        $$->data = $1->data;

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        print_grammer_rule("unit", "var_declaration");
        
        //print_log($$->data);


        //assembly
        // $$->code = $1->code;
        // $$->temp_var = $1->temp_var;
        // $$->stack_offset = $1->stack_offset;



        erase_helper_pointer($1);
    }
    | func_declaration {
        print_grammer_rule("unit", "func_declaration");

        $$ = new SymbolInfo("func_declaration","unit");
        $$->data = $1->data;

        

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        //assembly
        // $$->code = $1->code;
        // $$->temp_var = $1->temp_var;
        // $$->stack_offset = $1->stack_offset;

        // SP = 0;

        erase_helper_pointer($1);
    }
    | func_definition {
        print_grammer_rule("unit", "func_definition");

        $$ = new SymbolInfo("func_definition","unit");
        $$->data = $1->data;

       // print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        //assembly
        // $$->code = $1->code;
        // $$->temp_var = $1->temp_var;
        // $$->stack_offset = $1->stack_offset;

        // SP = 0;


        erase_helper_pointer($1);
    }
    ;

func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        print_grammer_rule("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
        $$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON","func_declaration");
        $$->data = $1->data;
        $$->data += " ";
        $$->data += $2->get_name();
        $$->data += "(";
        $$->data += $4->data;
        $$->data += ")";
        $$->data += ";";


        //$2->set_type($1->data);
        $2->isFunction = true;

        //$2->data_type = $1->name;

        for(int i=0;i<function_parameter_list.size();i++){
            $2->parameter_list.push_back(function_parameter_list[i]);
        }
        $2->data_type = $1->name;
        bool status = symbol_table->insert((*$2),place_holder);
        //cout<<$2->name<<" : "<<$2->parameter_list.size()<<endl;
        if(status){
            //cout<<$2->get_name()<<endl;
            //cout<<$2->get_type()<<endl;
            SymbolInfo* temp = symbol_table->LookUp($2->get_name());
            temp->isFunction = true;
        }
        else{
            //cout<<$2->get_name()<<endl;
            error_many_dec($2->get_name());
        }

       // print_log($$->data);

        function_parameter_list.clear();

        $$->start_line = $1->start_line;
        $$->end_line = $6->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);
        $$->children.push_back($5);
        $$->children.push_back($6);

        erase_helper_pointer($1);
        erase_sym_pointer($2);
        erase_helper_pointer($4);
    }
    | type_specifier ID LPAREN RPAREN SEMICOLON {
        
        
        $$ = new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON","func_declaration");
        $$->data = $1->data;
        $$->data += " ";
        $$->data += $2->get_name();
        $$->data += "(";
        $$->data += ")";
        $$->data += ";";


        //$2->set_type($1->data);
        $2->isFunction = true;

        for(int i=0;i<function_parameter_list.size();i++){
            $2->parameter_list.push_back(function_parameter_list[i]);
        }
        $2->data_type = $1->name;
        bool status = symbol_table->insert((*$2),place_holder);
        //cout<<$2->name<<" : "<<$2->parameter_list.size()<<endl;
        if(status){
            SymbolInfo* temp = symbol_table->LookUp($2->get_name());
            temp->isFunction = true;
        }
        else{
            //cout<<$2->get_name()<<endl;
            error_many_dec($2->get_name());
        }

        $$->start_line = $1->start_line;
        $$->end_line = $5->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);
        $$->children.push_back($5);

        //print_log($$->data);

        // print_log($2->get_name(), "ID");
        // print_log("(", "LPAREN");
        // print_log(")","RPAREN");
        // print_log(";","SEMICOLON");
        // print_log("yo , does above print?");
        print_grammer_rule("func_declaration", "type_specifier ID LPAREN RPAREN SEMICOLON");

        function_parameter_list.clear();

        erase_helper_pointer($1);
        erase_sym_pointer($2);

    }
    ;

func_definition: type_specifier ID LPAREN parameter_list RPAREN {
    _is_function = true;
    $1->id_name = $2->name;
    insert_func_definition($2 , $1); 

    returnLabel = newLabel();

    stack_offset = 0;



    asmout<<$2->name<<" "<<"PROC"<<endl;


    if($2->name == "main"){
        asmout<<"MOV AX , @DATA\n";
        asmout<<"MOV DS , AX\n";
        //asmout<<"PUSH BP\n";
        asmout<<"MOV BP , SP\n";
    }
    else{
        asmout<<"PUSH AX"<<endl;
        asmout<<"PUSH BX"<<endl;
        asmout<<"PUSH CX"<<endl;
        asmout<<"PUSH BP"<<endl;
        asmout<<"MOV BP , SP"<<endl;
    }
    
    } compound_statement {
        print_grammer_rule("func_definition", "type_specifier ID LPAREN parameter_list RPAREN compound_statement");

        $$ = new SymbolInfo( "type_specifier ID LPAREN parameter_list RPAREN compound_statement","func_definition");
        $$->data = $1->data;
        $$->data += " ";
        $$->data += $2->get_name();
        $$->data += "(";
        $$->data += $4->data;
        $$->data += $7->data;

       // print_log($$->data);

        //_is_function = false; // is it false?

        

        $$->start_line = $1->start_line;
        $$->end_line = $7->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);
        $$->children.push_back($5);
        $$->children.push_back($7);

        //assembly

        // $$->code = $2->name + " PROC\n";

        // if($2->name == "main"){
        //     $$->code += "MOV AX, @DATA\n";
        //     $$->code += "MOV DS, AX\n";
        // }

        // $$->code += "PUSH BP\n";
        // $$->code += "MOV BP,SP\n";

        // $$->code += "SUB SP,"+to_string(SP)+"\n";

        // $$->code += $4->code + "\n";
        // $$->code += $7->code + "\n";

        // $$->code += "L_" + current_function_asm + ":\n";
        // $$->code += "ADD SP," + to_string(SP)+ "\n";
        // $$->code += "POP BP\n";

        // if($2->name == "main"){
        //     $$->code += "MOV AH,4ch\n";
        //     $$->code += "INT 21h\n";
        // }
        // else{
        //     $$->code += "RET\n";
        // }

        // $$->code += $2->name+"ENDP\n";

        // if($2->name =="main"){
        //     $$->code += "END MAIN\n";
        // }

        //cout<<"should main print?\n";


        // stack_offset = 0;



        // asmout<<$2->name<<" "<<"PROC"<<endl;


        // if($2->name == "main"){
        //     asmout<<"MOV AX, @DATA\n";
        //     asmout<<"MOV DS, AX\n";
        //     //asmout<<"PUSH BP\n";
        //     asmout<<"MOV BP,SP\n";
        // }
        // else{
        //     asmout<<"PUSH AX"<<endl;
        //     asmout<<"PUSH BX"<<endl;
        //     asmout<<"PUSH CX"<<endl;
        //     asmout<<"PUSH BP"<<endl;
        //     asmout<<"MOV BP , SP"<<endl;
        // }


        SymbolInfo* symbol = symbol_table->LookUp($2->get_name());

        //assembly
        asmout<<returnLabel<<": "<<endl;
        returnLabel.clear();

        if($2->name == "main"){
            asmout<<"MOV AX , 4CH"<<endl;
            asmout<<"INT 21H"<<endl;
        }
        else{
            //asmout<<"MOV DX, AX"<<endl;
            asmout<<"MOV SP , BP"<<endl;
            asmout<<"POP BP "<<endl;
            asmout<<"POP CX "<<endl;
            asmout<<"POP BX "<<endl;
            asmout<<"POP AX "<<endl;

            asmout<<"RET "<<symbol->parameter_list.size()*2<<endl;
            //asmout<<"RET "<<endl;
        }

        

        function_parameter_list.clear();


        erase_helper_pointer($1);
        erase_sym_pointer($2);
        erase_helper_pointer($4);
        erase_helper_pointer($7);

    }
    | type_specifier ID LPAREN RPAREN {
        _is_function = true;
        $1->id_name = $2->name;

        if($2 == NULL){
            //cout<<"first is null";
        }
        else if($1 == NULL){
            //cout<<"second is NULL";
        }
        else{
            //cout<<$2->name<<endl;
            //cout<<$1->id_name<<endl;
        }
        
        insert_func_definition($2,$1);

        returnLabel = newLabel();

        stack_offset = 0;

        asmout<<$2->name<<" "<<"PROC"<<endl;
        if($2->name == "main"){
            asmout<<"MOV AX , @DATA\n";
            asmout<<"MOV DS , AX\n";
            //asmout<<"PUSH BP\n";
            asmout<<"MOV BP , SP\n";
        }
        else{
            asmout<<"PUSH AX"<<endl;
            asmout<<"PUSH BX"<<endl;
            asmout<<"PUSH CX"<<endl;
            asmout<<"PUSH BP"<<endl;
            asmout<<"MOV BP , SP"<<endl;
        }

        
    } compound_statement {
        print_grammer_rule("func_definition", "type_specifier ID LPAREN RPAREN compound_statement");

        $$ = new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement","func_definition");
        $$->data = $1->data;
        $$->data += " ";
        $$->data += $2->get_name();
        $$->data += "(";
        $$->data += ")";
        $$->data += $6->data;

        //$2->set_type($1->data);
        $2->isFunction = true;
        $2->data_type = $1->name;
        symbol_table->insert(*($2) , place_holder);
        //cout<<$2->name<<" : "<<$2->parameter_list.size()<<endl;
        //print_log($$->data);

        //_is_function = false;
        

        $$->start_line = $1->start_line;
        $$->end_line = $6->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);
        $$->children.push_back($6);


        //assembly

        // $$->code = $2->name + " PROC\n";

        // if($2->name == "main"){
        //     $$->code += "MOV AX, @DATA\n";
        //     $$->code += "MOV DS , AX\n";
        // }

        // $$->code += "PUSH BP\n";
        // $$->code += "MOV BP,SP\n";

        // $$->code += "SUB SP,"+ to_string(SP) + "\n";

        // $$->code += $6->code + "\n"; 

        // $$->code += "L_" + current_function_asm + ":\n";
        // $$->code += "ADD SP,"+to_string(SP)+"\n";
        // $$->code += "POP BP\n";

        // if($2->name == "main"){
        //     $$->code += "MOV AH, 4ch\n";
        //     $$->code += "INT 21h\n";
        // }
        // else{
        //     $$->code += "RET\n";
        // }

        // $$->code += $2->name + " ENDP\n";

        // if($2->name == "main"){
        //     $$->code += "END MAIN\n";
        // }

        //cout<<"should main print?2 \n";


        //assembly

        asmout<<returnLabel<<": "<<endl;
        returnLabel.clear();

        if($2->name == "main"){
            asmout<<"MOV AX , 4CH"<<endl;
            asmout<<"INT 21H"<<endl;
        }
        else{
            asmout<<"MOV SP , BP"<<endl;
            asmout<<"POP BP"<<endl;
            asmout<<"POP CX"<<endl;
            asmout<<"POP BX"<<endl;
            asmout<<"POP AX"<<endl;
            asmout<<"RET "<<endl;
        }

        asmout<<$2->name<<" ENDP"<<endl;



        function_parameter_list.clear();

        erase_helper_pointer($1);
        erase_sym_pointer($2);
        erase_helper_pointer($6);
    }
    ;

parameter_list: parameter_list COMMA type_specifier ID {

       
        //2/1/2023 

        $$ = new SymbolInfo("parameter_list COMMA type_specifier ID","parameter_list");

        $$->data = $1->data;
        $$->data += ",";
        $$->data += $3->data;
        $$->data += " ";
        $$->data += $4->get_name();

        $3->id_name = $4->name;

        $$->arg_list = $1->arg_list;
        $$->arg_list.push_back($3->id_name);

        $$->datatype_list = $1->datatype_list;
        $$->datatype_list.push_back($3->data_type);


        //$4->set_type($3->data);
        

        for(int i=0;i<function_parameter_list.size();i++){
            if($3->id_name == function_parameter_list[i]->id_name){
                if(!_is_function){
                    error_many_dec($3->id_name);
                    //errorout<<"this is it\n";
                }
            }
        }
        function_parameter_list.push_back($3);


        $$->start_line = $1->start_line;
        $$->end_line = $4->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);


        //print_log($$->data);
        //print_log($4->get_name(),"ID");
        print_grammer_rule("parameter_list", "parameter_list COMMA type_specifier ID");

        erase_helper_pointer($1);
        erase_helper_pointer($3);
        erase_sym_pointer($4);
    }
    | parameter_list COMMA type_specifier {
        print_grammer_rule("parameter_list", "parameter_list COMMA type_specifier");

        $$ = new SymbolInfo("parameter_list COMMA type_specifier","parameter_list");

        $$->data = $1->data;
        $$->data += ",";
        $$->data += $3->data;

        $$->arg_list = $1->arg_list;
        $$->arg_list.push_back($3->id_name);


        $$->datatype_list = $1->datatype_list;
        $$->datatype_list.push_back($3->data_type);



        SymbolInfo* temp;
        temp->set_type($3->name);

        temp->id_name = "";

        function_parameter_list.push_back(temp);

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
       

        erase_helper_pointer($1);
        erase_helper_pointer($3);
    }
    | type_specifier ID {
       

        $$ = new SymbolInfo("type_specifier ID","parameter_list");

        $$->data = $1->data;
        $$->data += " ";
        $$->data += $2->get_name();

        $1->id_name = $2->name;

        $$->arg_list.push_back($1->name);

     
        $$->datatype_list.push_back($1->data_type);


        //$2->set_type($1->data);
        function_parameter_list.push_back($1);

        $$->start_line = $1->start_line;
        $$->end_line = $2->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
      

        //print_log($$->data);
        //print_log($2->get_name(),"ID");
        print_grammer_rule("parameter_list", "type_specifier ID");
        erase_helper_pointer($1);
        erase_sym_pointer($2);
    }
    | type_specifier {
        print_grammer_rule("parameter_list" , "type_specifier");

        $$ = new SymbolInfo("type_specifier","parameter_list");

        $$->data = $1->data;

        $$->arg_list.push_back($1->name);

        $$->datatype_list.push_back($1->data_type);

        SymbolInfo* temp ;
        temp->set_type($1->name);

        temp->id_name = "";

        function_parameter_list.push_back(temp);

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
        

        erase_helper_pointer($1);

    }

compound_statement: LCURL {

        symbol_table->Enter_Scope();

        stack_offset = 0;
        //symbol_table->print_current_scope(place_holder);
        //cout<<"Printing finished\n";
        
        if(_is_function){
            int stk_offset = -8-function_parameter_list.size()*2;
            for(auto func_para: function_parameter_list){

                
                //cout<<"func para printing\n";
                //cout<<func_para.id_name<<endl;

                
                string temp_name, temp_type;
                temp_name = func_para->id_name;
                temp_type =  func_para->name;
                func_para->name  = temp_name;
                func_para->type = temp_type;
                func_para->stack_offset = stk_offset;
                func_para->isGlobal = false;
                stk_offset += 2;

               // cout<<"parameter name: "<<func_para.name<<" offset: "<<func_para.stack_offset<<endl;

                if(!symbol_table->insert(*func_para,place_holder)){
                    error_many_dec(func_para->get_name());
                    //cout<<"enters scope1"<<endl;
                }
            }
            function_parameter_list.clear();
        } 
    } statements RCURL {

        print_grammer_rule("compound_statement", "LCURL statements RCURL");
       $$ = new SymbolInfo("LCURL statements RCURL","compound_statement");

        $$->data = "{\n";
        $$->data += $3->data;
        $$->data += "\n}";

        //print_log($$->data);
        $$->start_line = $1->start_line;
        $$->end_line = $4->end_line;

        $$->children.push_back($1);

        $$->children.push_back($3);
        $$->children.push_back($4);

        symbol_table->print_all_scope(logout);
        symbol_table->Exit_Scope();
        _is_function = false;
        erase_helper_pointer($3);
    }
    | LCURL{
        symbol_table->Enter_Scope();
        //symbol_table->print_current_scope(place_holder);
        //cout<<"Printing finished\n";
        if(_is_function){
            for(auto func_para: function_parameter_list){

                //cout<<"func para printing\n";
                //cout<<func_para.id_name<<endl;

                string temp_name, temp_type;
                temp_name = func_para->id_name;
                temp_type =  func_para->name;
                func_para->name  = temp_name;
                func_para->type = temp_type;
                func_para->isGlobal = false;

                if(!symbol_table->insert(*func_para,place_holder)){
                    error_many_dec(func_para->get_name());
                    //cout<<"enters scope2"<<endl;
                }
            }
        } 
    } RCURL{
        print_grammer_rule("compound_statement", "LCURL RCURL");

        $$ = new SymbolInfo("LCURL RCURL","compound_statement");

        $$->data = "{";
        $$->data += "}";

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);

        $$->children.push_back($3);
     

        symbol_table->print_all_scope(logout);
        symbol_table->Exit_Scope();
        
    }
    ;

var_declaration : type_specifier declaration_list SEMICOLON{

        

        $$ = new SymbolInfo("type_specifier declaration_list SEMICOLON","var_declaration");

        $$->data = $1->data;
        $$->data += " ";
        $$->data += $2->data;
        $$->data += ";";

        if($1->name == "VOID"){
            for(int i=0;i<$2->var_list.size();i++){
                error_void_type($2->var_list[i]->name);
            }
            
        }
        else{
            for(int i=0;i<$2->var_list.size();i++){
                //$2->var_list[i]->set_type("$1->name");

                $2->var_list[i]->data_type = $1->name;
            
                if(!symbol_table->insert(*($2->var_list[i]),place_holder)){
                    //cout<<($2->var_list[i])->get_name()<<endl;
                    //error_many_dec(($2->var_list[i])->get_name());
                    error_conflict_types(($2->var_list[i])->get_name());
                }
                else{
                    int current_scopetable_id = symbol_table->current_scope->own_id;
                    //cout<<"Current scope: "<<current_scopetable_id<<endl;
                    if(current_scopetable_id==1){
                        global_var_list.push_back(*($2->var_list[i]));
                    }
                    
                }

            }
            // if(symbol_table->current_scope->own_id ==1){
            //     init_var_dec();
            // }
        }

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
       

        //print_log($$->data);
        //print_log(";","SEMICOLON");
        print_grammer_rule("var_declaration", "type_specifier declaration_list SEMICOLON");

        

        erase_helper_pointer($1);
        erase_helper_pointer($2);

    }
    ;
type_specifier: INT{
        //print_grammer_rule("type_specifier", "INT");

        //cout<<"seg fault?1\n";
        $$ = new SymbolInfo("INT","type_specifier");
        //cout<<"seg fault?2\n";

        if($1==NULL){
           // cout<<"it is null\n";
        }
        else{
            //cout<<"Not null\n";
        }
        $$->data = $1->get_name();
        $$->data_type = "INT";

        //print_log($$->data, "INT");

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
       


        logout<<"type_specifier : INT"<<endl;

        erase_sym_pointer($1);
    }
    | FLOAT {
        

        $$ = new SymbolInfo("FLOAT","type_specifier");

        $$->data = $1->get_name();

        $$->data = "FLOAT";

        //print_log($$->data,"FLOAT");

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
   


        print_grammer_rule("type_specifier", "FLOAT");
        erase_sym_pointer($1);     
    }
    | VOID {
        

        $$ = new SymbolInfo("VOID","type_specifier");
        $$->data = $1->get_name();

        $$->data_type = "VOID";

        //print_log($$->data,"VOID");
        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);



        print_grammer_rule("type_specifier", "VOID");
        erase_sym_pointer($1);
    }
    ;
declaration_list: declaration_list COMMA ID{
        

        $$ = new SymbolInfo("declaration_list COMMA ID","declaration_list");
        $$->data = $1->data;
        $$->data += ",";
        $$->data += $3->get_name();

        //$$->type = $1->type;

        $$->var_list = $1->var_list;
        $$->var_list.push_back($3);

        //print_log(",","COMMA");
        //print_log($3->get_name(),"ID");

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);

        


        if(symbol_table->current_scope->own_id >1){

            

            stack_offset += 2;

            $3->stack_offset = stack_offset;

            //symbol->stack_offset = stack_offset;

            //cout<<"putting stack offset "<<stack_offset<<endl;


            asmout<<"SUB SP , 2"<<endl;
            //cout<<$3->name<<" is isGlobal set?"<<endl;
            $3->isGlobal = false;

            //symbol->isGlobal  = false;
            //cout<<$3->isGlobal<<endl;

            //cout<<"Stack offset of "<<$3->name<<" "<<$3->stack_offset<<endl;
        }

        else{
            string init_global_var = $3->name + " DW 0 ";
            asmout<<init_global_var<<endl;
        }

        
        

        //symbol_table->insert(*($3), place_holder);


        print_grammer_rule("declaration_list", "declaration_list COMMA ID");
        erase_helper_pointer($1);

    }
    | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE{
        
        print_grammer_rule("declaration_list", "declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");

       $$ = new SymbolInfo( "declaration_list COMMA ID LSQUARE CONST_INT RSQUARE","declaration_list");

        $$->data = $1->data;
        $$->data += ",";
        $$->data += $3->get_name();
        $$->data += "[";
        $$->data += $5->get_name();
        $$->data += "]";

        //$$->type = $1->type;

        $$->var_list = $1->var_list;

        //$3->set_type("array");
        $3->is_array = true;
        $3->ara_size = $5->name;
        $$->var_list.push_back($3);

        $$->start_line = $1->start_line;
        $$->end_line = $6->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);
        $$->children.push_back($5);
        $$->children.push_back($6);

        //assembly

        //SymbolInfo* symbol = symbol_table->LookUp($3->get_name());
        //symbol->ara_size = ($5->get_name()) ;


        if(symbol_table->current_scope->own_id >1){

            cout<<"seg falult glovaal aarra checking3"<<endl;
            

            stack_offset += 2*  stoi($3->ara_size);

            $3->stack_offset = stack_offset;

            //symbol->stack_offset = stack_offset;

            //cout<<"putting stack offset "<<stack_offset<<endl;


            asmout<<"SUB SP,"<<$3->stack_offset<<endl;
            //cout<<$3->name<<" is isGlobal set?"<<endl;
            $3->isGlobal = false;

            //symbol->isGlobal  = false;
            //cout<<$3->isGlobal<<endl;

            //cout<<"Stack offset of "<<$3->name<<" "<<$3->stack_offset<<endl;
        }
        else{
            cout<<"seg falult glovaal aarra checking1"<<endl;
            string init_global_ara = $3->name + " DW " + $3->ara_size + " DUP(0) ";
            cout<<"seg falult glovaal aarra checking2"<<endl;
            asmout<<init_global_ara<<endl;
        }


        erase_helper_pointer($1);
        erase_sym_pointer($5);
    }
    | ID {
        

        $$ = new SymbolInfo("ID","declaration_list");
        //parsetree<<"error might be here\n";

        $$->data = $1->get_name();

        $$->var_list.push_back($1);

        //print_log($$->data, "ID");
        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        //cout<<"testing error with ID\n";
        //cout<<$1->name<<" "<<$1->type<<endl;

        $$->children.push_back($1);



        //symbol->stack_offset = stack_offset;

        if(symbol_table->current_scope->own_id >1){


            stack_offset += 2;

            //$$->code  = $1->name;

            $1->stack_offset = stack_offset;

            asmout<<"SUB SP,2"<<endl;
            //cout<<$1->name<<" is isGlobal set?"<<endl;
            $1->isGlobal = false;
            //cout<<$1->isGlobal<<endl;

            //symbol->isGlobal = false;
        }
        else{
            string init_global_var = $1->name + " DW 0 ";
            asmout<<init_global_var<<endl;
        }
        

        //symbol_table->insert(*($1),place_holder);
        

        print_grammer_rule("declaration_list", "ID");
    }
    | ID LSQUARE CONST_INT RSQUARE {
        print_grammer_rule("declaration_list", "ID LSQUARE CONST_INT RSQUARE");

        $$ = new SymbolInfo("ID LSQUARE CONST_INT RSQUARE","declaration_list");

        $$->data = $1->get_name();
        $$->data += "[";
        $$->data += $3->get_name();
        $$->data += "]";

        //$1->set_type("array");
        $1->is_array = true;
        $1->ara_size = $3->get_name();
        $$->var_list.push_back($1);

        $$->start_line = $1->start_line;
        $$->end_line = $4->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);

        //print_log($$->data);

        //assembly

        if(symbol_table->current_scope->own_id >1){

            //cout<<"seg falult glovaal aarra checking6"<<endl;
            

            stack_offset += 2*  stoi($1->ara_size);

            $1->stack_offset = stack_offset;

            //symbol->stack_offset = stack_offset;

            //cout<<"putting stack offset "<<stack_offset<<endl;


            asmout<<"SUB SP,"<<$1->stack_offset<<endl;
            //cout<<$3->name<<" is isGlobal set?"<<endl;
            $1->isGlobal = false;

            //symbol->isGlobal  = false;
            //cout<<$3->isGlobal<<endl;

            //cout<<"Stack offset of "<<$3->name<<" "<<$3->stack_offset<<endl;
        }
        else{
            //cout<<"seg falult glovaal aarra checking4"<<endl;
            string init_global_ara = $1->name + " DW " + $1->ara_size + " DUP(0) ";
            //cout<<"seg falult glovaal aarra checking5"<<endl;
            asmout<<init_global_ara<<endl;
        }

        erase_sym_pointer($3);

    }
    ;

statements: statement{
        print_grammer_rule("statements", "statement");

        $$ = new SymbolInfo("statement","statements");
        $$->data = $1->data;


        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
   

        erase_helper_pointer($1);

    }
    | statements statement{
        print_grammer_rule("statements", "statements statement");

        $$ = new SymbolInfo("statements statement","statements");
        $$->data = $1->data;
        $$->data += "\n";
        $$->data += $2->data;

       // print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $2->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
     

        erase_helper_pointer($1);
        erase_helper_pointer($2);      
    }
    ;


pseudo : IF LPAREN expression
{
    elseLabel = newLabel();
    asmout<<"POP AX"<<endl;
    asmout<<"CMP AX, 0"<<endl;
    asmout<<"JE "<<elseLabel<<";check1"<<endl;
} RPAREN statement
{
    $$ = new SymbolInfo("","");

    $$->children.push_back($1);
    $$->children.push_back($2);
    $$->children.push_back($3);
    $$->children.push_back($5);
    $$->children.push_back($6);


    string endLabel = newLabel();
    endLabelAll.push_back(endLabel);

    asmout<<"JMP "<<endLabel<<";check2"<<endl;

    erase_sym_pointer($3);
    erase_sym_pointer($6);
}
;

statement: var_declaration{
        print_grammer_rule("statement", "var_declaration");

        $$ = new SymbolInfo("var_declaration","statement");
        $$->data = $1->data;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
    

        erase_helper_pointer($1);
    }
    | expression_statement {
        print_grammer_rule("statement", "expression_statement");

        $$ = new SymbolInfo("expression_statement","statement");
        $$->data = $1->data;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
    

        erase_helper_pointer($1);
    }   
    | compound_statement {
        print_grammer_rule("statement", "compound_statement");

        $$ = new SymbolInfo("compound_statement","statement");
        $$->data = $1->data;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
     
        erase_helper_pointer($1);        
    }
    | FOR LPAREN expression_statement {

        condition_for = newLabel();
        body_for = newLabel();
        update_for = newLabel();
        end_for = newLabel();

        asmout<<condition_for<<": "<<endl;

    } expression_statement {
        
        asmout<<"CMP AX, 0"<<endl;
        asmout<<"JNE "<<body_for<<endl;
        asmout<<"JMP "<<end_for<<endl;
        asmout<<update_for<<": "<<endl;

    }expression {
        asmout<<"POP AX "<<endl;
        asmout<<"JMP "<<condition_for<<endl;
    }RPAREN {
        asmout<<body_for<<": "<<endl;
    } statement{
        print_grammer_rule("statement", "FOR LPAREN expression_statement expression_statement expression RPAREN statement");

        $$ = new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement","statement");

        // $$->data = "for";
        // $$->data += "(";
        // $$->data += $3->data;
        // $$->data += $4->data;
        // $$->data += $5->data;
        // $$->data += ")";
        // $$->data += $7->data;

        $$->start_line = $1->start_line;
        $$->end_line = $11->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($5);
        $$->children.push_back($7);
        $$->children.push_back($9);
        $$->children.push_back($11);



        //assembly

        asmout<<"JMP "<<update_for<<endl;
        asmout<<end_for<<": "<< endl;

        

        //print_log($$->data);

        erase_helper_pointer($3);
        erase_helper_pointer($5);
        erase_helper_pointer($7);
        erase_helper_pointer($11);
    }
    | pseudo %prec LOWER_THAN_ELSE{
        print_grammer_rule("statement","IF LPAREN expression RPAREN statement");
        
        $$ = new SymbolInfo("IF LPAREN expression RPAREN statement","statement");

        // $$->data = "if";
        // $$->data += "(";
        // $$->data += $3->data;
        // $$->data += ")";
        // $$->data += $5->data;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
        // $$->children.push_back($2);
        // $$->children.push_back($3);
        // $$->children.push_back($4);
        // $$->children.push_back($5);


        //assembly


        asmout<<endLabelAll.back() <<": "<<endl;
        endLabelAll.pop_back();

        if(!elseLabel.empty()){
            asmout<<elseLabel<<": "<<endl;
            elseLabel.clear();
        }
    

        erase_helper_pointer($1);
        //erase_helper_pointer($5);
    }
    | pseudo ELSE {
        asmout<<elseLabel<<": "<<endl;
        elseLabel.clear();
    }  statement{
        print_grammer_rule("statement","IF LPAREN expression RPAREN statement ELSE statement");
    
        $$ = new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement","statement");
    
        // $$->data = "if";
        // $$->data += "(";
        // $$->data += $3->data;
        // $$->data += ")";
        // $$->data += $5->data;
        // $$->data += "\nelse ";
        // $$->data += $7->data;

        $$->start_line = $1->start_line;
        $$->end_line = $4->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        //$$->children.push_back($3);
        $$->children.push_back($4);
        // $$->children.push_back($5);
        // $$->children.push_back($6);
        // $$->children.push_back($7);
       
        //assembly

        asmout<<endLabelAll.back()<<": "<<endl;
        endLabelAll.pop_back();


        //print_log($$->data);

        erase_helper_pointer($1);
        erase_helper_pointer($4);
        //erase_helper_pointer($7);
    }
    | WHILE LPAREN {

        condition_while = newLabel();
        body_while = newLabel();
        end_while = newLabel();
        asmout<< condition_while<<": "<<endl;

    } expression {
        asmout<<"POP AX"<<endl;
        asmout<<"CMP AX, 0"<<endl;
        asmout<<"JNE "<<body_while<<endl;
        asmout<<"JMP "<<end_while<<endl;
    } RPAREN {
        asmout<<body_while<<": "<<endl;
    }statement{
        print_grammer_rule("statement","WHILE LPAREN expression RPAREN statement");

        $$ = new SymbolInfo("WHILE LPAREN expression RPAREN statement","statement");

        // $$->data = "while";
        // $$->data += "(";
        // $$->data += $3->data;
        // $$->data += ")";
        // $$->data += $5->data;

        $$->start_line = $1->start_line;
        $$->end_line = $8->end_line;

        //print_log($$->data);

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($4);
        $$->children.push_back($6);
        $$->children.push_back($8);


        //assembly

        asmout<<"JMP "<<condition_while<<endl;

        asmout<<end_while<<": "<<endl;

        erase_helper_pointer($4);
        erase_helper_pointer($8);
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON{
        print_grammer_rule("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");

        $$ = new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON","statement");


        $$->start_line = $1->start_line;
        $$->end_line = $5->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);
        $$->children.push_back($5);

        //assembly

        //cout<<$3->name<<" is global "<<$3->isGlobal<<endl;

        SymbolInfo* symbol = symbol_table->LookUp($3->name);

        if(symbol->isGlobal){
            asmout<<"MOV AX , "<<symbol->name<<endl;
        }
        else{
            asmout<<"MOV AX , [BP-"<<symbol->stack_offset<<"]"<<endl;
        }
        asmout<<"CALL print_output\n";
        asmout<<"CALL new_line\n";
        //print_log($$->data);
        //undeclared error
    }
    | RETURN expression SEMICOLON{
        print_grammer_rule("statement","RETURN expression SEMICOLON");

        $$ = new SymbolInfo("RETURN expression SEMICOLON","statement");
        $$->data = "return";
        $$->data += " ";
        $$->data += $2->data;
        $$->data += ";";

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);


        //assembly

        asmout<<"POP DX"<<endl;
        asmout<<"JMP "<<returnLabel<<endl;

      

        //print_log($$->data);

        erase_helper_pointer($2);
    }
    ;

expression_statement: SEMICOLON{
        print_grammer_rule("expression_statement","SEMICOLON");

        $$ = new SymbolInfo("SEMICOLON","expression_statement");
        $$->data = ";";

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
  
        //print_log($$->data);
    }
    | expression SEMICOLON{
        print_grammer_rule("expression_statement","expression SEMICOLON");
        
        $$ = new SymbolInfo("expression SEMICOLON","expression_statement");

        
        $$->data = $1->data;
        $$->data += ";";

        $$->start_line = $1->start_line;
        $$->end_line = $2->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);

        //assembly

        asmout<<"POP AX"<<endl;
        

        //print_log($$->data);

        erase_helper_pointer($1);
    }
    ;
variable: ID{
        
        $$ = new SymbolInfo("ID","variable"); // entering name as arg type

        $$->data = $1->get_name();

        SymbolInfo* temp = symbol_table->LookUp($1->get_name());

        if(temp!=NULL){
            temp->isFunction = true;
        }

        // if(temp!=NULL){
        //     $$->arg_type = temp->data_type;
        // }


        //$$->type = temp->get_type();

        //print_log($$->data, "ID");

        $$->arg_type = $1->name;
        $$->data_type = $1->data_type;
        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
        

        print_grammer_rule("variable","ID");

        SymbolInfo* symbol = symbol_table->LookUp($1->get_name());

        if(symbol->isGlobal){
            asmout<<"MOV AX , "<<symbol->get_name()<<"; checking if gloval"<<endl;
        }
        else{
            asmout<<"MOV AX, [BP-"<<symbol->stack_offset<<"]"<<endl;
            cout<<"ax, bp checking:: symbol name: "<<symbol->name<<" offset: "<<symbol->stack_offset<<endl;
        }
        erase_sym_pointer($1);
        
    }
    | ID LSQUARE expression RSQUARE{
        print_grammer_rule("variable","ID LSQUARE expression RSQUARE");
        
        $$ = new SymbolInfo("ID LSQUARE expression RSQUARE","variable");
    
        $$->data = $1->get_name();
        $$->data += "[";
        $$->data += $3->data;
        $$->data += "]";

        SymbolInfo* temp = symbol_table->LookUp($1->get_name());
        if(temp!=NULL){
            temp->isFunction = true;
        }
        else{
            error_not_array($1->get_name());
        }

        $$->arg_type = $1->name; // entering name as arg type
        //$$->arg_type = $1->data_type;
        $$->is_array = true;



        if($3->data_type != "INT"){
            error_nonint_array();
        }




        //$$->type = temp->get_type();

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $4->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);

        //assembly

        // SymbolInfo* symbol = symbol_table->LookUp($1->get_name());

        // asmout<<"POP CX"<<endl;

        // asmout <<"SUB CX, "<<symbol->stack_offset<<endl;

        // asmout<<"MOV AX , [BP+CX]"<<endl;


        erase_sym_pointer($1);
        erase_helper_pointer($3);
    }
    ;
expression: logic_expression{
        print_grammer_rule("expression","logic_expression");

        $$ = new SymbolInfo("logic_expression","expression");

        $$->data = $1->data;

        //$$->type = $1->type;

        $$->arg_type = $1->arg_type;
        $$->data_type = $1->data_type;

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
       

        //print_log($$->data);

        erase_helper_pointer($1);
    }
    | variable ASSIGNOP logic_expression{
        print_grammer_rule("expression","variable ASSIGNOP logic_expression");
        
        $$ = new SymbolInfo("variable ASSIGNOP logic_expression","expression");

        
        $$->data = $1->data;
        $$->data += "=";
        $$->data += $3->data;

        //print_log($$->data);

        SymbolInfo* temp = symbol_table->LookUp($1->arg_type);

        if(temp == NULL){
            if($1->arg_type != ""){
                error_undeclared_variable($1->arg_type);
            }
        }
        else{
            SymbolInfo* temp = symbol_table->LookUp($1->arg_type);
            if(temp->is_array == false && $1->is_array == true){
                error_not_array($1->arg_type);
            }
        }

        if(temp!=NULL){

            if(temp->data_type == "INT" && $3->data_type == "FLOAT"){
                warning_precision("FLOAT", "INT");
            }
        }

        if($3->data_type == "VOID"){
            if(!void_expr){
                error_void_expr();
                void_expr = true;
            }
        }

        void_expr = false;

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);

        $1->code = $3->code;
        $$->code = $3->code;

       // asmout<<";"<<line_count<<endl;

        //asmout<<"MOV AX, "<<$3->code<<endl;
        //cout<<"before seg falult "<<$1->arg_type<<endl;
        SymbolInfo* symbol = symbol_table->LookUp($1->arg_type);

        //asmout<<"L"<<label<<":"<<endl;
        //label++;

        if(symbol->is_array){
            asmout<<"POP CX "<<endl;
            asmout<<"POP AX"<<endl;
            asmout<<"SHL AX,1"<<endl;

            if(symbol->isGlobal){
                asmout<<"MOV BX, AX"<<endl;
                asmout<<"MOV [" <<symbol->name<<"+BX] , CX"<<endl;
            }
            else{
                asmout<<"MOV SI, "<<symbol->stack_offset<<"; si"<<endl;
                asmout<<"ADD SI, AX"<<endl;
                asmout<<"NEG SI"<<endl;
                asmout<<"MOV [BP+SI] , CX"<<endl;
            }

            asmout<<"PUSH CX "<<endl;

        }
        else{

            asmout<<"POP AX"<<endl;

            if(symbol->isGlobal){
                asmout<<"MOV "<<symbol->name<<", AX"<<endl;
                
                //asmout<<"could be error"<<endl;
            }
            else{
                asmout<<"MOV [BP-"<<symbol->stack_offset<<"] , AX"<<endl;
            }
            asmout<<"PUSH AX"<<endl;
        }
        //asmout<<"POP AX"<<endl;

       

        erase_helper_pointer($1);
        erase_helper_pointer($3);
    }
    ;
logic_expression: rel_expression{
        print_grammer_rule("logic_expression","rel_expression");

       $$ = new SymbolInfo("rel_expression","logic_expression");

        $$->data = $1->data;

        $$->arg_type = $1->arg_type;
        $$->data_type = $1->data_type;

        //$$->type = $1->type;

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        $$->code = $1->code;
       

        //print_log($$->data);

        erase_helper_pointer($1);
    }
    | rel_expression LOGICOP rel_expression{
        print_grammer_rule("logic_expression","rel_expression LOGICOP rel_expression");
        
        $$ = new SymbolInfo("rel_expression LOGICOP rel_expression","logic_expression");

        $$->data = $1->data;
        $$->data += $2->get_name();
        $$->data += $3->data;


        string type_casted = imp_typecast($1->data_type, $3->data_type);

        if(type_casted == "ERROR"){
            if(!void_expr){
                error_void_expr();
                void_expr = true;
            }
        }

        $$->data_type = "INT";

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);

        //assembly

        string intermediate_label = newLabel();
        string end_label = newLabel();

        asmout<<"POP BX"<<endl;
        asmout<<"POP AX"<<endl;

        if($2->get_name() == "&&"){
            asmout<<"CMP AX, 0"<<endl;
            asmout<<"JE "<<intermediate_label<<endl; //false
            asmout<<"CMP BX, 0"<<endl;
            asmout<<"JE "<<intermediate_label<<endl;//false
            asmout<<"PUSH 1"<<endl; // true
            asmout<<"JMP "<<end_label<<endl;
            asmout<<intermediate_label<<": "<<endl;
            asmout<<"PUSH 0"<<endl;
            asmout<<end_label<<": "<<endl;
        }

        else if($2->get_name() == "||"){
            asmout<<"CMP AX, 0"<<endl;
            asmout<<"JNE "<<intermediate_label<<endl; //true
            asmout<<"CMP BX, 0"<<endl;
            asmout<<"JNE "<<intermediate_label<<endl;//true
            asmout<<"PUSH 0"<<endl; // false
            asmout<<"JMP "<<end_label<<endl;
            asmout<<intermediate_label<<": "<<endl;
            asmout<<"PUSH 1"<<endl;
            asmout<<end_label<<": "<<endl;            
        }
       

        erase_helper_pointer($1);
        erase_sym_pointer($2);
        erase_helper_pointer($3);
    }   
    ;
rel_expression: simple_expression{
        print_grammer_rule("rel_expression","simple_expression");

        $$ = new SymbolInfo("simple_expression","rel_expression");
    
        $$->data = $1->data;

        $$->arg_type = $1->arg_type;
        $$->data_type = $1->data_type;

        //print_log($$->data);
        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        $$->code = $1->code;
       

        erase_helper_pointer($1);
    }
    | simple_expression RELOP simple_expression{
        print_grammer_rule("rel_expression","simple_expression RELOP simple_expression");
        
        $$ = new SymbolInfo("simple_expression RELOP simple_expression","rel_expression");
        
        $$->data = $1->data;
        $$->data += $2->get_name();
        $$->data += $3->data;

        string type_casted = imp_typecast($1->data_type, $3->data_type);

        

        if(type_casted == "ERROR"){
            if(!void_expr){
                error_void_expr();
                void_expr = true;
            }
        }

        $$->data_type = "INT";

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);



        //assembly

        asmout<<"POP BX"<<endl;
        asmout<<"POP AX"<<endl;
        asmout<<"CMP AX,BX"<<endl;


        string trueLabel = newLabel();
        string falseLabel = newLabel();

        if($2->name == ">="){
            asmout<<"JGE "<<trueLabel<<endl;
        }
        else if($2->name == ">"){
            asmout<<"JG "<<trueLabel<<endl;
        }
        else if($2->name == "<="){
            asmout<<"JLE "<<trueLabel<<endl;
        }
        else if($2->name == "<"){
            asmout<<"JL "<<trueLabel<<endl;
        }
        else if($2->name == "=="){
            asmout<<"JE "<<trueLabel<<endl;
        }
        else if($2->name == "!="){
            asmout<<"JNE "<<trueLabel<<endl;
        }

        asmout<<"PUSH 0"<<endl;
        asmout<<"JMP "<<falseLabel<<endl;

        asmout<<trueLabel<<":"<<endl;
        asmout<<"PUSH 1"<<endl;

        asmout<<falseLabel<<":"<<endl;
       

        //print_log($$->data);

        erase_helper_pointer($1);
        erase_sym_pointer($2);
        erase_helper_pointer($3);

    }
    ;
simple_expression: term{
        print_grammer_rule("simple_expression","term");

        $$ = new SymbolInfo("term","simple_expression");

        $$->data = $1->data;

        $$->arg_type = $1->arg_type;
        $$->data_type = $1->data_type;

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        $$->code = $1->code;
       

        //print_log($$->data);

        erase_helper_pointer($1);
    }
    | simple_expression ADDOP term{
        print_grammer_rule("simple_expression","simple_expression ADDOP term");
        //cout<<"error in simple ecpr addop?1"<<endl;
        $$ = new SymbolInfo("simple_expression ADDOP term","simple_expression");
        //cout<<"error in simple ecpr addop?2"<<endl;
        $$->data = $1->data;
        //cout<<"error in simple ecpr addop?3"<<endl;
        $$->data += $2->get_name();
        //cout<<"error in simple ecpr addop?4"<<endl;
        //$$->data += $3->data;
        //cout<<"error in simple ecpr addop?5"<<endl;

        string type_casted = imp_typecast($1->data_type, $3->data_type);

        // cout<<"type casting check"<<endl;

        // cout<<$1->data_type<<endl;
        // cout<<$3->data_type<<endl;
        // cout<<type_casted<<endl;
        // cout<<line_count<<endl;


        if(type_casted == "ERROR"){
            if(!void_expr){
                error_void_expr();
                void_expr = true;
            }
        }


        $$->arg_type = $1->arg_type;
        $$->data_type = type_casted;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);

        //int first = stoi($1->code);
        //int second = stoi($4->code);





        //$$->code = to_string(first + second);



        // asmout<<"ADD DX, AX"<<endl;
        // asmout<<"MOV AX, DX"<<endl;
        // asmout<<"PUSH AX"<<endl;
        // asmout<<"POP AX"<<endl;

        if($2->get_name()== "+"){
            asmout<<"POP AX"<<endl;
            asmout<<"POP DX"<<endl;
            asmout<<"ADD AX, DX"<<endl;
            asmout<<"PUSH AX"<<endl;
        }
        else if($2->get_name() == "-"){
            asmout<<"POP DX"<<endl;
            asmout<<"POP AX"<<endl;
            asmout<<"SUB AX, DX"<<endl;
            asmout<<"PUSH AX"<<endl;
        }
        

        //cout<<"enters here"<<endl;
        

        erase_helper_pointer($1);
        erase_sym_pointer($2);
        erase_helper_pointer($3);
    }   
    ;
term: unary_expression{
        print_grammer_rule("term","unary_expression");

        $$ = new SymbolInfo("unary_expression","term");
 
        $$->data = $1->data;
  
        $$->arg_type = $1->arg_type;
        $$->data_type = $1->data_type;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        $$->code = $1->code;

        //asmout<<"MOV AX , "<<$1->code<<endl;
        //asmout<<"MOV DX, AX"<<endl;
   

        erase_helper_pointer($1);
    }
    | term MULOP unary_expression{
        print_grammer_rule("term","term MULOP unary_expression");

        $$ = new SymbolInfo("term MULOP unary_expression","term");
        
        // $$->data = $1->data;
        // $$->data += $2->get_name();
        // $$->data += $3->data;

        string type_casted = imp_typecast($1->data_type,$3->data_type);

        if(type_casted == "ERROR"){
            if(!void_expr){
                error_void_expr();
                void_expr = true;
            }
        }



        if($2->get_name() == "%"){
            if($3->data == "0"){
                //error
                warning_divide_by_zero();
            }
            
            else{
                if(type_casted == "INT"){
                    $$->data_type = "INT";
                }
                else{
                    //error
                    error_modulus_non_int();
                }
            }
        }
        
        else{
            $$->data_type = type_casted;
        }

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);


        if($2->get_name() ==  "*"){
            // asmout<<"CWD"<<endl;
            // asmout<<"MUL CX"<<endl;
            // asmout<<"PUSH AX"<<endl;
            // asmout<<"POP AX"<<endl;

            asmout<<"POP CX"<<endl;
            asmout<<"POP AX"<<endl;
            asmout<<"CWD"<<endl;
            asmout<<"IMUL CX"<<endl;
            asmout<<"PUSH AX"<<endl;
        }
         else if($2->get_name() == "%"){
        //     asmout<<"PUSH AX"<<endl;
        //     asmout<<"MOV AX, CX"<<endl;
        //     asmout<<"POP CX"<<endl;
        //     asmout<<"CWD"<<endl;
        //     asmout<<"DIV CX"<<endl;
        //     asmout<<"PUSH DX"<<endl;
        //     asmout<<"POP AX"<<endl; 

            asmout<<"POP CX"<<endl;
            asmout<<"POP AX"<<endl;
            asmout<<"CWD"<<endl;
            asmout<<"IDIV CX"<<endl;
            asmout<<"PUSH DX"<<endl;

        }

        else if($2->get_name() == "/"){
            asmout<<"POP CX"<<endl;
            asmout<<"POP AX"<<endl;
            asmout<<"CWD"<<endl;
            asmout<<"IDIV CX"<<endl;
            asmout<<"PUSH AX"<<endl;
        }
       

        erase_helper_pointer($1);
        erase_sym_pointer($2);
        erase_helper_pointer($3);

    }
    ;
unary_expression: ADDOP unary_expression{

        print_grammer_rule("unary_expression","ADDOP unary_expression");
        
        $$ = new SymbolInfo("ADDOP unary_expression","unary_expression");
        
        $$->data = $1->get_name();
        $$->data += $2->data;
        
        $$->arg_type = $2->arg_type;
        $$->data_type = $2->data_type;

        if($2->data_type == "VOID"){
            if(!void_expr){
                error_void_expr();
                void_expr = true;
            }
        }

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $2->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);


        //assembly


        if($1->name == "-"){
            asmout<<"POP AX"<<endl;
            asmout<<"NEG AX"<<endl;
            asmout<<"PUSH AX"<<endl;
        }
        

        erase_sym_pointer($1);
        erase_helper_pointer($2);
    }
    | NOT unary_expression{
        print_grammer_rule("unary_expression","NOT unary_expression");
        
        $$ = new SymbolInfo("NOT unary_expression","unary_expression");
        
        $$->data = "!";
        $$->data += $2->data;
        
        $$->arg_type = $2->arg_type;
        $$->data_type = $2->data_type;

        if($2->data_type == "VOID"){
            if(!void_expr){
                error_void_expr();
                void_expr = true;
            }
        }        

        $$->start_line = $1->start_line;
        $$->end_line = $2->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
     

        //print_log($$->data);

        erase_helper_pointer($2);
    }
    | factor{
        print_grammer_rule("unary_expression","factor");
        
        $$ = new SymbolInfo("factor","unary_expression");
        
        $$->data = $1->data;
  
        $$->arg_type = $1->arg_type;
        $$->data_type = $1->data_type;

        //cout<<"factor data type: "<<$$->arg_type<<endl;

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        $$->code = $1->code;
       

        //print_log($$->data);

        erase_helper_pointer($1);      
    }
    ;
factor: variable{
        print_grammer_rule("factor","variable");

        $$ = new SymbolInfo("variable","factor");
  
        $$->data = $1->data;

        SymbolInfo* var = symbol_table->LookUp($1->arg_type);
        if(var != NULL){
            $$->data_type = var->data_type;
        }

        $$->arg_type = $1->arg_type;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);

        //assm


        SymbolInfo* symbol = symbol_table->LookUp($1->arg_type);

        if(symbol->is_array){
            asmout<<"POP AX "<<endl;
            asmout<<"SHL AX , 1"<<endl;

            if(symbol->isGlobal){
                asmout<<"MOV BX, AX"<<endl;
                asmout<<"PUSH ["<<symbol->name<<"+BX]"<<endl;
            }
            else{
                asmout<<"MOV SI, "<<symbol->stack_offset<<endl;
                asmout<<"ADD SI, AX"<<endl;
                asmout<<"NEG SI"<<endl;
                asmout<<"PUSH [BP+SI]"<<endl;
            }
        }
        else{
            if(symbol->isGlobal){
                asmout<<"PUSH "<<symbol->get_name()<<endl;
            }
            else{
                asmout<<"PUSH [BP-"<<symbol->stack_offset<<"]"<<endl;
            }
        }
      

        erase_helper_pointer($1);
    }
    | ID LPAREN argument_list RPAREN{
        print_grammer_rule("factor","ID LPAREN argument_list RPAREN");

        $$ = new SymbolInfo("ID LPAREN argument_list RPAREN","factor");

        // $$->data = $1->get_name();
        // $$->data += "(";
        // $$->data += $3->data;
        // $$->data += ")";



         SymbolInfo* type_casted = symbol_table->LookUp($1->get_name());

        if(type_casted == NULL){

            
            //cout<<"type casted is null\n";
            //cout<<$1->get_name()<<endl;
            error_undeclared_function($1->name);

            for(int i=0;i<$3->arg_list.size();i++){

                //cout<<$3->arg_list[i]<<endl;
                SymbolInfo* temp = symbol_table->LookUp($3->arg_list[i]);
                if(temp == NULL){
                    //cmp = temp->data_type;
                    if($3->arg_list[i]!= "int" && $3->arg_list[i]!= "float"){
                        error_undeclared_variable($3->arg_list[i]);
                    }
                    //cout<<"this is cmp data type testing "<<cmp<<" "<<endl;
                }
            }

        }
        else{
            //cout<<$1->get_name()<<endl;
            //cout<<type_casted->name<<endl;
            // cout<<type_casted->type<<endl;
            // cout<<type_casted->var_list.size()<<endl;
            // cout<<type_casted->arg_list.size()<<endl;
            // cout<<type_casted->isFunction<<endl;
            // cout<<type_casted->parameter_list.size()<<endl;
            // cout<<type_casted->data_type<<endl;

        

            // $$->arg_type = type_casted->data_type;

            // for(int i=0;i<$1->var_list.size();i++){
            //     cout<<$1->var_list[i]->data_type<<endl;
            //     cout<<$2->arg_list[i]<<endl;
            // }

            // cout<<"Arg list printing "<<$1->name<<endl;
            // for(int i=0;i<$3->arg_list.size();i++){
            //     cout<<$3->arg_list[i]<<endl;
            // }

            SymbolInfo* func_name = symbol_table->LookUp($1->name);

            if(func_name!= NULL){
                $$->data_type = func_name->data_type; // variable arg_type is data type ex, int
                //cout<<"Data type inserted: "<<func_name->data_type<<endl;
            }

            //cout<<"Parameters: "<< func_name->name<<func_name->parameter_list.size()<<" "<<endl;
            //cout<<"Arguments: "<< $3->name<<$3->arg_list.size()<<" "<<endl;

            if(func_name->parameter_list.size()>$3->arg_list.size()){
                error_too_few_args(func_name->name);
            }
            else if(func_name->parameter_list.size()<$3->arg_list.size()){
                error_too_much_args(func_name->name);
            }
            else{
                for(int i=0;i<func_name->parameter_list.size();i++){

                    cout<<"arg list testing "<<$3->arg_list.size()<<endl;
                    //SymbolInfo* temp = symbol_table->LookUp(( $3->arg_list[i]));
                    //cout<<"Looked up for: "<<$3->arg_list[i]<<endl;
                    string cmp;
                    // if(temp==NULL){
                    //     cout<<"temp is null\n";
                    // }
                    // if( temp->data_type == "INT"){
                    //     cout<<"temp is: "<<temp->data_type<<endl;
                    //     cmp = "INT";
                    // }
                    // else if(temp!= NULL && temp->data_type == "FLOAT"){
                    //     cmp = "FLOAT";
                    //     cout<<"temp is: "<<temp->data_type<<endl;
                    // }
                    // else if(temp!= NULL && temp->data_type == "VOID"){
                    //     cout<<"temp is: "<<temp->data_type<<endl;
                    //     cmp = "VOID";
                    // }
                    // else{
                        
                    //     if(temp!= NULL){
                    //         cmp = temp->data_type;
                    //         cout<<"temp is: "<<temp->data_type<<endl;
                    //         //cout<<"this is cmp data type testing "<<cmp<<" "<<endl;
                    //     }
                    //     else{
                    //         if($3->arg_list[i]!= "int" && $3->arg_list[i]!= "float" && $3->arg_list[i]!=""){
                    //             error_undeclared_variable($3->arg_list[i]);
                    //         }
                    //     }
                    // }

                    

                    //cout<<"Cmp is: "<<cmp<<endl;
                    // cout<<"Arg list[i]: "<<$3->arg_list[i]<<endl;
                    // cout<<"datatype list[i]: "<<$3->datatype_list[i]<<endl;
                    // cout<<"func_name->parameter_list[i]->data_type "<<func_name->parameter_list[i].data_type<<endl;
                    if(func_name->parameter_list[i]->data_type != $3->datatype_list[i]){
                        error_type_mismatch(i+1,func_name->name);
                    }
                }
            }
        }



        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $4->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
        $$->children.push_back($4);

        //assembly

        asmout<<"CALL "<<$1->name<<endl;
        asmout<<"PUSH DX"<<endl;
     

        erase_sym_pointer($1);
        erase_helper_pointer($3);

    }
    | LPAREN expression RPAREN{
        print_grammer_rule("factor","LPAREN expression RPAREN");

        $$ = new SymbolInfo("LPAREN expression RPAREN","factor");
        
        $$->data = "(";
        $$->data += $2->data;
        $$->data += ")";

        $$->arg_type = $2->arg_type;
        $$->data_type = $2->data_type;

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
       

        //print_log($$->data);

        erase_helper_pointer($2);


    }
    | CONST_INT{
        print_grammer_rule("factor","CONST_INT");

        $$ = new SymbolInfo("CONST_INT","factor");
        $$->data = $1->get_name();

        
        $$->data_type = "INT";
        $$->arg_type = $1->get_name();
        $$->isConst = true;

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;
        $$->children.push_back($1);

        //cout<<"get name of const int: "<<$1->get_name()<<endl;

        $$->code = $1->get_name();
       
       asmout<<"MOV AX , "<<$1->get_name()<<endl;

       asmout<<"PUSH AX"<<endl;

        //print_log($$->data);

        erase_sym_pointer($1);
    }
    | CONST_FLOAT{
        print_grammer_rule("factor","CONST_FLOAT");

        $$ = new SymbolInfo("CONST_FLOAT","factor");
        $$->data = $1->get_name();

        
        $$->arg_type = $1->get_name();
        $$->data_type = "FLOAT";
        $$->isConst = true;

        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
     

        //print_log($$->data);

        erase_sym_pointer($1);
    }
    | variable INCOP{
        print_grammer_rule("factor","variable INCOP");

        $$ = new SymbolInfo("variable INCOP","factor");
        $$->data = $1->data;
        $$->data += "++";

        $$->arg_type = $1->arg_type;
        $$->data_type = $1->data_type;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $2->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);


        //assembly

        SymbolInfo* symbol = symbol_table->LookUp($1->arg_type);

        //cout<<"InCOP is global? "<<symbol->name<<" "<< symbol->isGlobal<<symbol->stack_offset<< endl;

        if(symbol->is_array){
            asmout<<"POP AX"<<endl;
            asmout<<"SHL AX, 1"<<endl;

            if(symbol->isGlobal){
                asmout<<"MOV BX , AX"<<endl;
                asmout<<"PUSH ["<<symbol->name<<"+BX]"<<endl;
                asmout<<"INC WORD PTR["<<symbol->name<<"+BX]"<<endl;
            }
            else{
                asmout<<"MOV SI, "<<symbol->stack_offset<<endl;
                asmout<<"ADD SI , AX"<<endl;
                asmout<<"NEG SI"<<endl;
                asmout<<"PUSH [BP+SI]"<<endl;
                asmout<<"INC WORD PTR[BP+SI]"<<endl;
            }
        }
        else{
            if(symbol->isGlobal){
                asmout<<"PUSH "<<symbol->name<<endl;
                asmout<<"INC "<<symbol->name<<endl;
            }
            else{
                asmout<<"PUSH [BP-"<<symbol->stack_offset<<"]"<<endl;
                asmout<<"INC WORD PTR [BP-"<<symbol->stack_offset<<"]"<<endl;
            }
        }
       

        erase_helper_pointer($1);
    }
    | variable DECOP{
        print_grammer_rule("factor","variable DECOP");

        $$ = new SymbolInfo("variable DECOP","factor");
        $$->data = $1->data;
        $$->data += "--";

        $$->arg_type = $1->arg_type;
        $$->data_type = $1->data_type;

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $2->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);

        //assembly

        SymbolInfo* symbol = symbol_table->LookUp($1->arg_type);

        //cout<<"InCOP is global? "<<symbol->name<<" "<< symbol->isGlobal<<symbol->stack_offset<< endl;


        if(symbol->is_array){
            asmout<<"POP AX"<<endl;
            asmout<<"SHL AX, 1"<<endl;

            if(symbol->isGlobal){
                asmout<<"MOV BX, AX"<<endl;
                asmout<<"PUSH ["<<symbol->name<<"+BX]"<<endl;
                asmout<<"DEC WORD PTR["<<symbol->name<<"+BX]"<<endl;
            }
            else{
                asmout<<"MOV SI, "<<symbol->stack_offset<<endl;
                asmout<<"ADD SI , AX"<<endl;
                asmout<<"NEG SI"<<endl;
                asmout<<"PUSH [BP+SI]"<<endl;
                asmout<<"DEC WORD PTR[BP+SI]"<<endl;
            }
        }
        else{
            if(symbol->isGlobal){
                asmout<<"PUSH "<<symbol->name<<endl;
                asmout<<"DEC "<<symbol->name<<endl;
            }
            else{
                asmout<<"PUSH [BP-"<<symbol->stack_offset<<"]"<<endl;
                asmout<<"DEC WORD PTR [BP-"<<symbol->stack_offset<<"]"<<endl;
            }
        }
       

        erase_helper_pointer($1);
    }
    ;
argument_list: arguments{
        print_grammer_rule("argument_list","arguments");

        $$ = new SymbolInfo("arguments","argument_list");
        $$->data = $1->data;

        $$->arg_list = $1->arg_list;
        $$->datatype_list = $1->datatype_list;

        //print_log($$->data);
        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
      

        erase_helper_pointer($1);
    }
    | {
        print_grammer_rule("argument_list","");

        $$ = new SymbolInfo("","argument_list");
    }
    ;
arguments: arguments COMMA logic_expression{
        print_grammer_rule("arguments","arguments COMMA logic_expression");
        
       $$ = new SymbolInfo("arguments COMMA logic_expression","arguments");
        $$->data = $1->data; 
        $$->data += ","; 
        $$->data += $3->data;

       
        $$->arg_list = $1->arg_list; 
        $$->arg_list.push_back($3->arg_type);

        $$->datatype_list = $1->datatype_list;
        $$->datatype_list.push_back($3->data_type);

        //print_log($$->data);

        $$->start_line = $1->start_line;
        $$->end_line = $3->end_line;

        $$->children.push_back($1);
        $$->children.push_back($2);
        $$->children.push_back($3);
   

        erase_helper_pointer($1);
        erase_helper_pointer($3);
    }
    |logic_expression{
        print_grammer_rule("arguments","logic_expression");

        $$ = new SymbolInfo("logic_expression","arguments");


        $$->data = $1->data; 

        //$$->type = $1->type;

        $$->arg_list.push_back($1->arg_type);
        $$->datatype_list.push_back($1->data_type);

        //print_log($$->data);
        $$->start_line = $1->start_line;
        $$->end_line = $1->end_line;

        $$->children.push_back($1);
        

        erase_helper_pointer($1);
    }
    ;




%%

int ScopeTable::id = 0;
main(int argc, char *argv[])
{
    if(argc!=2){
        cout<<"Provide input file name\n";
        return 0;
    }

    FILE *finput = fopen(argv[1], "r");
    if(finput == NULL){
        cout<<"Can't open\n";
        return 0;
    } 

    logout.open("log.txt");
    errorout.open("error.txt");
    place_holder.open("dump.txt");
    parsetree.open("parse_tree.txt");
    asmout.open("code.asm");

    init_asm();

    yyin = finput;
    yyparse();

    print_asm();

    symbol_table->print_all_scope(logout);

    logout<<"Total lines: "<<line_count<<endl;
    logout<<"Total errors: "<<error_count<<endl;

    fclose(yyin);

    logout.close();
    errorout.close();
    parsetree.close();

    exit(0);
}