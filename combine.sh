total="true"

declare -a students # stores rol numbers of students in the format ""

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
for file in *.csv;
do
    if [ -f "$file" ] && [ $file != "main.csv" ]; # checks only files and ignores any directory. Also, if main.csv is already present, it won't be read
    then
        exam=$(extract_exam_name $file) # extracts the exam name from file name
        while IFS="," read rolno name marks
        do
            if [[ ! " ${students[*]} " =~ " "$rolno","$name" " ]] # passes if student and rolno don't already exist in students array
            then
                students+=("$rolno","$name")
                # names["$rolno"]="$name"
                # echo $rolno
                # echo $name # echoing for debugging
            fi
            students_marks["$exam","$rolno","$name"]=$marks
            total_marks["$rolno","$name"]=$((total_marks["$rolno","$name"] + marks))
        done < <(sed 1d "$file" | sed "$ s/$/\n/" | sed "/\r/ s/\r//") # A new empty line is added at the end of the .csv files so that all lines of the file can be read. Without it, the last line was not being read.
        exams+=("$exam")
    fi
done
declare -A absentees_too # declaring an array entries which has been initialized to "a" for all exam,student pairs
for i in "${exams[@]}"
do
    for j in "${students[@]}"
    do
        absentees_too["$i","$j"]="a"
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

if [ "$total" = "true" ]
then
    header+=",total"
fi

echo "$header" > main.csv

declare -A entries # this array will store all the individual entries of the file main.csv and will use "rolno,name" as keys

for i in "${students[@]}"
do
    entries[$i]="$i" # initializing all etries to contain rolno and name seperated by ","
done

for i in "${students[@]}"
do
    for j in "${exams[@]}"
    do
        entries[$i]+=",${absentees_too["$j","$i"]}" # appending marks of exam at the end of each entry
    done
    if [ "$total" = "true" ]
    then
        # echo ${total_marks["$i"]} # echoing for debugging
        entries[$i]+=",${total_marks["$i"]}"
    fi
    echo "${entries[$i]}" >> main.csv
done
sed -i "$d" main.csv