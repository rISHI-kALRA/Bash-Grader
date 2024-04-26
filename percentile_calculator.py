import sys
import numpy as np

file_name = "main.csv"
file = open(file_name)
header = file.readline()
header = header.split(sep=",")
header[-1] = header[-1][:-1]
index = header.index(sys.argv[1])
marks_of_student = 0

marks = []

for line in file:
    rolno , name , *mark = line.split(sep=",")
    if mark[-1][-1] == '\n':
        mark[-1] = mark[-1][:-1]
    if mark[index-2] == 'a':
        mark[index-2] = 0
    marks.append(int(mark[index-2]))
    if rolno == sys.argv[2]:
        marks_of_student = int(mark[index-2])

marks.sort()
np_marks = np.array(marks)
print(marks_of_student , "&" , 100*(np.max(np.where(np_marks == marks_of_student))+1)/len(marks))