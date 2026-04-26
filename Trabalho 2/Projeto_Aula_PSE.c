// Conexoes LCD (modo 4 bits em PORTB)
sbit LCD_RS at RB2_bit;
sbit LCD_EN at RB3_bit;
sbit LCD_D4 at RB4_bit;
sbit LCD_D5 at RB5_bit;
sbit LCD_D6 at RB6_bit;
sbit LCD_D7 at RB7_bit;
sbit LCD_RS_Direction at TRISB2_bit;
sbit LCD_EN_Direction at TRISB3_bit;
sbit LCD_D4_Direction at TRISB4_bit;
sbit LCD_D5_Direction at TRISB5_bit;
sbit LCD_D6_Direction at TRISB6_bit;
sbit LCD_D7_Direction at TRISB7_bit;

unsigned short beb, tam;

void esperaSoltar() {
   while (!RB0_bit || !RB1_bit);
   Delay_ms(150);
}

unsigned short botao() {
   esperaSoltar();
   for (;;) {
      if (!RB0_bit) { esperaSoltar(); return 0; }
      if (!RB1_bit) { esperaSoltar(); return 1; }
   }
}

void greetUser() {
   Lcd_Cmd(_LCD_CLEAR);
   Lcd_Out(1, 4, "Maquina de");
   Lcd_Out(2, 7, "Chopp");
   Delay_ms(5000);
}

void selectBeverage() {
   beb = 0;
   for (;;) {
      Lcd_Cmd(_LCD_CLEAR);
      Lcd_Out(1, 1, "Bebida:");
      switch (beb) {
         case 0: Lcd_Out(2, 1, "1-Chopp");    break;
         case 1: Lcd_Out(2, 1, "2-Coca");  break;
         case 2: Lcd_Out(2, 1, "3-Guarana");    break;
         case 3: Lcd_Out(2, 1, "4-Suco");  break;
      }
      if (botao()) return;
      beb++;
      if (beb > 3) beb = 0;
   }
}

void selectSize() {
   tam = 0;
   for (;;) {
      Lcd_Cmd(_LCD_CLEAR);
      Lcd_Out(1, 1, "Tamanho:");
      switch (tam) {
         case 0: Lcd_Out(2, 1, "Pequena 3s"); break;
         case 1: Lcd_Out(2, 1, "Media 5s");   break;
         case 2: Lcd_Out(2, 1, "Grande 7s");  break;
      }
      if (botao()) return;
      tam++;
      if (tam > 2) tam = 0;
   }
}

void main() {
   CMCON  = 0x07;
   TRISA  = 0x00;
   TRISB  = 0x03;
   PORTA  = 0x00;
   OPTION_REG.NOT_RBPU = 0;

   Delay_ms(200);
   Lcd_Init();
   Lcd_Cmd(_LCD_CURSOR_OFF);

   while (1) {
      greetUser();
      selectBeverage();
      selectSize();

      Lcd_Cmd(_LCD_CLEAR);
      Lcd_Out(1, 1, "Servindo...");
      PORTA = (1 << beb);
      switch (tam) {
         case 0: Delay_ms(3000); break;
         case 1: Delay_ms(5000); break;
         case 2: Delay_ms(7000); break;
      }
      PORTA = 0x00;

      Lcd_Cmd(_LCD_CLEAR);
      Lcd_Out(1, 1, "Pronto!");
      Lcd_Out(2, 1, "Retire bebida");
      Delay_ms(2000);
   }
}