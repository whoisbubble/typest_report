/* Лабораторная работа № 7. Цифровой секундомер. Вариант 7. */
#include "stm32f10x.h"
#include "delays.h"

void Clock_Init(void);
void Ports_Init(void);
void Interrupts_Init(void);
void TIM_Init(void);

/* Формат: M.SS.d (минуты, секунды, десятые доли секунды). */
#define START_MIN  9u
#define START_SEC  59u
#define START_TENTH 5u

/* Общий анод: 0 включает сегмент, 1 выключает. */
static const uint8_t numbers[10] = {
    0xC0, 0xF9, 0xA4, 0xB0, 0x99,
    0x92, 0x82, 0xF8, 0x80, 0x90
};

/* Четыре разряда, как в методическом пособии. */
static volatile uint8_t digit_1 = START_MIN;
static volatile uint8_t digit_2 = START_SEC / 10u;
static volatile uint8_t digit_3 = START_SEC % 10u;
static volatile uint8_t digit_4 = START_TENTH;

int main(void)
{
    uint8_t digits[4];
    uint8_t j, code;

    __disable_irq();
    Clock_Init();
    Ports_Init();
    DelayInit();
    TIM_Init();
    Interrupts_Init();
    __enable_irq();

    while (1)
    {
        /* Согласованная копия всех цифр на один кадр. */
        __disable_irq();
        digits[0] = digit_1;
        digits[1] = digit_2;
        digits[2] = digit_3;
        digits[3] = digit_4;
        __enable_irq();

        for (j = 0; j < 4; j++)
        {
            code = numbers[digits[j]];
            /* Точки после минут и целых секунд. */
            if (j == 0u || j == 2u)
                code &= 0x7Fu;

            GPIOA->BRR = 0x0078u;  // Погасить все разряды
            GPIOB->ODR = (GPIOB->ODR & 0x0FFFu)
                       | ((code & 0x0Fu) << 12);
            GPIOA->ODR = (GPIOA->ODR & 0xF0FFu)
                       | ((code & 0xF0u) << 4);
            GPIOA->BSRR = 1u << (j + 3u); // Включить ANj
            Delay_ms(2);
        }
    }
}

/* Прерывание TIM3: один шаг обратного отсчёта (0,5 с). */
void TIM3_IRQHandler(void)
{
    if ((TIM3->SR & TIM_SR_UIF) == 0u)
        return;
    TIM3->SR = 0u; // В данном проекте используется только UIF

    if (digit_1 || digit_2 || digit_3 || digit_4)
    {
        if (digit_4 >= 5u)
            digit_4 -= 5u; // Например 9.59.5 -> 9.59.0
        else
        {
            digit_4 = 5u;  // Заём одной целой секунды
            if (digit_3 > 0u)
                digit_3--;
            else
            {
                digit_3 = 9u;
                if (digit_2 > 0u)
                    digit_2--;
                else
                {
                    digit_2 = 5u;
                    digit_1--;
                }
            }
        }
    }

    /* При нуле отсчёт прекращается, индикация продолжается. */
    if (!(digit_1 || digit_2 || digit_3 || digit_4))
        TIM3->CR1 &= ~TIM_CR1_CEN;
}

/* SB0 (PB0): старт или продолжение отсчёта. */
void EXTI0_IRQHandler(void)
{
    if (EXTI->PR & (1u << 0))
    {
        EXTI->PR = 1u << 0; // Запись 1 сбрасывает флаг EXTI
        if (digit_1 || digit_2 || digit_3 || digit_4)
            TIM3->CR1 |= TIM_CR1_CEN;
    }
}

/* SB1 (PB1): остановка с сохранением фазы счётчика. */
void EXTI1_IRQHandler(void)
{
    if (EXTI->PR & (1u << 1))
    {
        EXTI->PR = 1u << 1;
        TIM3->CR1 &= ~TIM_CR1_CEN;
        /* Учесть уже состоявшееся переполнение, если оно было. */
        if (TIM3->SR & TIM_SR_UIF)
            TIM3_IRQHandler();
        NVIC_ClearPendingIRQ(TIM3_IRQn);
    }
}

/* SB2 (PB11): остановка и возврат к исходному времени. */
void EXTI15_10_IRQHandler(void)
{
    if (EXTI->PR & (1u << 11))
    {
        EXTI->PR = 1u << 11;
        TIM3->CR1 &= ~TIM_CR1_CEN;
        TIM3->EGR = TIM_EGR_UG; // Сброс CNT и предделителя
        TIM3->SR = 0u;
        NVIC_ClearPendingIRQ(TIM3_IRQn);
        digit_1 = START_MIN;
        digit_2 = START_SEC / 10u;
        digit_3 = START_SEC % 10u;
        digit_4 = START_TENTH;
    }
}
