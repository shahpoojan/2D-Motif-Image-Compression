#include <pthread.h>

ConsensusGrid consensus_parallel(int i, int j,char* image, int image_height, int image_width)
{
    ConsensusGrid consensus_grid;
    char *result = (char*)malloc(sizeof(char)*(image_height-i)*(image_width-j));
    char* ptr = result;

    int* row_flag=(int*)calloc(sizeof(int),(image_height-i));
    int* col_flag=(int*)calloc(sizeof(int),(image_width-j));
    _Cilk_for(int row=i; row<image_height; row++)
    {
        _Cilk_for(int col=j; col<image_width; col++)
        {
            if(image[row*image_width+col] == image[(row-i)*image_width+col-j])
            {
                if(image[row*image_width+col] == '1')
                    result[(row-i)*(image_width-j)+ (col-j)]='1';

                else if(image[row*image_width+col] == '0')
                    result[(row-i)*(image_width-j)+ (col-j)]='0';

                row_flag[row-i]=1;
                col_flag[col-j]=1;
            }
            else
                result[(row-i)*(image_width-j)+ (col-j)]='o';
            //result++;
        }
    }
    _Cilk_sync;
    int row_start,row_end;
    int col_start,col_end;
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

    char *result2 = (char*)malloc(sizeof(char)*(row_end-row_start+1)*(col_end-col_start+1));
    consensus_grid.result = result2;
    _Cilk_for(int row=row_start; row<=row_end; row++) //_Cilk_
    {
        _Cilk_for(int col=col_start; col<=col_end; col++) //_Cilk_
        {
            result2[(row - row_start) * (col_end - col_start + 1) + (col - col_start)] = ptr[row*(image_width-j) + col];
        }
    }
    _Cilk_sync;

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
    pthread_mutex_t lock;
    pthread_mutex_init(&lock,NULL);

    _Cilk_for(int i=0; i<image_height*image_width; i++)
    {

        if((meet[i].height != 0) && (meet[i].width != 0))
        {
            pthread_mutex_t lock2;
            pthread_mutex_init(&lock2, NULL);

            tuple* temp_occurance_list = new tuple[image_height*image_width];
            _Cilk_for(int row_offset=0; row_offset<=image_height - meet[i].height; row_offset++)
            {
                
		for(int col_offset=0; col_offset<=image_width - meet[i].width; col_offset++)
                {

                    int count = 0;
                    for(int row = 0; row<meet[i].height; row++)
                    {
                        for(int col = 0; col<meet[i].width; col++)
                        {
                            if(meet[i].result[row*meet[i].width + col] == 'o' )
                                count++;
                            else
                            {
                                if(meet[i].result[row*meet[i].width + col] == image[(row+row_offset)*image_width + (col+col_offset)])
                                    count++;
                                else
                                    break;
                            }
                        }
                    }

                    if(count == meet[i].width*meet[i].height)
                    {
                        tuple t;
                        t.i = row_offset;
                        t.j = col_offset;
                        //meet[i].occurance[meet[i].occurance_count++] = t;
			pthread_mutex_lock(&lock2);
                        temp_occurance_list[meet[i].occurance_count++] = t;
			pthread_mutex_unlock(&lock2);
                    }
                }
            }

            if(meet[i].occurance_count >=0)
            {
                meet[i].occurance = new tuple[meet[i].occurance_count];
                for(int x=0; x<meet[i].occurance_count; x++)
                {
                    meet[i].occurance[x] = temp_occurance_list[x];
                }

		pthread_mutex_lock(&lock);
                not_null_count++;
		pthread_mutex_unlock(&lock);
            }
            else
            {
                meet[i].occurance_count = 0;
            }

            free(temp_occurance_list);
	    _Cilk_sync;
        }
    }
    _Cilk_sync;
}

void calculate_basis_parallel()
{
    int *basis_temp = (int*)calloc(sizeof(int),not_null_count);
    cout<<"Not null count "<<not_null_count<<endl;
    for(int i=0; i<image_height*image_width; i++)
    {
        int max = -1;
        int index = i;
        for(int j=i; j<image_height*image_width; j++)
        {
            if(max < meet[j].occurance_count)
            {
                max = meet[j].occurance_count;
                index = j;
            }
        }

        ConsensusGrid temp = meet[i];
        meet[i] = meet[index];
        meet[index] = temp;
    }

    for(int i=0; i<not_null_count; i++)
    {
        /// For every meet make count = 0
        int count = 0;
	
	int temp_count = meet[i].occurance_count;

        /// Loop over every element in occurance list
        for(int j = 0; j<temp_count; j++)
        {
            int flag = 0;

            /// Compare the occurance list of every meet with current meet
            for(int k=0; k<not_null_count; k++)
            {
                if( (k!=i) && (meet[k].occurance != NULL))
                {
                    /// Loop through all occurances
                    for(int l=0; l<meet[k].occurance_count; l++)
                    {
                        if((meet[k].occurance[l].i == meet[i].occurance[j].i) && (meet[k].occurance[l].j == meet[i].occurance[j].j))
                        {
                            //printf("found! i = %d  j = %d %d\n",i,meet[i].occurance[j].i, meet[i].occurance[j].j);
                            flag = 1;
                            break;
                        }
                    }
                    if(flag == 1)
                        break;
                }
                if(flag == 1)
                    break;
            }
            if(flag != 1);
               // break;
            else
                count++;


        }
        if((meet[i].occurance_count >0) && (count != temp_count))
            basis[basis_count++] = i;
        else
            meet[i].occurance_count = 0;
    }


    /*for(int i=0;i<not_null_count;i++)
    {
	if(basis_temp[i] == 1)
	{
		basis[basis_count++] = i;
	}
    }*/
}


