# sync_from_gps
Schematic, Verilog and bitfile to quickly build a $25 CPLD based 4 MHz clock generator synchronized from GPS 
with components from Aliexpress.

ATTENTION: this solution provides sync NOT BETTER THAN +-2Hz! (sorry for that :)  This design was intentional ) 
If you need better precision then first look if you can use TCXO (approx. 100 ppb). Generally, you can get 
+-1 Hz in this design if you carefully build generator or change its scheamtis, and rebuild bitfile as said 
in accompanying PDF.

Простой генератор тактовой частоты, синхронизируемый от GPS с точностью до нескольких Гц (ну, так себе, да)
на деталях с алиэкспресса.
