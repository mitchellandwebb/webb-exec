module Shell where

import Prelude

import CommandLine as Command
import Effect.Class (class MonadEffect)
import Webb.Directory.Data.Absolute as Abs


{- The local representation of shell commands. -}

newtype Shell = SH Unit

new :: forall m. MonadEffect m => m Shell
new = do 
  pure $ SH unit
  
-- Build the spago project to ensure we have the latest version of the script.
buildProject :: forall m. MonadEffect m => Shell -> m Unit
buildProject _ = do
  c <- Command.newCommandLine
  Command.spagoBuild c
  
-- Execute the file at the given path as a node script. This path _should_
-- be the path to the newly-constructed output file.
execute :: forall m. MonadEffect m => Shell -> Abs.AbsolutePath -> m Unit
execute _ path = do
  c <- Command.newCommandLine
  let command = "node " <> Abs.unwrap path
  void $ Command.shell c command
