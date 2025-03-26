#include<bits/stdc++.h>

using namespace std;


class Output
{
public:
    int scopetable_number;
    int hash_value = -1;
    int chain_number = -1;

};


class SymbolInfo
{

public:
    string name;
    string type;
    string data;
    vector<SymbolInfo*> var_list;
    vector<string> arg_list;
    vector<SymbolInfo*> children;
    bool isLeaf = false;

    bool isFunction = false;
    bool isNull = true;
    vector<string>parameter_list;
    int start_line, end_line;
    string id_name;
    bool is_array = false;
    string arg_type;
    string data_type;
    string arg_helper = "";
    
    SymbolInfo* next_symbol = NULL;

    void set_All(SymbolInfo sym){
        name = sym.name;
        type = sym.type;
        data = sym.data;
        var_list = sym.var_list;
        arg_list = sym.arg_list;
        children = sym.children;
        isLeaf = sym.isLeaf;
        isFunction = sym.isFunction;
        isNull = sym.isNull;
        parameter_list = sym.parameter_list;
        start_line = sym.start_line;
        end_line = sym.end_line;
        id_name = sym.id_name;
        is_array = sym.is_array;
        arg_type = sym.arg_type;
        data_type = sym.data_type;
        next_symbol = sym.next_symbol;
        arg_helper = sym.arg_helper;
    }
    string get_name()
    {
        return name;
    }
    string get_type()
    {
        return type;
    }
    void set_name(string name)
    {
        this->name = name;
    }
    void set_type(string type)
    {
        this->type = type;
    }

    SymbolInfo(){}

    SymbolInfo(string name,string type)
    {
        this->name = name;
        this->type = type;
    }
    SymbolInfo(string same){
        this->name = same;
        this->type = same;
    }
    SymbolInfo(string name, string type,SymbolInfo* next_symbol)
    {
        this->name = name;
        this->type = type;
        this->next_symbol = next_symbol;
    }

};

static unsigned long long int SDBMHash(string str) {
	unsigned long long int hash = 0;
	unsigned long long int i = 0;
	unsigned long long int len = str.length();

	for (i = 0; i < len; i++)
	{
		hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
	}

	return hash;
}

class ScopeTable
{
    SymbolInfo* hash_table;

    int num_buckets;


public:
    static int id ;
    int own_id;
    ScopeTable* parent_scope;
    ScopeTable(int buckets)
    {
        num_buckets = buckets;
        hash_table = new SymbolInfo[num_buckets];
        id++;
        //cout<<"\tScopeTable# "<<id<<" created\n";
        own_id = id;
    }
    ~ScopeTable()
    {
        delete [] hash_table;
    }
    void new_id(int x = 1)
    {
        id +=x;
    }

    SymbolInfo* LookUp(SymbolInfo symbol)
    {
        //cout<<"Look up scopetable symbol\n";
        int value = (SDBMHash(symbol.get_name()))%num_buckets;
        //cout<<value<<endl;
        SymbolInfo* iter =  &hash_table[value];
        bool symbol_found = false;
        while(iter->isNull != true)
        {
            if(iter->get_name() == symbol.get_name() )
            {
                symbol_found = true;
                break;
            }
            iter = iter->next_symbol;
        }
        if(symbol_found){
            return iter;
        }
        else{
            return NULL;
        }
    }
    SymbolInfo* LookUp(string symbol,int id, string instruction)
    {
        //cout<<"Look up scopetable string\n";
        int value = (SDBMHash(symbol))%num_buckets;
        int chain_number = 1;
        //cout<<value<<endl;
        SymbolInfo* iter =  &(hash_table[value]);
        bool symbol_found = false;
        while(iter->isNull != true)
        {
            //cout<<"enters while loop in scopetable lookup\n";
            if(iter->get_name() == symbol)
            {
                symbol_found = true;
                break;
            }
            iter = iter->next_symbol;
            chain_number++;
        }

        //cout<<"while loop in scopetable ends\n";
        //cout<<symbol_found<<endl;
        if(symbol_found){

            if(instruction=="L"){
                //cout<<"\t'"<<symbol<<"' found in ScopeTable# "<<id<<" at position "<<value+1<<", "<<chain_number<<endl;
            }
            else if(instruction=="D"){
                //cout<<"\tDeleted '"<<symbol<<"' from ScopeTable# "<<id<<" at position "<<value+1<<", "<<chain_number<<endl;
            }
            //cout<<value+1<<", "<<chain_number<<endl;
            return iter;
        }
        else{
            return NULL;
        }
    }
    bool insert(SymbolInfo symbol,ofstream& fout)
    {
        //cout<<"Scope table insert\n";
        int chain_number = 1;
        if(LookUp(symbol)==NULL){



            //cout<<"print1\n";
            int value = (SDBMHash(symbol.get_name()))%num_buckets;


            SymbolInfo* iter;
            iter = &(hash_table[value]);
            while(iter->isNull != true){
                iter = iter->next_symbol;
                chain_number++;
            }
            //iter = &symbol;
//cout<<"print2\n";

            iter->set_name(symbol.get_name());
            iter->set_type(symbol.get_type());
            iter->set_All(symbol);
            iter->isNull = false;
//cout<<"print3\n";
            SymbolInfo* new_symbol = new SymbolInfo();


            iter->next_symbol = new_symbol;
            //cout<<"print4\n";

            //cout<<hash_table[value].get_name()<<endl;
            //cout<<hash_table[value].get_type()<<endl;
            //cout<<"\tInserted in ScopeTable# "<<own_id<<" at position "<<value+1<<", "<<chain_number<<endl;
            //fout<<"\tInserted in ScopeTable# "<<own_id<<" at position "<<value+1<<", "<<chain_number<<endl;
            return true;
        }
        else{
            //cout<<"lookup symbol not null\n";
            //cout <<"\t"<<symbol.get_name()<<" already exisits in the current ScopeTable"<<endl;
            //fout <<"\t"<<symbol.get_name()<<" already exisits in the current ScopeTable"<<endl;

            //cout<<1<<endl;
            return false;
        }
    }

//    bool delete_symbol(SymbolInfo symbol)
//    {
//        if(LookUp(symbol)!=NULL){
//            int value = SDBMHash(symbol.get_name());
//            SymbolInfo* iter;
//            iter = &hash_table[value];
//
//            SymbolInfo* prev;
//            prev->next_symbol = iter;
//            int counter = 1;
//            while(iter->isNull != true){
//                if(iter->get_name() == symbol.get_name() && iter->get_type()==symbol.get_type()){
//                    //delete the symbol info
//                    prev->next_symbol = iter->next_symbol;
//                    iter->isNull = true;
//                    iter->next_symbol = NULL;
//                    break;
//                }
//                iter = iter->next_symbol;
//                prev = prev->next_symbol;
//
//            }
//            //iter = &symbol;
//            return true;
//        }
//        else{
//            return false;
//        }
//
//    }

