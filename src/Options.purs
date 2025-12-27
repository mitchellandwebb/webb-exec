module Options where

import Prelude

import CommandLine as Command
import Data.Array as Array
import Effect.Class (class MonadEffect, liftEffect)
import Webb.Monad.Prelude (forceMaybe')


newtype Options = O Unit

new :: forall m. MonadEffect m => m Options
new = do pure $ O unit

moduleName :: forall m. MonadEffect m => Options -> m String
moduleName _ = liftEffect do 
  c <- Command.newCommandLine
  args <- Command.args c 
  let mfirst = Array.index args 0
  forceMaybe' "Expected a module name argument" mfirst
  
methodName :: forall m. MonadEffect m => Options -> m String
methodName _ = liftEffect do
  c <- Command.newCommandLine
  args <- Command.args c
  let msecond = Array.index args 1
  forceMaybe' "Expected a method name argument" msecond