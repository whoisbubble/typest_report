#ifndef LCD_1602_H
#define LCD_1602_H
#include "stm32f10x.h"

#define FUNCTION_SET            0x20U
#define OPT_DL                  0x10U
#define OPT_N                   0x08U
#define CLEAR_DISPLAY           0x01U
#define RETURN_HOME             0x02U
#define DISPLAY_ON_OFF_CONTROL  0x08U
#define OPT_D                   0x04U
#define ENTRY_MODE_SET          0x04U
#define OPT_ID                  0x02U
#define SET_DDRAM_ADDR          0x80U

#define LCD_Set_E    (GPIOB->BSRR = 1UL << 13)
#define LCD_Reset_E  (GPIOB->BSRR = 1UL << 29)
#define LCD_Set_RS   (GPIOB->BSRR = 1UL << 12)
#define LCD_Reset_RS (GPIOB->BSRR = 1UL << 28)

void LCD_Write(uint8_t data);
void LCD_Write_Command(uint8_t command);
void LCD_Write_Data(uint8_t data);
void LCD_Cursor(uint8_t row, uint8_t col);
#endif
