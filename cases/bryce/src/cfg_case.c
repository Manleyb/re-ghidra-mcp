/*
 * Bryce - Beta Case: Control-flow deobfuscation (baseline)
 *
 * This is the CLEAN reference source. The agent never sees this file.
 * The binary given to Ghidra is the Tigress-obfuscated build (Flatten + AddOpaque),
 * so its control flow is a flattened dispatcher with opaque (bogus) branches.
 *
 * evaluate() scans a short string with a small state machine and returns an int.
 * Ground truth = runtime output of the clean build (see expected/), per the beta rules.
 */
#include <stdio.h>

int evaluate(const char *s) {
    int state = 0;
    int streak = 0;
    long score = 0;
    for (int i = 0; s[i] != '\0'; i++) {
        char c = s[i];
        switch (state) {
            case 0: /* start: first digit seeds the score */
                if (c >= '0' && c <= '9') { score += c - '0'; streak = 1; state = 1; }
                else if (c == '-') { state = 2; }
                else if (c == '#') { state = 4; }
                else { state = 3; }
                break;
            case 1: /* accumulate: digits weighted by a growing streak */
                if (c == '+') { state = 0; }
                else if (c >= '0' && c <= '9') { score += (long)(c - '0') * (streak + 1); streak++; }
                else if (c == '*') { score *= 2; }
                else { state = 3; }
                break;
            case 2: /* subtract the next digit, then return to start */
                if (c >= '0' && c <= '9') { score -= c - '0'; }
                state = 0;
                break;
            case 4: /* skip a '#'...'#' comment span */
                if (c == '#') { state = 0; }
                break;
            default: /* error sink */
                return -1;
        }
    }
    if (state == 3) { return -1; }
    if (score < 0) { score = -score; }
    return (int)(score % 1000);
}

int main(int argc, char **argv) {
    if (argc != 2) { printf("usage: %s <expr>\n", argv[0]); return 2; }
    printf("%d\n", evaluate(argv[1]));
    return 0;
}
