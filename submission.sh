echo "$1" | python3 autocorrect.py # if command does not exist, along with throwing an error, it will also recommend the correct command

####### DECLARING SOME GLOBAL VARIABLES TO BE USED THROUGHOUT THE SCRIPT

total="true" # stores whether total command has been run or not (upon running the total command, it will be set to true)

header="Roll_Number,Name" # the header of the file main.csv

remote_repo="/home/rishi/Desktop/Sample_file"

number_of_commits="1"

function extract_exam_name()
{
    if [[ "$1" =~ "/\//" ]]
    then
        echo $1 | sed -E "/ \// s/.*\/([^\/]+)\.csv/\1/" # extracts the name of the exam from the given csv file name for files like /Desktop/project1.csv
    else
        echo $1 | sed -E "s/^([^\/]+)\.csv/\1/" # does the same for file like midsem.csv and quiz1.csv
    fi
}

if [ "$1" = "combine" ]
then
    ./combine.sh
fi

# Optimized version of combine

if [ "$1" = "fcombine" ]
then
    if [ -f main.csv ]
    then
        rm main.csv
    fi
    ./combine $(ls *.csv) > main.csv
    if [ "$total" = "true" ]
    then
        awk -f total_calculation.awk main.csv > temp
        cp temp main.csv
        rm temp
    fi
    exit 0
fi


######

