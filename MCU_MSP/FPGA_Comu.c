#include "msp430.h"
#include "lcd_serial.h"
#include "BUS_FPGA.h"
#include "pid_delta.h"

double key_value;
int addata0,addata1,addata2,addata3;
double data0,data1,data2,data3;

double max = 0, MAX = 0;
double goal = 3.59, dealtV = 0;
int duty = 800, DutyCycle = 0;
int state = 0;
PID_DELTA pid;        //PID structure



void show(double data, unsigned char x, unsigned char y)
{
	unsigned char y1 = y-1;
	if(data<0)
	{
		DispString57At(x,y1*4,"-");
		DispFloat57At(x,y*4,-data,3,2);
	}
	else
	{
		DispString57At(x,y1*4," ");
		DispFloat57At(x,y*4,data,3,2);
	}
}

void Timer_Init()
{
	TA0CCR0 = 224;
	TA0CTL |= MC_1 + TASSEL_2 + TACLR;
	TA0CCTL0 = CCIE;
}

void AD(void)
{
/*************************获取AD数据********************************/
	key_value = IORD(0,0);
	addata3 = IORD(0x10,0);
	addata0 = IORD(0x20,0);
	addata1 = IORD(0x30,0);
	addata2 = IORD(0x40,0);
	max = IORD(0x50,0);

	if(key_value == 0x11)
	    state = 0;
	else if(key_value == 0x12)
	    state = 1;
/***************************转换**********************************/
	data0 = addata0 * 0.001355 - 11.305;
	data1 = addata1 * 0.001355 - 11.305;
	data2 = addata2 * 0.001355 - 11.305;
	data3 = addata3 * 0.001355 - 11.305;
	MAX = max * 0.001355 - 11.305;

/***************************显示**********************************/
	DispHex57At(0,1*4,key_value,2);
	show(data0,1,1);
	show(data1,2,1);
	show(data2,3,1);
	show(data3,4,1);
	DispFloat57At(4,14*4,MAX,3,2);

}

void pidAdjust()
{
    dealtV = PidDeltaCal(&pid,data1);
    if( dealtV <= -3.55)
        duty = duty + 10;
    else if(dealtV >= 7.1)
        duty = 0;
    else
        duty = duty + dealtV*10;
    DispFloat57At(5,1*4,dealtV,3,9);
    DispDec57At(6,1*4,duty,4);

}

void main( void )
{
	WDTCTL = WDTPW + WDTHOLD;
	P1REN |= BIT0;
	P1OUT |= BIT0;
	P1DIR |= ~BIT0;

	BUS_Init();
	Lcd_Init();
	Timer_Init();
	PidDeltaInit(&pid, goal, -0.3, 0.3, 1, 1.5, 0);
	_EINT();
	while(1);
}


#pragma vector=TIMER0_A0_VECTOR
__interrupt void TIMER0_A0_ISR(void)
{
	AD();
	pidAdjust();
	DutyCycle = state==0?800:duty;
	DispDec57At(6,8*4,DutyCycle,4);
	DutyCycle = DutyCycle|0x8000;
	IOWR(0x10,0,DutyCycle);
	TA0CCTL0 &= ~CCIFG;
}
