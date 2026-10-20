#include "stm32f10x.h"

void ADC_Init(void)
{
    volatile uint32_t i;

    SET_BIT(RCC->APB2ENR, RCC_APB2ENR_ADC1EN);
    CLEAR_BIT(RCC->CFGR, RCC_CFGR_ADCPRE);
    SET_BIT(RCC->CFGR, RCC_CFGR_ADCPRE_DIV6);

    CLEAR_BIT(ADC1->CR1, ADC_CR1_SCAN);
    CLEAR_BIT(ADC1->CR2, ADC_CR2_CONT |
                          ADC_CR2_ALIGN |
                          ADC_CR2_EXTSEL);
    SET_BIT(ADC1->CR2, ADC_CR2_EXTSEL |
                        ADC_CR2_EXTTRIG);

    CLEAR_BIT(ADC1->SQR1, ADC_SQR1_L);
    CLEAR_BIT(ADC1->SQR3, ADC_SQR3_SQ1);
    SET_BIT(ADC1->SQR3, ADC_SQR3_SQ1_3);

    CLEAR_BIT(ADC1->SMPR2, ADC_SMPR2_SMP8);
    SET_BIT(ADC1->SMPR2, ADC_SMPR2_SMP8_2 |
                         ADC_SMPR2_SMP8_1 |
                         ADC_SMPR2_SMP8_0);

    SET_BIT(ADC1->CR2, ADC_CR2_ADON);
    for (i = 0U; i < 10000U; i++) {
    }

    SET_BIT(ADC1->CR2, ADC_CR2_RSTCAL);
    while (READ_BIT(ADC1->CR2, ADC_CR2_RSTCAL) != 0U) {
    }

    SET_BIT(ADC1->CR2, ADC_CR2_CAL);
    while (READ_BIT(ADC1->CR2, ADC_CR2_CAL) != 0U) {
    }
}

uint16_t ADC_Read(void)
{
    SET_BIT(ADC1->CR2, ADC_CR2_SWSTART);

    while (READ_BIT(ADC1->SR, ADC_SR_EOC) == 0U) {
    }

    return (uint16_t)READ_REG(ADC1->DR);
}
