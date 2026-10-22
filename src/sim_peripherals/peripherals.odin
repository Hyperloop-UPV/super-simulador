#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package peripherals

/* NOTE: GPV (Global Programmer View) is alone 284KiB :( */

import "core:mem"
import "core:time"
import "core:dynlib"
import "core:mem/virtual"

PERIPHERAL_COUNT :: 245

/*
Handles any change in the the pages the peripheral uses

Arguments:
 - `rawctx`: will contain a ^Memory
 - `this_rawctx`: will contain a rawptr returned from the function in `SetupFn`

 - TODO: What would I need? Wanna try out making one before deciding
*/
Handler_Proc :: proc(rawctx, this_rawctx: rawptr)

/*
Setup function for a peripheral, will be called before the first step(),
after allocating ^Memory

Arguments:
 - `rawctx`: will contain a ^Memory
Returns:
 - a rawptr to the memory required for StepFn
*/
Setup_Proc :: #type proc(rawctx: rawptr) -> rawptr

/*
Step function that will be called when doing a single step(), 
whether it is a fixed step or a variable step

Arguments:
 - `rawctx`: will contain a ^Memory
 - `this_rawctx`: will contain a rawptr returned from the function in `SetupFn`
*/
Step_Proc :: #type proc(rawctx, this_rawctx: rawptr, step_time: time.Duration)

/*
Holds the function pointers necessary for simulating a peripheral
*/
Sim_Data :: struct {
  setup: Setup_Proc,
  step: Step_Proc,
  handler: Handler_Proc,

  this_ctx: rawptr,
}

Board_API :: struct {
  init: proc "c"(mem: ^Memory),
  update: proc "c"(),

  library: dynlib.Library,
}

/* Some peripherals might use more than a single page here, 
 * they won't be repeated but in Memory.handlers they will be
 */
