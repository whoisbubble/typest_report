#ifndef DELAYS_H
#define DELAYS_H

#include "stm32f10x.h"

void Delay_Init(void);
void Delay_us(uint32_t time_us);
void Delay_ms(uint32_t time_ms);

#endif
