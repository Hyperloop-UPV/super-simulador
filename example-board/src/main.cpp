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

void start_gpio_allpins(GPIO_TypeDef *gpio, char letter)
{
  RCC->AHB4ENR |= 1 << (letter - 'A');
  gpio->MODER |= 0b0101'0101'0101'0101'0101'0101'0101'0101;
}

extern "C" void Board_init(void *mem)
{
#ifdef SIMULATOR_BUILD
  Simulator_InitMemory(mem);
#else
  (void)mem;
#endif

  //static constexpr uint32_t pin = 0;
  //static constexpr uint32_t portletter = 'B';

  start_gpio_allpins(GPIOB, 'B');
  //RCC->AHB4ENR |= 1 << (portletter - 'A');
  //GPIOB->MODER |= 1 << (pin * 2);

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

uint32_t RNG_seed_parkmiller(uint32_t val)
{
  // seed must be coprime of 0x7FFF'FFFF
  // and also not be 0
  if(val == 0) val++;
  else val %= 0x7FFFFFFF;

  return val;
}

uint32_t RNG_lcg_parkmiller(uint32_t *state)
{
  // 48271 is the Park-Miller multiplier
  uint64_t product = (uint64_t)*state * 48271;
  // avoid doing 64-bit division
  uint32_t x = (uint32_t)((product & 0x7FFFFFFF) + (product >> 31));

  x = (x & 0x7FFFFFFF) + (x >> 31);
  return *state = x;
}

void toggle_led_pattern(GPIO_TypeDef *gpio, uint32_t *seed)
{
  static bool is_on[16] = {0};

  // random between [1 .. 0xFFFF]
  uint32_t n = (RNG_lcg_parkmiller(seed) % 0xFFFE) + 1;

  while(n != 0) {
    uint32_t idx = __builtin_ctz(n);
    n &= ~(1 << idx);

    if(is_on[idx]) {
      gpio->BSRR |= (GPIO_BSRR_BR0 << idx);
    } else {
      gpio->BSRR |= (GPIO_BSRR_BS0 << idx);
    }
    is_on[idx] = !is_on[idx];
  }
}

#ifdef SIMULATOR_BUILD
#include "stdio.h"
#endif

extern "C" void SysTick_Handler(void)
{
  static uint32_t seed0 = RNG_seed_parkmiller(120241);

  toggle_led_pattern(GPIOB, &seed0);
  //toggle_led();
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
