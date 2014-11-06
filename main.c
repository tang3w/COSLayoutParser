#include "common.h"

int main(int argc, char **argv) {
    void *scanner;

    cslayoutlex_init(&scanner);

    int result = (cslayoutparse(scanner));

    cslayoutlex_destroy(scanner);

    if (!result) fprintf(stdout, "Success!\n");

    return result;
}
