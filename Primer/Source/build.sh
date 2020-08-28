clang++ -g -Wall -std=c++11 -stdlib=libc++ -c -o PrimerTool.o -I. -I../3rdParty/include PrimerTool.cpp
#Make Primer lib?
clang++ -g -Wall -std=c++11 -stdlib=libc++ -c -o main.o -I. main.cpp
clang++ -lpthread -o Primer PrimerTool.o main.o -L../3rdParty/lib -lprimesieve
