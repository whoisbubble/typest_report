#include "lcd_1602.h"
#include "delays.h"

static const uint8_t row_address[2] = {0x00U, 0x40U};

void LCD_Write(uint8_t data)
{
    uint32_t output;

    output = (GPIOB->ODR & 0xF807U) | ((uint32_t)data << 3);
    GPIOB->ODR = output;

    LCD_Set_E();
    Delay_us(1U);
    LCD_Reset_E();
    Delay_us(50U);

    GPIOB->ODR &= 0xF807U;
}

void LCD_Write_Command(uint8_t command)
{
    LCD_Reset_RS();
    LCD_Write(command);

    if ((command == CLEAR_DISPLAY) || (command == RETURN_HOME)) {
        Delay_ms(2U);
    }
}

void LCD_Write_Data(uint8_t data)
{
    LCD_Set_RS();
    LCD_Write(data);
}

void LCD_Cursor(uint8_t row, uint8_t col)
{
    if (row > 1U) {
        row = 1U;
    }
    if (col > 15U) {
        col = 15U;
    }

    LCD_Write_Command((uint8_t)(SET_DDRAM_ADDR + row_address[row] + col));
}
