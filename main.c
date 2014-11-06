#include "common.h"

int main(int argc, char **argv) {
    if(!cs_layout_parse()) {
        fprintf(stdout, "Success!\n");
    }

    return 0;
}
