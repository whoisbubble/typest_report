#include "stm32f10x.h"                      // Подключение библиотеки МК

/*------------------------------------------------------------------------------
                       Инициализация портов ввода-вывода
    PA3..PA6   - разряды AN1..AN4
    PA8..PA11  - сегменты E, F, G, DP
    PB12..PB15 - сегменты A, B, C, D
    Все выводы - двухтактные выходы 2 МГц: MODE = 10, CNF = 00
------------------------------------------------------------------------------*/
void Ports_Init(void)
{
    RCC->APB2ENR |= RCC_APB2ENR_IOPAEN | RCC_APB2ENR_IOPBEN;  // Тактирование портов A и B

    // Начальное состояние - индикатор погашен:
    // сегменты = 1 (не светятся), разряды = 0 (ключи закрыты)
    GPIOB->BSRR = GPIO_BSRR_BS12 | GPIO_BSRR_BS13 | GPIO_BSRR_BS14 | GPIO_BSRR_BS15;
    GPIOA->BSRR = GPIO_BSRR_BS8  | GPIO_BSRR_BS9  | GPIO_BSRR_BS10 | GPIO_BSRR_BS11;
    GPIOA->BRR  = GPIO_BRR_BR3   | GPIO_BRR_BR4   | GPIO_BRR_BR5   | GPIO_BRR_BR6;

    // PA3..PA6 - регистр CRL (выводы 0..7)
    GPIOA->CRL &= ~(GPIO_CRL_MODE3 | GPIO_CRL_CNF3 | GPIO_CRL_MODE4 | GPIO_CRL_CNF4 |
                    GPIO_CRL_MODE5 | GPIO_CRL_CNF5 | GPIO_CRL_MODE6 | GPIO_CRL_CNF6);
    GPIOA->CRL |=  (GPIO_CRL_MODE3_1 | GPIO_CRL_MODE4_1 | GPIO_CRL_MODE5_1 | GPIO_CRL_MODE6_1);

    // PA8..PA11 - регистр CRH (выводы 8..15)
    GPIOA->CRH &= ~(GPIO_CRH_MODE8  | GPIO_CRH_CNF8  | GPIO_CRH_MODE9  | GPIO_CRH_CNF9  |
                    GPIO_CRH_MODE10 | GPIO_CRH_CNF10 | GPIO_CRH_MODE11 | GPIO_CRH_CNF11);
    GPIOA->CRH |=  (GPIO_CRH_MODE8_1 | GPIO_CRH_MODE9_1 | GPIO_CRH_MODE10_1 | GPIO_CRH_MODE11_1);

    // PB12..PB15 - регистр CRH (выводы 8..15)
    GPIOB->CRH &= ~(GPIO_CRH_MODE12 | GPIO_CRH_CNF12 | GPIO_CRH_MODE13 | GPIO_CRH_CNF13 |
                    GPIO_CRH_MODE14 | GPIO_CRH_CNF14 | GPIO_CRH_MODE15 | GPIO_CRH_CNF15);
    GPIOB->CRH |=  (GPIO_CRH_MODE12_1 | GPIO_CRH_MODE13_1 | GPIO_CRH_MODE14_1 | GPIO_CRH_MODE15_1);
}
