module Main

import Data.Fin
import Data.Vect
import Data.SnocList
import Data.String
import Data.List1
import Data.Ref
import Debug.Trace
import System.Clock
import System.File.Process
import System.File.Virtual
import Prelude.Num

data Optim = Yes | No
           
%default total

-- A well-scoped NbE implementation
data Tm : Nat -> Type
data Val : Nat -> Type
data Nf : Nat -> Type
Env : Nat -> Nat -> Type

data Idx : Nat -> Type where
  IZ : Idx (S n)
  IS : Idx n -> Idx (S n)

data Lvl : Nat -> Type where
  LZ : Lvl (S n)
  LS : Lvl n -> Lvl (S n)
  
toNat : Idx n -> Nat
toNat IZ = Z
toNat (IS n) = S (toNat n)
  
-- identity detected by Idris
weakLvl : Lvl n -> Lvl (S n)
weakLvl LZ = LZ
weakLvl (LS n) = LS (weakLvl n)

shiftIdx : Idx n -> Idx (S n)
shiftIdx IZ = IZ
shiftIdx (IS n) = IS (shiftIdx n)
  
-- identity detected by Idris
last : (n : Nat) -> Lvl (S n)
last Z = LZ
last (S n) = LS (last n)

-- identity detected by Idris
first : (n : Nat) -> Idx (S n)
first Z = IZ
first (S n) = IS (first n)

toIdx : (n : Nat) -> Lvl n -> Idx n
toIdx (S n) LZ = first n
toIdx (S n) (LS i) = shiftIdx (toIdx n i)

pred : Idx (S n) -> Idx (S n)
pred IZ = IZ
pred (IS i) = shiftIdx i

subtr : (n : Nat) -> Lvl (S n) -> Idx (S n)
subtr n' LZ = first n'
subtr n' (LS k') = pred (subtr n' (assert_smaller (LS k') (weakLvl k')))
    
toIdx' : (n : Nat) -> Lvl n -> Idx n
toIdx' (S n') k = subtr n' k

data Tm where
  Lam : Tm (S n) -> Tm n
  App : Tm n -> Tm n -> Tm n
  Var : Idx n -> Tm n
  
Show (Idx n) where
  show i = show (toNat i)
  
Show (Tm n)

covering
showSingle : Tm n -> String
showSingle (Var i) = show i
showSingle v = "(\{show v})"
  
covering
Show (Tm n) where
  show (Lam t) = "λ \{show t}"
  show (App v@(App _ _) u) = "\{show v} \{showSingle u}"
  show (App v u) = "\{showSingle v} \{showSingle u}"
  show (Var v) = show v

data Val where
  VLam : Env n m -> Tm (S m) -> Val n
  VApp : Lvl n -> SnocList (Val n) -> Val n
  
data Nf where
  NLam : Nf (S n) -> Nf n
  NApp : Idx n -> SnocList (Nf n) -> Nf n
  
emb : Nf n -> Tm n
emb (NLam t) = Lam (emb t)
emb (NApp i [<]) = Var i
emb (NApp i (xs :< x)) = App (emb (NApp i xs)) (emb x)
  
Env n m = Vect m (Val n)

VVar : Lvl n -> Val n
VVar i = VApp i [<]

-- All the NbE functions
covering eval : Env n m -> Tm m -> Val n
covering reify : (n : Nat) -> Val n -> Nf n
covering nf : (n : Nat) -> Tm n -> Nf n

-- Optimised variants
covering reify' : (n : Nat) -> Val n -> Nf n
covering nf' : (n : Nat) -> Tm n -> Nf n

-- Identity detection does not work for mutually-recursive
-- functions, and we cannot abstract over it.

-- Not detected by idris:
mutual 
  weak : Val n -> Val (S n)
  weak (VLam env t) = VLam (weakEnv env) t
  weak (VApp l n) = VApp (weakLvl l) (weakSnoc n)

  weakSnoc : SnocList (Val n) -> SnocList (Val (S n))
  weakSnoc [<] = [<]
  weakSnoc (xs :< x) = weakSnoc xs :< weak x

  weakEnv : Env m n -> Env (S m) n
  weakEnv [] = []
  weakEnv (x :: xs) = weak x :: weakEnv xs

%inline
weak' : {auto optim : Optim} -> Val n -> Val (S n)
weak' i = believe_me i

%inline
weakSnoc' : {auto optim : Optim} -> SnocList (Val n) -> SnocList (Val (S n))
weakSnoc' i = believe_me i

%inline
weakEnv' : {auto optim : Optim} -> Env m n -> Env (S m) n
weakEnv' i = believe_me i

id : (n : Nat) -> Env n n
id Z = []
id (S n) = VVar (last n) :: weakEnv (id n)

id' : (n : Nat) -> Env n n
id' Z = []
id' (S n) = VVar (last n) :: weakEnv' (id' n)

eval (v :: env) (Var IZ) = v
eval (v :: env) (Var (IS i)) = eval env (Var i)
eval env (App f x) with (eval env f) | (eval env x)
  _ | VLam env' t | v = eval (v :: env') t
  _ | VApp i vs | v = VApp i (vs :< v)
