#include "stm32f10x.h"

void Ports_Init(void)
{
    RCC->APB2ENR |= RCC_APB2ENR_AFIOEN | RCC_APB2ENR_IOPBEN;
    (void)RCC->APB2ENR;
    // No other AFIO remapping is used. Keep SWD, disable JTAG.
    AFIO->MAPR = AFIO_MAPR_SWJ_CFG_JTAGDISABLE;
    GPIOB->BSRR = 0x37F8UL << 16;

    // PB3..PB10, PB12, PB13: push-pull outputs, 2 MHz.
    // Preserve the configuration of unrelated pins.
    GPIOB->CRL = (GPIOB->CRL & 0x00000FFFUL) | 0x22222000UL;
    GPIOB->CRH = (GPIOB->CRH & ~0x00FF0FFFUL) | 0x00220222UL;
}
