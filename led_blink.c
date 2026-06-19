#define LED_ADDR ((volatile unsigned int *)0x00002000)

#define DELAY_COUNT 1000000

static void led_write(unsigned int pattern)
{
    *LED_ADDR = pattern;
}

static void delay(void)
{
    volatile unsigned int i;

    for (i = 0; i < DELAY_COUNT; i++) {
    }
}

void main(void)
{
    while (1) {
        led_write(0x01);
        delay();

        led_write(0x02);
        delay();

        led_write(0x04);
        delay();

        led_write(0x08);
        delay();

        led_write(0x10);
        delay();
    }
}
