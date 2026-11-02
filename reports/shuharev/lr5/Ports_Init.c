#include "stm32f10x.h"
#include "delays.h"
#include "hardware.h"

void Ports_Init(void)
{
    RCC->APB2ENR |= RCC_APB2ENR_AFIOEN |
                    RCC_APB2ENR_IOPAEN |
                    RCC_APB2ENR_IOPBEN;
    (void)RCC->APB2ENR;

    /* PB3 and PB4 are released from JTAG. SWD on PA13 and PA14 remains active. */
    AFIO->MAPR = (AFIO->MAPR & ~AFIO_MAPR_SWJ_CFG) |
                 AFIO_MAPR_SWJ_CFG_JTAGDISABLE;

    /* PA6 (ADC1_IN6): analog input, MODE=00 and CNF=00. */
    GPIOA->CRL &= ~(0xFUL << 24);

    /* PB3..PB10, PB12 and PB13: general-purpose push-pull outputs, 2 MHz. */
    GPIOB->CRL = (GPIOB->CRL & 0x00000FFFUL) | 0x22222000UL;
    GPIOB->CRH = (GPIOB->CRH & ~0x00FF0FFFUL) | 0x00220222UL;

    /* Start with all LCD data and control lines at logic zero. */
    GPIOB->BSRR = ((uint32_t)0x37F8U << 16);
}

void ADC1_Init_Channel6(void)
{
    RCC->APB2ENR |= RCC_APB2ENR_ADC1EN;
    (void)RCC->APB2ENR;

    /* PCLK2 is 56 MHz. Division by 4 gives the permitted 14 MHz ADC clock. */
    RCC->CFGR = (RCC->CFGR & ~RCC_CFGR_ADCPRE) | RCC_CFGR_ADCPRE_DIV4;

    ADC1->CR1 = 0U;
    ADC1->CR2 = 0U;
    ADC1->SMPR1 = 0U;
    ADC1->SMPR2 = (ADC1->SMPR2 & ~ADC_SMPR2_SMP6) |
                  ADC_SMPR2_SMP6_0 |
                  ADC_SMPR2_SMP6_1 |
                  ADC_SMPR2_SMP6_2;
    ADC1->SQR1 &= ~ADC_SQR1_L;
    ADC1->SQR2 = 0U;
    ADC1->SQR3 = 6U;

    /* One regular conversion, software start, right-aligned result. */
    ADC1->CR1 = ADC_CR1_EOCIE;
    ADC1->CR2 = ADC_CR2_EXTSEL | ADC_CR2_EXTTRIG;

    ADC1->CR2 |= ADC_CR2_ADON;
    Delay_us(10U);

    ADC1->CR2 |= ADC_CR2_RSTCAL;
    while ((ADC1->CR2 & ADC_CR2_RSTCAL) != 0U) {
    }

    ADC1->CR2 |= ADC_CR2_CAL;
    while ((ADC1->CR2 & ADC_CR2_CAL) != 0U) {
    }

    NVIC_ClearPendingIRQ(ADC1_2_IRQn);
    NVIC_SetPriority(ADC1_2_IRQn, 1U);
    NVIC_EnableIRQ(ADC1_2_IRQn);
}

void TIM3_Init_70ms(void)
{
    RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;
    (void)RCC->APB1ENR;

    TIM3->CR1 = 0U;
    TIM3->PSC = 55999U;
    TIM3->ARR = 69U;
    TIM3->CNT = 0U;
    TIM3->EGR = TIM_EGR_UG;
    TIM3->SR = 0U;
    TIM3->DIER = TIM_DIER_UIE;

    NVIC_ClearPendingIRQ(TIM3_IRQn);
    NVIC_SetPriority(TIM3_IRQn, 2U);
    NVIC_EnableIRQ(TIM3_IRQn);

    TIM3->CR1 = TIM_CR1_CEN;
}
