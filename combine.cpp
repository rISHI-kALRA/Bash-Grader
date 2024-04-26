#include <fstream>
#include <bits/stdc++.h>
using namespace std;

vector<string> split(string line , char c = ',') // splits a string into substrings seperated by character "c" and returns a vector. "c" is comma (,) by default
{
    vector<string> v;
    v.push_back("");
    for (int i = 0 ; i < line.size() ; i++)
    {
        if (line[i] == c)
        {
            v.push_back("");
        }
        else
        {
            v[v.size()-1] += line[i];
        }
    }
    return v;
}

int main(int argc , char* argv[]) // file names will be taken in as command line arguments
{
    set<string> rolno;
    map<string , string> marks;
    string header = "Roll_Number,Name";
    for(int i = 1 ; i < argc ; i++)
    {
        header += "," + split(argv[i] , '.')[0];
        string line;
        ifstream fin;
        set<string> present;
        fin.open(argv[i]);
        getline(fin , line);
        while(getline(fin , line))
        {
            vector<string> v = split(line);
            present.insert(v[0]);
            auto it = rolno.find(v[0]);
            if (it == rolno.end()) // the student's rol number has appeared for the first time in any exam's result file
            {
                rolno.insert(v[0]);
                marks[v[0]] = v[0] + "," + v[1];
                for(int j = 1 ; j < i ; j++)
                {
                    marks[v[0]] += ",a"; // putting "a" in place of all the exams in which the student was absent
                }
            }
            marks[v[0]] += "," + v[2];
        }
        for(auto x:rolno)
        {
            auto it = present.find(x);
            if(it == present.end())
            {
                marks[x] += ",a"; // marking the student absent if he/she was not present in any exam
            }
        }
        fin.close();
    }
    cout << header << endl;
    for(auto x:marks)
    {
        cout << x.second << endl;
    }
}