#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>





__global__ void heavyKernel(double* arr, int size, int loopSize, double* answer) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < size) {
        double sum = heavy(arr[i], loopSize);
        atomicAdd(answer, sum);
    }

}


double heavy(double data, int loopSize) {
    double sum = 0;       
    for (int i = 0; i < loopSize; i++)
        sum += cos(exp(sin(data * (i % 11))))/ loopSize;

     return sum;             
}


int main(int argc, char *argv[]) {
    int size = atoi(argv[1]);
    int loopSize = atoi(argv[2]);
    double* arr = (double*)malloc(size * sizeof(double));
    double* dev_arr;
    double* dev_answer;
    double answer = 0;
    cudaEvent_t start, stop;

    for (int i = 0; i < size; i++)
        arr[i] = rand() / RAND_MAX;

    cudaMalloc(&dev_arr, size * sizeof(double));
    cudaMalloc(&dev_answer, sizeof(double));
    cudaMemcpy(dev_arr, arr, size * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemset(dev_answer, 0, sizeof(double));

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    heavyKernel<<<(size + 255) / 256, 256>>>(dev_arr, size, loopSize, dev_answer);
    cudaDeviceSynchronize();
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    cudaMemcpy(&answer, dev_answer, sizeof(double), cudaMemcpyDeviceToHost);
    printf("answer = %e\n", answer);
    
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);
    printf("Time taken: %f ms\n", elapsedTime);

    cudaFree(dev_arr);
    cudaFree(dev_answer);
    free(arr);

    return 0;
}

 