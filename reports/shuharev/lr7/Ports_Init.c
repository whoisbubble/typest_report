#include "stm32f10x.h"

void Ports_Init(void)
{
    /* Тактирование AFIO и портов A, B. */
    RCC->APB2ENR |= RCC_APB2ENR_AFIOEN |
                    RCC_APB2ENR_IOPAEN | RCC_APB2ENR_IOPBEN;

    /* Начальное состояние: разряды и сегменты погашены. */
    GPIOA->BRR = 0x0078u;
    GPIOA->BSRR = 0x0F00u;
    GPIOB->BSRR = 0xF000u;

    /* PA3..PA6: AN1..AN4; PA8..PA11: E,F,G,DP. */
    /* MODE=10, CNF=00: двухтактные выходы 2 МГц. */
    GPIOA->CRL = (GPIOA->CRL & ~0x0FFFF000u) | 0x02222000u;
    GPIOA->CRH = (GPIOA->CRH & ~0x0000FFFFu) | 0x00002222u;
    /* PB12..PB15: A,B,C,D. */
    GPIOB->CRH = (GPIOB->CRH & ~0xFFFF0000u) | 0x22220000u;

    /* PB0, PB1, PB11: цифровой вход без внутренней подтяжки.
       MODE=00, CNF=01. Подтяжка к 3,3 В находится на стенде. */
    GPIOB->CRL = (GPIOB->CRL & ~0x000000FFu) | 0x00000044u;
    GPIOB->CRH = (GPIOB->CRH & ~0x0000F000u) | 0x00004000u;
}
