import numpy as np
import matplotlib.pyplot as plt
import sys

file_name = "main.csv"

f = open(file_name)

header = f.readline()
Roll_Number , Name , *exams = header.split(",")
exams[-1] = exams[-1][:-1] # removing the extra "\n" at the end of the last element of the list "exams"
x = np.arange(1 , len(exams)+1 , 1)
students = {}
names = {}
exam_marks = {}
for i in exams:
    exam_marks[i] = []

for line in f:
    rolno , name , *marks = line.split(",")
    names[rolno] = name
    if marks[-1][-1] == "\n":
        marks[-1] = marks[-1][:-1] # removing "\n" if present
    for i in range(len(marks)):
        if marks[i] == "a":
            marks[i] = 0
        marks[i] = int(marks[i])
        exam_marks[exams[i]].append(marks[i]) # appends the marks of this student in a specific exam to the list of marks of all students
    students[rolno] = marks
    
np_exam_marks = {}
for i in exams:
    np_exam_marks[i] = np.array(exam_marks[i])
    np_exam_marks[i] = np.sort(np_exam_marks[i])

for rolno in sys.argv[2:]:
    percentile = []
    for i in range(len(students[rolno])):
        percentile.append((np.max(np.where(np_exam_marks[exams[i]] == students[rolno][i]))+1)/len(np_exam_marks[exams[i]])*100) # appends the percentile of the student in the ith exam in the list "percentile"
    # print(percentile)
    plt.plot(exams , percentile , alpha=0.5)

font1 = {'family':'serif','color':'black','size':15}
font2 = {'family':'serif','color':'black','size':15}
font3 = {'family':'serif','color':'black','size':15}
x_pos = np.arange(len(exams))
plt.xticks(x_pos , exams , rotation=45 , fontdict=font2)
title_message = "Percentile of "
for i in sys.argv[2:]:
    title_message += i
    title_message += ", "
title_message = title_message[:-2] # removing the "," at the end
plt.title(title_message , fontdict=font1)
plt.ylabel("Percentile" , fontdict=font2)
plt.legend(sys.argv[2:] , loc='best')
plt.show()

if sys.argv[1] == "s":
    plt.savefig(title_message + ".png")