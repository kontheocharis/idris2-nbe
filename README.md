# NbE in Idris2

This is just a toy repository to see how good Idris2 is at identity function
detection. Currently, it does not work for mutually defined functions. It also
cannot (obviously) see through functions like `map`.

Because it does not work for mutually defined functions, it cannot see that 
weakening of syntax using de Bruijn levels is actually the identity function.

The identity function detection phase runs before codegen so it works for all
backends. To inspect the javascript output, run: `pack --cg node build`.

## Timings:

Here I am timing in seconds, the Scheme backend. The tests
are to compute n^2 as a Church numeral by multiplication. The initial
context length also varies. 'Before optimisation' includes the weakening pass,
while 'after optimisation' transforms it away using `believe_me`.
The value `-` indicates that the run exceeded the 10 second timeout.
There is a column that measures the additional optimisation of `toIdx` to
primitive subtraction (in addition to weakening). 

### Scheme backend

| Context Length | n | Church Numeral (n^2) | Before Optimisation | After Optimisation | After Levels Optimisation |
| - | - | - | - | - | - |
| 10 | 20 | 400 | 3.59e-4s | 3e-5s | 2.7e-5s |
| 10 | 40 | 1600 | 0.003107s | 1.32e-4s | 1.18e-4s |
| 10 | 60 | 3600 | 0.010345s | 2.6e-4s | 2.15e-4s |
| 10 | 80 | 6400 | 0.026328s | 5.47e-4s | 3.89e-4s |
| 10 | 100 | 10000 | 0.050978s | 8.33e-4s | 7.01e-4s |
| 10 | 120 | 14400 | 0.074533s | 0.001239s | 0.001058s |
| 10 | 140 | 19600 | 0.119052s | 0.001743s | 0.001486s |
| 10 | 160 | 25600 | 0.159106s | 0.002058s | 0.001755s |
| 10 | 180 | 32400 | 0.211167s | 0.003343s | 0.003079s |
| 10 | 200 | 40000 | 0.333986s | 0.004376s | 0.004027s |
| 10 | 220 | 48400 | 0.354779s | 0.005175s | 0.004956s |
| 10 | 240 | 57600 | 0.416265s | 0.006749s | 0.006271s |
| 10 | 260 | 67600 | 0.574484s | 0.008181s | 0.007365s |
| 10 | 280 | 78400 | 0.626402s | 0.010073s | 0.009379s |
| 10 | 300 | 90000 | 0.790296s | 0.011161s | 0.00997s |
| 10 | 320 | 102400 | 0.939803s | 0.013542s | 0.013727s |
| 10 | 340 | 115600 | 1.028716s | 0.016012s | 0.014334s |
| 10 | 360 | 129600 | 1.208965s | 0.018726s | 0.016749s |
| 10 | 380 | 144400 | 1.421331s | 0.023816s | 0.019359s |
| 10 | 400 | 160000 | 1.647699s | 0.025368s | 0.021851s |
| 10 | 420 | 176400 | 1.688123s | 0.028005s | 0.026265s |
| 10 | 440 | 193600 | 2.079433s | 0.040026s | 0.038543s |
| 10 | 460 | 211600 | 2.231117s | 0.039625s | 0.036212s |
| 10 | 480 | 230400 | 2.425484s | 0.04039s | 0.042432s |
| 10 | 500 | 250000 | 2.655568s | 0.042777s | 0.043289s |

| Context Length | n | Church Numeral (n^2) | Before Optimisation | After Optimisation | After Levels Optimisation |
| - | - | - | - | - | - |
| 0 | 100 | 10000 | 0.002093s | 6.5e-4s | 6.7e-4s |
| 100 | 100 | 10000 | 0.710379s | 0.002021s | 7.36e-4s |
| 200 | 100 | 10000 | 1.526512s | 0.003006s | 6.8e-4s |
| 300 | 100 | 10000 | 2.86226s | 0.004145s | 7.17e-4s |
| 400 | 100 | 10000 | 3.617659s | 0.005263s | 7.14e-4s |
| 500 | 100 | 10000 | 4.890946s | 0.00645s | 6.98e-4s |
| 600 | 100 | 10000 | 6.989295s | 0.007725s | 7.13e-4s |
| 700 | 100 | 10000 | 7.969545s | 0.009581s | 7.84e-4s |
| 800 | 100 | 10000 | 8.527201s | 0.010257s | 7.26e-4s |
| 900 | 100 | 10000 | - | 0.010899s | 7.19e-4s |
| 1000 | 100 | 10000 | - | 0.011996s | 6.92e-4s |

## Running

Build with `pack build nbe`, then run `build/exec/nbe size` or
`build/exec/nbe context`.
