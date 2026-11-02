#include "delays.h"

static void Delay_Ticks(uint32_t ticks)
{
    uint32_t chunk;

    while (ticks != 0U) {
        chunk = ticks;
        if (chunk > (SysTick_LOAD_RELOAD_Msk + 1U)) {
            chunk = SysTick_LOAD_RELOAD_Msk + 1U;
        }

        SysTick->CTRL = 0U;
        SysTick->LOAD = chunk - 1U;
        SysTick->VAL = 0U;
        SysTick->CTRL = SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_ENABLE_Msk;

        while ((SysTick->CTRL & SysTick_CTRL_COUNTFLAG_Msk) == 0U) {
        }

        SysTick->CTRL = 0U;
        ticks -= chunk;
    }
}

void Delay_Init(void)
{
    SystemCoreClockUpdate();
    SysTick->CTRL = 0U;
    SysTick->LOAD = 0U;
    SysTick->VAL = 0U;
}

void Delay_us(uint32_t time_us)
{
    uint32_t ticks_per_us = SystemCoreClock / 1000000U;

    if ((time_us != 0U) && (ticks_per_us != 0U)) {
        Delay_Ticks(ticks_per_us * time_us);
    }
}

void Delay_ms(uint32_t time_ms)
{
    while (time_ms != 0U) {
        Delay_us(1000U);
        time_ms--;
    }
}
