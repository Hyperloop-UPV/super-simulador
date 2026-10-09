#include "stm32h723xx.h"
#include "simulator.h"

extern "C" void Board_init(void *mem)
{
#ifdef SIMULATOR
  Simulator_InitMemory(mem);
#else
  (void)mem;
#endif

  // anything here really...
}

extern "C" void Board_update(void)
{
  // do something here like toggle led or whatever?
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
