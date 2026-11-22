#include <stdio.h>
#include <stdlib.h>

__attribute__((noinline))
static int assess_login_risk(int failed_attempts, int minutes_since_failure,
                             int trusted_device) {
    if (failed_attempts < 0 || minutes_since_failure < 0 ||
        (trusted_device != 0 && trusted_device != 1))
        return -1;

    if (failed_attempts >= 5 ||
        (failed_attempts >= 3 && minutes_since_failure <= 10))
        return 2;

    if (failed_attempts >= 2 && trusted_device == 0)
        return 1;

    return 0;
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <int> <int> <int>\n", argv[0]);
        return 64;
    }
    char *end;
    long values[3];
    for (int i = 0; i < 3; ++i) {
        values[i] = strtol(argv[i+1], &end, 10);
        if (*end != '\0' || end == argv[i+1] || values[i] < -100000 ||
            values[i] > 100000) {
            fprintf(stderr, "Invalid integer argument\n");
            return 65;
        }
    }
    int result = assess_login_risk((int)values[0], (int)values[1], (int)values[2]);
    printf("%d\n", result);
    return 0;
}
