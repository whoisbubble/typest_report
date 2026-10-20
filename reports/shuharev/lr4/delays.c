#include "delays.h"

volatile uint16_t left_us;
uint16_t left_ms;

void DelayInit(void)
{
    SystemCoreClockUpdate();
    if (SysTick_Config(SystemCoreClock / 1000000U) != 0U) {
        while (1) { }
    }
}

void Delay_us(uint16_t time_us)
{
    left_us = time_us;
    while (left_us != 0) { }
}

void Delay_ms(uint16_t time_ms)
{
    left_ms = time_ms;
    while (left_ms != 0) {
        Delay_us(1000);
        left_ms--;
    }
}

void SysTick_Handler(void)
{
    if (left_us) {
        left_us--;
    }
}
