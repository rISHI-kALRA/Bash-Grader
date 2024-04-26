echo "Enter name"
read name
echo "Enter rol number"
read rolno
echo "Enter exam name and updated marks in the format <quiz_name> <updated_marks>"
read exam marks junk # junk variable will store any extra (unwanted) input entered by the user
if [ "$exam" = "q" ] && [ "$marks" = "" ]
then
    exit 1
fi
while [ "$junk" != "" ]
do
    echo "Usage: <exam_name> <updated_marks>"
    echo "Error: more than one <updated_marks> recieved"
    echo "Enter exam name and updated marks in the format <quiz_name> <updated_marks>"
    read exam marks junk # junk variable will store any extra (unwanted) input entered by the user
    if [ "$exam" = "q" ] && [ "$marks" = "" ]
    then
        exit 1
    fi
done
updated_files=$(sed -n "17p" submission.sh)
if [[ ! "$updated_files" =~ "$exam" ]] # will change the variable "updated" in submission.sh iff the name of exam didn't peviously occur in it
then
    sed -i -E "17 s/\"$/$exam\ \"/" submission.sh
fi
sed -i -E "/$rolno/ s/[0-9]+$/$marks/" "$exam.csv"