eval env (Lam f) = VLam env f

reify n (VLam env t) = NLam (reify (S n) (eval (VVar (last n) :: weakEnv env) t))
reify n (VApp i xs) = NApp (toIdx n i) (map (reify n) xs)

-- Optimised (inlined)
reify' n (VLam env t) = NLam (reify' (S n) (eval (VVar (last n) :: weakEnv' env) t))
reify' n (VApp i xs) = NApp (toIdx n i) (map (reify' n) xs)

nf n t = reify n (eval (id n) t)

-- Optimised (inlined)
nf' n t = reify' n (eval (id n) t)

-- Examples

zero : Tm n
zero = Lam (Lam (Var IZ))

one : Tm n
one = Lam (Lam (App (Var (IS IZ)) (Var IZ)))

two : Tm n  
two = Lam (Lam (App (Var (IS IZ)) (App (Var (IS IZ)) (Var IZ))))

add : Tm n
add = Lam (Lam (Lam (Lam (
  App (App (Var (IS (IS (IS IZ)))) (Var (IS IZ)))
      (App (App (Var (IS (IS IZ))) (Var (IS IZ))) (Var IZ))
  ))))

-- Yes we can do much better with Church numbers but I want a slow example
mult : Tm n
mult = Lam (Lam (
    App (App (Var IZ) (App add (Var (IS IZ)))) zero
  ))

expo : Tm n -> Nat -> Tm n
expo t 0 = one
expo t (S n) = App (App mult t) (expo t n)

church : Nat -> Tm n
church Z = zero
church (S k) = App (App add one) (church k)

square : Nat -> Tm n
square n = App (App mult (church n)) (church n)

clockToSecs : Clock type -> Double
clockToSecs c = fromInteger (seconds c) + fromInteger (nanoseconds c) / 1000000000.0

-- Returns a time in s
covering %inline
runWithOptim : (ctxSize : Nat) -> (inputSize : Nat) -> (optim : Optim) -> IO Double
runWithOptim ctxSize inputSize Yes = do
  start <- clockToSecs <$> clockTime Process
  res <- pure $ emb (nf' ctxSize (square inputSize))
  end <- clockToSecs <$> clockTime Process
  pure $ end - start
runWithOptim ctxSize inputSize No = do
  start <- clockToSecs <$> clockTime Process
  res <- pure $ emb (nf ctxSize (square inputSize))
  end <- clockToSecs <$> clockTime Process
  pure $ end - start

median : List Double -> Double
median xs =
  let sorted = sort xs
      mid = divNatNZ (Prelude.List.length sorted) 2 %search
  in case List.drop mid sorted of
       (v :: _) => v
       [] => 0.0

samples : Nat
samples = 10

timeout : Double
timeout = 10.0

covering
collectSamples : (ctxSize : Nat) -> (inputSize : Nat) -> (optim : Optim)
              -> (remaining : Nat) -> (acc : List Double) -> IO (List Double)
collectSamples _ _ _ Z acc = pure acc
collectSamples ctxSize inputSize optim (S k) acc = do
  t <- runWithOptim ctxSize inputSize optim
  if t > timeout
    then pure acc -- stop early, don't include the timed-out run
    else collectSamples ctxSize inputSize optim k (t :: acc)

covering
runSampled : (ctxSize : Nat) -> (inputSize : Nat) -> (optim : Optim) -> IO (Maybe Double)
runSampled ctxSize inputSize optim = do
  -- Warmup run (also acts as timeout check)
  warmup <- runWithOptim ctxSize inputSize optim
  if warmup > timeout
    then pure Nothing
    else do
      times <- collectSamples ctxSize inputSize optim samples []
      case times of
        [] => pure Nothing
        _  => pure $ Just (median times)

covering
showResult : Maybe Double -> String
showResult Nothing = "-"
showResult (Just t) = "\{show t}s"

covering
printLn : String -> IO ()
printLn s = do
  putStrLn s
  fflush stdout

covering
bench : (optim : Optim) -> (ctxSize : Nat) -> (inputSize : Nat) -> IO ()
bench optim ctxSize inputSize = do
  m <- runSampled ctxSize inputSize optim
  printLn $ "| \{
    show inputSize} | \{
    show $ inputSize * inputSize} | \{
    showResult m} |"

covering
measure : IO ()
measure = do
  let ctx = 10

  printLn $ "| n | Church Numeral (n^2) | Before Optimisation (median of \{show samples}) |"
  printLn $ "| - | - | - |"

  for_ [20, 40 .. 500] $ \n => do
    bench No ctx n

  printLn $ "\n| n | Church Numeral (n^2) | After Optimisation (median of \{show samples}) |"
  printLn $ "| - | - | - |"

  for_ [20, 40 .. 500] $ \n => do
    bench Yes ctx n

covering
main : IO ()
main = measure
