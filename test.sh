echo "$1" | python3 .autocorrect.py # if command does not exist, along with throwing an error, it will also recommend the correct command

####### DECLARING SOME GLOBAL VARIABLES TO BE USED THROUGHOUT THE SCRIPT

total="false" # stores whether total command has been run or not (upon running the total command, it will be set to true)

header="Roll_Number,Name" # the header of the file main.csv

declare -a students # stores rol numbers of students in the format "rolno"

declare -a exams # stores names of exams conducted so far

declare -A names # maps rol numbers to names of the students

declare -A students_marks # stores exam-wise marks of individual students with key as "exam,rolno"

declare -A total_marks # stores total marks of individual students with key as "rolno"

declare -A entries # this array will store all the individual entries of the file main.csv and will use "rolno,name" as keys

function extract_exam_name()
{
    if [[ "$1" =~ "/\//" ]]
    then
        echo $1 | sed -E "/ \// s/.*\/([^\/]+)\.csv/\1/" # extracts the name of the exam from the given csv file name for files like /Desktop/project1.csv
    else
        echo $1 | sed -E "s/^([^\/]+)\.csv/\1/" # does the same for file like midsem.csv and quiz1.csv
    fi
}

# Execution of the combine command
if [ $1 = "combine" ] && [ ! -f "main.csv" ] # this block is for creating main.csv and uploading result of all exams in it
then
    for file in *.csv;
    do
        if [ -f "$file" ] ; # checks only files and ignores any directory
        then
            exam=$(extract_exam_name $file) # extracts the exam name from file name
            while IFS="," read rolno name marks
            do
                # echo $rolno
                if [[ ! " ${students[*]} " =~ " $rolno " ]] # passes if rolno doesn't already exist in students array
                then
                    students+=("$rolno")
                    names["$rolno"]="$name"
                    # echo $rolno
                    # echo $name # echoing for debugging
                fi
                students_marks["$exam,$rolno"]=$marks
                total_marks["$rolno"]=$((total_marks["$rolno"] + marks))
            done < <(sed 1d "$file" | sed "$ s/$/\n/" | sed "/\r/ s/\r//") # A new empty line is added at the end of the .csv files so that all lines of the file can be read. Without it, the last line was not being read.
            exams+=("$exam")
        fi
    done
    declare -A absentees_too # declaring an array entries which has been initialized to "a" for all exam,student pairs
    for i in "${exams[@]}"
    do
        for j in ${students[@]}
        do
            absentees_too["$i,$j"]="a"
        done
    done
    # updating the array entries so that all people who were not absent get the marks which have been stored in students_marks array
    for i in "${!students_marks[@]}"
    do
        absentees_too["$i"]="${students_marks[$i]}"
    done

    for i in "${exams[@]}"
    do
        header+=",$i"
    done

    if [ $total == "true" ]
    then
        header+=",total" # adding an extra "total" collumn if the total has been asked for
    fi

    echo "$header" > main.csv

    for i in "${students[@]}"
    do
        entries["$i"]="$i,${names[$i]}" # initializing all etries to contain name and rolno seperated by ","
    done

    for i in ${students[*]}
    do
        # echo $i
        for j in "${exams[@]}"
        do
            entries[$i]+=",${absentees_too["$j,$i"]}" # appending marks of exam at the end of each entry
        done
        if [ $total == "true" ]
        then
            entries[$i]+=",${total_marks[$i]}" # adding entries of the total collumn as well if asked for
        fi
        echo "${entries["$i"]}" >> main.csv
        echo "${entries["$i"]}"
    done
fi

######

declare -a uploaded # contains all the .csv files (except main) whose results have not been added to main.csv yet

# Execution of the upload command
if [ $1 == "upload" ]
then
    if [ $# -lt 2 ] # throws an error when no file is given as argument
    then
        echo "Usage: bash submission.sh upload <filepaths>"
        echo "Error: filepath not provided"
    else
        for i in $@
        do
            cp $i $(extract_exam_name $i)".csv" # All the files given as argument are copied
            uploaded+="$(extract_exam_name $i).csv"
        done
    fi
fi

# Now if combine command is run (i.e main.csv is present already)-
if [ "$1" = "combine" ] && [ -f "main.csv" ]
then
    for file in ${uploaded[@]}
    do
        exam=$(extract_exam_name $file)
        for i in ${students[@]}
        do
            students_marks["$exam,$rolno"]="a" # initializing all marks to "a" for this exam
        done
        while IFS="," read rolno name marks
        do
            if [ ! " $students[*] " =~ " $rolno " ]
            then
                students+="$rolno"
                names["$rolno"]="$name"
                total_marks["$rolno"]=0
                entries["$i"]="$rolno,${names["$rolno"]}"
                for i in ${exams[@]}
                do
                    students_marks["$i,$rolno"]="a" 
                    entries["$i"]+=",a" # if someone's name is appearing for the first time, he/she must have been absent in all the preceding examinations
                done
            fi
            exams+="$exam"
            students_marks["$exam,$rolno"]="$marks"
            total_marks["$rolno"]=$((total_marks["$rolno"] + marks))
        done < <(sed "1d" "$file" | sed "$ s/$/\n/" | sed "s/\r//")
        # updating the header depending on whether total has been called or not
        if [ $total = "true" ]
        then
            header=$(echo $header | sed -E "s/(.*),total/\1,$exam,total/")
        else
            header+="$exam"
        fi
        #updating individual entries depending on whether total has been called or not
        for i in ${students[@]}
        do
            if [ $total = "true" ]
            then
                entries["$i"]=$(echo "$entries["$i"]" | sed -E "s/(.*),total/\1,${students_marks["$exam,$i"]},total/")
            else
                entries["$i"]+=",${students_marks["$exam,$rolno"]}"
            fi
        done
    done
    echo "$header" > main.csv
    for i in ${entries[@]}
    do
        echo $i >> main.csv
    done
fi

###### IMPLIMENTING "TOTAL" COMMAND

if [ $1 == "total" ]
then
    sed -i "5 s/false/true/" "submission.sh" # changes the value of the variable total from "false" to "true"
    # while IFS="," read
fi 