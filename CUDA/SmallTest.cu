# include "basis.cu"
#include "basis_parallel.cu"
#include "print.cu"
#include "expected_results.cu"
#include<string.h>
void construct_image()
{
    image[0] = '0';
    image[1] = '0';
    image[2] = '1';
    image[3] = '1';
    image[4] = '1';
    image[5] = '1';
    image[6] = '0';
    image[7] = '0';
    image[8] = '1';
    image[9] = '1';
    image[10] = '0';
    image[11] = '1';
}

void assert_meet()
{
    cout<< "Asserting meet..."<<endl;
    for(int i=0; i< image_height * image_width; i++)
    {
        int expected_size = strlen(expected_meet[i]);
        int actual_size = meet[i].height * meet[i].width;

        if(expected_size != actual_size)
        {
            cout<<"Error in meet. Size mismatch in meet "<<i<<endl;
            exit(-1);
        }

        for(int j = 0; j < expected_size; j++)
        {
            if(meet[i].result[j] != expected_meet[i][j])
            {
                cout<<"Error in meet. Expected "<<expected_meet[i][j]<<" at meet "<<i<<" and at position "<<j<<" but got "<<meet[i].result[j];
                exit(-1);
            }
        }
    }
    cout<<"Meet is correct"<<endl;
}

void assert_occurance()
{
    cout<< "Asserting occurance..."<<endl;
    for(int x=0; x< image_height * image_width; x++)
    {
        for(int y = 0; expected_occurance[x][y] != -1; y+=2)
        {
            if((meet[x].occurance[y/2].i != expected_occurance[x][y]) || (meet[x].occurance[y/2].j != expected_occurance[x][y+1]))
            {
                cout<<"Error in occurance. Expected (i,j) value ("<<expected_occurance[x][y]<<","<<expected_occurance[x][y+1]<<")"
                    <<" for meet "<<x<<" at "<<y<<"th occurance but got ("<<meet[x].occurance[y/2].i<<","<<meet[x].occurance[y/2].j<<")";
                exit(-1);
            }
        }
    }
    cout<<"Occurance is correct"<<endl;
}

void assert_basis()
{
    cout<< "Asserting basis..."<<endl;
    for(int i=0; i< basis_count; i++)
    {
        int expected_size = strlen(expected_basis[i]);
        int actual_size = meet[basis[i]].height * meet[basis[i]].width;

        if(expected_size != actual_size)
        {
            cout<<"Error in basis. Size mismatch in basis "<<i<<"'s meet. Expected "<< expected_size<< " Actual "<< actual_size<<endl;
            exit(-1);
        }

        for(int j = 0; j< strlen(expected_basis[i]); j++)
        {
            if(meet[basis[i]].result[j] != expected_basis[i][j])
            {
                cout<<"Error in basis. Mismatch in the "<<i<<"th basis";
                exit(-1);
            }
        }
    }
    cout<<"Basis is correct"<<endl;
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

void compute_serial_basis()
{
    for(int i=0; i<image_height; i++)
    {
        for(int j = 0; j<image_width; j++)
        {
            meet[i*image_width+j]=consensus(i, j, image,image_height,image_width);
            meet[i*image_width+j].occurance = new tuple[image_height*image_width];
        }
    }

    calculate_list();
    calculate_basis();
}

void compute_parallel_basis()
{
    for(int i=0; i<image_height; i++)
    {
        for(int j = 0; j<image_width; j++)
        {
            meet[i*image_width+j]=consensus_parallel(i, j, image,image_height,image_width);
            meet[i*image_width+j].occurance = new tuple[image_height*image_width];
        }
    }

    calculate_list_parallel();
    calculate_basis();
}

void assert_parallel_code()
{
    cout<<endl<<"Asserting parallel result with serial"<<endl;
    image_height = 4;
    image_width = 3;
    create_image();

    reset_values();
    compute_serial_basis();

    int *basis_serial = (int*)malloc(sizeof(int)* basis_count);
    int basis_count_serial = basis_count;
    memcpy(basis_serial, basis, sizeof(int)*basis_count);

    reset_values();
    compute_parallel_basis();

    if(basis_count != basis_count_serial)
    {
        cout<<"Basis count mismatch. Serial: "<<basis_count_serial<<" Parallel: "<<basis_count;
        exit(-1);
    }

    for(int i=0; i< basis_count; i++)
    {
        int flag = 0;
        for(int j=0; j<basis_count; j++){
            if(basis_serial[i] == basis[j]){
                    flag = 1;
                    break;
            }
        }
        if(flag != 1)
        {
            cout<<"The basis at position "<<i<<" which was meet "<<basis[i]<<" was not found in the parallel code"<<endl;
            exit(-1);
        }
    }
    cout << "Basis computed with parallel code matched the serial one" << endl;
}
int main()
{
    cout<<"Asserting the output of prallel code with a precomputed one"<<endl;
    image_height=4;
    image_width=3;
    image = (char*)malloc(sizeof(char)*image_height*image_width);
    construct_image();

    meet=(ConsensusGrid*)malloc(sizeof(ConsensusGrid)*image_height*image_width);
    basis = (int*)malloc(sizeof(int)*image_height*image_width);

    for(int i=0; i<image_height; i++)
    {
        for(int j = 0; j<image_width; j++)
        {
            meet[i*image_width+j]=consensus_parallel(i, j, image,image_height,image_width);
            meet[i*image_width+j].occurance = new tuple[image_height*image_width];
        }
    }
    assert_meet();
    calculate_list_parallel();

//    assert_occurance();
    calculate_basis();
    assert_basis();
    assert_parallel_code();
}


