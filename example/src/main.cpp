#include "stm32h723xx.h"

//#include "simulator.h"
#include "simulator.c"

extern "C" void Board_init(void *mem)
{
#ifdef SIMULATOR
  Simulator_InitMemory(mem);
#else
  (void)mem;
#endif

  // anything here really...

  SysTick->CTRL &= ~SysTick_CTRL_CLKSOURCE_Msk;

  // 100Hz, assume CALIB is correct
  SysTick->LOAD = SysTick->CALIB*10000;

  SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk;

  SysTick->VAL = 0;
  SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk;
}

extern "C" void Board_update(void)
{
  // do something here like toggle led or whatever?
}

#ifdef SIMULATOR
#include "stdio.h"
#endif


extern "C" void SysTick_Handler(void)
{
  // TODO: Toggle led here

#ifdef SIMULATOR
  static uint64_t n = 0;
  printf("[%llu] Systick handler got called!\n", n);
  n++;
#endif

}

#ifndef SIMULATOR
int main()
{
  Board_init(0);

  for(;;) {
    Board_update();
  }
}
#endif
