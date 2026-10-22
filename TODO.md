 - [x] Separate peripheral definitions:
       {`peripherals.odin`, `peripheral_win32.odin`, `peripheral_other.odin`} in a module to orquestrate
       {`core_cm7.odin`, `stm32h723xx.odin`} in a module for the MCU
       {`stub_peripheral.odin`, ...} in a module to handle all peripherals
 - [ ] `__DSB()` (data synchronization barrier) stops simulated board until a full iteration of write detection in simulator happens

## micro simulators (simulators that might log data, etc.)
 - [ ] Calling micro simulators from super simulator (core simulator). Load dll etc.
 - [ ] Event queue for micro simulators. Example: GPIOx pin value changes, SysTick interrupts, etc.
 - [ ] Subscribing to events to avoid sending unwanted events ?
 - [ ] Micro simulator example

## Peripherals
 - [ ] Finish SCB peripheral (only VTOR register is usable)
 - [ ] Finish RCC peripheral (nothing has been simulated yet, only the file has been added)
 - [ ] Finish NVIC peripheral (not really sure if NVIC needs to handle writes or needs memory)
 - [ ] Finish GPIO peripheral (only basic digitaloutput has been simulated)
