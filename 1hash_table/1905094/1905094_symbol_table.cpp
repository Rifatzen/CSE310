

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
    string name;
    string type;
public:
    bool isNull = true;
    SymbolInfo* next_symbol = NULL;
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
        cout<<"\tScopeTable# "<<id<<" created\n";
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
                cout<<"\t'"<<symbol<<"' found in ScopeTable# "<<id<<" at position "<<value+1<<", "<<chain_number<<endl;
            }
            else if(instruction=="D"){
                cout<<"\tDeleted '"<<symbol<<"' from ScopeTable# "<<id<<" at position "<<value+1<<", "<<chain_number<<endl;
            }
            //cout<<value+1<<", "<<chain_number<<endl;
            return iter;
        }
        else{
            return NULL;
        }
    }
    bool insert(SymbolInfo symbol)
    {
        //cout<<"Scope table insert\n";
        int chain_number = 1;
        if(LookUp(symbol)==NULL){

            //cout<<"lookup symbol null\n";
            int value = (SDBMHash(symbol.get_name()))%num_buckets;


            SymbolInfo* iter;
            iter = &(hash_table[value]);
            while(iter->isNull != true){
                iter = iter->next_symbol;
                chain_number++;
            }
            //iter = &symbol;


            iter->set_name(symbol.get_name());
            iter->set_type(symbol.get_type());
            iter->isNull = false;

            SymbolInfo* new_symbol = new SymbolInfo();


            iter->next_symbol = new_symbol;

            //cout<<hash_table[value].get_name()<<endl;
            //cout<<hash_table[value].get_type()<<endl;
            cout<<"\tInserted in ScopeTable# "<<own_id<<" at position "<<value+1<<", "<<chain_number<<endl;
            return true;
        }
        else{
            //cout<<"lookup symbol not null\n";
            cout <<"\t'"<<symbol.get_name()<<"' already exists in the current ScopeTable"<<endl;
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
                    //delete the symbol info
                    prev->next_symbol = iter->next_symbol;
                    iter->isNull = true;
                    iter->next_symbol = NULL;
                    delete iter;
                    break;
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
    void print_scope_table()
    {
        cout<<"\tScopeTable# "<<own_id<<endl;
        for(int i=0;i<num_buckets;i++){
            cout<<"\t";
            cout<<i+1<<"--> ";

            SymbolInfo* iter;
            iter = &(hash_table[i]);
            while(iter->isNull != true){
                cout<<"<"<<iter->get_name()<<","<<iter->get_type()<<"> ";
                iter = iter->next_symbol;
            }
            cout<<endl;
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
            cout<<"\tScopeTable# "<<current_scope->own_id<<" removed\n";
            scope_counter--;
            ScopeTable* temp;
            temp = current_scope;
            current_scope = parent_scope;
            parent_scope = current_scope->parent_scope;
            delete temp;
        }
        else{
            //cout<<"\tCan't delete\n";
            cout<<"\tScopeTable# 1 cannot be removed\n";

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

    bool insert(SymbolInfo symbol)
    {
        //cout<<"\tInserted in ScopeTable# "<<current_scope->own_id<<" at position ";
        return current_scope->insert(symbol);
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
            cout<<"\tNot found in the current ScopeTable\n";
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
            cout<<"\t'"<<symbol<<"' not found in any of the ScopeTables\n";
        }
        return return_symbol;
    }


    void print_current_scope()
    {
        //cout<<"\tScopeTable# "<<current_scope->own_id<<endl;
        current_scope->print_scope_table();
        //cout<<endl;
    }

    void print_all_scope()
    {
        ScopeTable* temp ;
        temp = current_scope;
        while(temp->parent_scope != NULL){
            temp->print_scope_table();


            temp = temp->parent_scope;
            //current_scope = parent_scope;
            //parent_scope = current_scope->parent_scope;
            //delete temp;
        }
        //cout<<"does it get past?\n";
        temp->print_scope_table();
    }

};


int ScopeTable::id = 0;


int main()
{
    freopen("input.txt","r",stdin);
    freopen("output.txt","w",stdout);
    int buckets;

    cin>>buckets;

    SymbolTable sym_table(buckets);
    int cmd_count = 0;
    while(1){

        cmd_count++;
        cout<<"Cmd "<<cmd_count<<": ";
        string op;
        cin>>op;
        cout<<op;
        //getchar();

        if(op=="I"){
            string line_string;
            string temp_string;
            string name;
            string type;
            string excess;
            //cin>>name>>type>>excess;

            getline(cin,line_string,'\n');

            stringstream ss(line_string);

            int cnt = 0;
            while(getline(ss,temp_string,' ')){
                cnt++;
                if(cnt>3 || cnt ==1){
                    excess = temp_string;
                }
                else if(cnt==2){
                    name = temp_string;
                }
                else if(cnt ==3){
                    type = temp_string;
                }
            }

            if(cnt!=3){
                //cout<<cnt<<endl;
                cout<<line_string<<endl;
                cout<<"\tNumber of parameters mismatch for the command I"<<endl;
            }
            else{

                cout<<" "<<name<<" "<<type<<endl;

                SymbolInfo sym(name,type);
                //cout<<1<<endl;

                //cout<<sym.get_name()<<endl;
               // cout<<sym.get_type()<<endl;

                bool status = sym_table.insert(sym);
                if(status){

                    //cout<<"Inserted successfully\n";
                }
                else{
                    //cout<<"failed\n";
                }
            }
        }
        else if(op=="L"){
            string line_string;
            string temp_string;
            string excess;
            string name;
            //cin>>name;


            getline(cin,line_string,'\n');

            stringstream ss(line_string);

            int cnt = 0;
            while(getline(ss,temp_string,' ')){
                cnt++;
                if(cnt>2 || cnt ==1){
                    excess = temp_string;
                }
                else if(cnt==2){
                    name = temp_string;
                }
            }

            if(cnt!=2){
                    //cout<<cnt<<endl;
                cout<<line_string<<endl;
                cout<<"\tNumber of parameters mismatch for the command L"<<endl;
            }
            else{
                cout<<" "<<name<<endl;
                SymbolInfo* status =  sym_table.LookUp(name);

                if(status==NULL){
                    //cout<<"Not found\n";
                }
                else{
                    //cout<<"found\n";
                }
            }
        }
        else if(op=="D"){

            string line_string;
            string temp_string;
            string excess;
            string name;
            //cin>>name;


            getline(cin,line_string,'\n');

            stringstream ss(line_string);

            int cnt = 0;
            while(getline(ss,temp_string,' ')){
                cnt++;
                if(cnt>2 || cnt ==1){
                    excess = temp_string;
                }
                else if(cnt==2){
                    name = temp_string;
                }
            }

            if(cnt!=2){
                    //cout<<cnt<<endl;
                cout<<line_string<<endl;
                cout<<"\tNumber of parameters mismatch for the  command D"<<endl;
            }
            else{
                cout<<" "<<name<<endl;
                bool status =  sym_table.remove(name);

                if(!status){
                    //cout<<"Not there\n";
                }
                else{
                    //cout<<"deleted\n";
                }
            }
        }

        else if(op=="P"){

            string ins ;
//            cin>>ins;
//            cout<<" "<<ins<<endl;
//            if(ins=="C"){
//                sym_table.print_current_scope();
//            }
//            else if(ins=="A"){
//                sym_table.print_all_scope();
//            }
            string line_string;
            string temp_string;
            string excess;
            string name;
            //cin>>name;


            getline(cin,line_string,'\n');

            stringstream ss(line_string);

            int cnt = 0;
            while(getline(ss,temp_string,' ')){
                cnt++;
                if(cnt>2 || cnt==1 ){
                    excess = temp_string;
                }
                else if(cnt==2){
                    ins = temp_string;
                }
            }

            if(cnt!=2){
                    //cout<<cnt<<endl;
                cout<<line_string<<endl;
                cout<<"\tNumber of parameters mismatch for the  command P"<<endl;
            }
            else{
                cout<<" "<<ins<<endl;
                if(ins=="C"){
                    sym_table.print_current_scope();
                }
                else if(ins=="A"){
                    sym_table.print_all_scope();
                }
                else{
                   cout<<"\tInvalid parameter for the  command P"<<endl;
                }
            }



        }
//        else if(op=="D"){
//            string name;
//            cin>>name;
//            bool status=  sym_table.remove(name);
//
//            if(status){
//                cout<<"Deleted\n";
//            }
//            else{
//                cout<<"Can't find\n";
//            }
//        }

        else if(op=="S"){
            //cout<<endl;

            string line_string;
            getline(cin,line_string,'\n');
            stringstream ss(line_string);
            cout<<endl;
            //int cnt = 0;
            //while(getline(ss,temp_string,' '))

            sym_table.Enter_Scope();
        }
        else if(op=="E"){

            string line_string;
            getline(cin,line_string,'\n');
            stringstream ss(line_string);

            cout<<endl;
            sym_table.Exit_Scope();
        }
        else if(op=="Q"){

            string line_string;
            getline(cin,line_string,'\n');
            stringstream ss(line_string);
            cout<<endl;
            //exit all;
            sym_table.Exit_AllScope();
            break;
        }
        else{
            cout<<"\tInvalid command\n";
            continue;
        }
    }
    return 0;
}

/*
https://stackoverflow.com/questions/35592636/how-to-check-if-number-of-inputs-required-is-correct-or-not


*/
