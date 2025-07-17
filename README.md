# NbE in Idris2

This is just a toy repository to see how good Idris2 is at identity function
detection. Currently, it does not work for mutually defined functions. It also
cannot (obviously) see through functions like `map`.

Because it does not work for mutually defined functions, it cannot see that 
weakening of syntax using de-Brujin levels is actually the identity function.

The identity function detection phase runs before codegen so it works for all
backends. To inspect the javascript output, run: `pack --cg node build`.