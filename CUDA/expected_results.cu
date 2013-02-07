char meet_0[] = {'0', '0', '1', '1', '1', '1', '0', '0', '1', '1', '0', '1', '\0'};
char meet_1[] = {'0', 'o', '1', '1', '0', 'o', '\0'};
char meet_2[] = {'1', 'o', '1', '\0'};
char meet_3[] = {'o', '1', 'o', '1', '0', '1', '\0'};
char meet_4[] = {'o', '1', '0', 'o', '\0'};
char meet_5[] = {'1', '\0'};
char meet_6[] = {'0', '0', '1', '1', 'o', '1', '\0'};
char meet_7[] = {'0', 'o', 'o', '1', '\0'};
char meet_8[] = {'1', '\0'};
char meet_9[] = {'0', '1', '\0'};
char meet_10[] = {'0', '\0'};
char meet_11[] = {'\0'};

char* expected_meet[] = {meet_0, meet_1, meet_2, meet_3, meet_4, meet_5, meet_6, meet_7, meet_8, meet_9, meet_10, meet_11};

int occurance_0[] = {0,0, -1};
int occurance_1[] = {0,0, 0,1, -1};
int occurance_2[] = {0,2, 1,0, 1,2, -1};
int occurance_3[] = {0,1, 1,1, -1};
int occurance_4[] = {1,0, 1,1, 2,1, -1};
int occurance_5[] = {0,2, 1,0, 1,1, 1,2, 2,2, 3,0, 3,2, -1};
int occurance_6[] = {0,0, 2,0, -1};
int occurance_7[] = {0,0, 0,1, 2,1, -1};
int occurance_8[] = {0,2, 1,0, 1,1, 1,2, 2,2, 3,0, 3,2, -1};
int occurance_9[] = {0,1, 2,1, 3,1, -1};
int occurance_10[] = {0,0, 0,1, 2,0, 2,1, 3,1, -1};
int occurance_11[] = {-1};

int* expected_occurance[] = {occurance_0, occurance_1, occurance_2, occurance_3, occurance_4, occurance_5,
                             occurance_6, occurance_7, occurance_8, occurance_9, occurance_10, occurance_11};

char* expected_basis[] = {meet_5, meet_9, meet_6};