SimArray :: [?]Sim_Data {
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SCnSCB */
  {SCB_setup, SCB_step, SCB_handler, nil}, /* SCB */
  {SysTick_setup, SysTick_step, SysTick_handler, nil}, /* SysTick */
  {NVIC_setup, NVIC_step, NVIC_handler, nil}, /* NVIC */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* ITM */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DWT */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TPI */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* CoreDebug */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MPU */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FPU */
  
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM7 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM13 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM14 */
  
  {Stub_setup, Stub_step, Stub_handler, nil}, /* VREFBUF */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RTC */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* WWDG1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* IWDG1 */
  
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SPI2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SPI3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SPI4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SPI5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SPI6 */
  
  {Stub_setup, Stub_step, Stub_handler, nil}, /* USART2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* USART3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* USART6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* USART10 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* UART7 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* UART8 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* UART9 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* CRS */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* UART4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* UART5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* I2C1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* I2C2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* I2C3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* I2C4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* I2C5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FDCAN1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FDCAN2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FDCAN_CCU */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FDCAN3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM23 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM24 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* CEC */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* LPTIM1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* PWR */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DAC1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* LPUART1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SWPMI1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* LPTIM4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* LPTIM5 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* SYSCFG */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* COMP12 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* COMP1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* COMP2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* COMP12_COMMON */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* OPAMP */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* OPAMP1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* OPAMP2 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* EXTI */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* EXTI_D1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* EXTI_D2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SPI1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM8 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* USART1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM12 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM15 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM16 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* TIM17 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SAI1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SAI1_Block_A */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SAI1_Block_B */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SAI4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SAI4_Block_A */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SAI4_Block_B */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* SPDIFRX */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Channel0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Channel1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Channel2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Channel3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Channel4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Channel5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Channel6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Channel7 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Filter0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Filter1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Filter2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DFSDM1_Filter3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2D */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DCMI */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* PSSI */
  {RCC_setup, RCC_step, RCC_handler, nil}, /* RCC */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FLASH */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* CRC */

  {GPIOA_setup, GPIO_step, GPIO_handler, nil}, /* GPIOA */
  {GPIOB_setup, GPIO_step, GPIO_handler, nil}, /* GPIOB */
  {GPIOC_setup, GPIO_step, GPIO_handler, nil}, /* GPIOC */
  {GPIOD_setup, GPIO_step, GPIO_handler, nil}, /* GPIOD */
  {GPIOE_setup, GPIO_step, GPIO_handler, nil}, /* GPIOE */
  {GPIOF_setup, GPIO_step, GPIO_handler, nil}, /* GPIOF */
  {GPIOG_setup, GPIO_step, GPIO_handler, nil}, /* GPIOG */
  {GPIOH_setup, GPIO_step, GPIO_handler, nil}, /* GPIOH */
  {GPIOJ_setup, GPIO_step, GPIO_handler, nil}, /* GPIOJ */
  {GPIOK_setup, GPIO_step, GPIO_handler, nil}, /* GPIOK */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* ADC1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* ADC2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* ADC3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* ADC3_COMMON */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* ADC12_COMMON */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* RNG */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* SDMMC2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DLYB_SDMMC2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FMAC */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* CORDIC */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA_Channel0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA_Channel1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA_Channel2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA_Channel3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA_Channel4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA_Channel5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA_Channel6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* BDMA_Channel7 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC1_Monitor1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC1_Monitor2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC1_Monitor3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC1_Monitor4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC1_Monitor5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC1_Monitor6 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC2_Monitor1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC2_Monitor2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC2_Monitor3 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC3_Monitor1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RAMECC3_Monitor2 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_Channel0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_Channel1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_Channel2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_Channel3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_Channel4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_Channel5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_Channel6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_Channel7 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenerator0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenerator1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenerator2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenerator3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenerator4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenerator5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenerator6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenerator7 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_ChannelStatus */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX2_RequestGenStatus */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2_Stream0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2_Stream1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2_Stream2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2_Stream3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2_Stream4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2_Stream5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2_Stream6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA2_Stream7 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1_Stream0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1_Stream1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1_Stream2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1_Stream3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1_Stream4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1_Stream5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1_Stream6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMA1_Stream7 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel7 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel8 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel9 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel10 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel11 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel12 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel13 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel14 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_Channel15 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenerator0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenerator1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenerator2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenerator3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenerator4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenerator5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenerator6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenerator7 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_ChannelStatus */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DMAMUX1_RequestGenStatus */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* FMC_Bank1_R */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FMC_Bank1E_R */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FMC_Bank2_R */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FMC_Bank3_R */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FMC_Bank5_6_R */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* OCTOSPI1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DLYB_OCTOSPI1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* OCTOSPI2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DLYB_OCTOSPI2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* OCTOSPIM */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* SDMMC1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* DLYB_SDMMC1 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* DBGMCU */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* HSEM */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* HSEM_COMMON */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* LTDC */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* LTDC_Layer1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* LTDC_Layer2 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDIOS */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* ETH */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel0 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel1 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel2 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel3 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel4 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel5 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel6 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel7 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel8 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel9 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel10 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel11 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel12 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel13 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel14 */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* MDMA_Channel15 */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* USB1_OTG_HS */
}

