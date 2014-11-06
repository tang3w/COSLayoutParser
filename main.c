#include "common.h"

int main(int argc, char **argv) {
    if(!cslayoutparse()) {
        fprintf(stdout, "Success!\n");
    }

    return 0;
}
