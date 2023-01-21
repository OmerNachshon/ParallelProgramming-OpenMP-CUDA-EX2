#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>

__device__ double heavy(double data, int loopSize) {
    double sum = 0;       
    for (int i = 0; i < loopSize; i++)
        sum += cos(exp(sin(data * (i % 11))))/ loopSize;

     return sum;             
}


__global__ void heavyKernel(double* arr, int size, int loopSize, double* sum) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < size) {
        sum[i] = heavy(arr[i], loopSize);
        
    }

}

int main(int argc, char *argv[]) {
    int size = atoi(argv[1]);
    int loopSize = atoi(argv[2]);
    double* arr = (double*)malloc(size * sizeof(double));
    double* answers = (double*)malloc(size * sizeof(double));
    double* dev_arr;
    double* dev_answer;
    double sum = 0;
    cudaEvent_t start, stop;

//random value for arr 
    for (int i = 0; i < size; i++)
        arr[i] = rand() / RAND_MAX;

    cudaMalloc(&dev_arr, size * sizeof(double));
    cudaMalloc(&dev_answer, sizeof(double));
    cudaMemcpy(dev_arr, arr, size * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_answer, answers, sizeof(double), cudaMemcpyHostToDevice);

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    heavyKernel<<<(size + 255) / 256, 256>>>(dev_arr, size, loopSize, dev_answer);
    cudaMemcpy(answers, dev_answer, sizeof(double), cudaMemcpyDeviceToHost);

//sum up all values into variable sum 
    for(int i=0;i<size;i++)
    sum+=answers[i];

    printf("answer = %e\n", sum);
    cudaDeviceSynchronize();
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    //print total runtime
    printf("Time taken: %f s\n", elapsedTime/1000);

    cudaFree(dev_arr);
    cudaFree(dev_answer);
    free(arr);

    return 0;
}

 

 