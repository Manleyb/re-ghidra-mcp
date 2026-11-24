#include <stdio.h>

int main(void) {
    int input;

    printf("Enter a number: ");

    if (scanf("%d", &input) != 1) {
        puts("Invalid input");
        return 1;
    }

    if (input > 20 &&
        input < 100 &&
        input % 7 == 0 &&
        input % 2 != 0) {
        puts("Accepted");
    } else {
        puts("Rejected");
    }

    return 0;
}
