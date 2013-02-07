# include "basis.cu"
#include "print.cu"
# include "basis_parallel.cu"

int main(int argc, char** argv)
{
	if(argc > 3)
	{
		image_height=atoi(argv[1]);
		image_width=atoi(argv[1]);
		if(atoi(argv[2]) == 1)
			create_image();

		image = (char*)malloc(sizeof(char)*image_height*image_width);
		meet=(ConsensusGrid*)malloc(sizeof(ConsensusGrid)*image_height*image_width);
		basis = (int*)malloc(sizeof(int)*image_height*image_width);

		read_raw_image("image.raw",image,image_height,image_width);
		for(int i=0; i<image_height; i++)
		{
			for(int j = 0; j<image_width; j++)
			{
				if(atoi(argv[3]) == 1)
					meet[i*image_width+j]=consensus_parallel(i, j, image,image_height,image_width);
				else
					meet[i*image_width+j]=consensus(i, j, image,image_height,image_width);
			}
		}

		printf("Calculating list\n");
		if(atoi(argv[3]) == 1)
			calculate_list_parallel();
		else
			calculate_list();

		printf("Calculating basis\n");
		if(atoi(argv[3]) == 1)
			calculate_basis();
		else
			calculate_basis();

		cout << "Basis count = " << basis_count << endl << endl;
	}

	else
	{
		cout << "Insufficient arguments\n" << endl;
		cout << "First argument = Image Size" << endl;
		cout << "Second argument = 1 to create image, 0 not to create image" << endl;
		cout << "Third argument = 1 for parallel, 0 for not parallel\n" << endl;
	}
}
