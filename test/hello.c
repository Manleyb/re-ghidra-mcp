/* Setup smoke test ONLY. Not one of the experiment cases.
 * Purpose: prove Gemini can call Ghidra MCP tools and get decompilation back. */
#include <stdio.h>
#include <string.h>

static unsigned int checksum(const char *s) {
    unsigned int h = 5381;
    while (*s) {
        h = ((h << 5) + h) + (unsigned char)*s++;
    }
    return h;
}

static int is_valid(const char *s) {
    return strlen(s) == 6 && checksum(s) % 7 == 3;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("usage: %s <word>\n", argv[0]);
        return 2;
    }
    if (is_valid(argv[1])) {
        printf("ok\n");
        return 0;
    }
    printf("nope\n");
    return 1;
}
