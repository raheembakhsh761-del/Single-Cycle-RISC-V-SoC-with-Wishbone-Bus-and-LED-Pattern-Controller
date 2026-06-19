#define DMEM_BASE ((volatile unsigned int *)0x00001000)
#define LED_ADDR  ((volatile unsigned int *)0x00002000)

void main(void)
{
    volatile int a = 5;
    volatile int b = 3;

    volatile unsigned int arr[5];

    unsigned int i;
    unsigned int j;
    unsigned int temp;

    unsigned int fib_a = 0;
    unsigned int fib_b = 1;
    unsigned int fib_next;

    DMEM_BASE[0] = a + b;
    DMEM_BASE[1] = a - b;
    DMEM_BASE[2] = a & b;
    DMEM_BASE[3] = a | b;
    DMEM_BASE[4] = a ^ b;
    DMEM_BASE[5] = a < b;

    DMEM_BASE[10] = 0xDEADBEEF;
    DMEM_BASE[20] = DMEM_BASE[10];

    for (i = 0; i < 10; i++) {
        DMEM_BASE[30 + i] = fib_a;

        fib_next = fib_a + fib_b;
        fib_a = fib_b;
        fib_b = fib_next;
    }

    arr[0] = 5;
    arr[1] = 4;
    arr[2] = 3;
    arr[3] = 2;
    arr[4] = 1;

    for (i = 0; i < 5; i++) {
        for (j = 0; j < 4 - i; j++) {
            if (arr[j] > arr[j + 1]) {
                temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }

    DMEM_BASE[50] = arr[0];

    *LED_ADDR = 0x55;

    while (1) {
    }
}
