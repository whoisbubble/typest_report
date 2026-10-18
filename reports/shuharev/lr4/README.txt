ЛР №4. Отчёт и исходные файлы

report.typ - исходник отчёта; report.pdf - результат экспорта.
template.typ - шаблон оформления.
main.c, Ports_Init.c, delays.h/.c, lcd_1602.h/.c - код из отчёта.
Листинги отчёта читаются прямо из этих файлов: изменения кода попадут в PDF
при следующем экспорте.

Фотографии: положить stand.jpg и lcd.jpg рядом с report.typ,
в начале report.typ изменить include-photos = false на include-photos = true.
Экспорт: typst compile report.typ report.pdf

Файлы C предназначены для добавления в учебный проект Keil STM32F103C8T6.
Нужны stm32f10x.h/CMSIS, startup и system_stm32f10x.c из пакета устройства.
Задержки используют прерывания SysTick: проверить настройку ядра 72 МГц,
не добавлять второй SysTick_Handler. Это не готовая прошивка и не отдельный
самодостаточный проект .uvprojx. Сборка C и запуск на стенде не проверялись.
