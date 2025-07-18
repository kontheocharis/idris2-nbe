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
pragma. The value `-` indicates that the process crashed or ran out of memory.

### Scheme backend

| Context Length | n | Church Numeral (2^n) | Before Optimisation | After Optimisation |
| - | - | - | - | - |
| 0 | 5 | 32 | 3.11e-4s |  6e-6s |
| 100 | 5 | 32 | 0.218477s | 3e-5s |
| 0 | 6 | 64 | 0.068966s | 6e-6s |
| 100 | 6 | 64 | 0.293329s | 3.6e-5s |
| 0 | 7 | 128 | 0.662255s |  1.7e-5s |
| 100 | 7 | 128   | - | 7.3e-5s |
| 0 | 8 | 256     | - | 3.1e-5s |
| 100 | 8 | 256   | - | 9.7e-5s |
| 0 | 9 | 512     | - | 5.9e-5s |
| 100 | 9 | 512   | - | 1.56e-4s |
| 0 | 10 | 1024   | - | 1.2e-4s |
| 100 | 10 | 1024 | - | 2.76e-4s |
| 0 | 11 | 2048 | - | 2.34e-4s |
| 100 | 11 | 2048 | - | 5.15e-4s |
| 0 | 12 | 4096 | - | 5.61e-4s |
| 100 | 12 | 4096 | - | 7.82e-4s |
| 0 | 13 | 8192 | - | 7.23e-4s |
| 100 | 13 | 8192 | - | 0.001664s |
| 0 | 14 | 16384 | - | 0.001776s |
| 100 | 14 | 16384 | - | 0.003802s |
| 0 | 15 | 32768 | - | 0.004242s |
| 100 | 15 | 32768 | - | 0.007251s |

### JS backend

| Context Length | n | Church Numeral (2^n) | Before Optimisation | After Optimisation |
| - | - | - | - | - |
| 0   | 5  | 32    | 0.002205833s |  0.000814083s |
| 100 | 5  | 32    | 0.519502292s |  0.002432876s |
| 0   | 6  | 64    | 0.136811542s |  0.000303583s |
| 100 | 6  | 64    | - | 0.000750042s |
| 0   | 7  | 128   | - | 0.000725667s |
| 100 | 7  | 128   | - | 0.001047625s |
| 0   | 8  | 256   | - | 0.001259416s |
| 100 | 8  | 256   | - | 0.001260917s |
| 0   | 9  | 512   | - | 0.000706085s |
| 100 | 9  | 512   | - | 0.002575582s |
| 0   | 10 | 1024  | - | 0.001659291s |
| 100 | 10 | 1024  | - | 0.004588417s |
| 0   | 11 | 2048  | - | 0.002526666s |
| 100 | 11 | 2048  | - | 0.007705166s |
| 0   | 12 | 4096  | - | 0.004207s    |
| 100 | 12 | 4096  | - | 0.010378751s |
| 0   | 13 | 8192  | - | 0.007884501s |
| 100 | 13 | 8192  | - | 0.024083249s |
| 0   | 14 | 16384 | - | 0.013614709s |
| 100 | 14 | 16384 | - | 0.0507215s   |
| 0   | 15 | 32768 | - | 0.062286749s |
| 100 | 15 | 32768 | - | 0.113337417s |