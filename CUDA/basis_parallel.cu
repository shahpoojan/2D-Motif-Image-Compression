#include <cuda_runtime.h>
#include <sys/time.h>


struct timeval t_s, t_e, t_s2, t_e2, t_s3, t_e3;
double t1, t2, t3;

__global__ void compute_Dontcares(char* image,int* row_flag,int* col_flag,char* result, int i, int j, int image_width)
{
	int row = (blockIdx.x + i);
	int col = threadIdx.x + j;
	if(image[row*image_width+col] == image[(row-i)*image_width+col-j])
	{
		if(image[row*image_width+col] == '1')
			result[(row-i)*(image_width-j)+ (col-j)]='1';

		else//(image[row*image_width+col] == '0')
			result[(row-i)*(image_width-j)+ (col-j)]='0';

		row_flag[row-i]=1;
		col_flag[col-j]=1;
	}
	else
		result[(row-i)*(image_width-j)+ (col-j)]='o';
}


__global__ void compute_Result(char* ptr_ptr ,int image_height, int image_width, int row_start,int col_start, int col_end, char* result2_ptr, int j)    {
	int row = blockIdx.x + row_start;
	int col = threadIdx.x + col_start;
	result2_ptr[(row - row_start) * (col_end - col_start + 1) + (col - col_start)] = ptr_ptr[row*(image_width-j) + col];
}

__global__
void compute_count(int image_width, char* result, int* occurance_count, char* image, tuple* temp_occurance_list, int height, int width)
{
	int row_offset = threadIdx.x;
	for(int col_offset=0; col_offset<=image_width - width; col_offset++)
	{

		int count = 0;
		for(int row = 0; row<height; row++)
		{
			for(int col = 0; col<width; col++)
			{
				if(result[row*width + col] == 'o' )
				{
					count++;
				}
				else
				{
					if(result[row*width + col] == image[(row+row_offset)*image_width + (col+col_offset)])
					{
						count++;
					}
					else
						break;
				}
			}
		}
		
		if(count == width*height)
		{
			tuple t;
			t.i = row_offset;
			t.j = col_offset;

			int old_count = atomicInc((unsigned int*)(&(occurance_count[0])),(unsigned int)999999999);
			temp_occurance_list[old_count] = t;
		}
	}
}

ConsensusGrid consensus_parallel(int i, int j,char* image, int image_height, int image_width)
{
	ConsensusGrid consensus_grid;
	char* image_ptr;
	int* row_flag_ptr;
	int*  col_flag_ptr;
	char * ptr_ptr;
	char*  result2_ptr;
	char* result_ptr;

	char *result = (char*)malloc(sizeof(char)*(image_height-i)*(image_width-j));
	char* ptr = result;

	int* row_flag=(int*)calloc(sizeof(int),(image_height-i));
	int* col_flag=(int*)calloc(sizeof(int),(image_width-j));

	//copy result and image to gpu
	//compute the result array
	//copy result back to cpu
	cudaMalloc((void**)&image_ptr, sizeof(char)*(image_height*image_width));
	cudaMemcpy(image_ptr, image, sizeof(char)*(image_height*image_width) ,  cudaMemcpyHostToDevice);
	cudaMalloc((void**)&row_flag_ptr, sizeof(int)*(image_height-i));
	cudaMemcpy(row_flag_ptr, row_flag, sizeof(int)*(image_height-i) ,  cudaMemcpyHostToDevice);
	cudaMalloc((void**)&col_flag_ptr, sizeof(int)*(image_width-j));
	cudaMemcpy(col_flag_ptr, col_flag, sizeof(int)*(image_width-j) ,  cudaMemcpyHostToDevice);
	cudaMalloc((void**)&result_ptr, sizeof(char)*(image_width-j)*(image_height-i));

	gettimeofday(&t_s, NULL);

	// __global__ functions are called:  Func<<< Dg, Db, Ns  >>>(parameter);
	compute_Dontcares<<<(image_height-i),(image_width-j)>>>(image_ptr,row_flag_ptr, col_flag_ptr, result_ptr,i,j, image_width);

	cudaDeviceSynchronize();

	gettimeofday(&t_e, NULL);
	t1 = (((double)t_e.tv_sec-(double)t_s.tv_sec)*1000) + ((double)t_e.tv_usec - (double)t_s.tv_usec)/1000;

	cudaMemcpy(result, result_ptr, sizeof(char)*(image_height-i)*(image_width-j),  cudaMemcpyDeviceToHost);
	cudaMemcpy(row_flag, row_flag_ptr, sizeof(int)*(image_height-i),  cudaMemcpyDeviceToHost);
	cudaMemcpy(col_flag, col_flag_ptr, sizeof(int)*(image_width-j),  cudaMemcpyDeviceToHost);
	cudaMemcpy(image, image_ptr, sizeof(char)*(image_height)*(image_width),  cudaMemcpyDeviceToHost);
	
	int col_start,col_end, row_start, row_end;
	for(row_start=0; row_start<(image_height-i); row_start++)
	{
		if(row_flag[row_start]==1)
			break;
	}
	for(row_end=(image_height-i-1); row_end>=0; row_end--)
	{
		if(row_flag[row_end]==1)
			break;
	}
	for(col_start=0; col_start<(image_width-j); col_start++)
	{
		if(col_flag[col_start]==1)
			break;
	}
	for(col_end=(image_width-j-1); col_end>=0; col_end--)
	{
		if(col_flag[col_end]==1)
			break;
	}

	if((row_start > row_end) || (col_start > col_end) )
	{
		consensus_grid.result = NULL;
		consensus_grid.height = 0;
		consensus_grid.width = 0;
		return consensus_grid;
	}

	char* result2 = (char*)malloc(sizeof(char)*(row_end-row_start+1)*(col_end-col_start+1));
	cudaMalloc((void**)&result2_ptr, sizeof(char)*(row_end-row_start+1)*(col_end-col_start+1));

	cudaMalloc((void**)&ptr_ptr, sizeof(char)*(image_height-i)*(image_width-j));
	cudaMemcpy(ptr_ptr, ptr, sizeof(char)*(image_height-i)*(image_width-j) ,  cudaMemcpyHostToDevice);

	consensus_grid.result = result2;

	gettimeofday(&t_s2, NULL);

	compute_Result<<<(row_end-row_start+1),(col_end-col_start+1)>>>(ptr_ptr , image_height, image_width, row_start,col_start, col_end, result2_ptr, j);

	cudaDeviceSynchronize();

	gettimeofday(&t_e2, NULL);
	t2 = (((double)t_e2.tv_sec-(double)t_s2.tv_sec)*1000) + ((double)t_e2.tv_usec - (double)t_s2.tv_usec)/1000;

	cudaMemcpy(result2, result2_ptr, sizeof(char)*(row_end-row_start+1)*(col_end-col_start+1),  cudaMemcpyDeviceToHost);


	consensus_grid.height = row_end - row_start + 1;
	consensus_grid.width = col_end - col_start + 1;
	consensus_grid.occurance = NULL;
	consensus_grid.occurance_count = 0;

	free(ptr);
	free(row_flag);
	free(col_flag);
	return consensus_grid;
}

