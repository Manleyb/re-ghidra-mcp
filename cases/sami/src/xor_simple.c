#include <stdio.h>

int main() {
    unsigned char encoded[] = {
        0x70, 0x66, 0x60, 0x71, 0x66, 0x77, 0x00
    };

    unsigned char key = 0x23;

    for (int i = 0; i < 6; i++) {
        encoded[i] ^= key;
    }

    printf("Decoded: %s\n", encoded);

    return 0;
}
