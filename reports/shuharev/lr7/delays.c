#include "delays.h"

/* SysTick: один тик = 10 мкс. volatile обязателен для ISR. */
static volatile uint32_t left_ticks;

void DelayInit(void)
{
    SystemCoreClockUpdate();
    SysTick_Config(SystemCoreClock / 100000u);
    /* Прерывания кнопок и TIM3 имеют более высокий приоритет. */
    NVIC_SetPriority(SysTick_IRQn, 3u);
}

void Delay_us(uint16_t time_us)
{
    /* Округление до целого числа тиков (разрешение 10 мкс). */
    left_ticks = ((uint32_t)time_us + 9u) / 10u;
    while (left_ticks != 0u) {}
}

void Delay_ms(uint16_t time_ms)
{
    left_ticks = (uint32_t)time_ms * 100u;
    while (left_ticks != 0u) {}
}

void SysTick_Handler(void)
{
    if (left_ticks != 0u)
        left_ticks--;
}
