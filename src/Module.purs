module Module where

import Prelude

import Data.Newtype (class Newtype, unwrap)
import Effect.Aff (finally)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect)
import Webb.Directory.Action as Action
import Webb.Directory.Data.Absolute (AbsolutePath, (++))
import Webb.Directory.Data.Absolute as AbsPath
import Webb.File as File
import Webb.Monad.Prelude (throwString)


newtype Module = M 
  { moduleName :: String
  , methodName :: String
  }
  
derive instance Newtype Module _
  
new :: forall m. MonadEffect m => String -> String -> m Module
new mod meth = do
  pure $ M { moduleName: mod, methodName: meth }
  
moduleName :: Module -> String
moduleName = unwrap >>> _.moduleName

methodName :: Module -> String
methodName = unwrap >>> _.methodName

-- Find the module's file placement. This is in the 'output' folder after
-- compilation.
inputFilePath :: Module -> AbsolutePath
inputFilePath mod = let 
  cwd = AbsPath.cwd unit 
  in cwd ++ "output" ++ moduleName mod ++ "index.js"
  
outputDirPath :: Module -> AbsolutePath
outputDirPath mod = let
  cwd = AbsPath.cwd unit
  in cwd ++ ".webb-exec" ++ moduleName mod
  
-- A single file will be the executable for running the given code.
outputFilePath :: Module -> AbsolutePath
outputFilePath mod = let
  dir = outputDirPath mod
  in dir ++ (methodName mod <> ".mjs")

ensureInputFile :: forall m. MonadAff m => Module -> m Unit
ensureInputFile mod = liftAff do
  action <- Action.newAction
  exists <- Action.exists action (inputFilePath mod)
  unless exists do
    throwString $ "No file found at " <> show (inputFilePath mod)
    
-- Ensure the output directory exists properly, so we can write the file there.
ensureOutputDir :: forall m. MonadAff m => Module -> m Unit
ensureOutputDir mod = liftAff do
  action <- Action.newAction
  Action.ensureDir action (outputDirPath mod) 

-- Write the executable to the specified file location. The file will literally only
-- import the desired method name from the absolute file path, call the method name,
-- and then ... that's it.
writeExecutable :: forall m. MonadAff m => Module -> m Unit
writeExecutable mod = liftAff do
  let imports = 
        "import { " <> methodName mod <> " } from '" <> 
          show (inputFilePath mod) <> "'"
      call = methodName mod <> "()"
      code = imports <> "\n\n" <> call <> "\n"
  file <- File.newFile (outputFilePath mod)
  File.openTruncated file
  finally (File.close file) do
    File.writeString file code



