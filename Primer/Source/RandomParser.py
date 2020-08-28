import csv
import os
import numpy as np

np.set_printoptions(linewidth=np.inf)

averages = []
minimums = []
maximums = []

def initData():
    global averages, minimums, maximums
    with open('input/0PrimerOutput.txt') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        #for row in csv_reader:
        for idx, row in enumerate(csv_reader):
            if idx == 0:
                averages.append(row)
                minimums.append(row)
                maximums.append(row)
            elif idx > 0:
                averages.append(np.array(row).astype(np.int))
                minimums.append(np.array(row).astype(np.int))
                maximums.append(np.array(row).astype(np.int))

def parseFile(fileName):
    global averages, minimums, maximums
    with open(fileName) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        #for row in csv_reader:
        for idx, row in enumerate(csv_reader):
            if idx > 0:
                vector = np.array(row).astype(np.int)
                averages[idx] = averages[idx] + vector
                minimums[idx] = np.minimum(minimums[idx],vector)
                maximums[idx] = np.maximum(maximums[idx],vector)

def outputDatasets():
    global averages, minimums, maximums
    with open('RandomOutput_Averages.txt', 'wb') as myfile:
        wr = csv.writer(myfile)
        for row in averages:
            wr.writerow(row)
    with open('RandomOutput_Min.txt', 'wb') as myfile:
        wr = csv.writer(myfile)
        for row in minimums:
            wr.writerow(row)
    with open('RandomOutput_Max.txt', 'wb') as myfile:
        wr = csv.writer(myfile)
        for row in maximums:
            wr.writerow(row)

if __name__== "__main__":
  initData()

  for index in range(1,128):
      fileName = 'input/'+str(index)+'PrimerOutput.txt'
      parseFile(fileName)

  #Average out the datasets
  for idx, row in enumerate(averages):
      if idx > 0:
          averages[idx] = row/(128)

  #Output the datasets
  outputDatasets()
