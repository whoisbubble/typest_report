#include "lcd_1602.h"
#include "delays.h"

void LCD_Write(uint8_t data)
{
    uint32_t sent;
    LCD_Reset_E;
    sent = ((uint32_t)data << 3) | (GPIOB->ODR & 0xF807U);
    GPIOB->ODR = sent;
    Delay_us(2);
    LCD_Set_E;
    Delay_ms(1);
    LCD_Reset_E;
    Delay_ms(1);
}

void LCD_Write_Command(uint8_t command)
{
    LCD_Reset_RS;
    LCD_Write(command);
    if (command == CLEAR_DISPLAY || (command & 0xFEU) == RETURN_HOME) {
        Delay_ms(3);
    }
}

void LCD_Write_Data(uint8_t data)
{
    LCD_Set_RS;
    LCD_Write(data);
}

void LCD_Cursor(uint8_t row, uint8_t col)
{
    const uint8_t start[] = {0x00, 0x40};
    if (row < 2U && col < 16U) {
        LCD_Write_Command(SET_DDRAM_ADDR + start[row] + col);
    }
}
