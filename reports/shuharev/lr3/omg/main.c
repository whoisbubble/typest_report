#include "stm32f10x.h"

void Ports_Init(void);
void ADC_Init(void);
uint16_t ADC_Read(void);

void LED_Output(uint8_t count)
{
    CLEAR_BIT(GPIOA->ODR, GPIO_ODR_ODR8 |
                            GPIO_ODR_ODR9 |
                            GPIO_ODR_ODR10 |
                            GPIO_ODR_ODR11);
    CLEAR_BIT(GPIOB->ODR, GPIO_ODR_ODR3 |
                            GPIO_ODR_ODR4 |
                            GPIO_ODR_ODR5 |
                            GPIO_ODR_ODR6);

    if (count >= 1U) SET_BIT(GPIOA->ODR, GPIO_ODR_ODR8);
    if (count >= 2U) SET_BIT(GPIOA->ODR, GPIO_ODR_ODR9);
    if (count >= 3U) SET_BIT(GPIOA->ODR, GPIO_ODR_ODR10);
    if (count >= 4U) SET_BIT(GPIOA->ODR, GPIO_ODR_ODR11);
    if (count >= 5U) SET_BIT(GPIOB->ODR, GPIO_ODR_ODR3);
    if (count >= 6U) SET_BIT(GPIOB->ODR, GPIO_ODR_ODR4);
    if (count >= 7U) SET_BIT(GPIOB->ODR, GPIO_ODR_ODR5);
    if (count >= 8U) SET_BIT(GPIOB->ODR, GPIO_ODR_ODR6);
}

int main(void)
{
    uint16_t adc_value;
    uint8_t leds;

    Ports_Init();
    ADC_Init();

    while (1) {
        adc_value = ADC_Read();
        leds = (uint8_t)(((uint32_t)adc_value * 8U) / 4095U);
        LED_Output(leds);
    }
}
