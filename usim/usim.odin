#+vet style
#+vet unused
#+vet unused-variables
#+vet unused-imports
#+vet shadowing
package usim

import "core:dynlib"

/*
maximum usims at the same time, limited by a couple of factors
*/
MAX_USIMS :: 64

/*
Maximum elements in the event queue channel
*/
QUEUE_MAX_SIZE :: 256

/* As a bit of a warning: `Sim_add_event_watch` should be used very sparingly
 * since it makes the core simulator call the function ptr
 * instead of just add the event to the queue which is a much faster operation.
 */

/*
Provides a way to distinguish between usims to the core simulator
*/
Id :: distinct u64

Recv_Channel :: struct {
  impl: rawptr,
}

Event_Kind :: enum u32 {
  /* when the simulator is done, it will enqueue a Quit event */
  Quit = 0,
  GPIO_Modified = 1,

  Count = 2,
}

GPIO_Mod :: struct {
  gpio_char: u8,
  value: u32,
}

Event :: struct {
  kind: Event_Kind,
  board_name: cstring,
  as: struct #raw_union {
    gpio_mod: GPIO_Mod,
  },
}

/*
Procedure that will be called after starting up peripherals for a specific board.
Will be called once for every board dll which this usim is attached to.

Arguments:
 - `memory`: An already initialized ^peripherals.Memory, should not be written to, only read
 - `api`: The usim api, includes own functions but mostly to access [`Sim_subscribe_event`,`Sim_wait_event`,`Sim_add_event_watch`,`Sim_poll_event`]
 - `board_name`: The board name that was attached to the usim
 - `usim_mem`: A pointer to be filled in with the usim memory given to `Update_Proc` and `Deinit_Proc`, if it is the first call, `usim_mem^` will be nil (`*usim_mem`), else it will be a prevously returned value from Init_Proc
Returns:
 - If initialization succeeded

If this returns false, it won't be called again for any other boards
*/
Init_Proc :: #type proc "c"(memory: rawptr, api: ^API, board_name: cstring, usim_id: Id, usim_mem: ^rawptr) -> bool

/*
Procedure that will be called in a loop until `sim_is_done` is true.

Arguments:
 - `usim_mem`: rawptr (same as void*) to memory recieved from `Init_Proc`
Returns:
 - `end_early`: if end_early is true, `Update_Proc` will stop being called and `Deinit_Proc` will be called once
 */
Update_Proc :: #type proc "c"(usim_mem: rawptr) -> (end_early: bool)

/*
Procedure that will be called after the call to `Update_Proc` with `sim_is_done` == true or after the call to `Update_Proc` with `end_early` == true

Arguments:
 - `usim_mem`: rawptr (same as void*) to memory recieved from `Init_Proc`
*/
Deinit_Proc :: #type proc "c"(usim_mem: rawptr)

/* ----------------------------------------- */
/* WARNING: Only call the following procedures from the main thread of the usim */

/*
Procedure to call in `Init_Proc` to subscribe to an event kind

Arguments:
 - `id`: The usim id given by `Init_Proc`
 - `memory`: The memory given by `Init_Proc`
 - `kind`: the event kind to subscribe to
Returns:
 - if the operation succeeded or not
*/
Event_Subscribe_Proc :: #type proc "c"(memory: rawptr, kind: Event_Kind, id: Id) -> bool

/*
Procedure to call in `Update_Proc` to check for any new events in this usim's event queue

Arguments:
 - `event`: will be filled with the newest event if there was any
Returns:
 - if there was an event
*/
Poll_Event_Proc :: #type proc "c"(channel: Recv_Channel, event: ^Event) -> bool

/*
Procedure to call in `Update_Proc` to wait for the next event in this usim's event queue

Arguments:
 - `event`: will be filled in with the newest event if there was any
Returns:
 - if there was an error while trying to gather the newest event
*/
Wait_Event_Proc :: #type proc "c"(channel: Recv_Channel, event: ^Event) -> bool

/* callback type for `Add_Event_Watch_Proc` */
Event_Watch_Callback_Proc :: #type proc "c"(event: ^Event, ctx: rawptr)

/*
Procedure to call in `Init_Proc` to handle events of a specific kind in a callback.

WARNING: This callback will be called in a different thread and you won't be getting an event of that kind in `poll_event` or in `wait_event`. Also use this sparingly because it will interrupt the board's running thread.

Arguments:
 - `id`: The usim id given by `Init_Proc`
 - `memory`: The memory given by `Init_Proc`
 - `kind`: the event kind to be handled in the callback
 - `callback`: the callback that handles this event
 - `ctx`: the context to give to the callback
Returns:
 - if there was an error while trying to add the callback
*/
Add_Event_Watch_Proc :: #type proc "c"( \
  memory: rawptr, \
  kind: Event_Kind, \
  id: Id, \
  callback: Event_Watch_Callback_Proc, \
  ctx: rawptr, \
) -> bool

API :: struct {
  /* api from core sim to usim */

  event_subscribe: Event_Subscribe_Proc,
  poll_event: Poll_Event_Proc,
  wait_event: Wait_Event_Proc,
  add_event_watch: Add_Event_Watch_Proc,

  /*
  Recieve channel for usim, used internally in `poll_event` and `wait_event`
  will be chan.Chan(Event, .Recv)
  */
  channel: Recv_Channel,

  /* api from usim to core sim (taken from dll) */

  /* USim_init is expected to be found */
  _init:  Init_Proc,
  /* USim_update is expected to be found */
  _update: Update_Proc,
  /* USim_deinit is expected to be found */
  _deinit: Deinit_Proc,

  _library: dynlib.Library,
}
