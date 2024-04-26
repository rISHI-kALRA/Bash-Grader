import csv
import os
import sys

sys.path.append(sys.argv[1])

def compare_csv_files(dir1, dir2):
    # Get list of CSV files in both directories
    files1 = [f for f in os.listdir(dir1) if f.endswith('.csv')]
    files2 = [f for f in os.listdir(dir2) if f.endswith('.csv')]

    # Compare files in both directories
    common_files = set(files1) & set(files2)
    unique_files1 = set(files1) - set(files2)
    unique_files2 = set(files2) - set(files1)

    print("Common files:")
    for file in common_files:
        compare_csv(os.path.join(dir1, file), os.path.join(dir2, file))
    if(len(unique_files1) != 0):
        print("\nFiles unique to", dir1 + ":")
        print(unique_files1)
    if(len(unique_files2) != 0):
        print("\nFiles unique to", dir2 + ":")
        print(unique_files2)

def compare_csv(file1, file2):
    # Read CSV files
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        csv_reader1 = csv.reader(f1)
        csv_reader2 = csv.reader(f2)

        # Compare rows
        row_count1 = 0
        row_count2 = 0
        for row1 in csv_reader1:
            row2 = f2.readline()
            row2 = row2.split(sep=",")
            row_count1 += 1
            row_count2 += 1
            # removes extra whitespaces, we don't need 
            # to consider differences in whitespaces
            for i in range(len(row1)):
                row1[i] = row1[i].strip() 
            for i in range(len(row2)):
                row2[i] = row2[i].strip()
            if row1 != row2:
                print("Difference found in file", file1)
                print("Row" , row_count1 , "in", file1 , "in working directory:", row1)
                print("Row" , row_count2 , "in", file1 , "in commit:", row2)
                print()
        for row2 in f2:
            row2 = row2.split(sep=",")
            row_count2 += 1
            row_count1 += 1
            for i in range(len(row2)):
                row2[i] = row2[i].strip()
            print("Row" , row_count1 , "in", file1 , "in working directory:", "''")
            print("Row" , row_count2 , "in", file2 ,  "in commit:", row2)
# Example usage
dir1 = sys.argv[2]
dir2 = sys.argv[3]
compare_csv_files(dir1, dir2)
