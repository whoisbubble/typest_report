#include "stm32f10x.h"
#include "delays.h"
#include "hardware.h"
#include "lcd_1602.h"

static volatile uint16_t adc_result = 0U;
static volatile uint8_t sample_ready = 0U;

static void LCD_Init_Module(void)
{
    Delay_ms(50U);

    LCD_Write_Command(0x30U);
    Delay_ms(5U);
    LCD_Write_Command(0x30U);
    Delay_ms(1U);
    LCD_Write_Command(0x30U);
    Delay_ms(1U);

    LCD_Write_Command(FUNCTION_SET | OPT_DL | OPT_N);
    LCD_Write_Command(CLEAR_DISPLAY);
    LCD_Write_Command(DISPLAY_ON_OFF_CONTROL | OPT_D);
    LCD_Write_Command(ENTRY_MODE_SET | OPT_ID);
}

static void LCD_Write_Line(uint8_t row, const char text[16])
{
    uint8_t i;

    LCD_Cursor(row, 0U);
    for (i = 0U; i < 16U; i++) {
        LCD_Write_Data((uint8_t)text[i]);
    }
}

static void LCD_Show_Voltage(uint16_t adc_code)
{
    uint32_t voltage_mv;
    char line[16] = "U=0.000 V       ";

    /* Rounding is added before division. Code 4095 is displayed as 3.300 V. */
    voltage_mv = (((uint32_t)adc_code * 3300U) + 2047U) / 4095U;

    line[2] = (char)('0' + (voltage_mv / 1000U));
    line[4] = (char)('0' + ((voltage_mv / 100U) % 10U));
    line[5] = (char)('0' + ((voltage_mv / 10U) % 10U));
    line[6] = (char)('0' + (voltage_mv % 10U));

    LCD_Write_Line(1U, line);
}

int main(void)
{
    uint16_t local_result;
    uint8_t update_display;
    static const char first_line[16] = "T=0.07s TIM3    ";

    Delay_Init();
    Ports_Init();
    ADC1_Init_Channel6();
    LCD_Init_Module();

    LCD_Write_Line(0U, first_line);
    LCD_Show_Voltage(0U);

    TIM3_Init_70ms();

    while (1) {
        update_display = 0U;

        __disable_irq();
        if (sample_ready != 0U) {
            local_result = adc_result;
            sample_ready = 0U;
            update_display = 1U;
        }
        __enable_irq();

        if (update_display != 0U) {
            LCD_Show_Voltage(local_result);
        }
    }
}

void TIM3_IRQHandler(void)
{
    if ((TIM3->SR & TIM_SR_UIF) != 0U) {
        TIM3->SR &= (uint16_t)~TIM_SR_UIF;
        ADC1->CR2 |= ADC_CR2_SWSTART;
    }
}

void ADC1_2_IRQHandler(void)
{
    if ((ADC1->SR & ADC_SR_EOC) != 0U) {
        adc_result = (uint16_t)ADC1->DR;
        sample_ready = 1U;
    }
}
