`timescale 1ns / 1ps
//
// Стабилизатор тактовой частоты 4 МГц от импульса PPS с приёмника GPS
//
module main(
    input CLK,		// Вход подстраиваемой тактовой частоты от генератора VCXO
    input PPS,		// Вход PPS от GPS
    input BTN,		// Кнопка для отладки
    output LED1, // Индикатор импульсов PPS
    output LED2,
    output LED3,	// "Частота генератора МЕНЬШЕ 4 МГц"
    output LED4,	// "Частота генератора РАВНА 4 МГц +- 16 Гц"
    output LED5,	// "Частота генератора БОЛЬШЕ 4 МГц"
    output PWM,	// Выход подстройки частоты генератора VCXO
	 output DIAG  // Выход импульсов PWM для подсчёта осциллографом
    );
//reg[21:0] counter = 22'b0;
// Мы считаем счётчиком по кругу, он много раз переполнится. 
// Но когда досчитает до 4000000, то в нём будет примерно 256 
// (3906*1024 + 256 = 4000000). Если он недосчитал (частота 
// кварца меньше), то в счётчике будет от 768 через 0 до 256.
// Тогда надо повышать частоту. Если сосчитал слишком много, 
// то будет от 257 до 767. Если частота кварца слишком сильно 
// отличается то 4 МГц, то мы можем зацепиться за другую частоту!
reg[9:0] counter = 10'b0;   // 0...1023, счётчик бОльшей разрядности не лезет в CPLD XC2C64a
reg[9:0] pwmvalue = 10'b0;
reg oldpps = 1'b0;
reg pwmout = 1'b0;
reg[3:0] difference;
// Пока не было ни одного PPS, горят два красных диода
reg reg_led3 = 1; // Частота меньше 4 МГц - красный
reg reg_led4 = 0; // Частота почти равна 4 МГц - зелёный
reg reg_led5 = 1; // Частота больше 4 МГц - красный
	
reg reg_led1 = 0; // PPS - индикатор на плате dangerousprototypes.com
reg reg_led2 = 0; // Не используется
	
always @(posedge CLK)
	begin
		if(PPS == 1'b1 && oldpps == 1'b0)
			begin
				reg_led1 = ~reg_led1; // Инвертируем светодиод
				
				if(counter >= 10'd768 || counter < 10'd256) // Частота менее 4 МГц
					begin
					if(pwmvalue < 10'd1023)
						begin
							pwmvalue = pwmvalue + 1; // повышаем частоту
						end
					if(counter < (256-64) || counter >= 10'd768)
						difference = 4'hf;
					else
						difference = (256-counter)>>2;
						
					reg_led3 = 1; reg_led4 = 0; reg_led5 = 0;
					end

				if(counter >= 10'd256 && counter <= 10'd767) // Частота более 4 МГц
					begin
					if(pwmvalue > 10'd0)
						begin
							pwmvalue = pwmvalue - 1;
						end
					if(counter >= (256+64))
						difference = 4'hf;
					else
						difference = (counter-256)>>2 ;

					reg_led3 = 0; reg_led4 = 0; reg_led5 = 1;
					end
					
				if(difference < 2)  // Частота +- 4 Гц
					begin
					reg_led3 = 0; reg_led4 = 1; reg_led5 = 0;
					end

				counter = 10'b0;
			end
		else
			begin
				counter = counter + 1;	
			end
			
		// если нижние 10 бит счётчика больше pwmvalue, то на выход 0
		if(counter[9:0] > pwmvalue)
			pwmout = 1'b0;
		else
			pwmout = 1'b1;
			
		oldpps = PPS; // Сохраняем предыдущий PPS
		
		// Нажатие на кнопку - принудительный сброс PWM примерно в середину шкaлы
		if(BTN == 0)
			begin
				pwmvalue = 10'd512;					
				reg_led3 = 1; reg_led4 = 1; reg_led5 = 1;
			end

	end // @(posedge CLK)
	
	assign PWM = pwmout;
	assign LED1 = reg_led1;
	assign LED2 = counter[9];//reg_led2;
	assign LED3 = reg_led3;
	assign LED4 = reg_led4;
	assign LED5 = reg_led5;
	assign DIAG = CLK & pwmout;

endmodule
