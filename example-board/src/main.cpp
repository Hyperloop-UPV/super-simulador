#include "stm32h723xx.h"

//#include "simulator.h"
#include "simulator.c"

void init_systick(void)
{
  SysTick->CTRL &= ~SysTick_CTRL_CLKSOURCE_Msk;

  // assume CALIB is correct
  SysTick->LOAD = SysTick->CALIB*100;

  SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk;

  SysTick->VAL = 0;
  SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk;
}

extern "C" void Board_init(void *mem)
{
#ifdef SIMULATOR_BUILD
  Simulator_InitMemory(mem);
#else
  (void)mem;
#endif

  // anything here really...
  static constexpr uint32_t pin = 0;
  static constexpr uint32_t portletter = 'B';

  RCC->AHB4ENR |= 1 << (portletter - 'A');
  GPIOB->MODER |= 1 << (pin * 2);

  GPIOB->BSRR |= GPIO_BSRR_BS0 << pin;

  //for(volatile uint32_t i = 0; i < 1000'000; i++) {}

  GPIOB->BSRR |= GPIO_BSRR_BR0 << pin;

  init_systick();
}

extern "C" void Board_update(void)
{
  // do something here like toggle led or whatever?
}

void toggle_led(void)
{
  static bool is_on = false;
  if(is_on) {
    GPIOB->BSRR |= GPIO_BSRR_BR0;
  } else {
    GPIOB->BSRR |= GPIO_BSRR_BS0;
  }
  is_on = !is_on;
}

#ifdef SIMULATOR_BUILD
#include "stdio.h"
#endif

extern "C" void SysTick_Handler(void)
{
  toggle_led();
}

#ifndef SIMULATOR_BUILD
int main()
{
  Board_init(0);

  for(;;) {
    Board_update();
  }
}
#endif
