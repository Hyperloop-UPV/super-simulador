## What had to be changed in Board code

### Board
 - Needed an `init()` function that takes the base addresses of all peripherals
 - Needed an `update()` function that is called by the simulator on each step (this might be changed)

### CMSIS
 - Needed to change NVIC vector table, the offset now also uses a base address given by the simulator, which is 0 when not in simulator build and the vectors (interrupt addresses) are now `size_t` size (see function `__NVIC_SetVector` and `__NVIC_GetVector` in `core_cm7.h`)
 - {`SCB_InvalidateICache_by_Addr`, `SCB_CleanICache_by_Addr`, `SCB_InvalidateDCache_by_Addr`, `SCB_CleanDCache_by_Addr`, `SCB_CleanInvalidateDCache_by_Addr`} needed change from `uint32_t` values for addresses to `size_t`. Not sure about these functions considering SCB ICIMVAU is a 32bit register. We might need something special for them or change SCB slightly?


