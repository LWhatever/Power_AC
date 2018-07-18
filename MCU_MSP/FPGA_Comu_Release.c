#include "msp430.h"
#include "lcd_serial.h"
#include "BUS_FPGA.h"
#include "pid_delta.h"

int key_value;
int addata0,addata1,addata2,addata3;
double data0,data1,data2,data3;

double max_v = 0, MAX_V = 0, max_i = 0, MAX_I = 0;
double dealtV = 0;
int duty = 500, DutyCycle = 500, DutyCycleW = 500|0x8000;
int state = 0, last_state = 1, cnt = 0;
PID_DELTA pid;        //PID structure

double goal = 3.28, min_V = 2.05, max_V = 3.63;
int freq = 141;
double set_freq = 0;

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

void change_freq()
{
    switch(key_value)
    {
    case 0x11:
        set_freq = set_freq*10 + 1;break;
    case 0x12:
        set_freq = set_freq*10 + 2;break;
    case 0x14:
        set_freq = set_freq*10 + 3;break;
    case 0x21:
        set_freq = set_freq*10 + 4;break;
    case 0x22:
        set_freq = set_freq*10 + 5;break;
    case 0x24:
        set_freq = set_freq*10 + 6;break;
    case 0x41:
        set_freq = set_freq*10 + 7;break;
    case 0x42:
        set_freq = set_freq*10 + 8;break;
    case 0x44:
        set_freq = set_freq*10 + 9;break;
    case 0x82:
        set_freq = set_freq*10 + 0;break;
    default:break;
    }
    freq = (int)(set_freq * 3.3555);
}

void AD(void)
{
/*************************获取AD数据********************************/
    key_value = IORD(0,0);
    addata3 = IORD(0x10,0);
    addata0 = IORD(0x20,0);
    addata1 = IORD(0x30,0);
    addata2 = IORD(0x40,0);
    max_v = IORD(0x50,0);
    max_i = IORD(0x60,0);

    if(key_value == 0x18)
    {
        Lcd_Init();
        state = 1;
    }
    else if(key_value == 0x28)
    {
        state = 2;
        duty = 500;
    }
    else if(key_value == 0x48)
    {
        if(state == 4)
        {
            IOWR(0x10,0,freq);
            set_freq = 0;
            state = last_state;
        }
        else
        {
            last_state = state;
            state = 4;
        }
    }
/***************************转换**********************************///    data0 = addata0 * 0.001355 - 11.305;
//    DispDec57At(2,1*4,addata1,6);
    data0 = addata0 * 0.00135261 - 11.27494065;
    data1 = addata1 * 0.00135261 - 11.27494065;
    data2 = addata2 * 0.00135261 - 11.27494065;
    data3 = addata3 * 0.00135261 - 11.27494065;
    MAX_V = max_v * 0.00135261 - 11.27494065;
    MAX_I = max_i * 0.00135261 - 11.27494065;

/***************************保护**********************************/
    if((data0 >= max_V || data0 <= min_V)&&(state != 0))
    {
        state = 3;
    }

/***************************显示**********************************/
    DispHex57At(0,1*4,key_value,2);
    show(data0,1,1);
    show(data1,2,1);
    show(data2,3,1);
    DispFloat57At(3,14*4,MAX_I,3,2);
    show(data3,4,1);
    DispFloat57At(4,14*4,MAX_V,3,2);

}

void pidAdjust()
{
    dealtV = PidDeltaCal(&pid,data1);
    if( dealtV <= -3)
        duty = duty + 10;
    else if(dealtV >= 1)
        duty = 100;
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
    PidDeltaInit(&pid, goal, -0.3, 0.3, 1, 8, 0);
    _EINT();
    while(1);
}


#pragma vector=TIMER0_A0_VECTOR
__interrupt void TIMER0_A0_ISR(void)
{
    AD();
    //new
    DispDec57At(0,8*4,state,2);
    switch(state)
    {
    case 0:
        cnt++;
        if(cnt > 50000)
            state = 1;
        break;
    case 1:
        DutyCycle = 500;
        DispDec57At(6,8*4,DutyCycle,4);
        DutyCycleW = DutyCycle|0x8000;
        IOWR(0x10,0,DutyCycleW);
        break;
    case 2:
        pidAdjust();
        DutyCycle = duty;
        DispDec57At(6,8*4,DutyCycle,4);
        DutyCycleW = DutyCycle|0x8000;
        IOWR(0x10,0,DutyCycleW);
        break;
    case 3:
        DutyCycleW = DutyCycle|0x8000;
        IOWR(0x10,0,DutyCycleW);
        CS_ADDR = 0x20;
        SET_WR;
        break;
    case 4:
        change_freq();break;
    default:break;
    }
    //new end

//old start

//  pidAdjust();
//  DutyCycle = state==0?800:duty;
//  DispDec57At(6,8*4,DutyCycle,4);
//  DutyCycle = DutyCycle|0x8000;
//  IOWR(0x10,0,DutyCycle);

//old end

    TA0CCTL0 &= ~CCIFG;
}
