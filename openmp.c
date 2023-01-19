#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

//  This function performs heavy computations
//  No Changes to this function are allowed
double heavy(double data, int loopSize)
{
    double sum = 0;
    for (int i = 0; i < loopSize; i++)
        sum += cos(exp(sin(data * (i % 11)))) / loopSize;
    return sum;
}
// Sequential code to be parallelized
int main(int argc, char *argv[])
{
    clock_t begin = clock();
    int i;
    int size = 1000;
    int loopSize = 1000;
    double *arr = (double *)malloc(size * sizeof(double));

    // no need to use shared memory because each index is used once
#pragma omp parallel for
    for (i = 0; i < size; i++)
        arr[i] = rand() / RAND_MAX;
    double answer = 0;

    // using +sum reduction should cover the addition
    //  no write to array so shared memory is not required
#pragma omp parallel for
    for (i = 0; i < size; i++)
        answer += heavy(arr[i], loopSize);

    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    printf("answer = %e\n , time spent:%lf", answer, time_spent);
}