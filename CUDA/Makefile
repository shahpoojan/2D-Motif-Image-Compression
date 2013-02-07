
all: main.cu
	nvcc -arch sm_20 main.cu -o main.o

test: Test.cu
	nvcc -arch sm_20 Test.cu -o test.o

smalltest: SmallTest.cu
	nvcc -arch sm_20 SmallTest.cu -o smalltest.o

clean:
	rm -rf *.o
