import sys
import os
import numpy as np

statistic = sys.argv[1]

file_name = "main.csv"
f = open(file_name)
h = f.readline()
headers = h.split(",")[2:]
headers[-1] = headers[-1][:len(headers[-1]) - 1] # removing the '\n' at the end of the last entry in list "headers"
# print(headers)
if len(sys.argv) == 2:
    total = []
    if headers[-1] == "total":
        for line in f:
            total.append(int(line.split(",")[-1]))
    else:
        for line in f:
            l = line.split(",")[2:]
            total_marks = 0
            for i in l:
                if i != "a":
                    total_marks += int(i)
            total.append(total_marks)
    total_marks = np.array(total)
    print("The" , statistic , "is:") # calculating the required statistics
    if statistic == "mean":
        print(np.mean(total_marks))
    elif statistic == "median":
        print(np.median(total_marks))
    elif statistic == "std":
        print(np.std(total_marks))
    elif statistic == "max":
        print(np.max(total_marks))
    elif statistic == "min":
        print(np.min(total_marks))
else:
    marks = {}
    marks_present = {}
    quiz_index = {}
    for quiz in sys.argv[2:]:
        if quiz not in headers:
            print("Please upload and combine the results of" , quiz , "before being able to see the statistics\n")
            continue
        i = headers.index(quiz)
        marks[quiz] = []
        marks_present[quiz] = []
        quiz_index[quiz] = i
    for line in f:
        l = line.split(",")[2:]
        for quiz , index in quiz_index.items():
            # print(quiz , index)
            if l[index] == "a":
                marks[quiz].append(0)
            else:
                marks[quiz].append(int(l[index]))
                marks_present[quiz].append(int(l[index]))
    for quiz , index in quiz_index.items():  # calculating the required statistics of all the quizzes
        np_marks = np.array(marks[quiz])
        np_marks_present = np.array(marks_present[quiz])
        print(np.percentile(np_marks , 10))
        # print(np_marks)
        print("The" , statistic , "of" , quiz , "is:")
        if statistic == "mean":
            print(np.mean(np_marks))
        elif statistic == "median":
            print(np.median(np_marks))
        elif statistic == "std":
            print(np.std(np_marks))
        elif statistic == "max":
            print(np.max(np_marks))
        elif statistic == "min":
            print(np.min(np_marks))
        elif statistic == "mean_present":
            print(np.mean(np_marks_present))
        elif statistic == "median_present":
            print(np.median(np_marks_present))
        elif statistic == "std_present":
            print(np.std(np_marks_present))
        elif statistic == "max_present":
            print(np.max(np_marks_present))
        elif statistic == "min_present": 
            print(np.min(np_marks_present))
        print("\n")