    bool delete_symbol(string symbol)
    {
        int chain_number = 1;
        if(LookUp(symbol,own_id,"D")!=NULL){
            int value = (SDBMHash(symbol))%num_buckets;
            SymbolInfo* iter;
            iter = &hash_table[value];

            SymbolInfo* prev = new SymbolInfo();
            prev->next_symbol = iter;
            int counter = 1;
            while(iter->isNull != true){

                if(iter->get_name() == symbol){


                    if(iter->next_symbol==NULL && prev->isNull ){
                        //cout<<"it enters here1\n";
                        iter->isNull = true;
                    }
                    else if(iter->next_symbol->isNull && prev->isNull){
                        //cout<<"it enters here2\n";
                        SymbolInfo* temp = iter->next_symbol;
                        *(prev->next_symbol) = *(iter->next_symbol);

                        //delete iter->next_symbol;



                        delete temp;

                        //prev->next_symbol = iter->next_symbol;
                        //SymbolInfo* temp = hash_table+value;
                        //temp =  iter->next_symbol;

                        //iter->next_symbol = NULL;
                        //delete iter;

                    }
                    else{
                        //cout<<"it enters here3\n";
                        SymbolInfo* temp = iter->next_symbol;
                        *(prev->next_symbol) = *(iter->next_symbol);

                        delete temp;


//                        prev->next_symbol = iter->next_symbol;
//
//                        iter->isNull = true;
//                        iter->next_symbol = NULL;
//                        delete iter;
                    }


                    break;





                    //delete the symbol info
//                    prev->next_symbol = iter->next_symbol;
//                    iter->isNull = true;
//                    iter->next_symbol = NULL;
//                    delete iter;
//                    break;
                }
                iter = iter->next_symbol;
                prev = prev->next_symbol;
                chain_number++;

            }
            //iter = &symbol;
            //cout<<value+1<<", "<<chain_number<<endl;
            return true;
        }
        else{
            return false;
        }

    }
    void print_scope_table(ofstream& fout)
    {
        //cout<<"\tScopeTable# "<<own_id<<endl;
        //fout<<"\tScopeTable# "<<own_id<<endl;
        for(int i=0;i<num_buckets;i++){

            SymbolInfo* iter;
            iter = &(hash_table[i]);
            if(iter->isNull){
                continue;
            }

            //cout<<"\t";
            //cout<<i+1<<"--> ";
            fout<<"\t";
            fout<<i+1<<"--> ";           

            // SymbolInfo* iter;
            // iter = &(hash_table[i]);
            while(iter->isNull != true){
                //cout<<"<"<<iter->get_name()<<","<<iter->get_type()<<"> ";
                //fout<<"<"<<iter->get_name()<<","<<iter->get_type()<<"> ";
                iter = iter->next_symbol;
            }
            fout<<endl;
        }
        
    }

