void print_meet(int index)
{
    cout<<" For meet "<<index<<endl;
    for(int j=0; j< meet[index].height * meet[index].width; j++)
    {
        cout<< meet[index].result[j]<< ", ";
    }
    cout<<endl;
}

void print_meets()
{
    cout<< "Getting all the meets";
    for(int i=0; i< image_height* image_width; i++)
    {
        print_meet(i);
    }
}

void print_occurances()
{
    for(int i=0; i<image_height*image_width; i++)
    {
        cout<<" The occurances of meet "<< i<< "with the occurance count"<<meet[i].occurance_count<< endl;
        for(int j=0; j< meet[i].occurance_count; j++)
            cout<<"i = "<< meet[i].occurance[j].i<< " j= "<< meet[i].occurance[j].j<<endl;
    }
}

void print_basis()
{
    cout << "The basis count is "<< basis_count<<endl;
    cout<<"The basis has"<< endl;
    for(int i=0; i< basis_count; i++ )
    {
        cout<<"The "<<i+1<<"th meet in the basis is"<< endl;
        print_meet(basis[i]);
    }
}

