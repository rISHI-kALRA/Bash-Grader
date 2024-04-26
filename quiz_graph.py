import matplotlib.pyplot as plt
import numpy as np
import sys

file_name = sys.argv[1] + ".csv"

a = input("Enter class interval for graph of " + sys.argv[1] + ": ")
a = int(a)

f = open(file_name)
head = f.readline()
marks = []

for line in f:
    rolno, name, mark = line.split(sep=",")
    if mark[-1] == "\n":
        mark = mark[:-1]
    mark = int(mark)
    marks.append(mark)

np_marks = np.array(marks)

# Plot the histogram using numerical positions
plt.hist(np_marks , bins = np.arange((np.min(np_marks)//a)*a , a + a*(np.max(np_marks)//a) , a) , color = 'yellow' , edgecolor = 'red')
font1 = {'family':'serif','color':'black','size':25}
font2 = {'family':'serif','color':'black','size':15}
# Customize the x-axis labels
plt.xticks(np.arange((np.min(np_marks)//a)*a , a + a*(np.max(np_marks)//a) , a) , labels=np.arange((np.min(np_marks)//a)*a , a + a*(np.max(np_marks)//a) , a))
plt.title(sys.argv[1] , fontdict=font1)
plt.ylabel("Number of Students" , fontdict=font2)
plt.show()

if len(sys.argv) >= 3 and sys.argv[2] == "s":
    plt.savefig(sys.argv[1] + ".png")