    void set_parent(ScopeTable* scope)
    {
        parent_scope = scope;
    }
};


class SymbolTable
{
    int num_buckets;
    int scope_counter;
public:
    ScopeTable* current_scope;
    ScopeTable* parent_scope;

    SymbolTable(int buckets)
    {
        num_buckets = buckets;
        ScopeTable* scopetable = new ScopeTable(num_buckets);
        current_scope = scopetable;
        parent_scope = NULL;
        current_scope->parent_scope = parent_scope;
        scope_counter = 1;
    }

    void Enter_Scope()
    {
        //cout<<"\tScope Counter: "<<scope_counter<<endl;
        ScopeTable* scopetable = new ScopeTable(num_buckets);
        parent_scope = current_scope;
        current_scope = scopetable;
        current_scope->parent_scope = parent_scope;
        scope_counter++;
        //cout<<"\tScope Counter: "<<scope_counter<<endl;
    }
    void Exit_Scope()
    {
        if(scope_counter>1){
            //cout<<"\tScopeTable# "<<current_scope->own_id<<" removed\n";
            scope_counter--;
            ScopeTable* temp;
            temp = current_scope;
            current_scope = parent_scope;
            parent_scope = current_scope->parent_scope;
            delete temp;
        }
        else{
            //cout<<"\tCan't delete\n";
            //cout<<"\tScopeTable# 1 cannot be removed\n";

        }
        //cout<<"\tScope Counter: "<<scope_counter<<endl;
    }
    void Exit_AllScope()
    {
        while(scope_counter>1){
            Exit_Scope();
            scope_counter--;
        }
        delete current_scope;
        cout<<"\tScopeTable# 1 removed\n";
    }

    bool insert(SymbolInfo symbol, ofstream& fout)
    {
        //cout<<"\tInserted in ScopeTable# "<<current_scope->own_id<<" at position ";
        return current_scope->insert(symbol,fout);
    }


//    bool remove(SymbolInfo symbol)
//    {
//        return current_scope->delete_symbol(symbol);
//    }

    bool remove(string symbol)
    {
        //cout<<"\tDeleted '"<<symbol<<"' from ScopeTable# "<<current_scope->own_id<<" at position ";

        bool status = current_scope->delete_symbol(symbol);
        if(!status){
            //cout<<"\tNot found in the current ScopeTable\n";
        }
        return current_scope->delete_symbol(symbol);
    }

//    SymbolInfo* LookUp(SymbolInfo symbol)
//    {
//        ScopeTable* iter;
//        iter = current_scope;
//        SymbolInfo* return_symbol = NULL;
//        while(iter != NULL)
//        {
//            return_symbol= iter->LookUp(symbol);
//            if(return_symbol != NULL){
//                break;
//            }
//            else{
//                if(scope_counter>1){
//                    ScopeTable* temp;
//                    temp = current_scope;
//                    current_scope = parent_scope;
//                    parent_scope = current_scope->parent_scope;
//                    delete temp;
//                }
//            }
//        }
//        return return_symbol;
//    }
    SymbolInfo* LookUp(string symbol)
    {
        ScopeTable* iter;
        iter = current_scope;
        SymbolInfo* return_symbol = NULL;

        ScopeTable* temp;
        temp = current_scope;
        //ScopeTable* temp;
        //temp = current_scope;
        //cout<<"look up into symbol table\n";
        while(temp != NULL)
        {

            return_symbol= temp->LookUp(symbol,temp->own_id,"L");
            if(return_symbol != NULL){
                //cout<<"'"<<symbol<<"' found in ScopeTable# "<<own_id<<" at position ";
                break;
            }
            else{
                if(scope_counter==1){
                    break;
                }
                //ScopeTable* temp;
                //temp = current_scope;
                //current_scope = parent_scope;
                //parent_scope = current_scope->parent_scope;

                //delete temp;


                temp = temp->parent_scope;
                //scope_counter--;
                //cout<<"it goes here\n";
            }
            //iter = current_scope;
        }
        if(return_symbol == NULL){
            //cout<<"\t'"<<symbol<<"' not found in any of the ScopeTables\n";
        }
        return return_symbol;
    }


    void print_current_scope(ofstream& fout)
    {
        //cout<<"\tScopeTable# "<<current_scope->own_id<<endl;
        current_scope->print_scope_table(fout);
        //cout<<endl;
    }

    void print_all_scope(ofstream& fout)
    {
        ScopeTable* temp ;
        temp = current_scope;
        while(temp->parent_scope != NULL){
            temp->print_scope_table( fout);


            temp = temp->parent_scope;
            //current_scope = parent_scope;
            //parent_scope = current_scope->parent_scope;
            //delete temp;
        }
        //cout<<"does it get past?\n";
        temp->print_scope_table( fout);
    }

};


//int ScopeTable::id = 0;

