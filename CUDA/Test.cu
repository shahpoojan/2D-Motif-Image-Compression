# include "basis.cu"
#include "print.cu"
# include "basis_parallel.cu"
#include <sys/time.h> 

void sort(int* ary, int count)
{
	for(int i=0; i < count; i++)
	{
		int min = 1000000;
		int index = i;
		for(int j=i; j < count; j++)
		{
			if(min > ary[j])
			{
				index = j;
				min = ary[j];
			}
		}

		int temp = ary[i];
		ary[i] = ary[index];
		ary[index] = temp;
	}
}

void reset_values()
{
    delete(meet);
    delete(basis);
    delete(image);
    image = (char*)malloc(sizeof(char)*image_height*image_width);
    read_raw_image("image.raw",image,image_height,image_width);

    meet=(ConsensusGrid*)malloc(sizeof(ConsensusGrid)*image_height*image_width);
    basis = (int*)malloc(sizeof(int)*image_height*image_width);
    not_null_count = 0;
    basis_count = 0;
}

void Assert_Output(int* basis1, int* basis2, int count1, int count2)
{
	if(count1 != count2)
	{
		cout << "Count's dont match" << endl;
		exit(-1);
	}
	sort(basis1, count1);
	sort(basis2, count2);

	for(int i=0; i<count1; i++)
	{
		if(basis1[i] != basis2[i])
		{
			cout << "Basis indices dont match" << endl;
			for(int i=1; i<count1; i++)
			{
				cout << basis1[i] << ", ";
			}
			cout << endl;
                        for(int i=1; i<count1; i++)
                        {
                                cout << basis2[i] << ", ";
                        }
                        cout << endl;
			exit(-1);
		}
	}
	cout << "Correct Output!" << endl;
}

int main(int argc, char** argv)
{
	if(argc > 1)
	{
		int* basis_serial;
		int* basis_parallel;
		int basis_count1, basis_count2;
		

		image_height=atoi(argv[1]);
		image_width=atoi(argv[1]);
		
		create_image();

		image = (char*)malloc(sizeof(char)*image_height*image_width);
		meet=(ConsensusGrid*)malloc(sizeof(ConsensusGrid)*image_height*image_width);
		basis = (int*)malloc(sizeof(int)*image_height*image_width);

		read_raw_image("image.raw",image,image_height,image_width);

		/// For serial implementation
		for(int i=0; i<image_height; i++)
		{
			for(int j = 0; j<image_width; j++)
			{
				meet[i*image_width+j]=consensus(i, j, image,image_height,image_width);
			}
		}

		printf("Calculating list for serial\n");
		calculate_list();

		printf("Calculating basis for serial\n");
		calculate_basis();

		basis_serial = basis;

		basis_count1 = basis_count;
		cout << "Serial Basis count = " << basis_count << endl << endl;

		reset_values();
		
		/// For parallel implementation
		
                for(int i=0; i<image_height; i++)
                {
                        for(int j = 0; j<image_width; j++)
                        {
                                meet[i*image_width+j]=consensus_parallel(i, j, image,image_height,image_width);
                        }
                }

                printf("Calculating list for parallel\n");
                calculate_list_parallel();

                printf("Calculating basis for parallel\n");
		calculate_basis();


                basis_parallel = basis;

		basis_count2 = basis_count;
                cout << "Parallel Basis count = " << basis_count << endl;

		Assert_Output(basis_serial, basis_parallel, basis_count1, basis_count2);

	}

	else
	{
		cout << "Insufficient arguments\n" << endl;
		cout << "First argument = Image Size" << endl;
	}
}
