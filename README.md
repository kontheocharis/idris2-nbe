# NbE in Idris2

This is just a toy repository to see how good Idris2 is at identity function
detection. Currently, it does not work for mutually defined functions. It also
cannot (obviously) see through functions like `map`.

Because it does not work for mutually defined functions, it cannot see that 
weakening of syntax using de-Brujin levels is actually the identity function.

The identity function detection phase runs before codegen so it works for all
backends. To inspect the javascript output, run: `pack --cg node build`.

## Timings:

Here I am timing in seconds, the Scheme backend and the JS backend. The tests
are to compute 2^n as a Church numeral by repeated multiplication. The initial
context length also varies. 'Before optimisation' includes the weakening pass,
while 'after optimisation' transforms it away using Idris2's `%transform`
pragma.

### Scheme backend

| Context Length | n | Church Numeral (2^n) | Before Optimisation | After Optimisation |
|---|---|---|---|---|
| 0 | 5 | 32 | 0.067s | 0.066s |
| 0 | 6 | 64 | 0.136s | 0.066s |
| 0 | 7 | 128 | 8.723s | 0.066s |
| 100 | 5 | 32 | 0.306s | 0.066s |
| 100 | 6 | 64 | 14.143s | 0.066s |
| 100 | 7 | 128 | 4:36.48 (killed) | 0.067s |

### JS backend

| Context Length | n | Church Numeral (2^n) | Before Optimization | After Optimization |
|---|---|---|---|---|
| 0 | 5 | 32 | 0.130s | 0.044s |
| 0 | 6 | 64 | 0.164s | 0.040s |
| 0 | 7 | 128 | OOM crash | 0.039s |
| 100 | 5 | 32 | 0.588s | 0.043s |
| 100 | 6 | 64 | OOM crash | 0.041s |
| 100 | 7 | 128 | OOM crash | 0.041s |
