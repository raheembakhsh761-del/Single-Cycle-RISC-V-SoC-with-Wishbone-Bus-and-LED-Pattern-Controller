#define DMEM8  ((volatile unsigned char *)0x00001000)
#define DMEM16 ((volatile unsigned short *)0x00001000)
#define DMEM32 ((volatile unsigned int *)0x00001000)
#define LED_ADDR ((volatile unsigned int *)0x00002000)

void main(void)
{
    volatile signed char *signed8;
    volatile signed short *signed16;

    signed8 = (volatile signed char *)0x00001000;
    signed16 = (volatile signed short *)0x00001000;

    DMEM32[0] = 0;

    DMEM8[0] = 0x11;
    DMEM8[1] = 0x22;
    DMEM8[2] = 0x83;
    DMEM8[3] = 0x44;

    DMEM32[10] = DMEM8[0];
    DMEM32[11] = DMEM8[1];
    DMEM32[12] = DMEM8[2];
    DMEM32[13] = (unsigned int)signed8[2];

    DMEM16[2] = 0x5566;
    DMEM16[3] = 0x8777;

    DMEM32[14] = DMEM16[2];
    DMEM32[15] = DMEM16[3];
    DMEM32[16] = (unsigned int)signed16[3];

    *LED_ADDR = 0x55;

    while (1) {
    }
}
