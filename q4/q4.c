#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

void build_lib_name(char *dest, const char *op) {
    strcpy(dest, "./lib");
    strcat(dest, op);
    strcat(dest, ".so");
}

int main() {
    char operation[6];
    int x, y;

    while (1) {
        if (scanf("%5s %d %d", operation, &x, &y) != 3)
            break;

        char library[32];
        build_lib_name(library, operation);
        void *lib_handle = dlopen(library, RTLD_NOW);
        if (!lib_handle) {
            fprintf(stderr, "Cannot open %s\n", library);
            continue;
        }
        int (*op_func)(int, int) = NULL;
        op_func = (int (*)(int, int)) dlsym(lib_handle, operation);

        if (!op_func) {
            fprintf(stderr, "Function %s not found\n", operation);
            dlclose(lib_handle);
            continue;
        }

        
        int ans = op_func(x, y);
        printf("%d\n", ans);
        dlclose(lib_handle);
    }

    return 0;
}