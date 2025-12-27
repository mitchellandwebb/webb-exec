module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)

{- Ensures that the given method in the module is run as the 'main' function on NodeJs. This will enable shell commands like 

`webb-exec Main build`
-}

main :: Effect Unit
main = do
  pure unit
  {-}
  shell <- Shell.new
  Shell.buildProject
  options <- Options.new
  moduleName <- Options.moduleName options
  methodName <- Options.methodName options 
  paths <- Paths.new
  mod <- Paths.findModule paths moduleName methodName
  dir <- Dir.new
  Dir.ensureOutputDir dir mod
  Mod.writeCallingFile mod dir
  outputFile <- Dir.outputFilePath dir
  Shell.execute shell outputFile
  -}
  
  

