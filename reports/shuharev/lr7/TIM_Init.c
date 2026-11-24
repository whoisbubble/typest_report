#include "stm32f10x.h"

/* HSE = 8 МГц, PLL x7. APB1 = 28 МГц, TIM3 = 56 МГц. */
void Clock_Init(void)
{
    RCC->CR |= RCC_CR_HSION;
    while (!(RCC->CR & RCC_CR_HSIRDY)) {}
    RCC->CFGR &= ~RCC_CFGR_SW;
    while (RCC->CFGR & RCC_CFGR_SWS) {}
    RCC->CR &= ~RCC_CR_PLLON;
    while (RCC->CR & RCC_CR_PLLRDY) {}

    FLASH->ACR = (FLASH->ACR & ~7u) | 2u | (1u << 4);
    RCC->CR |= RCC_CR_HSEON;
    while (!(RCC->CR & RCC_CR_HSERDY)) {}

    /* AHB /1, APB1 /2, APB2 /1, ADC /6, HSE x7. */
    RCC->CFGR &= ~0x003FFFF0u;
    RCC->CFGR |= (4u << 8) | (2u << 14) | (1u << 16) | (5u << 18);
    RCC->CR |= RCC_CR_PLLON;
    while (!(RCC->CR & RCC_CR_PLLRDY)) {}
    RCC->CFGR = (RCC->CFGR & ~RCC_CFGR_SW) | 2u;
    while ((RCC->CFGR & RCC_CFGR_SWS) != (2u << 2)) {}
    SystemCoreClockUpdate();
}

void TIM_Init(void)
{
    RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;

    /* URS: запрос прерывания только при переполнении. CEN=0. */
    TIM3->CR1 = TIM_CR1_URS;
    TIM3->DIER = 0u;
    TIM3->PSC = 2799u; // 56 МГц / 2800 = 20 кГц
    TIM3->ARR = 9999u; // 10000 / 20000 = 0,5 с
    TIM3->EGR = TIM_EGR_UG; // Загрузить PSC, сбросить CNT
    TIM3->SR = 0u;
    TIM3->DIER = TIM_DIER_UIE;

    NVIC_SetPriority(TIM3_IRQn, 2u);
    NVIC_ClearPendingIRQ(TIM3_IRQn);
    NVIC_EnableIRQ(TIM3_IRQn);
    /* Запуск производится только по кнопке SB0. */
}
