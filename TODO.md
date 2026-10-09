 - [ ] Separate peripheral definitions:
       {`peripherals.odin`, `peripheral_win32.odin`, `peripheral_other.odin`} in a module to orquestrate
       {`core_cm7.odin`, `stm32h723xx.odin`} in a module for the MCU
       {`stub_peripheral.odin`, ...} in a module to handle all peripherals
 - [ ] `__DSB()` (data synchronization barrier) stops simulated board until a full iteration of write detection in simulator happens
 - [ ] Finish SCB peripheral (only VTOR register is usable)
