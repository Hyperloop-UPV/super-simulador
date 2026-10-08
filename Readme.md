## Hyperloop UPV firmware, (eventually) communications and (eventually) physical emulator

This is a simulator. Not an emulator (yet).

### Reasoning for the language we are going to use
We are choosing Odin because:
 - It is a systems programming language
 - It is simple, as opposed to C++ and Rust. The [overview](https://odin-lang.org/docs/overview) describes the whole language
 - It has a good [standard library](https://pkg.odin-lang.org/core), as opposed to C or C++ which don't include much
 - It has hashmaps builtin to the language (which we will probably use)
 - It has generics and reflection (which we will probably use)
 - It has inline assembly built in to the compiler (we might use this)
 - It has a large repository of easy to find [example code](https://pkg.odin-lang.org/examples)
 - It contains, in its standard library an [odin parser](https://pkg.odin-lang.org/core/odin/parser)
 - It contains, in its standard library a high-performance multi-architecture [encoder/decoder/printer](https://pkg.odin-lang.org/core/rexcode)
 - It contains, in its vendor library (provided by the compiler), a high performance real time [physics simulation library](https://pkg.odin-lang.org/vendor/box3d)
 - It is soon to get to [v1.0](https://www.youtube.com/watch?v=dLPAqXi9In0)

Personally:
 - It is a language I enjoy using
 - It is a language I have used many times before, as opposed to Rust, Haskell, Java, Prolog or Javascript
