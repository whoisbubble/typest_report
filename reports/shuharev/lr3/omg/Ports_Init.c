#include "stm32f10x.h"

void Ports_Init(void)
{
    SET_BIT(RCC->APB2ENR, RCC_APB2ENR_IOPAEN |
                            RCC_APB2ENR_IOPBEN |
                            RCC_APB2ENR_AFIOEN);

    CLEAR_BIT(AFIO->MAPR, AFIO_MAPR_SWJ_CFG);
    SET_BIT(AFIO->MAPR, AFIO_MAPR_SWJ_CFG_JTAGDISABLE);

    CLEAR_BIT(GPIOB->CRL, GPIO_CRL_MODE0 |
                            GPIO_CRL_CNF0);

    CLEAR_BIT(GPIOA->CRH, GPIO_CRH_MODE8 |
                            GPIO_CRH_CNF8 |
                            GPIO_CRH_MODE9 |
                            GPIO_CRH_CNF9 |
                            GPIO_CRH_MODE10 |
                            GPIO_CRH_CNF10 |
                            GPIO_CRH_MODE11 |
                            GPIO_CRH_CNF11);
    SET_BIT(GPIOA->CRH, GPIO_CRH_MODE8_1 |
                          GPIO_CRH_MODE9_1 |
                          GPIO_CRH_MODE10_1 |
                          GPIO_CRH_MODE11_1);

    CLEAR_BIT(GPIOB->CRL, GPIO_CRL_MODE3 |
                            GPIO_CRL_CNF3 |
                            GPIO_CRL_MODE4 |
                            GPIO_CRL_CNF4 |
                            GPIO_CRL_MODE5 |
                            GPIO_CRL_CNF5 |
                            GPIO_CRL_MODE6 |
                            GPIO_CRL_CNF6);
    SET_BIT(GPIOB->CRL, GPIO_CRL_MODE3_1 |
                          GPIO_CRL_MODE4_1 |
                          GPIO_CRL_MODE5_1 |
                          GPIO_CRL_MODE6_1);

    CLEAR_BIT(GPIOA->ODR, GPIO_ODR_ODR8 |
                            GPIO_ODR_ODR9 |
                            GPIO_ODR_ODR10 |
                            GPIO_ODR_ODR11);
    CLEAR_BIT(GPIOB->ODR, GPIO_ODR_ODR3 |
                            GPIO_ODR_ODR4 |
                            GPIO_ODR_ODR5 |
                            GPIO_ODR_ODR6);
}
