# include "basis.cpp"
#include "print.cpp"
# include "basis_parallel.cpp"
#include <sys/time.h>

int main(int argc, char** argv)
{
	if(argc > 3)
	{
		double t1, t2, t3;
		struct timeval t_s1, t_e1, t_s2, t_e2, t_s3, t_e3;

		image_height=atoi(argv[1]);
		image_width=atoi(argv[1]);
		if(atoi(argv[2]) == 1)
			create_image();

		image = (char*)malloc(sizeof(char)*image_height*image_width);
		meet=(ConsensusGrid*)malloc(sizeof(ConsensusGrid)*image_height*image_width);
		basis = (int*)malloc(sizeof(int)*image_height*image_width);

		read_raw_image("image.raw",image,image_height,image_width);

		cout << "Calculating consensus..." << endl << endl;
		for(int i=0; i<image_height; i++)
		{
			for(int j = 0; j<image_width; j++)
			{
				if(atoi(argv[3]) == 1)
				{
				        gettimeofday(&t_s1, NULL);

					meet[i*image_width+j]=consensus_parallel(i, j, image,image_height,image_width);

					gettimeofday(&t_e1, NULL);
        				t1 = (((double)t_e1.tv_sec-(double)t_s1.tv_sec)*1000) + ((double)t_e1.tv_usec - (double)t_s1.tv_usec)/1000;
				}
				else
				{
                                        gettimeofday(&t_s1, NULL);
					meet[i*image_width+j]=consensus(i, j, image,image_height,image_width);
                                        gettimeofday(&t_e1, NULL);
                                        t1 = (((double)t_e1.tv_sec-(double)t_s1.tv_sec)*1000) + ((double)t_e1.tv_usec - (double)t_s1.tv_usec)/1000;
				}
			}
		}

		cout << "Calculating list..." << endl << endl;
		if(atoi(argv[3]) == 1)
		{
        		gettimeofday(&t_s2, NULL);
			calculate_list_parallel();
			gettimeofday(&t_e2, NULL);
		        t2 = (((double)t_e2.tv_sec-(double)t_s2.tv_sec)*1000) + ((double)t_e2.tv_usec - (double)t_s2.tv_usec)/1000;

		}
		else
		{
                        gettimeofday(&t_s2, NULL);
			calculate_list();
                        gettimeofday(&t_e2, NULL);
                        t2 = (((double)t_e2.tv_sec-(double)t_s2.tv_sec)*1000) + ((double)t_e2.tv_usec - (double)t_s2.tv_usec)/1000;

		}
		cout << "Calculating basis..." << endl << endl;
		if(atoi(argv[3]) == 1)
		{
       		 	gettimeofday(&t_s3, NULL);
			calculate_basis();

			gettimeofday(&t_e3, NULL);
        		t3 = (((double)t_e3.tv_sec-(double)t_s3.tv_sec)*1000) + ((double)t_e3.tv_usec - (double)t_s3.tv_usec)/1000;
		}
		else
		{
                        gettimeofday(&t_s3, NULL);
			calculate_basis();
                        gettimeofday(&t_e3, NULL);
                        t3 = (((double)t_e3.tv_sec-(double)t_s3.tv_sec)*1000) + ((double)t_e3.tv_usec - (double)t_s3.tv_usec)/1000;

		}
		cout << "Basis count = " << basis_count << endl;

		cout << endl << "Time for Parallel Consensus Calculation = " << t1 << " msec" << endl;
		cout << "Time for Parallel List Calculation = " << t2 << " msec" << endl;
		cout << "Time for Basis  Calculation = " << t3 << " msec" << endl;
	}

	else
	{
		cout << "Insufficient arguments\n" << endl;
		cout << "First argument = Image Size" << endl;
		cout << "Second argument = 1 to create image, 0 not to create image" << endl;
		cout << "Third argument = 1 for parallel, 0 for not parallel\n" << endl;
	}
}
