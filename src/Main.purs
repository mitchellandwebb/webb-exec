module Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console (log)
import Module as Mod
import Options as Options
import Shell as Shell

{- Ensures that the given method in the module is run as the 'main' function on NodeJs. This will enable shell commands like 

`webb-exec Main build`
-}

main :: Effect Unit
main = launchAff_ do
  shell <- Shell.new
  Shell.buildProject shell
  options <- Options.new
  moduleName <- Options.moduleName options
  methodName <- Options.methodName options 
  mod <- Mod.new moduleName methodName
  Mod.ensureInputFile mod
  Mod.ensureOutputDir mod
  Mod.writeExecutable mod
  log "Wrote the Purescript executable"
  let execPath = Mod.outputFilePath mod
  Shell.execute shell execPath
  log "Executed the Purescript executable"
  
  

