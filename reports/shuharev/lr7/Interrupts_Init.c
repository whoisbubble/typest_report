#include "stm32f10x.h"

void Interrupts_Init(void)
{
    const uint32_t mask = (1u << 0) | (1u << 1) | (1u << 11);

    EXTI->IMR &= ~mask;
    /* Мультиплексоры: код порта B = 0001. */
    AFIO->EXTICR[0] = (AFIO->EXTICR[0] & ~0xFFu) | 0x11u;
    AFIO->EXTICR[2] = (AFIO->EXTICR[2] & ~0xF000u) | 0x1000u;

    /* В покое 1, при нажатии 0: прерывание по спаду. */
    EXTI->RTSR &= ~mask;
    EXTI->FTSR |= mask;
    EXTI->PR = mask;

    /* Одинаковый приоритет с TIM3: нет взаимного вытеснения. */
    NVIC_SetPriority(EXTI0_IRQn, 2u);
    NVIC_SetPriority(EXTI1_IRQn, 2u);
    NVIC_SetPriority(EXTI15_10_IRQn, 2u);
    NVIC_ClearPendingIRQ(EXTI0_IRQn);
    NVIC_ClearPendingIRQ(EXTI1_IRQn);
    NVIC_ClearPendingIRQ(EXTI15_10_IRQn);
    NVIC_EnableIRQ(EXTI0_IRQn);
    NVIC_EnableIRQ(EXTI1_IRQn);
    NVIC_EnableIRQ(EXTI15_10_IRQn);
    EXTI->IMR |= mask;
}
