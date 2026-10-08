#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package peripherals

/* NOTE: GPV (Global Programmer View) is alone 284KiB :( */

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
HandlerArray: []proc(rawctx: rawptr) : {
  Stub_Handler, /* SCnSCB */
  Stub_Handler, /* SCB */
  Stub_Handler, /* SysTick */
  Stub_Handler, /* NVIC */
  Stub_Handler, /* ITM */
  Stub_Handler, /* DWT */
  Stub_Handler, /* TPI */
  Stub_Handler, /* CoreDebug */
  Stub_Handler, /* MPU */
  Stub_Handler, /* FPU */
  
  Stub_Handler, /* TIM2 */
  Stub_Handler, /* TIM3 */
  Stub_Handler, /* TIM4 */
  Stub_Handler, /* TIM5 */
  Stub_Handler, /* TIM6 */
  Stub_Handler, /* TIM7 */
  Stub_Handler, /* TIM13 */
  Stub_Handler, /* TIM14 */
  
  Stub_Handler, /* VREFBUF */
  Stub_Handler, /* RTC */
  Stub_Handler, /* WWDG1 */
  Stub_Handler, /* IWDG1 */
  
  Stub_Handler, /* SPI2 */
  Stub_Handler, /* SPI3 */
  Stub_Handler, /* SPI4 */
  Stub_Handler, /* SPI5 */
  Stub_Handler, /* SPI6 */
  
  Stub_Handler, /* USART2 */
  Stub_Handler, /* USART3 */
  Stub_Handler, /* USART6 */
  Stub_Handler, /* USART10 */
  Stub_Handler, /* UART7 */
  Stub_Handler, /* UART8 */
  Stub_Handler, /* UART9 */
  Stub_Handler, /* CRS */
  Stub_Handler, /* UART4 */
  Stub_Handler, /* UART5 */
  Stub_Handler, /* I2C1 */
  Stub_Handler, /* I2C2 */
  Stub_Handler, /* I2C3 */
  Stub_Handler, /* I2C4 */
  Stub_Handler, /* I2C5 */
  Stub_Handler, /* FDCAN1 */
  Stub_Handler, /* FDCAN2 */
  Stub_Handler, /* FDCAN_CCU */
  Stub_Handler, /* FDCAN3 */
  Stub_Handler, /* TIM23 */
  Stub_Handler, /* TIM24 */
  Stub_Handler, /* CEC */
  Stub_Handler, /* LPTIM1 */
  Stub_Handler, /* PWR */
  Stub_Handler, /* DAC1 */
  Stub_Handler, /* LPUART1 */
  Stub_Handler, /* SWPMI1 */
  Stub_Handler, /* LPTIM4 */
  Stub_Handler, /* LPTIM5 */

  Stub_Handler, /* SYSCFG */
  Stub_Handler, /* COMP12 */
  Stub_Handler, /* COMP1 */
  Stub_Handler, /* COMP2 */
  Stub_Handler, /* COMP12_COMMON */
  Stub_Handler, /* OPAMP */
  Stub_Handler, /* OPAMP1 */
  Stub_Handler, /* OPAMP2 */

  Stub_Handler, /* EXTI */
  Stub_Handler, /* EXTI_D1 */
  Stub_Handler, /* EXTI_D2 */
  Stub_Handler, /* TIM1 */
  Stub_Handler, /* SPI1 */
  Stub_Handler, /* TIM8 */
  Stub_Handler, /* USART1 */
  Stub_Handler, /* TIM12 */
  Stub_Handler, /* TIM15 */
  Stub_Handler, /* TIM16 */
  Stub_Handler, /* TIM17 */
  Stub_Handler, /* SAI1 */
  Stub_Handler, /* SAI1_Block_A */
  Stub_Handler, /* SAI1_Block_B */
  Stub_Handler, /* SAI4 */
  Stub_Handler, /* SAI4_Block_A */
  Stub_Handler, /* SAI4_Block_B */

  Stub_Handler, /* SPDIFRX */
  Stub_Handler, /* DFSDM1_Channel0 */
  Stub_Handler, /* DFSDM1_Channel1 */
  Stub_Handler, /* DFSDM1_Channel2 */
  Stub_Handler, /* DFSDM1_Channel3 */
  Stub_Handler, /* DFSDM1_Channel4 */
  Stub_Handler, /* DFSDM1_Channel5 */
  Stub_Handler, /* DFSDM1_Channel6 */
  Stub_Handler, /* DFSDM1_Channel7 */
  Stub_Handler, /* DFSDM1_Filter0 */
  Stub_Handler, /* DFSDM1_Filter1 */
  Stub_Handler, /* DFSDM1_Filter2 */
  Stub_Handler, /* DFSDM1_Filter3 */
  Stub_Handler, /* DMA2D */
  Stub_Handler, /* DCMI */
  Stub_Handler, /* PSSI */
  Stub_Handler, /* RCC */
  Stub_Handler, /* FLASH */
  Stub_Handler, /* CRC */

  Stub_Handler, /* GPIOA */
  Stub_Handler, /* GPIOB */
  Stub_Handler, /* GPIOC */
  Stub_Handler, /* GPIOD */
  Stub_Handler, /* GPIOE */
  Stub_Handler, /* GPIOF */
  Stub_Handler, /* GPIOG */
  Stub_Handler, /* GPIOH */
  Stub_Handler, /* GPIOJ */
  Stub_Handler, /* GPIOK */

  Stub_Handler, /* ADC1 */
  Stub_Handler, /* ADC2 */
  Stub_Handler, /* ADC3 */
  Stub_Handler, /* ADC3_COMMON */
  Stub_Handler, /* ADC12_COMMON */

  Stub_Handler, /* RNG */
  Stub_Handler, /* SDMMC2 */
  Stub_Handler, /* DLYB_SDMMC2 */
  Stub_Handler, /* FMAC */
  Stub_Handler, /* CORDIC */

  Stub_Handler, /* BDMA */
  Stub_Handler, /* BDMA_Channel0 */
  Stub_Handler, /* BDMA_Channel1 */
  Stub_Handler, /* BDMA_Channel2 */
  Stub_Handler, /* BDMA_Channel3 */
  Stub_Handler, /* BDMA_Channel4 */
  Stub_Handler, /* BDMA_Channel5 */
  Stub_Handler, /* BDMA_Channel6 */
  Stub_Handler, /* BDMA_Channel7 */

  Stub_Handler, /* RAMECC1 */
  Stub_Handler, /* RAMECC1_Monitor1 */
  Stub_Handler, /* RAMECC1_Monitor2 */
  Stub_Handler, /* RAMECC1_Monitor3 */
  Stub_Handler, /* RAMECC1_Monitor4 */
  Stub_Handler, /* RAMECC1_Monitor5 */
  Stub_Handler, /* RAMECC1_Monitor6 */

  Stub_Handler, /* RAMECC2 */
  Stub_Handler, /* RAMECC2_Monitor1 */
  Stub_Handler, /* RAMECC2_Monitor2 */
  Stub_Handler, /* RAMECC2_Monitor3 */

  Stub_Handler, /* RAMECC3 */
  Stub_Handler, /* RAMECC3_Monitor1 */
  Stub_Handler, /* RAMECC3_Monitor2 */

  Stub_Handler, /* DMAMUX2 */
  Stub_Handler, /* DMAMUX2_Channel0 */
  Stub_Handler, /* DMAMUX2_Channel1 */
  Stub_Handler, /* DMAMUX2_Channel2 */
  Stub_Handler, /* DMAMUX2_Channel3 */
  Stub_Handler, /* DMAMUX2_Channel4 */
  Stub_Handler, /* DMAMUX2_Channel5 */
  Stub_Handler, /* DMAMUX2_Channel6 */
  Stub_Handler, /* DMAMUX2_Channel7 */

  Stub_Handler, /* DMAMUX2_RequestGenerator0 */
  Stub_Handler, /* DMAMUX2_RequestGenerator1 */
  Stub_Handler, /* DMAMUX2_RequestGenerator2 */
  Stub_Handler, /* DMAMUX2_RequestGenerator3 */
  Stub_Handler, /* DMAMUX2_RequestGenerator4 */
  Stub_Handler, /* DMAMUX2_RequestGenerator5 */
  Stub_Handler, /* DMAMUX2_RequestGenerator6 */
  Stub_Handler, /* DMAMUX2_RequestGenerator7 */

  Stub_Handler, /* DMAMUX2_ChannelStatus */
  Stub_Handler, /* DMAMUX2_RequestGenStatus */

  Stub_Handler, /* DMA2 */
  Stub_Handler, /* DMA2_Stream0 */
  Stub_Handler, /* DMA2_Stream1 */
  Stub_Handler, /* DMA2_Stream2 */
  Stub_Handler, /* DMA2_Stream3 */
  Stub_Handler, /* DMA2_Stream4 */
  Stub_Handler, /* DMA2_Stream5 */
  Stub_Handler, /* DMA2_Stream6 */
  Stub_Handler, /* DMA2_Stream7 */

  Stub_Handler, /* DMA1 */
  Stub_Handler, /* DMA1_Stream0 */
  Stub_Handler, /* DMA1_Stream1 */
  Stub_Handler, /* DMA1_Stream2 */
  Stub_Handler, /* DMA1_Stream3 */
  Stub_Handler, /* DMA1_Stream4 */
  Stub_Handler, /* DMA1_Stream5 */
  Stub_Handler, /* DMA1_Stream6 */
  Stub_Handler, /* DMA1_Stream7 */

  Stub_Handler, /* DMAMUX1 */
  Stub_Handler, /* DMAMUX1_Channel0 */
  Stub_Handler, /* DMAMUX1_Channel1 */
  Stub_Handler, /* DMAMUX1_Channel2 */
  Stub_Handler, /* DMAMUX1_Channel3 */
  Stub_Handler, /* DMAMUX1_Channel4 */
  Stub_Handler, /* DMAMUX1_Channel5 */
  Stub_Handler, /* DMAMUX1_Channel6 */
  Stub_Handler, /* DMAMUX1_Channel7 */
  Stub_Handler, /* DMAMUX1_Channel8 */
  Stub_Handler, /* DMAMUX1_Channel9 */
  Stub_Handler, /* DMAMUX1_Channel10 */
  Stub_Handler, /* DMAMUX1_Channel11 */
  Stub_Handler, /* DMAMUX1_Channel12 */
  Stub_Handler, /* DMAMUX1_Channel13 */
  Stub_Handler, /* DMAMUX1_Channel14 */
  Stub_Handler, /* DMAMUX1_Channel15 */

  Stub_Handler, /* DMAMUX1_RequestGenerator0 */
  Stub_Handler, /* DMAMUX1_RequestGenerator1 */
  Stub_Handler, /* DMAMUX1_RequestGenerator2 */
  Stub_Handler, /* DMAMUX1_RequestGenerator3 */
  Stub_Handler, /* DMAMUX1_RequestGenerator4 */
  Stub_Handler, /* DMAMUX1_RequestGenerator5 */
  Stub_Handler, /* DMAMUX1_RequestGenerator6 */
  Stub_Handler, /* DMAMUX1_RequestGenerator7 */

  Stub_Handler, /* DMAMUX1_ChannelStatus */
  Stub_Handler, /* DMAMUX1_RequestGenStatus */

  Stub_Handler, /* FMC_Bank1_R */
  Stub_Handler, /* FMC_Bank1E_R */
  Stub_Handler, /* FMC_Bank2_R */
  Stub_Handler, /* FMC_Bank3_R */
  Stub_Handler, /* FMC_Bank5_6_R */

  Stub_Handler, /* OCTOSPI1 */
  Stub_Handler, /* DLYB_OCTOSPI1 */
  Stub_Handler, /* OCTOSPI2 */
  Stub_Handler, /* DLYB_OCTOSPI2 */
  Stub_Handler, /* OCTOSPIM */

  Stub_Handler, /* SDMMC1 */
  Stub_Handler, /* DLYB_SDMMC1 */

  Stub_Handler, /* DBGMCU */

  Stub_Handler, /* HSEM */
  Stub_Handler, /* HSEM_COMMON */

  Stub_Handler, /* LTDC */
  Stub_Handler, /* LTDC_Layer1 */
  Stub_Handler, /* LTDC_Layer2 */

  Stub_Handler, /* MDIOS */

  Stub_Handler, /* ETH */
  Stub_Handler, /* MDMA */
  Stub_Handler, /* MDMA_Channel0 */
  Stub_Handler, /* MDMA_Channel1 */
  Stub_Handler, /* MDMA_Channel2 */
  Stub_Handler, /* MDMA_Channel3 */
  Stub_Handler, /* MDMA_Channel4 */
  Stub_Handler, /* MDMA_Channel5 */
  Stub_Handler, /* MDMA_Channel6 */
  Stub_Handler, /* MDMA_Channel7 */
  Stub_Handler, /* MDMA_Channel8 */
  Stub_Handler, /* MDMA_Channel9 */
  Stub_Handler, /* MDMA_Channel10 */
  Stub_Handler, /* MDMA_Channel11 */
  Stub_Handler, /* MDMA_Channel12 */
  Stub_Handler, /* MDMA_Channel13 */
  Stub_Handler, /* MDMA_Channel14 */
  Stub_Handler, /* MDMA_Channel15 */

  Stub_Handler, /* USB1_OTG_HS */
}

Memory :: struct {
  ranges: [len(Types)]struct {
    bot: rawptr,
    top: rawptr,
  },
  platform: Memory_PlatformSpecific,
  // One handler per page (256 pages max, unless we use GPV)
  handlers: [dynamic; 256]proc(rawctx: rawptr),
  base: rawptr,

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
}
