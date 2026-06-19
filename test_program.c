#define DMEM_BASE ((volatile unsigned int *)0x00001000)
#define LED_ADDR  ((volatile unsigned int *)0x00002000)

/*
 * Delay value for FPGA LED visibility.
 * Increase it if LEDs change too quickly.
 * Decrease it if LEDs change too slowly.
 */
#ifndef DELAY_COUNT
#define DELAY_COUNT 1000000
#endif
static void led_write(unsigned int pattern)
{
    *LED_ADDR = pattern;
}

static void delay_visible(void)
{
    volatile unsigned int count;

    for (count = 0; count < DELAY_COUNT; count++) {
        /*
         * Empty loop used only to create a visible delay.
         * volatile prevents the compiler from removing the loop.
         */
    }
}

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

    /*
     * ==========================================================
     * Basic ALU instruction tests
     * ==========================================================
     */

    DMEM_BASE[0] = a + b;       /* Expected: 8 */
    DMEM_BASE[1] = a - b;       /* Expected: 2 */
    DMEM_BASE[2] = a & b;       /* Expected: 1 */
    DMEM_BASE[3] = a | b;       /* Expected: 7 */
    DMEM_BASE[4] = a ^ b;       /* Expected: 6 */
    DMEM_BASE[5] = a < b;       /* Expected: 0 */

    /*
     * ==========================================================
     * Load and store test
     * ==========================================================
     */

    DMEM_BASE[10] = 0xDEADBEEF;
    DMEM_BASE[20] = DMEM_BASE[10];

    /*
     * ==========================================================
     * Fibonacci test
     * ==========================================================
     */

    for (i = 0; i < 10; i++) {
        DMEM_BASE[30 + i] = fib_a;

        fib_next = fib_a + fib_b;
        fib_a = fib_b;
        fib_b = fib_next;
    }

    /*
     * ==========================================================
     * Sorting test
     * ==========================================================
     */

    arr[0] = 5;
    arr[1] = 4;
    arr[2] = 3;
    arr[3] = 2;
    arr[4] = 1;

    for (i = 0; i < 5; i++) {
        for (j = 0; j < (4 - i); j++) {
            if (arr[j] > arr[j + 1]) {
                temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }

    DMEM_BASE[50] = arr[0];     /* Expected: 1 */

    /*
     * All processor tests completed successfully.
     */
    led_write(0x55);

#ifdef FPGA_BUILD

    /*
     * ==========================================================
     * FPGA running LED pattern
     * ==========================================================
     *
     * The processor reaches this section only after completing
     * all arithmetic, memory, Fibonacci, and sorting operations.
     */

    delay_visible();

    while (1) {
        led_write(0x01);        /* 00001 */
        delay_visible();

        led_write(0x02);        /* 00010 */
        delay_visible();

        led_write(0x04);        /* 00100 */
        delay_visible();

        led_write(0x08);        /* 01000 */
        delay_visible();

        led_write(0x10);        /* 10000 */
        delay_visible();

        led_write(0x08);        /* 01000 */
        delay_visible();

        led_write(0x04);        /* 00100 */
        delay_visible();

        led_write(0x02);        /* 00010 */
        delay_visible();
    }

#else

    /*
     * Simulation mode:
     * Keep the final LED value at 0x55 so the self-checking
     * testbench can verify successful program completion.
     */
    while (1) {
    }

#endif
}