void calculate_list_parallel()
{
	char* image_ptr;
	tuple* temp_occurance_list_ptr;
	char* result_ptr;
	int* occurance_count_ptr;
	pthread_mutex_t lock;
	pthread_mutex_init(&lock,NULL);

	for(int i=0; i<image_height*image_width; i++)
	{

		if((meet[i].height != 0) && (meet[i].width != 0))
		{

			tuple* temp_occurance_list = new tuple[image_height*image_width];

			cudaMalloc((void**)&image_ptr, sizeof(char)*image_height*image_width);
			cudaMemcpy(image_ptr, image, sizeof(char)*image_height*image_width, cudaMemcpyHostToDevice);
			cudaMalloc((void**)&temp_occurance_list_ptr, sizeof(tuple)*image_height*image_width);
			cudaMemcpy(temp_occurance_list_ptr, temp_occurance_list, sizeof(tuple)*image_height*image_width, cudaMemcpyHostToDevice);

			cudaMalloc((void**)&result_ptr, sizeof(char)*meet[i].height*meet[i].width);
                        cudaMemcpy(result_ptr, meet[i].result, sizeof(char)*meet[i].height*meet[i].width, cudaMemcpyHostToDevice);
			
			cudaMalloc((void**)&occurance_count_ptr, sizeof(int));
                        
			cudaMemcpy(occurance_count_ptr, &(meet[i].occurance_count), sizeof(int), cudaMemcpyHostToDevice);

			gettimeofday(&t_s3, NULL);

			compute_count<<< 1, image_height-meet[i].height+1>>> (image_width,result_ptr, occurance_count_ptr, image_ptr, temp_occurance_list_ptr, meet[i].height, meet[i].width);

			cudaDeviceSynchronize();

			gettimeofday(&t_e3, NULL);
			t3 = (((double)t_e3.tv_sec-(double)t_s3.tv_sec)*1000) + ((double)t_e3.tv_usec - (double)t_s3.tv_usec)/1000;


			cudaMemcpy(temp_occurance_list, temp_occurance_list_ptr, sizeof(tuple)*image_height*image_width, cudaMemcpyDeviceToHost);
			cudaMemcpy(&meet[i].occurance_count,occurance_count_ptr, sizeof(int), cudaMemcpyDeviceToHost);

			if(meet[i].occurance_count >=0)
			{
				meet[i].occurance = new tuple[meet[i].occurance_count];
				for(int x=0; x<meet[i].occurance_count; x++)
				{
					meet[i].occurance[x] = temp_occurance_list[x];
				}

				not_null_count++;
			}
			else
			{
				meet[i].occurance_count = 0;
			}

			free(temp_occurance_list);
cudaDeviceReset();
		}
	}
}

