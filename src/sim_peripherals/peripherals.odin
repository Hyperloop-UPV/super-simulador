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

Types :: [?]typeid {
  SCnSCB,
  SCB,
  SysTick,
  NVIC,
  ITM,
  DWT,
  TPI,
  CoreDebug,
  MPU,
  FPU,

  TIM, /* TIM2 */
  TIM, /* TIM3 */
  TIM, /* TIM4 */
  TIM, /* TIM5 */
  TIM, /* TIM6 */
  TIM, /* TIM7 */
  TIM, /* TIM13 */
  TIM, /* TIM14 */

  VREFBUF,
  RTC,
  WWDG,
  IWDG,

  SPI, /* SPI2 */
  SPI, /* SPI3 */
  SPI, /* SPI4 */
  SPI, /* SPI5 */
  SPI, /* SPI6 */

  USART, /* USART2 */
  USART, /* USART3 */
  USART, /* USART6 */
  USART, /* USART10 */
  USART, /* UART7 */
  USART, /* UART8 */
  USART, /* UART9 */
  CRS,
  USART, /* UART4 */
  USART, /* UART5 */
  I2C, /* I2C1 */
  I2C, /* I2C2 */
  I2C, /* I2C3 */
  I2C, /* I2C4 */
  I2C, /* I2C5 */

  FDCAN, /* FDCAN1 */
  FDCAN, /* FDCAN2 */
  FDCAN_CCU, /* FDCAN_CCU */
  FDCAN, /* FDCAN3 */
  TIM, /* TIM23 */
  TIM, /* TIM24 */
  CEC,
  LPTIM, /* LPTIM1 */
  PWR,
  DAC, /* DAC1 */
  USART, /* LPUART1 */
  SWPMI, /* SWPMI1 */
  LPTIM, /* LPTIM4 */
  LPTIM, /* LPTIM5 */
  SYSCFG,
  COMPOPT, /* COMP12 */
  COMP, /* COMP1 */
  COMP, /* COMP2 */
  COMP_Common, /* COMP12_COMMON */
  OPAMP, /* OPAMP */
  OPAMP, /* OPAMP1 */
  OPAMP, /* OPAMP2 */

  EXTI,
  EXTI_Core, /* EXTI_D1 */
  EXTI_Core, /* EXTI_D2 */
  TIM, /* TIM1 */
  SPI, /* SPI1 */
  TIM, /* TIM8 */
  USART, /* USART1 */
  TIM, /* TIM12 */
  TIM, /* TIM15 */
  TIM, /* TIM16 */
  TIM, /* TIM17 */
  SAI, /* SAI1 */
  SAI_Block, /* SAI1_Block_A */
  SAI_Block, /* SAI1_Block_B */
  SAI, /* SAI4 */
  SAI_Block, /* SAI4_Block_A */
  SAI_Block, /* SAI4_Block_B */

  SPDIFRX,
  DFSDM_Channel, /* DFSDM1_Channel0 */
  DFSDM_Channel, /* DFSDM1_Channel1 */
  DFSDM_Channel, /* DFSDM1_Channel2 */
  DFSDM_Channel, /* DFSDM1_Channel3 */
  DFSDM_Channel, /* DFSDM1_Channel4 */
  DFSDM_Channel, /* DFSDM1_Channel5 */
  DFSDM_Channel, /* DFSDM1_Channel6 */
  DFSDM_Channel, /* DFSDM1_Channel7 */
  DFSDM_Filter, /* DFSDM1_Filter0 */
  DFSDM_Filter, /* DFSDM1_Filter1 */
  DFSDM_Filter, /* DFSDM1_Filter2 */
  DFSDM_Filter, /* DFSDM1_Filter3 */
  DMA2D,
  DCMI,
  PSSI,
  RCC,
  FLASH,
  CRC,

  GPIO, /* GPIOA */
  GPIO, /* GPIOB */
  GPIO, /* GPIOC */
  GPIO, /* GPIOD */
  GPIO, /* GPIOE */
  GPIO, /* GPIOF */
  GPIO, /* GPIOG */
  GPIO, /* GPIOH */
  GPIO, /* GPIOJ */
  GPIO, /* GPIOK */

  ADC, /* ADC1 */
  ADC, /* ADC2 */
  ADC, /* ADC3 */
  ADC_Common, /* ADC3_COMMON */
  ADC_Common, /* ADC12_COMMON */

  RNG,
  SDMMC, /* SDMMC2 */
  DLYB, /* DLYB_SDMMC2 */
  FMAC,
  CORDIC,

  BDMA,
  BDMA_Channel, /* BDMA_Channel0 */
  BDMA_Channel, /* BDMA_Channel1 */
  BDMA_Channel, /* BDMA_Channel2 */
  BDMA_Channel, /* BDMA_Channel3 */
  BDMA_Channel, /* BDMA_Channel4 */
  BDMA_Channel, /* BDMA_Channel5 */
  BDMA_Channel, /* BDMA_Channel6 */
  BDMA_Channel, /* BDMA_Channel7 */

  RAMECC, /* RAMECC1 */
  RAMECC_Monitor, /* RAMECC1_Monitor1 */
  RAMECC_Monitor, /* RAMECC1_Monitor2 */
  RAMECC_Monitor, /* RAMECC1_Monitor3 */
  RAMECC_Monitor, /* RAMECC1_Monitor4 */
  RAMECC_Monitor, /* RAMECC1_Monitor5 */
  RAMECC_Monitor, /* RAMECC1_Monitor6 */

  RAMECC, /* RAMECC2 */
  RAMECC_Monitor, /* RAMECC2_Monitor1 */
  RAMECC_Monitor, /* RAMECC2_Monitor2 */
  RAMECC_Monitor, /* RAMECC2_Monitor3 */

  RAMECC, /* RAMECC3 */
  RAMECC_Monitor, /* RAMECC3_Monitor1 */
  RAMECC_Monitor, /* RAMECC3_Monitor2 */
  
  DMAMUX_Channel, /* DMAMUX2 */
  DMAMUX_Channel, /* DMAMUX2_Channel0 */
  DMAMUX_Channel, /* DMAMUX2_Channel1 */
  DMAMUX_Channel, /* DMAMUX2_Channel2 */
  DMAMUX_Channel, /* DMAMUX2_Channel3 */
  DMAMUX_Channel, /* DMAMUX2_Channel4 */
  DMAMUX_Channel, /* DMAMUX2_Channel5 */
  DMAMUX_Channel, /* DMAMUX2_Channel6 */
  DMAMUX_Channel, /* DMAMUX2_Channel7 */
  
  DMAMUX_RequestGen, /* DMAMUX2_RequestGenerator0 */
  DMAMUX_RequestGen, /* DMAMUX2_RequestGenerator1 */
  DMAMUX_RequestGen, /* DMAMUX2_RequestGenerator2 */
  DMAMUX_RequestGen, /* DMAMUX2_RequestGenerator3 */
  DMAMUX_RequestGen, /* DMAMUX2_RequestGenerator4 */
  DMAMUX_RequestGen, /* DMAMUX2_RequestGenerator5 */
  DMAMUX_RequestGen, /* DMAMUX2_RequestGenerator6 */
  DMAMUX_RequestGen, /* DMAMUX2_RequestGenerator7 */
  
  DMAMUX_ChannelStatus, /* DMAMUX2_ChannelStatus */
  DMAMUX_RequestGenStatus, /* DMAMUX2_RequestGenStatus */

  DMA, /* DMA2 */
  DMA_Stream, /* DMA2_Stream0 */
  DMA_Stream, /* DMA2_Stream1 */
  DMA_Stream, /* DMA2_Stream2 */
  DMA_Stream, /* DMA2_Stream3 */
  DMA_Stream, /* DMA2_Stream4 */
  DMA_Stream, /* DMA2_Stream5 */
  DMA_Stream, /* DMA2_Stream6 */
  DMA_Stream, /* DMA2_Stream7 */

  DMA, /* DMA1 */
  DMA_Stream, /* DMA1_Stream0 */
  DMA_Stream, /* DMA1_Stream1 */
  DMA_Stream, /* DMA1_Stream2 */
  DMA_Stream, /* DMA1_Stream3 */
  DMA_Stream, /* DMA1_Stream4 */
  DMA_Stream, /* DMA1_Stream5 */
  DMA_Stream, /* DMA1_Stream6 */
  DMA_Stream, /* DMA1_Stream7 */

  DMAMUX_Channel, /* DMAMUX1 */
  DMAMUX_Channel, /* DMAMUX1_Channel0 */
  DMAMUX_Channel, /* DMAMUX1_Channel1 */
  DMAMUX_Channel, /* DMAMUX1_Channel2 */
  DMAMUX_Channel, /* DMAMUX1_Channel3 */
  DMAMUX_Channel, /* DMAMUX1_Channel4 */
  DMAMUX_Channel, /* DMAMUX1_Channel5 */
  DMAMUX_Channel, /* DMAMUX1_Channel6 */
  DMAMUX_Channel, /* DMAMUX1_Channel7 */
  DMAMUX_Channel, /* DMAMUX1_Channel8 */
  DMAMUX_Channel, /* DMAMUX1_Channel9 */
  DMAMUX_Channel, /* DMAMUX1_Channel10 */
  DMAMUX_Channel, /* DMAMUX1_Channel11 */
  DMAMUX_Channel, /* DMAMUX1_Channel12 */
  DMAMUX_Channel, /* DMAMUX1_Channel13 */
  DMAMUX_Channel, /* DMAMUX1_Channel14 */
  DMAMUX_Channel, /* DMAMUX1_Channel15 */

  DMAMUX_RequestGen, /* DMAMUX1_RequestGenerator0 */
  DMAMUX_RequestGen, /* DMAMUX1_RequestGenerator1 */
  DMAMUX_RequestGen, /* DMAMUX1_RequestGenerator2 */
  DMAMUX_RequestGen, /* DMAMUX1_RequestGenerator3 */
  DMAMUX_RequestGen, /* DMAMUX1_RequestGenerator4 */
  DMAMUX_RequestGen, /* DMAMUX1_RequestGenerator5 */
  DMAMUX_RequestGen, /* DMAMUX1_RequestGenerator6 */
  DMAMUX_RequestGen, /* DMAMUX1_RequestGenerator7 */

  DMAMUX_ChannelStatus, /* DMAMUX1_ChannelStatus */
  DMAMUX_RequestGenStatus, /* DMAMUX1_RequestGenStatus */

  FMC_Bank1,
  FMC_Bank1E,
  FMC_Bank2,
  FMC_Bank3,
  FMC_Bank5_6,
  
  OCTOSPI, /* OCTOSPI1 */
  DLYB, /* DLYB_OCTOSPI1 */
  OCTOSPI, /* OCTOSPI2 */
  DLYB, /* DLYB_OCTOSPI2 */
  OCTOSPIM,
  
  SDMMC, /* SDMMC1 */
  DLYB, /* DLYB_SDMMC1 */

  DBGMCU,
  
  HSEM,
  HSEM_Common,
  
  LTDC,
  LTDC_Layer, /* LTDC_Layer1 */
  LTDC_Layer, /* LTDC_Layer2 */
  
  MDIOS,
  
  ETH,
  MDMA,
  MDMA_Channel, /* MDMA_Channel0 */
  MDMA_Channel, /* MDMA_Channel1 */
  MDMA_Channel, /* MDMA_Channel2 */
  MDMA_Channel, /* MDMA_Channel3 */
  MDMA_Channel, /* MDMA_Channel4 */
  MDMA_Channel, /* MDMA_Channel5 */
  MDMA_Channel, /* MDMA_Channel6 */
  MDMA_Channel, /* MDMA_Channel7 */
  MDMA_Channel, /* MDMA_Channel8 */
  MDMA_Channel, /* MDMA_Channel9 */
  MDMA_Channel, /* MDMA_Channel10 */
  MDMA_Channel, /* MDMA_Channel11 */
  MDMA_Channel, /* MDMA_Channel12 */
  MDMA_Channel, /* MDMA_Channel13 */
  MDMA_Channel, /* MDMA_Channel14 */
  MDMA_Channel, /* MDMA_Channel15 */
  USB_OTG, /* USB1_OTG_HS */

  //GPV,  
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
  {Stub_setup, Stub_step, Stub_handler, nil}, /* RCC */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* FLASH */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* CRC */

  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOA */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOB */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOC */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOD */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOE */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOF */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOG */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOH */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOJ */
  {Stub_setup, Stub_step, Stub_handler, nil}, /* GPIOK */

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

Memory :: struct {
  using _: struct #raw_union {
    memories: [len(Types)]rawptr,

    using periph: struct {
      SCnSCB_base: rawptr,
      SCB_base: rawptr,

      SysTick_base: rawptr,
      NVIC_base: rawptr,
      ITM_base: rawptr,
      DWT_base: rawptr,
      TPI_base: rawptr,
      CoreDebug_base: rawptr,
      MPU_base: rawptr,
      FPU_base: rawptr,
    
      TIM2_base: rawptr,
      TIM3_base: rawptr,
      TIM4_base: rawptr,
      TIM5_base: rawptr,
      TIM6_base: rawptr,
      TIM7_base: rawptr,
      TIM13_base: rawptr,
      TIM14_base: rawptr,
    
      VREFBUF_base: rawptr,
      RTC_base: rawptr,
      WWDG1_base: rawptr,
      IWDG1_base: rawptr,
    
      SPI2_base: rawptr,
      SPI3_base: rawptr,
      SPI4_base: rawptr,
      SPI5_base: rawptr,
      SPI6_base: rawptr,
    
      USART2_base: rawptr,
      USART3_base: rawptr,
      USART6_base: rawptr,
      USART10_base: rawptr,
      UART7_base: rawptr,
      UART8_base: rawptr,
      UART9_base: rawptr,
      CRS_base: rawptr,
      UART4_base: rawptr,
      UART5_base: rawptr,
      I2C1_base: rawptr,
      I2C2_base: rawptr,
      I2C3_base: rawptr,
      I2C4_base: rawptr,
      I2C5_base: rawptr,
      FDCAN1_base: rawptr,
      FDCAN2_base: rawptr,
      FDCAN_CCU_base: rawptr,
      FDCAN3_base: rawptr,
      TIM23_base: rawptr,
      TIM24_base: rawptr,
      CEC_base: rawptr,
      LPTIM1_base: rawptr,
      PWR_base: rawptr,
      DAC1_base: rawptr,
      LPUART1_base: rawptr,
      SWPMI1_base: rawptr,
      LPTIM4_base: rawptr,
      LPTIM5_base: rawptr,
    
      SYSCFG_base: rawptr,
      COMP12_base: rawptr,
      COMP1_base: rawptr,
      COMP2_base: rawptr,
      COMP12_COMMON_base: rawptr,
      OPAMP_base: rawptr,
      OPAMP1_base: rawptr,
      OPAMP2_base: rawptr,
    
      EXTI_base: rawptr,
      EXTI_D1_base: rawptr,
      EXTI_D2_base: rawptr,
      TIM1_base: rawptr,
      SPI1_base: rawptr,
      TIM8_base: rawptr,
      USART1_base: rawptr,
      TIM12_base: rawptr,
      TIM15_base: rawptr,
      TIM16_base: rawptr,
      TIM17_base: rawptr,
      SAI1_base: rawptr,
      SAI1_Block_A_base: rawptr,
      SAI1_Block_B_base: rawptr,
      SAI4_base: rawptr,
      SAI4_Block_A_base: rawptr,
      SAI4_Block_B_base: rawptr,
    
      SPDIFRX_base: rawptr,
      DFSDM1_Channel0_base: rawptr,
      DFSDM1_Channel1_base: rawptr,
      DFSDM1_Channel2_base: rawptr,
      DFSDM1_Channel3_base: rawptr,
      DFSDM1_Channel4_base: rawptr,
      DFSDM1_Channel5_base: rawptr,
      DFSDM1_Channel6_base: rawptr,
      DFSDM1_Channel7_base: rawptr,
      DFSDM1_Filter0_base: rawptr,
      DFSDM1_Filter1_base: rawptr,
      DFSDM1_Filter2_base: rawptr,
      DFSDM1_Filter3_base: rawptr,
      DMA2D_base: rawptr,
      DCMI_base: rawptr,
      PSSI_base: rawptr,
      RCC_base: rawptr,
      FLASH_base: rawptr,
      CRC_base: rawptr,
    
      GPIOA_base: rawptr,
      GPIOB_base: rawptr,
      GPIOC_base: rawptr,
      GPIOD_base: rawptr,
      GPIOE_base: rawptr,
      GPIOF_base: rawptr,
      GPIOG_base: rawptr,
      GPIOH_base: rawptr,
      GPIOJ_base: rawptr,
      GPIOK_base: rawptr,
    
      ADC1_base: rawptr,
      ADC2_base: rawptr,
      ADC3_base: rawptr,
      ADC3_COMMON_base: rawptr,
      ADC12_COMMON_base: rawptr,
    
      RNG_base: rawptr,
      SDMMC2_base: rawptr,
      DLYB_SDMMC2_base: rawptr,
      FMAC_base: rawptr,
      CORDIC_base: rawptr,
    
      BDMA_base: rawptr,
      BDMA_Channel0_base: rawptr,
      BDMA_Channel1_base: rawptr,
      BDMA_Channel2_base: rawptr,
      BDMA_Channel3_base: rawptr,
      BDMA_Channel4_base: rawptr,
      BDMA_Channel5_base: rawptr,
      BDMA_Channel6_base: rawptr,
      BDMA_Channel7_base: rawptr,
    
      RAMECC1_base: rawptr,
      RAMECC1_Monitor1_base: rawptr,
      RAMECC1_Monitor2_base: rawptr,
      RAMECC1_Monitor3_base: rawptr,
      RAMECC1_Monitor4_base: rawptr,
      RAMECC1_Monitor5_base: rawptr,
      RAMECC1_Monitor6_base: rawptr,
    
      RAMECC2_base: rawptr,
      RAMECC2_Monitor1_base: rawptr,
      RAMECC2_Monitor2_base: rawptr,
      RAMECC2_Monitor3_base: rawptr,
    
      RAMECC3_base: rawptr,
      RAMECC3_Monitor1_base: rawptr,
      RAMECC3_Monitor2_base: rawptr,
    
      DMAMUX2_base: rawptr,
      DMAMUX2_Channel0_base: rawptr,
      DMAMUX2_Channel1_base: rawptr,
      DMAMUX2_Channel2_base: rawptr,
      DMAMUX2_Channel3_base: rawptr,
      DMAMUX2_Channel4_base: rawptr,
      DMAMUX2_Channel5_base: rawptr,
      DMAMUX2_Channel6_base: rawptr,
      DMAMUX2_Channel7_base: rawptr,
    
      DMAMUX2_RequestGenerator0_base: rawptr,
      DMAMUX2_RequestGenerator1_base: rawptr,
      DMAMUX2_RequestGenerator2_base: rawptr,
      DMAMUX2_RequestGenerator3_base: rawptr,
      DMAMUX2_RequestGenerator4_base: rawptr,
      DMAMUX2_RequestGenerator5_base: rawptr,
      DMAMUX2_RequestGenerator6_base: rawptr,
      DMAMUX2_RequestGenerator7_base: rawptr,
    
      DMAMUX2_ChannelStatus_base: rawptr,
      DMAMUX2_RequestGenStatus_base: rawptr,
    
      DMA2_base: rawptr,
      DMA2_Stream0_base: rawptr,
      DMA2_Stream1_base: rawptr,
      DMA2_Stream2_base: rawptr,
      DMA2_Stream3_base: rawptr,
      DMA2_Stream4_base: rawptr,
      DMA2_Stream5_base: rawptr,
      DMA2_Stream6_base: rawptr,
      DMA2_Stream7_base: rawptr,
    
      DMA1_base: rawptr,
      DMA1_Stream0_base: rawptr,
      DMA1_Stream1_base: rawptr,
      DMA1_Stream2_base: rawptr,
      DMA1_Stream3_base: rawptr,
      DMA1_Stream4_base: rawptr,
      DMA1_Stream5_base: rawptr,
      DMA1_Stream6_base: rawptr,
      DMA1_Stream7_base: rawptr,
    
      DMAMUX1_base: rawptr,
      DMAMUX1_Channel0_base: rawptr,
      DMAMUX1_Channel1_base: rawptr,
      DMAMUX1_Channel2_base: rawptr,
      DMAMUX1_Channel3_base: rawptr,
      DMAMUX1_Channel4_base: rawptr,
      DMAMUX1_Channel5_base: rawptr,
      DMAMUX1_Channel6_base: rawptr,
      DMAMUX1_Channel7_base: rawptr,
      DMAMUX1_Channel8_base: rawptr,
      DMAMUX1_Channel9_base: rawptr,
      DMAMUX1_Channel10_base: rawptr,
      DMAMUX1_Channel11_base: rawptr,
      DMAMUX1_Channel12_base: rawptr,
      DMAMUX1_Channel13_base: rawptr,
      DMAMUX1_Channel14_base: rawptr,
      DMAMUX1_Channel15_base: rawptr,
    
      DMAMUX1_RequestGenerator0_base: rawptr,
      DMAMUX1_RequestGenerator1_base: rawptr,
      DMAMUX1_RequestGenerator2_base: rawptr,
      DMAMUX1_RequestGenerator3_base: rawptr,
      DMAMUX1_RequestGenerator4_base: rawptr,
      DMAMUX1_RequestGenerator5_base: rawptr,
      DMAMUX1_RequestGenerator6_base: rawptr,
      DMAMUX1_RequestGenerator7_base: rawptr,
    
      DMAMUX1_ChannelStatus_base: rawptr,
      DMAMUX1_RequestGenStatus_base: rawptr,
    
      FMC_Bank1_R_base: rawptr,
      FMC_Bank1E_R_base: rawptr,
      FMC_Bank2_R_base: rawptr,
      FMC_Bank3_R_base: rawptr,
      FMC_Bank5_6_R_base: rawptr,
    
      OCTOSPI1_base: rawptr,
      DLYB_OCTOSPI1_base: rawptr,
      OCTOSPI2_base: rawptr,
      DLYB_OCTOSPI2_base: rawptr,
      OCTOSPIM_base: rawptr,
    
      SDMMC1_base: rawptr,
      DLYB_SDMMC1_base: rawptr,
    
      DBGMCU_base: rawptr,
    
      HSEM_base: rawptr,
      HSEM_COMMON_base: rawptr,
    
      LTDC_base: rawptr,
      LTDC_Layer1_base: rawptr,
      LTDC_Layer2_base: rawptr,
    
      MDIOS_base: rawptr,
    
      ETH_base: rawptr,
      MDMA_base: rawptr,
      MDMA_Channel0_base: rawptr,
      MDMA_Channel1_base: rawptr,
      MDMA_Channel2_base: rawptr,
      MDMA_Channel3_base: rawptr,
      MDMA_Channel4_base: rawptr,
      MDMA_Channel5_base: rawptr,
      MDMA_Channel6_base: rawptr,
      MDMA_Channel7_base: rawptr,
      MDMA_Channel8_base: rawptr,
      MDMA_Channel9_base: rawptr,
      MDMA_Channel10_base: rawptr,
      MDMA_Channel11_base: rawptr,
      MDMA_Channel12_base: rawptr,
      MDMA_Channel13_base: rawptr,
      MDMA_Channel14_base: rawptr,
      MDMA_Channel15_base: rawptr,
    
      USB1_OTG_HS_base: rawptr,
    
      // GPV
    },
  },

  /* base address of 'arena', will be used in the board code as a base then offset for stuff
   * like the SCB NVIC vector offset which is 32 bit, this way it can keep being 32 bit
   * but it will be an offset to this base.
   */
  arena_base: rawptr,

  /* NOTE: These are at the bottom because they don't need to be sent to the board */
  platform: Memory_PlatformSpecific,
  library: dynlib.Library,
  // One handler per page (256 pages max, unless we use GPV)
  handlers: [dynamic; 256]Handler_Proc,
  peripheral_contexts: [dynamic; 256]rawptr,
  base: rawptr,

  // NOTE: The arena does not support freeing of individual elements,
  //       it is purely for long-lived allocations
  arena: virtual.Arena,
  arena_allocator: mem.Allocator,
}
