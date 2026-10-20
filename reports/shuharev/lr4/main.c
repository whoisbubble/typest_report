#include "stm32f10x.h"
#include "delays.h"
#include "lcd_1602.h"

void Ports_Init(void);
unsigned char num = 0;
char str_0[] = "Chigirev Timur  ";
char str_1[] = "DVGUPS BOD41IST ";

int main(void)
{
    DelayInit();
    Ports_Init();
    Delay_ms(50);

    LCD_Write_Command(0x30);
    Delay_ms(5);
    LCD_Write_Command(0x30);
    Delay_ms(1);
    LCD_Write_Command(0x30);
    Delay_ms(1);

    LCD_Write_Command(FUNCTION_SET | OPT_DL | OPT_N);
    LCD_Write_Command(CLEAR_DISPLAY);
    LCD_Write_Command(DISPLAY_ON_OFF_CONTROL | OPT_D);
    LCD_Write_Command(ENTRY_MODE_SET | OPT_ID);

    LCD_Cursor(0, 0);
    for (num = 0; num <= 15; num++) {
        LCD_Write_Data(str_0[num]);
    }
    LCD_Cursor(1, 0);
    for (num = 0; num <= 15; num++) {
        LCD_Write_Data(str_1[num]);
    }
    while (1) { }
}
