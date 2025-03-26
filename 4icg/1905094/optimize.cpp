#include<bits/stdc++.h>
#include<sstream>

using namespace std;

int main(){
    ifstream finput("code.asm");
    ofstream foutput("opt1.asm");

    string line;
    string word;
    string piece;
    string temp_str;
    bool istemp_str = false;
    vector<string> wordlist;

    string prev_word1 = "";
    string prev_word2 = "";
    string new_word1;
    string new_word2;

    while(getline(finput, line)){


        stringstream word(line);
        
        while(getline(word, piece, ' ')){
            wordlist.push_back(piece);
        }


        if(istemp_str){

            if(wordlist.size()==2){
                //cout<<wordlist[0]<<endl;
                //cout<<wordlist[1]<<endl;
                new_word1 = wordlist[0];
                new_word2 = wordlist[1];

                if(new_word1 == "POP" && prev_word1 == "PUSH" && new_word2 == prev_word2){

                    istemp_str = false ;

                }
                else{
                    foutput<<temp_str<<endl;
                    temp_str = line;

                    prev_word1 = new_word1;
                    prev_word2 = new_word2;
                }

            }
            else{
                foutput<<temp_str<<endl;
                foutput<<line<<endl;
                istemp_str = false;
                
            }
        }
        else{
            if(wordlist.size()==2){
                prev_word1 = wordlist[0];
                prev_word2 = wordlist[1];
                istemp_str = true;
                temp_str = line;
            }
            else{
                foutput<<line<<endl;
            }

        }

        // if(wordlist.size()==2){
        //     //cout<<wordlist[0]<<endl;
        //     //cout<<wordlist[1]<<endl;
        //     new_word1 = wordlist[0];
        //     new_word2 = wordlist[1];
            
        // }
        wordlist.clear();

       

    }
    foutput<<temp_str<<endl;
    return 0;
}