Raw_Memory :: struct {
  SCnSCB_base: ^SCnSCB,
  SCB_base: ^SCB,

  SysTick_base: ^SysTick,
  NVIC_base: ^NVIC,
  ITM_base: ^ITM,
  DWT_base: ^DWT,
  TPI_base: ^TPI,
  CoreDebug_base: ^CoreDebug,
  MPU_base: ^MPU,
  FPU_base: ^FPU,

  TIM2_base: ^TIM,
  TIM3_base: ^TIM,
  TIM4_base: ^TIM,
  TIM5_base: ^TIM,
  TIM6_base: ^TIM,
  TIM7_base: ^TIM,
  TIM13_base: ^TIM,
  TIM14_base: ^TIM,

  VREFBUF_base: ^VREFBUF,
  RTC_base: ^RTC,
  WWDG1_base: ^WWDG,
  IWDG1_base: ^IWDG,

  SPI2_base: ^SPI,
  SPI3_base: ^SPI,
  SPI4_base: ^SPI,
  SPI5_base: ^SPI,
  SPI6_base: ^SPI,

  USART2_base: ^USART,
  USART3_base: ^USART,
  USART6_base: ^USART,
  USART10_base: ^USART,
  UART7_base: ^USART,
  UART8_base: ^USART,
  UART9_base: ^USART,
  CRS_base: ^CRS,
  UART4_base: ^USART,
  UART5_base: ^USART,
  I2C1_base: ^I2C,
  I2C2_base: ^I2C,
  I2C3_base: ^I2C,
  I2C4_base: ^I2C,
  I2C5_base: ^I2C,
  FDCAN1_base: ^FDCAN,
  FDCAN2_base: ^FDCAN,
  FDCAN_CCU_base: ^FDCAN_CCU,
  FDCAN3_base: ^FDCAN,
  TIM23_base: ^TIM,
  TIM24_base: ^TIM,
  CEC_base: ^CEC,
  LPTIM1_base: ^LPTIM,
  PWR_base: ^PWR,
  DAC1_base: ^DAC,
  LPUART1_base: ^USART,
  SWPMI1_base: ^SWPMI,
  LPTIM4_base: ^LPTIM,
  LPTIM5_base: ^LPTIM,

  SYSCFG_base: ^SYSCFG,
  COMP12_base: ^COMPOPT,
  COMP1_base: ^COMP,
  COMP2_base: ^COMP,
  COMP12_COMMON_base: ^COMP_Common,
  OPAMP_base: ^OPAMP,
  OPAMP1_base: ^OPAMP,
  OPAMP2_base: ^OPAMP,

  EXTI_base: ^EXTI,
  EXTI_D1_base: ^EXTI_Core,
  EXTI_D2_base: ^EXTI_Core,
  TIM1_base: ^TIM,
  SPI1_base: ^SPI,
  TIM8_base: ^TIM,
  USART1_base: ^USART,
  TIM12_base: ^TIM,
  TIM15_base: ^TIM,
  TIM16_base: ^TIM,
  TIM17_base: ^TIM,
  SAI1_base: ^SAI,
  SAI1_Block_A_base: ^SAI_Block,
  SAI1_Block_B_base: ^SAI_Block,
  SAI4_base: ^SAI,
  SAI4_Block_A_base: ^SAI_Block,
  SAI4_Block_B_base: ^SAI_Block,

  SPDIFRX_base: ^SPDIFRX,
  DFSDM1_Channel0_base: ^DFSDM_Channel,
  DFSDM1_Channel1_base: ^DFSDM_Channel,
  DFSDM1_Channel2_base: ^DFSDM_Channel,
  DFSDM1_Channel3_base: ^DFSDM_Channel,
  DFSDM1_Channel4_base: ^DFSDM_Channel,
  DFSDM1_Channel5_base: ^DFSDM_Channel,
  DFSDM1_Channel6_base: ^DFSDM_Channel,
  DFSDM1_Channel7_base: ^DFSDM_Channel,
  DFSDM1_Filter0_base: ^DFSDM_Filter,
  DFSDM1_Filter1_base: ^DFSDM_Filter,
  DFSDM1_Filter2_base: ^DFSDM_Filter,
  DFSDM1_Filter3_base: ^DFSDM_Filter,
  DMA2D_base: ^DMA2D,
  DCMI_base: ^DCMI,
  PSSI_base: ^PSSI,
  RCC_base: ^RCC,
  FLASH_base: ^FLASH,
  CRC_base: ^CRC,

  GPIOA_base: ^GPIO,
  GPIOB_base: ^GPIO,
  GPIOC_base: ^GPIO,
  GPIOD_base: ^GPIO,
  GPIOE_base: ^GPIO,
  GPIOF_base: ^GPIO,
  GPIOG_base: ^GPIO,
  GPIOH_base: ^GPIO,
  GPIOJ_base: ^GPIO,
  GPIOK_base: ^GPIO,

  ADC1_base: ^ADC,
  ADC2_base: ^ADC,
  ADC3_base: ^ADC,
  ADC3_COMMON_base: ^ADC_Common,
  ADC12_COMMON_base: ^ADC_Common,

  RNG_base: ^RNG,
  SDMMC2_base: ^SDMMC,
  DLYB_SDMMC2_base: ^DLYB,
  FMAC_base: ^FMAC,
  CORDIC_base: ^CORDIC,

  BDMA_base: ^BDMA,
  BDMA_Channel0_base: ^BDMA_Channel,
  BDMA_Channel1_base: ^BDMA_Channel,
  BDMA_Channel2_base: ^BDMA_Channel,
  BDMA_Channel3_base: ^BDMA_Channel,
  BDMA_Channel4_base: ^BDMA_Channel,
  BDMA_Channel5_base: ^BDMA_Channel,
  BDMA_Channel6_base: ^BDMA_Channel,
  BDMA_Channel7_base: ^BDMA_Channel,

  RAMECC1_base: ^RAMECC,
  RAMECC1_Monitor1_base: ^RAMECC_Monitor,
  RAMECC1_Monitor2_base: ^RAMECC_Monitor,
  RAMECC1_Monitor3_base: ^RAMECC_Monitor,
  RAMECC1_Monitor4_base: ^RAMECC_Monitor,
  RAMECC1_Monitor5_base: ^RAMECC_Monitor,
  RAMECC1_Monitor6_base: ^RAMECC_Monitor,

  RAMECC2_base: ^RAMECC,
  RAMECC2_Monitor1_base: ^RAMECC_Monitor,
  RAMECC2_Monitor2_base: ^RAMECC_Monitor,
  RAMECC2_Monitor3_base: ^RAMECC_Monitor,

  RAMECC3_base: ^RAMECC,
  RAMECC3_Monitor1_base: ^RAMECC_Monitor,
  RAMECC3_Monitor2_base: ^RAMECC_Monitor,

  DMAMUX2_base: ^DMAMUX_Channel,
  DMAMUX2_Channel0_base: ^DMAMUX_Channel,
  DMAMUX2_Channel1_base: ^DMAMUX_Channel,
  DMAMUX2_Channel2_base: ^DMAMUX_Channel,
  DMAMUX2_Channel3_base: ^DMAMUX_Channel,
  DMAMUX2_Channel4_base: ^DMAMUX_Channel,
  DMAMUX2_Channel5_base: ^DMAMUX_Channel,
  DMAMUX2_Channel6_base: ^DMAMUX_Channel,
  DMAMUX2_Channel7_base: ^DMAMUX_Channel,

  DMAMUX2_RequestGenerator0_base: ^DMAMUX_RequestGen,
  DMAMUX2_RequestGenerator1_base: ^DMAMUX_RequestGen,
  DMAMUX2_RequestGenerator2_base: ^DMAMUX_RequestGen,
  DMAMUX2_RequestGenerator3_base: ^DMAMUX_RequestGen,
  DMAMUX2_RequestGenerator4_base: ^DMAMUX_RequestGen,
  DMAMUX2_RequestGenerator5_base: ^DMAMUX_RequestGen,
  DMAMUX2_RequestGenerator6_base: ^DMAMUX_RequestGen,
  DMAMUX2_RequestGenerator7_base: ^DMAMUX_RequestGen,

  DMAMUX2_ChannelStatus_base: ^DMAMUX_ChannelStatus,
  DMAMUX2_RequestGenStatus_base: ^DMAMUX_RequestGenStatus,

  DMA2_base: ^DMA,
  DMA2_Stream0_base: ^DMA_Stream,
  DMA2_Stream1_base: ^DMA_Stream,
  DMA2_Stream2_base: ^DMA_Stream,
  DMA2_Stream3_base: ^DMA_Stream,
  DMA2_Stream4_base: ^DMA_Stream,
  DMA2_Stream5_base: ^DMA_Stream,
  DMA2_Stream6_base: ^DMA_Stream,
  DMA2_Stream7_base: ^DMA_Stream,

  DMA1_base: ^DMA,
  DMA1_Stream0_base: ^DMA_Stream,
  DMA1_Stream1_base: ^DMA_Stream,
  DMA1_Stream2_base: ^DMA_Stream,
  DMA1_Stream3_base: ^DMA_Stream,
  DMA1_Stream4_base: ^DMA_Stream,
  DMA1_Stream5_base: ^DMA_Stream,
  DMA1_Stream6_base: ^DMA_Stream,
  DMA1_Stream7_base: ^DMA_Stream,

  DMAMUX1_base: ^DMAMUX_Channel,
  DMAMUX1_Channel0_base: ^DMAMUX_Channel,
  DMAMUX1_Channel1_base: ^DMAMUX_Channel,
  DMAMUX1_Channel2_base: ^DMAMUX_Channel,
  DMAMUX1_Channel3_base: ^DMAMUX_Channel,
  DMAMUX1_Channel4_base: ^DMAMUX_Channel,
  DMAMUX1_Channel5_base: ^DMAMUX_Channel,
  DMAMUX1_Channel6_base: ^DMAMUX_Channel,
  DMAMUX1_Channel7_base: ^DMAMUX_Channel,
  DMAMUX1_Channel8_base: ^DMAMUX_Channel,
  DMAMUX1_Channel9_base: ^DMAMUX_Channel,
  DMAMUX1_Channel10_base: ^DMAMUX_Channel,
  DMAMUX1_Channel11_base: ^DMAMUX_Channel,
  DMAMUX1_Channel12_base: ^DMAMUX_Channel,
  DMAMUX1_Channel13_base: ^DMAMUX_Channel,
  DMAMUX1_Channel14_base: ^DMAMUX_Channel,
  DMAMUX1_Channel15_base: ^DMAMUX_Channel,

  DMAMUX1_RequestGenerator0_base: ^DMAMUX_RequestGen,
  DMAMUX1_RequestGenerator1_base: ^DMAMUX_RequestGen,
  DMAMUX1_RequestGenerator2_base: ^DMAMUX_RequestGen,
  DMAMUX1_RequestGenerator3_base: ^DMAMUX_RequestGen,
  DMAMUX1_RequestGenerator4_base: ^DMAMUX_RequestGen,
  DMAMUX1_RequestGenerator5_base: ^DMAMUX_RequestGen,
  DMAMUX1_RequestGenerator6_base: ^DMAMUX_RequestGen,
  DMAMUX1_RequestGenerator7_base: ^DMAMUX_RequestGen,

  DMAMUX1_ChannelStatus_base: ^DMAMUX_ChannelStatus,
  DMAMUX1_RequestGenStatus_base: ^DMAMUX_RequestGenStatus,

  FMC_Bank1_R_base: ^FMC_Bank1,
  FMC_Bank1E_R_base: ^FMC_Bank1E,
  FMC_Bank2_R_base: ^FMC_Bank2,
  FMC_Bank3_R_base: ^FMC_Bank3,
  FMC_Bank5_6_R_base: ^FMC_Bank5_6,

  OCTOSPI1_base: ^OCTOSPI,
  DLYB_OCTOSPI1_base: ^DLYB,
  OCTOSPI2_base: ^OCTOSPI,
  DLYB_OCTOSPI2_base: ^DLYB,
  OCTOSPIM_base: ^OCTOSPIM,

  SDMMC1_base: ^SDMMC,
  DLYB_SDMMC1_base: ^DLYB,

  DBGMCU_base: ^DBGMCU,

  HSEM_base: ^HSEM,
  HSEM_COMMON_base: ^HSEM_Common,

  LTDC_base: ^LTDC,
  LTDC_Layer1_base: ^LTDC_Layer,
  LTDC_Layer2_base: ^LTDC_Layer,

  MDIOS_base: ^MDIOS,

  ETH_base: ^ETH,
  MDMA_base: ^MDMA,
  MDMA_Channel0_base: ^MDMA_Channel,
  MDMA_Channel1_base: ^MDMA_Channel,
  MDMA_Channel2_base: ^MDMA_Channel,
  MDMA_Channel3_base: ^MDMA_Channel,
  MDMA_Channel4_base: ^MDMA_Channel,
  MDMA_Channel5_base: ^MDMA_Channel,
  MDMA_Channel6_base: ^MDMA_Channel,
  MDMA_Channel7_base: ^MDMA_Channel,
  MDMA_Channel8_base: ^MDMA_Channel,
  MDMA_Channel9_base: ^MDMA_Channel,
  MDMA_Channel10_base: ^MDMA_Channel,
  MDMA_Channel11_base: ^MDMA_Channel,
  MDMA_Channel12_base: ^MDMA_Channel,
  MDMA_Channel13_base: ^MDMA_Channel,
  MDMA_Channel14_base: ^MDMA_Channel,
  MDMA_Channel15_base: ^MDMA_Channel,

  USB1_OTG_HS_base: ^USB_OTG,

  // GPV,
}

Memory :: struct {
  using raw: struct #raw_union {
    base_addresses: [PERIPHERAL_COUNT]rawptr,
    using memory: Raw_Memory,
  },

  /* base address of 'arena', will be used in the board code as a base then offset for stuff
   * like the SCB NVIC vector offset which is 32 bit, this way it can keep being 32 bit
   * but it will be an offset to this base.
   */
  arena_base: rawptr,

  /* NOTE: These are at the bottom because they don't need to be sent to the board */
  writeWatchRequestMem: [PERIPHERAL_COUNT * PLATFORM_REQ_MULTIPLIER]rawptr,
  pageCount: uint,
  totalMem: uint,

  board_api: Board_API,
  // One handler per page (256 pages max, unless we use GPV)
  handlers: [dynamic; 256]Handler_Proc,
  peripheral_contexts: [dynamic; 256]rawptr,
  base: rawptr,
  simArray: []Sim_Data,

  // NOTE: The arena does not support freeing of individual elements,
  //       it is purely for long-lived allocations
  arena: virtual.Arena,
  arena_allocator: mem.Allocator,
}
