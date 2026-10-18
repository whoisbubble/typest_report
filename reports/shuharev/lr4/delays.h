#ifndef DELAYS_H
#define DELAYS_H
#include "stm32f10x.h"

void DelayInit(void);
void Delay_us(uint16_t time_us);
void Delay_ms(uint16_t time_ms);
#endif