# Execution of the upload command
if [ $1 == "upload" ]
then
    if [ $# -lt 2 ] # throws an error when no file is given as argument
    then
        echo "Usage: bash submission.sh upload <filepaths>"
        echo "Error: filepath not provided"
        exit 1
    else
        for i in $@
        do
            if [ -f "$i" ]
            then
                cp $i $(extract_exam_name $i)".csv" # All the files given as argument are copied
                uploaded+="$(extract_exam_name $i).csv "
                sed -i -E "19 s/=(.*)/=\"$uploaded\"/" submission.sh
            fi
        done
    fi
fi

###### implementing "TOTAL" COMMAND

if [ $1 == "total" ] && [ $total = "false" ]
then
    if [ "$total" = "true" ]
    then
        exit 0
    fi
    sed -i "5 s/false/true/" "submission.sh" # changes the value of the variable total from "false" to "true"
    sed -i "1 s/false/true/" "combine.sh" # changes the value of the variable total from "false" to "true"
    awk -f total_calculation.awk main.csv > temp
    cp temp main.csv
    rm temp
fi 

###### implementing VERSION CONTROL SYSTEM

function find_commit_number()
{
    if [ "$2" = "-m" ]
    then
        commit_number=$(grep "$3" "$remote_repo/.git_log" | sed -E "/$3/ s/^(.*):\ .*\:.*/\1/")
        echo $commit_number
    else
        commit_number=$(grep "$2" "$remote_repo/.git_log" | sed -E "/$2/ s/(.*)\:.*\:.*$/\1/")
        echo $commit_number
    fi
}

# implementing git_init
if [ $1 = "git_init" ]
then
    loc=$(echo $2 | sed 's/\//\\\//g')
        # throwing an error when number of command line arguments is more or less than 2
        if [ $# -lt 2 ]
        then
            echo "Usage: bash submission.sh git_init <file_path>"
            echo "Error: file_path not provided"
            exit 1
        elif [ $# -gt 2 ]
        then
            echo "Usage: bash submission.sh git_init <file_path>"
            echo 'Error: too many arguments after "git_init"'
            exit 1
        fi
    if [ "$remote_repo" == " " ]
    then
        if [ ! -d "$2" ]
        then
            mkdir "$2" 
        fi
        if [ -f "$2/.git_log" ]
        then
            > "$2/.git_log" # removing all contents of .git_log file without deleting it in case it was already present
        else
            touch "$2/.git_log" # creating .git_log file in case it was not present
        fi
        sed -i -E "9 s/.*/remote_repo=\"$loc\"/" submission.sh # changes value of the remote_repo variable
    else
        echo "Error: repository has already been initialized"
        echo "Do you want to change the location of remote repository (note: all your previous commits will be deleted)?[y/n]"
        read confirmation
        if [ $confirmation = "y" ]
        then
            if [ ! -d "$2" ] # if directory does not already exist, then make one
            then
                mkdir "$2"
            fi
            # cp -r "$remote_repo/*" "$2/"
            sed -i -E "9 s/.*/remote_repo=\"$loc\"/" submission.sh # changes value of the remote_repo variable
        else
            exit 0
        fi
    fi
    number_of_commits=0
    # hash_number=$(echo $(shuf -i 10-99 -n 8) | sed "s/\ //g") # generating a random hash number
    mkdir "$2/$number_of_commits" # creating original files directory
    # mkdir "$2/last_commit_files" # creating a folder which will store files from the last commit, will help in telling names of files that differ
    sed -i -E "11 s/.*/original_files=\"$loc\/$number_of_commits\"/" submission.sh # contains the original files, the files at the time of git_init
    original_files="$2/$number_of_commits"
    for i in $(ls -a)
    do
        cp "./$i" "$original_files/$i" # copying all the .csv files in it
        # cp "./$i" "$2/last_commit_files" # initializing the last_commit_files folder
    done
    sed -i -E "13 s/.*/number_of_commits=\"$number_of_commits\"/" submission.sh
fi

# implementing git_commit
if [ $1 = "git_commit" ]
then
    if [ "$remote_repo" = " " ] # if git is not initialized
    then
        echo "Error: remote repository not initialized"
        echo "Do you want to initialize a git repository?[y/n]" # user will be asked if he/she wants to initialize git or not
        read confirmation
        if [ "$confirmation" = "y" ] # "y" means yes
        then
            echo "Enter file path of the remote repository: "
            read file_path
            ./submission.sh git_init $file_path # inititializing git
            ./submission.sh "$@"
        fi
    else
        # printing names of files which have been changed
        for i in ${updated[@]}
        do
            echo "$i has been changed"
        done

        for i in ${uploaded[@]}
        do
            echo "$i has been added"
        done

        sed -i -E "17 s/\".*\"/\"\"/" submission.sh
        sed -i -E "19 s/\".*\"/\"\"/" submission.sh

        commit_number=$(echo $(shuf -i 10-99 -n 8) | sed "s/\ //g") # shuf command gives 8 random numbers from 10 to 99, which is processed by sed to concatenate all the individual numbers to give a random 16 digit number
        if [ "$2" = "-m" ] && [ "$3" != "" ]
        then
            number_of_commits=$((number_of_commits + 1))
            echo "$number_of_commits: $commit_number: $3" >> "$remote_repo/.git_log" # appending commit number and commit message to .git_log file
            sed -i -E "13 s/.*/number_of_commits=\"$number_of_commits\"/" submission.sh # updating number of commits variable
        else
            while  [ "$message" = "" ] # keep asking for commit message till a finite string length string is provided
            do
                echo "Enter commit message: " # ask for commit message if -m flag not present or if commit message not given
                read message
                if [ "$message" = "" ]
                then
                    echo "Error: message cannot be empty"
                fi
            done
            number_of_commits=$((number_of_commits + 1)) # updates number of commits
            echo "$number_of_commits: $commit_number: $message" >> "$remote_repo/.git_log" # appending commit number and commit message to .git_log file
            sed -i -E "11 s/.*/number_of_commits=\"$number_of_commits\"/" submission.sh # updating number of commits variable
        fi
        
        mkdir "$remote_repo/$number_of_commits" # makes a new directory which will store all the differences

        for i in $(ls -a)
        do
            cp "./$i" "$remote_repo/$number_of_commits/$i" # copy the files in a folder in remote repo
        done

        for (( i = 1 ; i <= $number_of_commits ; i++ ))
        do
            sed -i -E "11 s/.*/number_of_commits=\"$number_of_commits\"/" "$remote_repo/$i/submission.sh" # updating "number_of_commits" variable in all the folders containing the commited files
        done

    fi
fi

# implementing git_checkout
if [ $1 = "git_checkout" ]
then
    if [ "$2" = "-m" ]
    then
        if [ "$3" == "" ]
        then
            echo "Error: commit message not provided"
        else
            commit_number=$(find_commit_number "$@") # extracting commit number
            hash_value=$(grep "$3" "$remote_repo/.git_log" | sed -E "/$3/ s/^.*:\ (.*)\:.*/\2/") # extracting hash value of that commit
            n=$(grep -c "$3" "$remote_repo/.git_log")
            if [[ $n != 1 ]]
            then
                echo "Error: commit not found enter first few digits of commit number: "
                read hash_value
                ./submission.sh git_checkout $hash_value
            else
                if [ "$4" = "" ] # if file has not been specified
                then
                    rsync -av --delete "$remote_repo/$commit_number/" ./ # completely overwrites contents of working directory with contents of that commit folder
                else
                    for ((i = 4; i <= $#; i++))
                    do
                        if [ ! -f "$remote_repo/$commit_number/${!i}" ]
                        then
                            echo "${!i} file not found in that commit"
                        else
                            cp "$remote_repo/$commit_number/${!i}" "./${!i}"
                        fi
                    done
                fi
            fi
        fi
    else
        if [ "$2" == "" ]
        then
            echo "Error: commit number not provided"
        else
            commit_number=$(find_commit_number $@) # extracting commit number
            hash_value=$(grep "$2" "$remote_repo/.git_log" | sed -E "/$2/ s/.*\:\ (.*)\:.*$/\1/") # extracting hash value
            n=$(grep -c "$3" "$remote_repo/.git_log")
            if [[ $n != 1 ]]
            then
                echo "Error: commit not found enter more digits of the commit number: "
                read hash_value
                ./submission.sh git_checkout $hash_value
            else
                if [ "$3" = "" ] # if file has not been specified
                then
                    rsync -av --delete "$remote_repo/$commit_number/" ./ # completely overwrites contents of working directory with contents of that commit folder
                else
                    for ((i = 3; i <= $#; i++))
                    do
                        if [ ! -f "$remote_repo/$commit_number/${!i}" ]
                        then
                            echo "${!i} file not found in that commit"
                        else
                            cp "$remote_repo/$commit_number/${!i}" "./${!i}" # copies files from that commit into working directory
                        fi
                    done
                fi
            fi
        fi
    fi
fi

# implementing git_log (gives details of all commits done so far)
if [ "$1" = "git_log" ]
then
    cat "$remote_repo/.git_log"
fi

#implementing git_diff (gives difference between particular files from different commits). 2nd argument will be commit number. If 3rd argument is a file, then it will return difference between those specific files, if it is a commit number, then it will return difference between those two commits.
if [ "$1" = "git_diff" ]
then
    if [ $2 = "" ]
    then
        echo "Error: commit number not provided"
        exit 1
    fi
    if [ "$2" != "-m" ]
    then
        if [ "$3" = "" ] # If files are not specified, by default it will return difference between the entire directory
        then
            n=$(grep -c "$2" "$remote_repo/.git_log")
            if [[ $n != 1 ]]
            then
                echo "Error: commit not found enter first few digits of commit number: "
                read hash_value
                ./submission.sh git_diff $hash_value
            else
                commit_number=$(find_commit_number $@)
                echo "$commit_number"
                python3 difference_directory.py "$remote_repo" "$(pwd)" "$remote_repo/$commit_number"
                # diff -ruN "$(pwd)" "$remote_repo/$commit_number"
            fi
        else
            commit_number=$(find_commit_number $@)
            for ((i = 3; i <= $#; i++))
            do
                if [ ! -f "$remote_repo/$commit_number/${!i}" ]
                then
                    echo "${!i} file not found in that commit"
                    echo "$remote_repo/$commit_number/${!i}"
                elif [ ! -f "${!i}" ]
                then
                    echo "${!i} file not found"
                else
                    python3 difference_file.py "$remote_repo/$commit_number" "${!i}" "$remote_repo/$commit_number/${!i}"
                fi
            done
        fi
    elif [ "$2" = "-m" ]
    then
        if [ "$3" = "" ]
        then
            echo "Error: commit message not provided"
            exit 1
        fi            
        n=$(grep -c "$3" "$remote_repo/.git_log")
        if [[ $n != 1 ]]
        then
            echo "Error: commit not found enter first few digits of commit number: "
            read hash_value
            ./submission.sh git_diff $hash_value
        else
            commit_number=$(find_commit_number $@)
            if [ "$4" = "" ]
            then
                python3 difference_directory.py "$remote_repo" "$(pwd)" "$remote_repo/$commit_number"
            else
                for ((i = 4; i <= $#; i++))
                do
                    if [ ! -f "$remote_repo/$commit_number/${!i}" ]
                    then
                        echo "${!i} file not found in that commit"
                    elif [ ! -f "${!i}" ]
                    then
                        echo "${!i} file not found"
                    else
                        python3 difference_file.py "$remote_repo/$commit_number" "${!i}" "$remote_repo/$commit_number/${!i}"
                    fi
                done
            fi
        fi
    fi
fi

####### IMPLEMENTING UPDATE COMMAND

if [ "$1" = "update" ]
then
    if [ "$2" = "" ]
    then
        ./update_marks.sh
        updated+=""
        ./combine.sh # running combine command to compile the updated result
    elif [ "$2" = "-n" ] # change marks of multiple students
    then
        while [ $? -eq 0 ]
        do
            ./update_marks.sh
        done
        ./combine.sh # running combine command to compile the updated result
    else
        echo "Error: $2 command not found"
    fi
fi

# implementing graphs and stats

stats="mean median min max std mean_present median_present min_present std_present max_present"

if [[ " $stats " =~ " $1 " ]] # checks if the first command line argument is one of the calculable statistics
then
    python3 stats.py $@ # by default stats are calculated of the total marks
fi

if [ "$1" = "get_graph" ]
then
    if [ "$2" = "" ]
    then
        echo "Error: arguments not provided"
        exit 1
    fi
    if [[ "$2 $3" =~ "-quiz" ]] # has the quiz flag i.e. marks of all students present in a quiz will be displayed in a bar graph
    then
        if [[ "$2 $3" =~ "-s" ]] # has -s flag i.e. whether or not the plot needs to be saved
        then
            if [ "$4" = "" ]
            then
                echo "Error: quiz name not provided"
                exit 1
            fi
            for ((i = 4; i <= $#; i++))
            do
                python3 quiz_graph.py ${!i} s # iterating over all the quiz names provided and save their graphs
            done
        else
            if [ "$3" = "" ]
            then
                echo "Error: quiz name not provided"
                exit 1
            fi
            for ((i = 3; i <= $#; i++))
            do
                python3 quiz_graph.py ${!i} # iterating over all the quiz names provided
            done
        fi
    elif [[ "$2 $3" =~ "-student" ]] # get graph of performance of a specific student
    then
        if [[ "$2 $3" =~ "-s " ]]
        then
            if [ "$4" = "" ]
            then
                echo "Error: Roll Number not provided"
                exit 1
            fi
            rol_numbers=""
            for ((i = 4; i <= $#; i++))
            do
                rol_numbers+=" ${!i}"
            done
            python3 student_graph.py s $rol_numbers # plots percentile of multiple students in same graph in order to compare performances
        else
            if [ "$3" = "" ]
            then
                echo "Error: Roll Number not provided"
                exit 1
            fi
            rol_numbers=""
            for ((i = 3; i <= $#; i++))
            do
                rol_numbers+=" ${!i}"
            done
            python3 student_graph.py ns $rol_numbers # plots percentile of multiple students in same graph in order to compare performances
        fi
    else
        echo "Error: enter correct flag" # throws error if student or quiz is not specified
        exit 1
    fi
fi

# Implementing report card

if [ "$1" = "get_report" ]
then
    if [ "$2" = "" ]
    then
        echo "Error: Roll Number not provided"
        exit 1
    fi
    n=$(grep -c -i "$2" "main.csv") # counts number of occurences of rol number in main.csv
    if [[ $n != 1 ]]
    then
        echo "Error: student with given roll number not found"
        exit 1
    fi
    if [ "$total" = "false" ] # in case total was not run previously, we will copy contents of main.csv to main1.csv, then run total, and laater we will copy main1.csv back to main.csv and remove main1.csv
    then
        cp main.csv main1.csv
        ./submission.sh total
        sed -i "5 s/false/true/" "submission.sh" # changes the value of the variable total from "false" to "true"
    fi
    cp "report_template.tex" "$2.tex"
    name=$(grep -i "$2" main.csv | cut -d "," -f 2)
    sed -i "/rolno/ s/rolno/$2/g" "$2.tex" # replaces all occurences of rolno with the actual roll number of the student
    sed -i "/name/ s/name/$name/g" "$2.tex" # replace all instances of name with the actual name of the student
    for i in $(ls *.csv)
    do
        if [ "$i" == "main.csv" ]
        then
            continue
        fi
        exam=$(extract_exam_name "$i")
        marks_percentile=$(python3 percentile_calculator.py "$exam" "$2") # returns marks and percentile of the student in that particular quiz
        n=$(grep -c "$2" "$i") # calculates number of occurences of rol number of the student in that file
        if [[ $n == 0 ]]
        then
            marks="a" # mark the student absent in that particular quiz
        fi
        sed -i "57a $exam & $marks_percentile \\\ \\\hline" "$2.tex"
        sed -i '58 s/\\/\\\\/' "$2.tex"
    done
    # putting the table row containing total marks and percentile
    marks_percentile=$(python3 percentile_calculator.py total "$2")
    sed -i "/end{tabular}/i total & $marks_percentile \\\ \\\hline" "$2.tex"
    sed -i '/total/ s/\\/\\\\/' "$2.tex"
    pdflatex "$2"
    python3 student_graph.py s "$2"
    if [ "$total" = "false" ]
    then
        mv main1.csv main.csv
    fi
fi